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

	UPGRADING FROM SPLogger 1.2 to 1.3

	=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

*/

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.AddDebugTrace')
          and type in ('P','PC'))
   drop procedure splogger.AddDebugTrace
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.AddSQLSelectTrace')
          and type in ('P','PC'))
   drop procedure splogger.AddSQLSelectTrace
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.FinishLog')
          and type in ('P','PC'))
   drop procedure splogger.FinishLog
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.StartLog')
          and type in ('IF', 'FN', 'TF'))
   drop function splogger.StartLog
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
    
    IF splogger.GetRunningLevel(@pLogger) > 0
    BEGIN
        -- Checks if the Logger log level is above DEBUG.
        RETURN
    END
   
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


CREATE PROCEDURE splogger.FinishLog @pLogger XML, @pParentLogger XML = NULL OUT, @pLoggerLevelMinToSave INT = -1
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
        
        Logger or SubLogger finalisation.
        Task duration (between StartLog and FinishLog) is computed and added as attribute to the log/sub-log element.
        
        @param   pLogger   XML   Logger to finalise
        @param   pParentLogger   XML OUT   (default to NULL)  Parent logger if any. Be carefull this parameter SHOULD be passed as OUTPUT
        @param   pLoggerLevelMinToSave   INT   (default -1=No level minimum)   Minimum log level to be reached by the logger to be save if top-level logger.
        
        @return   ...   
        
           - if logger is disabled (log level = -1), the return value is 0 (zero)
        
           - If it's a main logger, 
              if level_max don't reach the log level minimal, the return value is 0 (zero)
              else if SP finished without ERROR (level_max < 3), the return value is the Id of the inserted LogHistory row. 
              else if SP finished in ERROR (level_max = 3), the return value is "- Id" (negative value) of the inserted LogHistory row. 
        
              It can be use in caller app to load task log information.
        
           - If it's a sub-logger, the return value is the "level_max" reached. This return value SHOULD be return by SP and checked in caller SP
        
        @see   StartLog
     */
    SET NOCOUNT ON
    DECLARE @logEvent XML
    DECLARE @levelMax INT = 0
    
    BEGIN TRY          
        -- Checks for maximum expected duration  
        DECLARE @WarnExpectedMaxDuration BIT = 0
        DECLARE @startTime DATETIME = @pLogger.value('(/*[1]/@start_time)', 'DATETIME') 
        DECLARE @endDate DATETIME = GETUTCDATE()
        DECLARE @expectedMaxDuration INT = @pLogger.value('(/*[1]/@expected_max_duration)', 'INT') 
        DECLARE @duration INT = DATEDIFF( MS, @startTime, @endDate)
        
        IF @expectedMaxDuration > 0 AND @duration > @expectedMaxDuration
        BEGIN
            -- Duration above the expected maximum duration for this log (task)
            -- Adding an INFO event
            SET @WarnExpectedMaxDuration = 1
    		SET @logEvent = splogger.NewEvent_Warning ( 53001, 'This logger/task has run longer than the maximumu expected duration (in milliseconds).')
                EXEC splogger.AddParam @logEvent OUT, '@expected duration', @expectedMaxDuration
    			EXEC splogger.AddParam @logEvent OUT, '@run duration', @duration
    		EXEC splogger.AddEvent @pLogger OUT, @logEvent
        END
        ELSE 
        BEGIN
            SET @pLogger.modify('delete /*[1]/@expected_max_duration')
        END
        
        -- Checks if logging is disabled (interactive call - SSMS)
        SET @levelMax = @pLogger.value('(/*[1]/@level_max)', 'INT')                    
        DECLARE @logLevelFilter INT = splogger.GetRunningLevel(@pLogger)         
        IF @logLevelFilter = -1
        BEGIN
            IF @pParentLogger IS NULL
                RETURN 0
            ELSE
                RETURN @levelMax
        END
               
        -- Computing task duration
        DECLARE @durationAsText VARCHAR(20)
        SET @duration = DATEDIFF( MINUTE, @startTime, @endDate)
        
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
            
        SET @pLogger.modify('replace value of (/*[1]/@duration) with (sql:variable("@durationAsText"))')   
        
        -- Auto-detection system for timed-group support - Remove for ended log
        IF @pLogger.exist('(/*[1]/@container)') = 1
        BEGIN
            SET @pLogger.modify('delete /*[1]/@container')
        END             
        
        -- Log finalisation
        IF @pParentLogger IS NULL
        BEGIN
            -- This is a main log (Top level one)            
            -- Check if the reached log level is below the logger log level defined
            IF @levelMax < @pLoggerLevelMinToSave
                RETURN 0
        
            -- Top level logger finalisation
            -- Database insertion of a new LogHistory record            
    		DECLARE @tranCount INT = @@TRANCOUNT
    
            IF @tranCount > 0
            BEGIN
                -- Checks if any transaction is in progress. 
                -- If this is the cas, warns that the log record will be lost if the current transaction will be rollbacked.
                SET @logEvent = splogger.NewEvent_Warning( -100, 'Be carefull. this log detail has been inserted in LogHistory inside an active transaction. This log COULD BE LOST in case of a ROLLBACK in the coming transaction activity. If possible, move the call to "FinishLog" outside of the transaction.')
                    EXEC splogger.AddParam @logEvent OUT, '@@TRANCOUNT', @tranCount 
                EXEC splogger.AddEvent @pLogger OUT, @logEvent                                             
            END
    
            -- Database insertion
            DECLARE @taskKey NVARCHAR(128) = @pLogger.value('(/*[1]/@task_key)', 'NVARCHAR(128)')         
        
            INSERT INTO splogger.LogHistory( DbName, TaskKey, StartedAt, EndedAt, DurationInSeconds, EventsMaxLevel, LogDetail, WarnExpectedMaxDuration )
                VALUES ( DB_NAME(), @taskKey, @startTime, @endDate, DATEDIFF( SECOND, @startTime, @endDate), @levelMax, @pLogger, @WarnExpectedMaxDuration )
                            
            IF @levelMax > 2
                RETURN -1 * @@IDENTITY        
            ELSE
                RETURN @@IDENTITY        
        END
        ELSE
        BEGIN
            -- Check if Unit Test is NOT in progress
            IF splogger.GetRunningLevel(@pParentLogger) <> -8   
            BEGIN
                -- Sub-logger finalisation.
                -- This logger is added to its parent one.            
                DECLARE @containerLevelMax INT = @pParentLogger.value('(/*[1]/@level_max)', 'INT') 
                DECLARE @containerLevel INT = splogger.GetRunningLevel(@pParentLogger) 
        
                -- Its parent's logger maximum reached level will be updated if needed
                IF @levelMax > @containerLevelMax
                    SET @pParentLogger.modify('replace value of (/*[1]/@level_max) with (sql:variable("@levelMax"))')
        
                -- Checks if the current logger log level is the same as its parent one
                IF @logLevelFilter = @containerLevel
                    SET @pLogger.modify('delete /*[1]/@level')
            
                -- In case of a sub-logger, no need for sub-start time
                SET @pLogger.modify('delete /*[1]/@start_time')    
            
                -- In case of a sub-logger, 
                -- if the log level reached by it, is above the minimal log level to save,
                -- just the sub-logger element is inserted. All its details are removed.
                IF @levelMax < @pLoggerLevelMinToSave
                    SET @pLogger.modify('delete /*[1]/event[*]')
                        
                -- Auto-detection system for timed-group support - Remove for ended log
                IF @pParentLogger.exist('(/*[1]/@container)') = 1
                BEGIN
                    -- Adding the new Event inside the timed-group
        		    SET @pParentLogger.modify('insert (sql:variable("@pLogger")) into (((//*[@container])[last()])[1])')        
                END
                ELSE
                BEGIN
                    -- Sub-logger adding to parent logger
        		    SET @pParentLogger.modify('insert (sql:variable("@pLogger")) into (/*[1])')
                END
            END
            ELSE
            BEGIN
                --
                -- Unit Test in progress
                -- Adding to Unit Test
                --        
                SET @pLogger.modify('delete /*[1]/@level')
                
                -- Creating a special UT Value representing the level_max reached by the tested SP
                DECLARE @xmlUTValue XML = '<run-value key="level_max" datatype="int" isnull="0" checked="0"><description><![CDATA[sploggerUT:Exit level of the tested SP]]></description><value>'+CONVERT(NVARCHAR(2), @levelMax)+'</value></run-value>'          
                SET @pParentLogger.modify('insert (sql:variable("@xmlUTValue")) into (/unit-test[1]/run-values[1])')  
                
                -- Adding log to UT
       		    SET @pParentLogger.modify('insert (sql:variable("@pLogger")) into (/unit-test[1])')                                    
            END 
            
            -- Returns the maximum log level reached by this sub-logger.
            -- This value can be used by the caller SP to do something...
            RETURN @levelMax     
        END           
    END TRY
    BEGIN CATCH
        IF @pParentLogger IS NOT NULL AND splogger.GetRunningLevel(@pParentLogger) = -8   
        BEGIN
            -- Unit Test is in progress
            SET @logEvent = splogger.NewEvent_For_SqlError( 3 )	
		    EXEC splogger.AddEvent @pParentLogger OUT, @logEvent	            
            -- Adding to Unit Test
            SET @pParentLogger.modify('insert (sql:variable("@pLogger")) into (/unit-test[1])')        
        END
        -- Ignore, but warn in interactive mode (SSMS)
        DECLARE @ts VARCHAR(20) = CONVERT( VARCHAR(20), GETUTCDATE(), 126 )
        DECLARE @errNum INT = ERROR_NUMBER()
        DECLARE @errMsg NVARCHAR(2048) = ERROR_MESSAGE()
        RAISERROR ( N'%s - splogger.FinishLog - Error #%d : %s', 10, 0, @ts, @errNum, @errMsg ) WITH NOWAIT        
    END CATCH        
END
go



CREATE FUNCTION splogger.StartLog (@pParentLogger XML, @pTaskKey NVARCHAR(128), @pLogLevel INT, @pTitle NVARCHAR(255))
RETURNS XML
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
        
        Initialize a new logger with its own log level if no @pParentLogger is defined.
        Initialize a sub-logger using the parent logger's log level if a @pParentLogger is passed.
        
        @param   pParentLogger   XML   Parent logger in which the new logger will be inserted (xml child node) and used to define le runtime logging level to used.
        @param   pTaskKey   NVARCHAR(128)   Identifiant of the logged task used to filter LogHistory entries or sub tasks.
        @param   pLogLevel   INT   When no parent logger set, log level to use. A value of "-1" disable logging.
        @param   pTitle   NVARCHAR(255)   Logged task description.
        
        @see   FinishLog
     */
    DECLARE @log XML
    
    IF @pParentLogger IS NULL
    BEGIN
        -- Creating a main logger
        SET @log = '<log task_key="'+@pTaskKey+'" start_time="'+CONVERT( VARCHAR(25), GETUTCDATE(), 126 )+'" duration="-1" level="'+CONVERT(VARCHAR(2), @pLogLevel)+'" expected_max_duration="-1" level_max="-1"><description><![CDATA['+@pTitle+']]></description></log>'
    END
    ELSE
    BEGIN         
        DECLARE @parentLevel INT = splogger.GetRunningLevel(@pParentLogger)      
        -- If a Unit Test is in progress  
        IF @parentLevel = -8
        BEGIN                        
            IF @pParentLogger.exist('(/unit-test[1]/@utkey)') = 1   
            BEGIN        
                -- If parent is the unit-test then create logger for Unit Testing (top-call) 
                SET @log = '<log task_key="'+@pTaskKey+'" start_time="'+CONVERT( VARCHAR(25), GETUTCDATE(), 126 )+'" duration="-1" level="-8" expected_max_duration="-1" level_max="-1"><description><![CDATA['+@pTitle+']]></description></log>'
            END
            ELSE
            BEGIN
                -- If it's a sub call from Unit tested SP, we switch a minima to INFO cause we don't want any <trace>
                IF @pLogLevel < 1
                BEGIN
                    SET @pLogLevel = 1
                END
                SET @log = '<sub-log task_key="'+@pTaskKey+'" start_time="'+CONVERT( VARCHAR(25), GETUTCDATE(), 126 )+'" duration="-1" level="'+CONVERT(VARCHAR(2), @pLogLevel)+'" expected_max_duration="-1" level_max="-1"><description><![CDATA['+@pTitle+']]></description></sub-log>'
            END
        END
        ELSE
        BEGIN
            -- Else create a sub-logger  
            SET @log = '<sub-log task_key="'+@pTaskKey+'" start_time="'+CONVERT( VARCHAR(25), GETUTCDATE(), 126 )+'" duration="-1" level="'+CONVERT(NVARCHAR(2), @parentLevel)+'" expected_max_duration="-1" level_max="-1"><description><![CDATA['+@pTitle+']]></description></sub-log>'
        END
    END
    
    RETURN @log
END
go

-- Creating tagging synonym
CREATE synonym [splogger].[LogHistory 1.3] for [splogger].[LogHistory]
GO

