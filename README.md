A logging and tracing system for SQL stored procedures that survive to a rollback event.  
![SPLogger](./splogger-banner.png "SPLogger")
# What is SPLogger ?

First of all, SPLogger is a set of procedures and functions used to logging Microsoft SQLServer stored procedures execution...  
...that survive to a **rollback** event (if well used).  

But it's also a set of procedures and functions that allows tracing/debugging T-SQL batches.  

And SPLogger:
- Works on SQLServer 2008 and above
- Don't need CLR (Amazon RDS compatible)
- 100% T-SQL code
- Logs are stored in a dedicated database table shareable across DATABASES
 

## How does it work ?
To be able to survive to a rollback event raised during SQL execution, SPLogger use **XML datastructure** to store runtime events/trace logged by the developer.  

During execution of the SQL batch/SP, each *Log Event* is added, on the flow, as a **XML Node** to the *Logger Object* which can be save into the dedicated table *splogger.LogHistory* at the end of the surrounding call and after the **COMMIT** or the **ROLLBACK**.    

The *Logger Object* (XML variable) is passed as **OUTPUT** (byRef) parameter to the SPLogger stored procedures, so it can be filled by sub-routines. 

The logs are saved inside an XML column in a dedicated table. That allows XSLT transformations for User friendly presentation. 

## Which are the SPLogger's functionalities
 - Support 4 levels of logging (DEBUG, INFO, WARNING and ERROR)
 - Support `<sub-log>` which are automatically created when call a SP with its own Logger from an other SP with a Logger
 - The maximum level reached during the execution is memorized as a `<log>` tag attribute. It reflects automatically the maximum level reached by any of its `<sub-log>`
 - Timestamp (UTC) every `<event>`
 - Simplify the creation of an `<event>` filled with all informations available from the last raised Exception (**should** be used inside a CATCH Statement)
 - Compute and memorize as a `<log>` tag attribute the total duration of the execution (from `StartLog`to `FinishLog`)
 - `log`and `event`support `params` tag used to memorize variable/parameters runtime values
 - Support XML variable logging as XML sub-nodes or as CDATA text
 - Support `nb` attribute on WARNING or ERROR `event` to count how many times **in a row** the same `event` has been logged (perhaps due to a `event` logged in a loop). This is used to limit the `log`size.
 - `sql-trace` allows to memorize inside the `log`the result set of a **SELECT** statement or the content of a table
 - `sql-trace` supports the temporary tables created inside the SP. It's awesome to debug from SSMS :-)
 - An *expected maximum duration* can be set for a logger, and a warning will be automatically inserted by `FinishLog` if the running duration is over the expected one
 - Support logging for multiple databases in the same **SPLogger database** throught the use of synonyms to the SPLogger objects

***
# How to install SPLogger ?

SPLogger can be installed in its own database or in an user database without any risk cause it uses its own SQL schema `splogger`.  

If you decide to use a **dedicated database** (SPLogger for example), you have to create it before continuing and you shoud be sure to select this database before running the following SQL scripts.  

If you decide to use an **existing database** (in case of RDS for example), you shoud be sure to select this database before running the following SQL scripts.  

So, installing SPLogger is as simple as execute the following SQL scripts in order :
  - Create `splogger` SQL schema [10-splogger-create-schema](./src/10-splogger-create-schema.sql)
  - Create all SPLogger SQL objects [20-splogger-create-dbobjects](./src/20-splogger-create-dbobjects.sql)
  - if needed, Create SPLogger Role and set grants to this role [30-splogger-role-grants](./src/30-splogger-role-grants.sql)
  - if needed (use of a dedicated DB for SPLogger), Create synonyms to SPLogger objects to a user defined schema on its own DB [40-splogger-create-synonyms](./src/40-splogger-create-synonyms.sql)
  - Run the SPLogger's tests [99-splogger-tests](./src/99-splogger-tests.sql)

# How to use SPLogger ?

Using SPLogger is simple...  

Just create a logger (@see [toplevel-stored-procedure-template](./templates/toplevel-stored-procedure-template.sql)) and pass it as OUTPUT parameter to all called sub-procedures. It will be filled with `Events` and finally saved in the database.

It's possible to prepare stored procedure to be used as a main or a sub-routine by creating inside it a logger attached to the parent logger (@see [stored-procedure-template](./templates/stored-procedure-template.sql))

Finally, you can pass the logger as output parameter to any stored procedure and use it to log events without creating a sub-logger (good for small procedure).

To get an running sample, you can have a look at [SPLogger Tests](./src/99-splogger-tests.sql)

# SPLogger Database model

![SPLogger Database Model](./splogger-physical-data-model.png "SPLogger Database Model")

