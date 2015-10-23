#Upgrading from SPLogger 1.4 to 1.4.1

##SPLogger and SPLoggerUT dedicated DB

Connect to SPLogger database as DB Owner

1) Run script [splogger-update](./splogger-update.sql) 
1) If use of Unit Test system, run script [sploggerUT-update](./sploggerUT-update.sql) 

##SPLogger and SPLoggerUT client DB

Connect to user databases database as DB Owner

1) Run script [splogger-userdb-update](./users-dbs/splogger-userdb-update.sql) 
1) If use of Unit Test system, run script [sploggerUT-userdb-update](./users-dbs/sploggerUT-userdb-update.sql) 


