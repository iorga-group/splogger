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
          where  id = object_id('splogger.FinishLog')
          and type in ('P','PC'))
   drop procedure splogger.FinishLog
go


CREATE PROCEDURE splogger.FinishLog @pLogger XML, @pParentLogger XML = NULL OUT, @pAlwaysSave BIT = 1, @pDbName NVARCHAR(128) = NULL
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
        @param   pDbName   NVARCHAR(128) (default to DB_NAME())  User database name (hosting the proxy SP). If NULL, that means SPLogger is dedicated to the current database (all schema objects are created inside user database) 
        @param   pAlwaysSave   BIT   (default 1)   If to level looger, should the log be always save in database (default), or only if it reached the level log defined. "false" is usefull for interactive calls, "true" is usefull for planned batches
        
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
        DECLARE @runningLogLevel INT = splogger.GetRunningLevel(@pLogger)         
        IF @runningLogLevel = -1
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
            -- Check if we save only if reached level is above or equals the running level
            IF @pAlwaysSave = 0 AND @runningLogLevel < @levelMax
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
                VALUES ( ISNULL(@pDbName, DB_NAME()), @taskKey, @startTime, @endDate, DATEDIFF( SECOND, @startTime, @endDate), @levelMax, @pLogger, @WarnExpectedMaxDuration )
                            
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
                IF @runningLogLevel = @containerLevel
                    SET @pLogger.modify('delete /*[1]/@level')
            
                -- In case of a sub-logger, no need for sub-start time
                SET @pLogger.modify('delete /*[1]/@start_time')                                
                        
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

-- drop old tagging synonym
DROP synonym [splogger].[LogHistory 1.4]
GO

-- Creating tagging synonym
CREATE synonym [splogger].[LogHistory 1.4.1] for [splogger].[LogHistory]
GO
