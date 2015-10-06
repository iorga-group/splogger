Upgrading from SPLogger 1.0 to 1.1
   1) Check current release of SPLogger by looking at the last "LogHistory x.x" synonym in SPLogger database.
   2) If no synonym or the last one is "LogHistory 1.0" then
      1) Being connected to the SPlogger database, run "10-splogger-upgrade-1.0_1.1-sploggerDB.sql"
      2) For each databases using SPLogger, run "20-splogger-upgrade-1.0_1.1-userDBs.sql" to create new synonyms   