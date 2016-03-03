FROM gk0909c/ubuntu
MAINTAINER gk0909c@gmail.com

ENV DEBIAN_FRONTEND=noninteractive \
    PG_VERSION=9.5 \
    PG_USER=postgres

ENV PG_DATA=/var/lib/postgresql/${PG_VERSION}/data \
    PG_BIN=/usr/lib/postgresql/${PG_VERSION}/bin

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main ${PG_VERSION}" > /etc/apt/sources.list.d/postgresql.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && \
    apt-get update && apt-get install -y postgresql-${PG_VERSION}

COPY cmd.sh /opt/cmd.sh
RUN chmod 755 /opt/cmd.sh

EXPOSE 5432
CMD ["/opt/cmd.sh"]

