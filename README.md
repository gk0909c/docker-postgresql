# docker postgresql #
postgresql server.  

## usage ##
To run,
```bash
docker run -d -p 15432:5432 --name postgresql gk0909c/postgresql
```

If you want to create user and database,
bellow means create user1 and user2, user1 can connect db1, user2 can connect db2.
```bash
docker run -d -e DB_USERS=user1:pass1,user2:pass2 -e DB_NAMES=db1:user1,db2:user2 -p 15432:5432 --name postgresql gk0909c/postgresql
```

