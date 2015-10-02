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

***
# How to install SPLogger ?

**COMING SOON...**

# How to use SPLogger ?

**COMING SOON...**

