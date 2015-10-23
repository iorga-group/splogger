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
          where  id = object_id('splogger.About')
          and type in ('IF', 'FN', 'TF'))
   drop function splogger.About
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.AddDebugTrace')
          and type in ('P','PC'))
   drop procedure splogger.AddDebugTrace
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.FinishLog')
          and type in ('P','PC'))
   drop procedure splogger.FinishLog
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
          where  id = object_id('splogger.StartTGroup')
          and type in ('P','PC'))
   drop procedure splogger.StartTGroup
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.AddEvent')
          and type in ('P','PC'))
   drop procedure splogger.AddEvent
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.AddParam_DateTime')
          and type in ('P','PC'))
   drop procedure splogger.AddParam_DateTime
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.AddParam_GUID')
          and type in ('P','PC'))
   drop procedure splogger.AddParam_GUID
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.AddParam_XmlAsCDATA')
          and type in ('P','PC'))
   drop procedure splogger.AddParam_XmlAsCDATA
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.AddParam')
          and type in ('P','PC'))
   drop procedure splogger.AddParam
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.AddParam_Xml')
          and type in ('P','PC'))
   drop procedure splogger.AddParam_Xml
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.FinishTGroup')
          and type in ('P','PC'))
   drop procedure splogger.FinishTGroup
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.GetRunningLevel')
          and type in ('IF', 'FN', 'TF'))
   drop function splogger.GetRunningLevel
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.NewEvent_Debug')
          and type in ('IF', 'FN', 'TF'))
   drop function splogger.NewEvent_Debug
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.NewEvent_Error')
          and type in ('IF', 'FN', 'TF'))
   drop function splogger.NewEvent_Error
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.NewEvent_For_SqlError')
          and type in ('IF', 'FN', 'TF'))
   drop function splogger.NewEvent_For_SqlError
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.NewEvent_Info')
          and type in ('IF', 'FN', 'TF'))
   drop function splogger.NewEvent_Info
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.NewEvent_Warning')
          and type in ('IF', 'FN', 'TF'))
   drop function splogger.NewEvent_Warning
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.SetExpectedMaxDuration')
          and type in ('P','PC'))
   drop procedure splogger.SetExpectedMaxDuration
go

if exists (select 1
          from sysobjects
          where  id = object_id('splogger.StartLog')
          and type in ('IF', 'FN', 'TF'))
   drop function splogger.StartLog
go

if exists (select 1
          from sysobjects
          where  id = object_id('_NewEvent')
          and type in ('IF', 'FN', 'TF'))
   drop function _NewEvent
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('splogger.LogHistory')
            and   name  = 'IDX_2_4D'
            and   indid > 0
            and   indid < 255)
   drop index splogger.LogHistory.IDX_2_4D
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('splogger.LogHistory')
            and   name  = 'IDX_2_3_4D'
            and   indid > 0
            and   indid < 255)
   drop index splogger.LogHistory.IDX_2_3_4D
go

if exists (select 1
            from  sysobjects
           where  id = object_id('splogger.LogHistory')
            and   type = 'U')
   drop table splogger.LogHistory
go

create table splogger.LogHistory (
   Id                   int                  identity,
   DbName               nvarchar(128)        not null,
   TaskKey              nvarchar(128)        not null,
   StartedAt            smalldatetime        not null,
   EndedAt              smalldatetime        not null,
   DurationInSeconds    integer              not null,
   EventsMaxLevel       smallint             not null,
   LogDetail            xml                  not null,
   WarnExpectedMaxDuration bit                  not null default 0,
   VerifiedOn           smalldatetime        null,
   constraint PK_LOGHISTORY primary key (Id)
)
go

create index IDX_2_3_4D on splogger.LogHistory (
DbName ASC,
TaskKey ASC,
StartedAt DESC
)
go

create index IDX_2_4D on splogger.LogHistory (
DbName ASC,
StartedAt DESC
)
go


CREATE FUNCTION splogger.About ()
RETURNS NVARCHAR(2000)
BEGIN
    RETURN N'SPLogger - A logging and tracing system for MSSQL stored procedures that survive to a rollback event
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

Contact Email : splogger@iorga.com'
END
go


CREATE PROCEDURE splogger.AddParam @pContainer XML OUT, @pName NVARCHAR(128), @pValue NVARCHAR(MAX)
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
        
        Add a "param" node to the specified container which can be an "logger" (sub-logger) or an "event".
        The value's data type should be implicitely convertable to a NVARCHAR type.
        
        @param   pContainer   XML OUT   targeted Logger or Event element. Be carefull this parameter SHOULD be passed as OUTPUT
        @param   pName   NVARCHAR(128)  parameter's name
        @param   pValue   NVARCHAR(MAX)   parameter's value
        
        Note: 
           - NULL values are saved as "{null}" in assertion result.
           - The pValue is stored as a <![CDATA[]]> element.
           - Any error raise during param insertion is ignored (severity 10) but immediatly logged to the console.
     */
    SET NOCOUNT ON
    
    IF @pContainer IS NULL
        RETURN 
        
    IF @pValue IS NULL
        SET @pValue = '{null}'    
     
    BEGIN TRY    
		DECLARE @xmlParam XML = '<param name="'+@pName+'"><![CDATA['+@pValue+']]></param>'       
        SET @pContainer.modify('insert (sql:variable("@xmlParam")) into (/*[1])')
	END TRY
	BEGIN CATCH
		-- Ignore, but warn in interactive mode (SSMS)
		DECLARE @ts VARCHAR(20) = CONVERT( VARCHAR(20), GETUTCDATE(), 116 )
        DECLARE @errNum INT = ERROR_NUMBER()
        DECLARE @errMsg NVARCHAR(2048) = ERROR_MESSAGE()
        RAISERROR ( N'%s - splogger.AddParam - Error #%d : %s\n%s=%s', 10, 0, @ts, @errNum, @errMsg, @pName, @pValue ) WITH NOWAIT
	END CATCH	
END
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


CREATE PROCEDURE splogger.AddParam_DateTime @pContainer XML OUT, @pName NVARCHAR(128), @pValue DATETIME
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
        
        Add a "param" node  with a DATETIME (or implicatly convertable to)  typed value to the specified container which can be an "logger" (sub-logger) or an "event".
        
        @param   pContainer   XML OUT   targeted Logger or Event element. Be carefull this parameter SHOULD be passed as OUTPUT
        @param   pName   NVARCHAR(128)  parameter's name
        @param   pValue   DATETIME   parameter's value
        
        The pValue is converted to an ISO8601 string (yyyy-mm-ddThh:mi:ss.mmm)
        
        Any error raise during param insertion is ignored (severity 10) but immediatly logged to the console.
        
        @see AddParam
     */
    SET NOCOUNT ON
    
    DECLARE @dt126 NVARCHAR(25) = CONVERT( NVARCHAR(25), @pValue, 126 )     
    EXEC splogger.AddParam @pContainer OUT, @pName, @dt126 
END
go


CREATE PROCEDURE splogger.AddParam_XmlAsCDATA @pContainer XML OUT, @pName NVARCHAR(128), @pValue XML
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
        
        Add a "param" node with a <![CDATA[]]> element filled with the convertion of the XML (or implicatly convertable to)  typed value  to the specified container which can be an "logger" (sub-logger) or an "event".
        
        @param   pContainer   XML OUT   targeted Logger or Event element. Be carefull this parameter SHOULD be passed as OUTPUT
        @param   pName   NVARCHAR(128)  parameter's name
        @param   pValue   XML   parameter's value
        
        Any error raise during param insertion is ignored (severity 10) but immediatly logged to the console.
        
        @see AddParam
     */
    SET NOCOUNT ON
    
    DECLARE @xmlAsStr NVARCHAR(MAX) = CONVERT( NVARCHAR(MAX), @pValue)     
    EXEC splogger.AddParam @pContainer OUT, @pName, @xmlAsStr 
END
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


CREATE PROCEDURE splogger.AddParam_GUID @pContainer XML OUT, @pName NVARCHAR(128), @pValue UNIQUEIDENTIFIER 
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
        
        Add a "param" node  with a UNIQUEIDENTIFIED typed value to the specified container which can be an "logger" (sub-logger) or an "event".
        
        @param   pContainer   XML OUT   targeted Logger or Event element. Be carefull this parameter SHOULD be passed as OUTPUT
        @param   pName   NVARCHAR(128)  parameter's name
        @param   pValue   UNIQUEIDENTIFIER   parameter's value
        
        Any error raise during param insertion is ignored (severity 10) but immediatly logged to the console.
        
        @see AddParam
     */
    SET NOCOUNT ON
    
    DECLARE @xmlAsStr NVARCHAR(100) = CONVERT( NVARCHAR(100), @pValue)     
    EXEC splogger.AddParam @pContainer OUT, @pName, @xmlAsStr 
END
go


CREATE PROCEDURE splogger.AddParam_Xml @pContainer XML OUT, @pName NVARCHAR(128), @pValue XML
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
        
        Add a "param" node  with a XML (or implicatly convertable to)  typed value (set as node value) to the specified container which can be an "logger" (sub-logger) or an "event".
        
        @param   pContainer   XML OUT   targeted Logger or Event element. Be carefull this parameter SHOULD be passed as OUTPUT
        @param   pName   NVARCHAR(128)  parameter's name
        @param   pValue   XML   parameter's value
        
        Any error raise during param insertion is ignored (severity 10) but immediatly logged to the console.
        
        @see AddParam
     */
    SET NOCOUNT ON
    
    IF @pContainer IS NULL
        RETURN 
     
    BEGIN TRY    
		DECLARE @xmlParam XML = '<param name="'+@pName+'"></param>' 
        IF @pValue IS NOT NULL      
            SET @xmlParam.modify('insert (sql:variable("@pValue")) into (/*[1])')
        -- Setting param value    
        SET @pContainer.modify('insert (sql:variable("@xmlParam")) into (/*[1])')
	END TRY
	BEGIN CATCH
		-- Ignore
		DECLARE @ts VARCHAR(20) = CONVERT( VARCHAR(20), GETDATE(), 116 )
        DECLARE @errNum INT = ERROR_NUMBER()
        DECLARE @errMsg NVARCHAR(2048) = ERROR_MESSAGE()
        DECLARE @xmlAsStr NVARCHAR(MAX) = CONVERT( NVARCHAR(MAX), @pValue) 
        RAISERROR ( N'%s - splogger.AddParam_Xml - Error #%d : %s\n%s=%s', 10, 0, @ts, @errNum, @errMsg, @pName, @xmlAsStr ) WITH NOWAIT
	END CATCH	
END
go


CREATE FUNCTION _NewEvent (@pLogLevel INT, @pCode INT, @pText NVARCHAR(MAX))
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
        
        ==
        == Internal use only. Use suffixed procedures
        ==
        Initialize a log event for a specified log level.
        "param" element could be added to it before its log attachment (@see AddParam and AddParam suffixed procedures)
        
        @param   pLogLevel   INT  Event log level. Possible values are 0=DEBUG, 1=INFO, 2=WARNING ou 3=ERROR
        @param   pCode   INT   Event's code (optionnal). In fact, this code is mandatory for WARNING and ERROR levels.
        @param   pText   NVARCHAR(MAX)   Event description
        
        @return   <event [code=""] at="" level="" nb="1"><text><![CDATA[]]></text></event>
        @attribute   code   Event's associated code when level is WARNING or ERROR
        @attribute   at   TimeStamp of the creation
        @attribute   level   Event's level
        @attribute   nb   Counter of same code events in a row (to avoid too many identical events in a row when logging in a loop)
        @element   text   Event's description
        
        The "nb" attribute is removed from the "event" element if it's equal to "1"
        
        @see   NewEvent_Debug, NewEvent_Info, NewEvent_Warning, NewEvent_Error, NewEvent_For_SqlError
     */
    IF ISNULL(@pCode, 0) = 0
        RETURN '<event at="'+CONVERT( VARCHAR(25), GETUTCDATE(), 126 )+'" level="'+CONVERT(VARCHAR, @pLogLevel)+'"><text><![CDATA['+@pText+']]></text></event>'
    
    RETURN '<event code="'+CONVERT(VARCHAR, @pCode)+'" at="'+CONVERT( VARCHAR(25), GETUTCDATE(), 126 )+'" level="'+CONVERT(VARCHAR, @pLogLevel)+'" nb="1"><text><![CDATA['+@pText+']]></text></event>'
END
go


CREATE FUNCTION splogger.NewEvent_Error ( @pCode INT, @pText NVARCHAR(MAX))
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
        
        Initialize a "ERROR" level log event.
        
        @param   pCode   INT   Event's code
        @param   pText   NVARCHAR(MAX)   Event description
        
        @see   _NewEvent
     */    
    RETURN dbo._NewEvent ( 3, @pCode, @pText)
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


CREATE FUNCTION splogger.NewEvent_Warning ( @pCode INT, @pText NVARCHAR(MAX))
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
        
        Initialize a "WARNING" level log event.
        
        @param   pCode   INT   Event's code
        @param   pText   NVARCHAR(MAX)   Event description
        
        @see   _NewEvent
     */    
    RETURN dbo._NewEvent ( 2, @pCode, @pText)
END
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


CREATE FUNCTION splogger.GetRunningLevel ( @pLogger XML )
RETURNS INT
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
        
        Return the current log level for the specified logger.
        This level can be the creation time one or the parent logger one if specified.
        If the specified logger is NULL then the returned level is "-1" (desactivated)
        
        @param   pLogger   XML   Parent logger in which the new logger will be inserted (xml child node) and used to define le runtime logging level to used.
        
        @return   INT   Running log level 
     */
    IF @pLogger IS NULL
        RETURN -1
         
    RETURN @pLogger.value('(/*[1]/@level)', 'INT') 
END
go


CREATE FUNCTION splogger.NewEvent_Debug ( @pText NVARCHAR(MAX))
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
        
        Initialize a "DEBUG" level log event.
        
        @param   pText   NVARCHAR(MAX)   Event description
        
        @see   _NewEvent
     */    
    RETURN dbo._NewEvent ( 0, 0, @pText)
END
go


CREATE FUNCTION splogger.NewEvent_For_SqlError ( @pLogLevel INT )
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
        
        Initialize a log event of the specified level.
        Be carefull, this event type should be created only from inside a CATCH statement !
        
        All informations from the last raised SQL exception are added to it as "param" child elements.
        The current value of the "XACT_ABORT" is also added.
        
        @param   pLogLevel   INT  Event log level. Possible values are 0=DEBUG, 1=INFO, 2=WARNING ou 3=ERROR
        
        @see   _NewEvent
        
        TODO   The "param" elements can be created in only one concatenation and XML insertion.
     */   
    DECLARE @errNum INT = ERROR_NUMBER()
    DECLARE @errMsg NVARCHAR(2048) = ERROR_MESSAGE()
    
    DECLARE @XACT_ABORT VARCHAR(3) = 'OFF';
	IF ( (16384 & @@OPTIONS) = 16384 ) SET @XACT_ABORT = 'ON';
    
    DECLARE @xmlEvent XML = dbo._NewEvent ( @pLogLevel, @errNum, @errMsg)
    
    DECLARE @xmlParam XML = '<param name="ERROR_SEVERITY"><![CDATA['+CONVERT(VARCHAR, ERROR_SEVERITY())+']]></param>'       
    SET @xmlEvent.modify('insert (sql:variable("@xmlParam")) into (/*[1])')
    SET @xmlParam = '<param name="ERROR_STATE"><![CDATA['+CONVERT(VARCHAR, ERROR_STATE())+']]></param>'       
    SET @xmlEvent.modify('insert (sql:variable("@xmlParam")) into (/*[1])')
    SET @xmlParam = '<param name="ERROR_PROCEDURE"><![CDATA['+ERROR_PROCEDURE()+']]></param>'       
    SET @xmlEvent.modify('insert (sql:variable("@xmlParam")) into (/*[1])')
    SET @xmlParam = '<param name="ERROR_LINE"><![CDATA['+CONVERT(VARCHAR, ERROR_LINE())+']]></param>'       
    SET @xmlEvent.modify('insert (sql:variable("@xmlParam")) into (/*[1])')
    SET @xmlParam = '<param name="XACT_ABORT"><![CDATA['+@XACT_ABORT+']]></param>'       
    SET @xmlEvent.modify('insert (sql:variable("@xmlParam")) into (/*[1])')

    RETURN @xmlEvent
END
go


CREATE FUNCTION splogger.NewEvent_Info ( @pText NVARCHAR(MAX))
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
        
        Initialize a "INFO" level log event.
        
        @param   pText   NVARCHAR(MAX)   Event description
        
        @see   _NewEvent
     */    
    RETURN dbo._NewEvent ( 1, 0, @pText)
END
go


CREATE PROCEDURE splogger.SetExpectedMaxDuration @pLogger XML OUT, @pExpectedMaxDuration INT, @pDurationUnit NVARCHAR(3) = 'SEC' 
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
        
        Define the expected max duration in seconds for the logger to achieve.
        
        @param   pLogger   XML   Logger for which we want to set the expected max duration.
        @param   pExpectedMaxDuration  INT (default to -1)   Maximum expected duration. A duration above this value adds a WARNING. A value of -1 disables it.
        @param   pDurationUnit   NVARCHAR(3) (default to 'SEC'=seconds)   duration in which unity in MS=milliseconds, SEC=seconds or MIN=minutes ?
        
        @see   FinishLog
     */
    SET NOCOUNT ON
    
    IF @pLogger IS NULL
        RETURN 
    
    IF UPPER(@pDurationUnit) <> 'MS'
    BEGIN
        IF UPPER(@pDurationUnit) = 'SEC'
            SET @pExpectedMaxDuration = @pExpectedMaxDuration * 1000
        ELSE IF UPPER(@pDurationUnit) = 'MIN'
            SET @pExpectedMaxDuration = @pExpectedMaxDuration * 60000
    END
    
    -- Memorize duration in milliseconds
    SET @pLogger.modify('replace value of (/*[1]/@expected_max_duration) with (sql:variable("@pExpectedMaxDuration"))')                     
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

-- Grant update right to admin
GRANT UPDATE ON splogger.LogHistory(VerifiedOn) TO [splogger_admin]
GO

-- Creating tagging synonym
CREATE synonym [splogger].[LogHistory 1.4.1] for [splogger].[LogHistory]
GO
