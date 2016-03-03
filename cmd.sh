#!/bin/bash

exec_as_postgres() {
  sudo -HEu ${PG_USER} "$@"
}

# init database
if [[ ! -d ${PG_DATA} ]]; then
  exec_as_postgres ${PG_BIN}/initdb --pgdata=${PG_DATA} 
  exec_as_postgres echo "host all  all    0.0.0.0/0  md5" >> ${PG_DATA}/pg_hba.conf && \
  exec_as_postgres echo "listen_addresses='*'" >> ${PG_DATA}/postgresql.conf
fi

exec_as_postgres ${PG_BIN}/pg_ctl -U ${PG_USER} -D ${PG_DATA} -w start

# CREATE USERS
if [ -v DB_USERS ]; then
  for db_user in $(awk -F',' '{for (i = 1 ; i <= NF ; i++) print $i}' <<< "${DB_USERS}"); do
    userpass=($(echo $db_user | sed -e 's/:/ /g'))

    if [[ -z $(psql -U ${PG_USER} -Atc "SELECT 1 FROM pg_catalog.pg_user WHERE usename = '${userpass[0]}'";) ]]; then
      psql -U ${PG_USER} -c "CREATE ROLE \"${userpass[0]}\" with LOGIN CREATEDB PASSWORD '${userpass[1]}';"
    fi
  done
fi

# CREATE DATABASES
if [ -v DB_NAMES ]; then
  for database in $(awk -F',' '{for (i = 1 ; i <= NF ; i++) print $i}' <<< "${DB_NAMES}"); do
    db_user=($(echo $database | sed -e 's/:/ /g'))

    if [[ -z $(psql -U ${PG_USER} -Atc "SELECT 1 FROM pg_catalog.pg_database WHERE datname = '${db_user[0]}'";) ]]; then
      psql -U ${PG_USER} -c "CREATE DATABASE \"${db_user[0]}\";"
      psql -U ${PG_USER} -c "REVOKE ALL ON DATABASE \"${db_user[0]}\" FROM public;"
      psql -U ${PG_USER} -c "GRANT ALL PRIVILEGES ON DATABASE \"${db_user[0]}\" to \"${db_user[1]}\";"
    fi
  done
fi

exec_as_postgres ${PG_BIN}/pg_ctl -D ${PG_DATA} -w stop

# exec
exec_as_postgres ${PG_BIN}/postgres -D ${PG_DATA} 

