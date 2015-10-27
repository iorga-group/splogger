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

	Contact Email : fprevost@iorga.com

	=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

	Warning ! Before running this script you SHOULD verify that you have select the SPLogger database
*/

USE [SPLogger]
GO

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.AddDebugTrace')
          and type in ('P','PC'))
   drop procedure splogger.AddDebugTrace
go

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

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.FinishTGroup')
          and type in ('P','PC'))
   drop procedure splogger.FinishTGroup
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.StartTGroup')
          and type in ('P','PC'))
   drop procedure splogger.StartTGroup
go


CREATE PROCEDURE splogger.AddDebugTrace @pLogger XML OUT, 
                                    @pDescription NVARCHAR(255) = NULL, 
                                    @pTextValue NVARCHAR(MAX) = NULL, 
                                    @pDateTimeValue DATETIME = NULL, 
                                    @pXmlValue XML = NULL
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
        
        Add to the logger an "debug-trace".
        
        @param   pLogger   XML OUT      Targeted logger. Be carefull this parameter SHOULD be passed as OUTPUT                                   
        @param   pDescription   NVARCHAR(255)  (default NULL)   description of the logged value(s)
        @param   pTextValue   NVARCHAR(MAX)  (default NULL)   implicitely convertible to NVARCHAR value to log
        @param   pDateTimeValue   DATETIME  (default NULL)   DateTime value to log
        @param   pXmlValue   XML  (default NULL)   Xml value to log
        @param   pUTKey   NVARCHAR(128)  (default=null = none)  Identifiant of the unit test trace (use to check Asserts).
        
     */
    SET NOCOUNT ON
    
    -- Null Logger protection (1.4.2)
    IF @pLogger IS NULL
        RETURN
    
    -- Checks if the Logger log level is above DEBUG.
    IF splogger.GetRunningLevel(@pLogger) > 0        
        RETURN
   
    -- Event's initialisation.    
    DECLARE @newEvent XML = '<debug-trace></debug-trace>'       
    DECLARE @valueData XML
   
    BEGIN TRY 
        IF @pDescription IS NOT NULL
        BEGIN
            SET @valueData = '<description><![CDATA['+@pDescription+']]></description>'       
            SET @newEvent.modify('insert (sql:variable("@valueData")) into (/*[1])')
        END
    
        IF @pTextValue IS NOT NULL
        BEGIN
            SET @valueData = '<value><![CDATA['+@pTextValue+']]></value>'       
            SET @newEvent.modify('insert (sql:variable("@valueData")) into (/*[1])')
        END
    
        IF @pDateTimeValue IS NOT NULL
        BEGIN
            SET @valueData = '<value><![CDATA['+CONVERT( NVARCHAR(25), @pDateTimeValue, 126 )+']]></value>'       
            SET @newEvent.modify('insert (sql:variable("@valueData")) into (/*[1])')
        END
    
        IF @pXmlValue IS NOT NULL
        BEGIN
            SET @valueData = '<value></value>'               
            SET @valueData.modify('insert (sql:variable("@pXmlValue")) into (/*[1])')
            SET @newEvent.modify('insert (sql:variable("@valueData")) into (/*[1])')
        END
                           
        -- Adding the new Event to the logger
        EXEC splogger.AddEvent @pLogger OUT, @newEvent        
	END TRY
	BEGIN CATCH
        -- Inserting an ERROR Event instead of SQLTrace Event
        SET @newEvent = splogger.NewEvent_For_SqlError(3)
            EXEC splogger.AddParam @newEvent OUT, '@pDescription', @pDescription
            EXEC splogger.AddParam @newEvent OUT, '@pTextValue', @pTextValue
            EXEC splogger.AddParam_DateTime @newEvent OUT, '@pDateTimeValue', @pDateTimeValue
            EXEC splogger.AddParam_XmlAsCDATA @newEvent OUT, '@pXmlValue', @pXmlValue
	    EXEC splogger.AddEvent @pLogger OUT, @newEvent        
	END CATCH	
END
go


CREATE PROCEDURE splogger.AddSQLSelectTrace @pLogger XML OUT, @pSelectSQL NVARCHAR(MAX), @pDescription NVARCHAR(255) = NULL, @pLogLevel INT = 0, @pDbName NVARCHAR(128) = NULL                                    
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
        @param   pDescription   NVARCHAR(255)  (default NULL)   description of the logged value(s)
        @param   pLogLevel   INT (default 0=DEBUG)   The log level of the Event
        @param   pDbName   NVARCHAR(128)  (default=NULL)   current database name (hosting the SP). If NULL, that means SPLogger is dedicated to the current database (created inside) 
        
        Important:
           * The level of the event to create is compared to the current log level of the targeted Logger to prevent an unecessary query execution.
           * Only SELECT statement are allowed
     */
    SET NOCOUNT ON
    
    -- Null Logger protection (1.4.2)
    IF @pLogger IS NULL
        RETURN
    
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
        SET @newEvent = '<sql-trace></sql-trace>'
    ELSE 
        SET @newEvent = '<sql-trace level="'+CONVERT(VARCHAR, @pLogLevel)+'"></sql-trace>'
    
    -- Adding comment if any
    DECLARE @valueData XML
    
    IF @pDescription IS NOT NULL
    BEGIN
        SET @valueData = '<description><![CDATA['+@pDescription+']]></description>'       
        SET @newEvent.modify('insert (sql:variable("@valueData")) into (/*[1])')
    END
    
    -- Adding the Query
    SET @valueData = '<query><![CDATA['+@pSelectSQL+']]></query>'       
    SET @newEvent.modify('insert (sql:variable("@valueData")) into (/*[1])')
    
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
        DECLARE @xmlRowCount XML
        
        -- Wrap the SQL query to convert result set to XML
    	DECLARE @sSQL NVARCHAR(max) = N'SET @xmlRS = ('+@pSelectSQL+' FOR XML RAW(''row''), ROOT(''resultset''))'    	
        
        -- Execute the wrapped SQL query 
        EXEC sp_executesql @sSQL, N'@xmlRS XML OUTPUT', @xmlRS OUTPUT 
        
        -- Adding the rowcount to the Event
        DECLARE @rowCount INT = @xmlRS.value('count(/resultset/row)', 'int')
        IF @rowCount IS NOT NULL 
        BEGIN
            SEt @xmlRowCount = '<rowcount>'+CONVERT(VARCHAR,@rowCount)+'</rowcount>'       
            SET @newEvent.modify('insert (sql:variable("@xmlRowCount")) into (/*[1])')
               
            -- Adding the result set to the Event
            SET @newEvent.modify('insert (sql:variable("@xmlRS")) into (/*[1])')
        END
        ELSE
        BEGIN
            -- No row / empty resultset
            SET @xmlRowCount = '<rowcount>0</rowcount><resultset />'       
            SET @newEvent.modify('insert (sql:variable("@xmlRowCount")) into (/*[1])')
        END            
        
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


CREATE PROCEDURE splogger.AddSQLTableTrace @pLogger XML OUT, @pSQLTableName NVARCHAR(128), @pDescription NVARCHAR(255) = NULL, @pLogLevel INT = 0, @pRowLimit INT = 0, @pDbName NVARCHAR(128) = NULL
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
        @param   pDescription   NVARCHAR(255)  (default NULL)   description of the logged value(s)
        @param   pLogLevel   INT (default 0=DEBUG)   The log level of the Event
        @param   pRowLimit   INT (default to 0=ALL rows)   Limit number of rows to return (TOP(x))
        @param   pDbName   NVARCHAR(128)  (default=NULL)   current database name (hosting the SP). If NULL, that means SPLogger is dedicated to the current database (created inside)         
        
        @see   AddSQLSelectTrace
     */
    SET NOCOUNT ON
    
    -- Null Logger protection (1.4.2)
    IF @pLogger IS NULL
        RETURN
    
    -- Building the SELECT query for the asked table.
    -- If needed a TOP clause is inserted in the query
    DECLARE @sSQL NVARCHAR(max)
    IF @pRowLimit = 0
        SET @sSQL = 'SELECT * FROM '+@pSQLTableName
    ELSE
        SET @sSQL = 'SELECT TOP('+CONVERT(VARCHAR, @pRowLimit)+') * FROM '+@pSQLTableName
    
    -- Dynamic query execution and initialisation of the @pNewEvent Event
    EXEC splogger.AddSQLSelectTrace @pLogger OUT, @sSQL, @pDescription, @pLogLevel, @pDbName
END
go


CREATE PROCEDURE splogger.FinishTGroup @pLogger XML OUT
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
        
        End the closest active timed-group. 
        
        @param   pLogger   XML OUT   Targeted logger. Be carefull this parameter SHOULD be passed as OUTPUT
        
        @see StartTGroup
     */
    SET NOCOUNT ON
    
    -- Null Logger protection (1.4.2)
    IF @pLogger IS NULL
        RETURN
    
    DECLARE @startTime DATETIME = @pLogger.value('(//timed-group[@container])[last()]/@start_ts', 'DATETIME') 
    DECLARE @endDate DATETIME = GETUTCDATE()
    
    -- Computing task duration
    DECLARE @durationAsText VARCHAR(20)
    DECLARE @duration INT = DATEDIFF( MINUTE, @startTime, @endDate)
    
    IF @duration > 29 
    BEGIN
        -- If more than 29 minutes, using minutes as duration's unit
        SET @durationAsText = CONVERT(VARCHAR(12), @duration)+'mins'
    END
    ELSE
    BEGIN
		SET @duration = DATEDIFF( SECOND, @startTime, @endDate)
        IF @duration > 29	
		BEGIN
            -- If more than 29 seconds, using seconds as duration's unit
			SET @durationAsText = CONVERT(VARCHAR(12), @duration)+'s'
		END
		ELSE
		BEGIN
            -- Else using microseconds as duration's unit
			SET @duration = DATEDIFF( ms, @startTime, @endDate)
			SET @durationAsText = CONVERT(VARCHAR(12), @duration)+'ms'
		END
    END
    
    -- Writing duration attribute  
    SET @pLogger.modify('replace value of (((//timed-group[@container])[last()])[1]/@duration) with (sql:variable("@durationAsText"))')      
       
    -- Removing control attributes
    SET @pLogger.modify('delete ((//timed-group[@container])[last()])[1]/@start_ts')         
    SET @pLogger.modify('delete ((//timed-group[@container])[last()])[1]/@container')         
END
go


CREATE PROCEDURE splogger.StartTGroup @pLogger XML OUT, @pDescription NVARCHAR(255)
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
        
        Start a new timed-group for the Logger.
        Timed-group can be nested inside another timed-group. 
        The nesting of timed-group is automatically done when calling this procedure when a not finish one exists.
        
        @param   pLogger   XML OUT   Targeted logger. Be carefull this parameter SHOULD be passed as OUTPUT
        @param   pDescription   NVARCHAR(255)   Timed-group description
     */
    SET NOCOUNT ON
    
    -- Null Logger protection (1.4.2)
    IF @pLogger IS NULL
        RETURN
    
    -- Adding the new timed-group to the Logger
    DECLARE @tGroup XML = '<timed-group start_ts="'+CONVERT( VARCHAR(25), GETUTCDATE(), 126 )+'" duration="?" container="1"><description><![CDATA['+@pDescription+']]></description></timed-group>'        
    EXEC splogger.AddEvent @pLogger OUT, @tGroup         
    
    -- Auto-detection system for timed-group support
    IF @pLogger.exist('(/*[1]/@container)') = 0
    BEGIN
        SET @pLogger.modify('insert attribute container {"on"} into (/*[1])')
    END
END
go

-- drop old tagging synonym
DROP synonym [splogger].[LogHistory 1.4.1]
GO

-- Creating tagging synonym
CREATE synonym [splogger].[LogHistory 1.4.2] for [splogger].[LogHistory]
GO
