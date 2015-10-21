#Upgrading from SPLogger 1.3 to 1.4

##SPLogger and SPLoggerUT dedicated DB

As the security model changed to be better and flexible {refs #13}, the easiest way to upgrade is to do a clean install of it .

Use note

Only splogger.AddSqlSelectTrace and splogger.AddSqlTableTrace stored procedure present a change in their footprint. 

A "@pDescription NVARCHAR(255) = NULL" {refs #11} parameter has been added at the 3rd position.

##SPLogger and SPLoggerUT client DB

TODO

