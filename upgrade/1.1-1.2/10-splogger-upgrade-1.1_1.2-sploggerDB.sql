/**
	SPLogger - A logging and tracing system for MSSQL stored procedures that survive to a rollback event
    Copyright (C) 2015  Iorga

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

	Contact Email : splogger@iorga.com
 
	=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

	UPGRADING FROM SPLogger 1.1 to 1.2

	=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

*/

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.AddSQLTableTrace')
          and type in ('P','PC'))
   drop procedure splogger.AddSQLTableTrace
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.AddSQLSelectTrace')
          and type in ('P','PC'))
   drop procedure splogger.AddSQLSelectTrace
go


CREATE PROCEDURE splogger.AddSQLSelectTrace @pLogger XML OUT, @pSelectSQL NVARCHAR(MAX), @pLogLevel INT = 0, @pDbName NVARCHAR(128) = NULL                                    
AS
BEGIN
    /**
        SPLogger - A logging and tracing system for MSSQL stored procedures that survive to a rollback event
        Copyright (C) 2015  Iorga
        
        This program is free software: you can redistribute it and/or modify
        it under the terms of the GNU Lesser General Public License as published by
        the Free Software Foundation, either version 3 of the License, or
        (at your option) any later version.
        
        This program is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.
        
        You should have received a copy of the GNU General Public License
        along with this program.  If not, see <http://www.gnu.org/licenses/>.
        
        Contact Email : splogger@iorga.com
        
        =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        
        Add to the logger an "sql-trace" with the result of the execution of an SQL SELECT statement.
        Before running the query, {{database}} markers will be replace by @pDatabase.
        
        
        @param   pLogger   XML OUT      Targeted logger. Be carefull this parameter SHOULD be passed as OUTPUT                                   
        @param   pSelectSQL   NVARCHAR(MAX)   The SELECT statement to log
        @param   pLogLevel   INT (default 0=DEBUG)   The log level of the Event
        @param   pDbName   NVARCHAR(128)  (default=NULL)   current database name (hosting the SP). If NULL, that means SPLogger is dedicated to the current database (created inside) 
        
        Important:
           * The level of the event to create is compared to the current log level of the targeted Logger to prevent an unecessary query execution.
           * Only SELECT statement are allowed
     */
    SET NOCOUNT ON
    
    IF splogger.GetRunningLevel(@pLogger) > @pLogLevel
    BEGIN
        -- Checks if the Logger log level is above the asked log level for the SQL trace.
        -- If the logger log level is above then return without executing the SQL query :-)
        RETURN
    END
   
    -- Replacing {{database}} tokens by running database
    -- If no @pDbName passed as parameter, that means SPLogger is dedicated to the current database (created inside)    
    IF @pDbName IS NULL
        SET @pDbName = DB_NAME()
            
    SET @pSelectSQL = REPLACE( @pSelectSQL, '{{database}}', @pDbName)
   
    -- Event's initialisation.
    -- The query expression is saved as an <![CDATA[]]> query element's value
    DECLARE @newEvent XML
    IF @pLogLevel = 0
        SET @newEvent = '<sql-trace><query><![CDATA['+@pSelectSQL+']]></query></sql-trace>'
    ELSE 
        SET @newEvent = '<sql-trace level="'+CONVERT(VARCHAR, @pLogLevel)+'"><query><![CDATA['+@pSelectSQL+']]></query></sql-trace>'
    
    -- Checks validity of input parameters
    IF UPPER(SUBSTRING(@pSelectSQL, 1, 7)) <> 'SELECT '
    BEGIN
        -- Inserting an ERROR Event instead of SQLTrace Event
        SET @newEvent = splogger.NewEvent_Error ( -55000, N'splogger.NewSQLSelectTraceEvent - The SQL query SHOULD BE a SELECT query.')
            EXEC splogger.AddParam @newEvent OUT, 'query', @pSelectSQL
	    EXEC splogger.AddEvent @pLogger OUT, @newEvent        
        RETURN
    END
       
    BEGIN TRY        
        DECLARE @xmlRS XML  
        -- Wrap the SQL query to convert result set to XML
    	DECLARE @sSQL NVARCHAR(max) = N'SET @xmlRS = ('+@pSelectSQL+' FOR XML RAW(''row''), ROOT(''resultset''))'    	
        
        -- Execute the wrapped SQL query 
        EXEC sp_executesql @sSQL, N'@xmlRS XML OUTPUT', @xmlRS OUTPUT 
        
        -- Adding the rowcount to the Event
        DECLARE @rowCount INT = @xmlRS.value('count(/resultset/row)', 'int')  
        DECLARE @xmlRowCount XML = '<rowcount>'+CONVERT(VARCHAR,@rowCount)+'</rowcount>'       
        SET @newEvent.modify('insert (sql:variable("@xmlRowCount")) into (/*[1])')
               
        -- Adding the result set to the Event
        SET @newEvent.modify('insert (sql:variable("@xmlRS")) into (/*[1])')
        
        -- Adding the new Event to the logger
        EXEC splogger.AddEvent @pLogger OUT, @newEvent        
	END TRY
	BEGIN CATCH
        -- Inserting an ERROR Event instead of SQLTrace Event
        SET @newEvent = splogger.NewEvent_For_SqlError(3)
            EXEC splogger.AddParam @newEvent OUT, 'query', @pSelectSQL
	    EXEC splogger.AddEvent @pLogger OUT, @newEvent        
	END CATCH	
END
go

CREATE PROCEDURE splogger.AddSQLTableTrace @pLogger XML OUT, @pSQLTableName NVARCHAR(128), @pLogLevel INT = 0, @pRowLimit INT = 0, @pDbName NVARCHAR(128) = NULL
AS
BEGIN
    /**
        SPLogger - A logging and tracing system for MSSQL stored procedures that survive to a rollback event
        Copyright (C) 2015  Iorga
        
        This program is free software: you can redistribute it and/or modify
        it under the terms of the GNU Lesser General Public License as published by
        the Free Software Foundation, either version 3 of the License, or
        (at your option) any later version.
        
        This program is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.
        
        You should have received a copy of the GNU General Public License
        along with this program.  If not, see <http://www.gnu.org/licenses/>.
        
        Contact Email : splogger@iorga.com
        
        =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        
        Add to the logger an sqltrace with the the rows (limited count if needed) form the specified table.
        The specified table can be a temporary one (nice for tracing complex stored procedure execution)
        
        @param   pLogger   XML OUT      Targeted logger. Be carefull this parameter SHOULD be passed as OUTPUT                                   
        @param   pSQLTableName   NVARCHAR(128)    
        @param   pLogLevel   INT (default 0=DEBUG)   The log level of the Event
        @param   pRowLimit   INT (default to 0=ALL rows)   Limit number of rows to return (TOP(x))
        @param   pDbName   NVARCHAR(128)  (default=NULL)   current database name (hosting the SP). If NULL, that means SPLogger is dedicated to the current database (created inside)         
        
        @see   AddSQLSelectTrace
     */
    SET NOCOUNT ON
    
    -- Building the SELECT query for the asked table.
    -- If needed a TOP clause is inserted in the query
    DECLARE @sSQL NVARCHAR(max)
    IF @pRowLimit = 0
        SET @sSQL = 'SELECT * FROM '+@pSQLTableName
    ELSE
        SET @sSQL = 'SELECT TOP('+CONVERT(VARCHAR, @pRowLimit)+') * FROM '+@pSQLTableName
    
    -- Dynamic query execution and initialisation of the @pNewEvent Event
    EXEC splogger.AddSQLSelectTrace @pLogger OUT, @sSQL, @pLogLevel, @pDbName
END
go

-- Creating tagging synonym
CREATE synonym [splogger].[LogHistory 1.2] for [splogger].[LogHistory]
GO