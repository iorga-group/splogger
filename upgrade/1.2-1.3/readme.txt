Upgrading from SPLogger 1.2 to 1.3
   1) Check current release of SPLogger by looking at the last "LogHistory x.x" synonym in SPLogger database.
   2) If the last one is "LogHistory 1.2" then
      1) Being connected to the SPlogger database, run "10-splogger-upgrade-1.2_1.3-sploggerDB.sql"
	  
If you wish to install support for SP Unit Testing, you can install it by running in order the SQL scripts present in ../../src/sploggerUT
      