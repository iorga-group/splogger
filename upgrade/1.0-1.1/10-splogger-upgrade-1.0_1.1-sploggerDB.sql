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

	UPGRADING FROM SPLogger 1.0 to 1.1

	=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

	Warning ! Before running this script you SHOULD remplace all the Template parameters :
  		
		<SPLOGGER_DB, NVARCHAR, SPLogger> : SPLogger dedicated database
		<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole> : SPLogger dedicated role

*/

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.FinishLog')
          and type in ('P','PC'))
   drop procedure splogger.FinishLog
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.AddEvent')
          and type in ('P','PC'))
   drop procedure splogger.AddEvent
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.StartLog')
          and type in ('IF', 'FN', 'TF'))
   drop function splogger.StartLog
go


CREATE PROCEDURE splogger.AddEvent @pLogger XML OUT, @pEvent XML, @pRaiseIfNoLog BIT = 0
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
        
        Add the specified Event to the target Logger if the Event log level is above or equal to the Logger log level.
        The maximum level reached by the Logger is automatically updated if needed
        When adding WARNING /ERROR Event, all consecutive Events with the same "code" increment the occurence counter instead of insert new Event element.
        
        @param   pLogger   XML OUT   Targeted logger. Be carefull this parameter SHOULD be passed as OUTPUT
        @param   pEvent   XML   Event to add to logger if level condition is reached
        @param   pRaiseIfNoLog   BIT (default to 0)   Should it raises SQL error if not logger specified (NULL) and Event log level above INFO
     */
    SET NOCOUNT ON 
    DECLARE @levelEvent int = 0
     
    IF @pLogger IS NULL 
    BEGIN
        -- NULL/No logger is specified
        -- Check if NULL event too or if no raise error if no logger specified
        IF @pEvent IS NULL OR @pRaiseIfNoLog = 0
            RETURN
               
        -- An event is defined. Checks if the event log level is below "WARNING" level. 
        -- If it's below then ignores it
        IF @pEvent.exist('(/*[1]/@level)') = 1
            SET @levelEvent = @pEvent.value('(/*[1]/@level)', 'INT')
            
        IF @levelEvent < 2
            RETURN
                 
        -- If it's an WARNING or ERROR leveled event then raises an SQL error.
        -- The code and text associated to the Event is used as SQL error code and text.
        DECLARE @EWCode int = @pEvent.value('(/*[1]/@code)', 'INT')                                
        DECLARE @EWText NVARCHAR(4000) = @pEvent.value('(/*[1]/text[1])', 'NVARCHAR')         
        RAISERROR ( N'%d : %s', @EWText, 16, 1, @EWCode, @EWText );          
    END
    ELSE
    BEGIN 
        -- A logger is specified
        BEGIN TRY   
            -- Checks if logger is desactivated (log level = "-1")         
            DECLARE @logLevelFilter int = splogger.GetRunningLevel(@pLogger)
            IF @logLevelFilter = -1
                RETURN 
        
            -- Getting Event log level
            IF @pEvent.exist('(/*[1]/@level)') = 1
                SET @levelEvent = @pEvent.value('(/*[1]/@level)', 'INT')         
        
            -- Updating if needed the maximum level reached by the current logger if needed
            DECLARE @logLevelMax int = @pLogger.value('(/*[1]/@level_max)', 'INT')                 
            IF @levelEvent > @logLevelMax
                SET @pLogger.modify('replace value of (/*[1]/@level_max) with (sql:variable("@levelEvent"))')
            
            -- If the Event's log level is below the logger log level then ignore it
            IF @levelEvent < @logLevelFilter
                RETURN 
                            
            -- Event's code and loop counter management
            DECLARE @code int = @pEvent.value('(/*[1]/@code)', 'INT')       
            IF @code <> 0 
            BEGIN                                    
                IF @pLogger.exist('(/*[1]/*[last()]/@code)') = 1
                BEGIN
                    DECLARE @lastCode int = @pLogger.value('(/*[1]/*[last()]/@code)', 'INT')
            
                    -- Checks if this Event has the same code value as the previous Event ?
                    IF @lastCode = @code 
                    BEGIN
                        -- If yes, then just increment the loop counter (nb attribute)
                        SET @pLogger.modify('replace value of (/*[1]/*[last()]/@nb) with (/*[1]/*[last()]/@nb + 1)')                    
                        RETURN
                    END    
                END
            END
       
            -- Auto-detection system for timed-group support - Remove for ended log
            IF @pLogger.exist('(/*[1]/@container)') = 1
            BEGIN
                -- Adding the new Event inside the timed-group
    		    SET @pLogger.modify('insert (sql:variable("@pEvent")) into (((//*[@container])[last()])[1])')        
            END
            ELSE
            BEGIN
                -- Adding the new Event at the end of the Logger children
    		    SET @pLogger.modify('insert (sql:variable("@pEvent")) into (/*[1])')        
            END
    	END TRY
    	BEGIN CATCH
    		-- Ignore, but warn in interactive mode (SSMS)
            DECLARE @ts VARCHAR(20) = CONVERT( VARCHAR(20), GETUTCDATE(), 116 )
            DECLARE @errNum INT = ERROR_NUMBER()
            DECLARE @errMsg NVARCHAR(2048) = ERROR_MESSAGE()
            DECLARE @xmlAsStr NVARCHAR(2048) = CONVERT( NVARCHAR(2048), @pEvent )
            RAISERROR ( N'%s - splogger.AddEvent - Error #%d : %s\n%s', 10, 0, @ts, @errNum, @errMsg, @xmlAsStr ) WITH NOWAIT
    	END CATCH
    END
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
        @pParentLogger XML OUT (default to NULL)  Parent logger if any. Be carefull this parameter SHOULD be passed as OUTPUT
        @pLoggerLevelMinToSave INT (default -1=No level minimum)   Minimum log level to be reached by the logger to be save if top-level logger.
        
        @see   StartLog
     */
    SET NOCOUNT ON
    
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
    		DECLARE @logEvent XML = splogger.NewEvent_Warning ( 53001, 'This logger/task has run longer than the maximumu expected duration (in milliseconds).')
                EXEC splogger.AddParam @logEvent OUT, '@expected duration', @expectedMaxDuration
    			EXEC splogger.AddParam @logEvent OUT, '@run duration', @duration
    		EXEC splogger.AddEvent @pLogger OUT, @logEvent
        END
        ELSE 
        BEGIN
            SET @pLogger.modify('delete /*[1]/@expected_max_duration')
        END
        
        -- Checks if logging is disabled (interactive call - SSMS)
        DECLARE @levelMax INT = @pLogger.value('(/*[1]/@level_max)', 'INT')                    
        DECLARE @logLevelFilter INT = splogger.GetRunningLevel(@pLogger)         
        IF @logLevelFilter = -1
            RETURN @levelMax
               
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
                DECLARE @tranWarnEvent XML = splogger.NewEvent_Warning( -100, 'Be carefull. this log detail has been inserted in LogHistory inside an active transaction. This log COULD BE LOST in case of a ROLLBACK in the coming transaction activity. If possible, move the call to "FinishLog" outside of the transaction.')
                EXEC splogger.AddParam @tranWarnEvent OUT, '@@TRANCOUNT', @tranCount 
                EXEC splogger.AddEvent @pLogger OUT, @tranWarnEvent                                             
            END
        
            -- Database insertion
            DECLARE @taskKey NVARCHAR(128) = @pLogger.value('(/*[1]/@task_key)', 'NVARCHAR(128)')         
            
            INSERT INTO splogger.LogHistory( DbName, TaskKey, StartedAt, EndedAt, DurationInSeconds, EventsMaxLevel, LogDetail, WarnExpectedMaxDuration )
                VALUES ( DB_NAME(), @taskKey, @startTime, @endDate, DATEDIFF( SECOND, @startTime, @endDate), @levelMax, @pLogger, @WarnExpectedMaxDuration )
            
            RETURN @@IDENTITY        
        END
        ELSE
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
            
            -- Returns the maximum log level reached by this sub-logger.
            -- This value can be used by the caller SP to do something...
            RETURN @levelMax
        END
    END TRY
    BEGIN CATCH
        -- Ignore, but warn in interactive mode (SSMS)
        DECLARE @ts VARCHAR(20) = CONVERT( VARCHAR(20), GETUTCDATE(), 116 )
        DECLARE @errNum INT = ERROR_NUMBER()
        DECLARE @errMsg NVARCHAR(2048) = ERROR_MESSAGE()
        RAISERROR ( N'%s - splogger.FinishLog - Error #%d : %s', 10, 0, @ts, @errNum, @errMsg ) WITH NOWAIT        
    END CATCH        
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
        SET @log = '<log task_key="'+@pTaskKey+'" start_time="'+CONVERT( VARCHAR(25), GETUTCDATE(), 126 )+'" duration="-1" level="'+CONVERT(VARCHAR, @pLogLevel)+'" expected_max_duration="-1" level_max="-1"><description><![CDATA['+@pTitle+']]></description></log>'
    END
    ELSE
    BEGIN 
        SET @log = '<sub-log task_key="'+@pTaskKey+'" start_time="'+CONVERT( VARCHAR(25), GETUTCDATE(), 126 )+'" duration="-1" level="'+@pParentLogger.value('(/*[1]/@level)', 'VARCHAR(2)')+'" expected_max_duration="-1" level_max="-1"><description><![CDATA['+@pTitle+']]></description></sub-log>'
    END
    
    RETURN @log
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

-- Adding grant to new SPs
GRANT EXECUTE ON [splogger].[StartTGroup] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[FinishTGroup] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GO

-- Creating tagging synonym
CREATE synonym [splogger].[LogHistory 1.1] for [splogger].[LogHistory]
GO

