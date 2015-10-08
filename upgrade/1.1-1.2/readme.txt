Upgrading from SPLogger 1.1 to 1.2
   1) Check current release of SPLogger by looking at the last "LogHistory x.x" synonym in SPLogger database.
   2) If the last one is "LogHistory 1.1" then
      1) Being connected to the SPlogger database, run "10-splogger-upgrade-1.1_1.2-sploggerDB.sql"
      2) For each databases using SPLogger, run "20-splogger-upgrade-1.1_1.2-userDBs.sql" to create new proxies   