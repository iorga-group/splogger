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
 */

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

if exists (select 1 from sysobjects where  id = object_id('splogger.SPTest_SubLogger') and type in ('P','PC'))
   drop procedure splogger.SPTest_SubLogger
go

if exists (select 1 from sysobjects where  id = object_id('splogger.SPTest_SQLException') and type in ('P','PC'))
   drop procedure splogger.SPTest_SQLException
go

if exists (select 1 from sysobjects where  id = object_id('splogger.SPTest') and type in ('P','PC'))
   drop procedure splogger.SPTest
go

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

CREATE PROCEDURE splogger.SPTest_SubLogger @pParentLog XML OUT, @pParam1 INT, @pParam2 DATE, @pLogLevel INT = 0
AS 
BEGIN
	/**
		This nestable SP shows you:
		   - Use of SP templates
		   - How to create a sub-logger
		   - How to log the result of a SQL select on a temporary table
		   - How to save the the result of a SQL select for UT (query executed only if in UT mode)
	 */
	SET NOCOUNT ON
	DECLARE @retVal INT 
	DECLARE @tranCount INT

	-- In case of running UT, check if this SP is launched if a first level transaction.
	-- If it's not the case (@@ROWCOUNT <> 1) then raise an error.
	SET @tranCount = @@TRANCOUNT

	DECLARE @logEvent XML
	DECLARE @logger XML = splogger.StartLog ( @pParentLog, 'splogger.SPTest_SubLogger', @pLogLevel, 'Testing SPLogger sub-logger functionnalities')
		EXEC splogger.AddParam @logger OUT, '@pParam1', @pParam1
		EXEC splogger.AddParam_DateTime @logger OUT, '@pParam2', @pParam2

	BEGIN TRY
		IF @trancount = 0
			BEGIN TRANSACTION
		ELSE
			SAVE TRANSACTION "splogger.SPTest_SubLogger"
		
		-- Personnalised query
		DECLARE @sqlQ NVARCHAR(2000) = 'SELECT * FROM #spLoggerTest WHERE Id % '+CONVERT(VARCHAR, @pParam1)+' = 0 ORDER BY Country'	
		EXEC splogger.AddSQLSelectTrace @logger OUT, @sqlQ, 'Query with test modulo', 1

		-- Exit. SHOULD BE used in GOTO in place of any RETURN
		label_exit:   
   
		IF @trancount = 0
			COMMIT       
         
		-- Close logging session. 
		-- Save log in database if not a sub-logger or UT Mode.
		-- So return the Log Id if not in UT, level_max if in UT		
        EXEC @retVal = splogger.FinishLog @logger, @pParentLog OUT
		RETURN @retVal    
	END TRY
	BEGIN CATCH
		-- In case of any exception
		-- Auto log all exception data as an Error		
		DECLARE @xstate INT = XACT_STATE()                        		

		-- So log the error and rollback 
		SET @logEvent = splogger.NewEvent_For_SqlError(3)	
			EXEC splogger.AddEvent @logger OUT, @logEvent

        IF @xstate = 1
        BEGIN
			IF @trancount = 0       
			BEGIN
				-- The transaction was initiated here and it's valid. 				
				ROLLBACK
			END
			ELSE 
			BEGIN 
				-- The transaction wasn't initialised here.		
				ROLLBACK TRANSACTION "splogger.SPTest_SubLogger"
			END
        END
        ELSE IF @xstate = -1     
		BEGIN
			-- Invalid transaction.
			-- Only one think to do...
			ROLLBACK
		END
		       
        -- Now the Rollback is done, 
		-- so finish the logger and save it to database (if not UT mode)
		-- before rethrow/raiserror
        EXEC @retVal = splogger.FinishLog @logger, @pParentLog OUT
        
        IF @trancount > 0 AND @pParentLog IS NULL
			-- A transaction was initied outside an not in UT mode
			-- so rethrow/raise
			-- 2012 and above rethrow the exception
			-- Under SQLServer 2008/2008R2 you should use RAISERROR()
			--;THROW  
			RAISERROR( N'An unexpected error has been raised', 16, 0 )
		ELSE
			-- No transaction was initied outside
			-- so return "- id" meaning error 
			-- and allow loading of log detail 
			RETURN @retVal
        		
	END CATCH    
END
GO

CREATE PROCEDURE splogger.SPTest_SQLException @pParentLog XML OUT, @pParam1 INT, @pParam2 INT, @pLogLevel INT = 3
AS 
BEGIN
	/**
		This nestable SP shows you:
		   - Use of SP templates
		   - How to create a sub-logger
		   - How to trap exceptions and log them log 
		   - How to save the values for UT (query executed only if in UT mode)
	 */
	SET NOCOUNT ON
	DECLARE @retVal INT 
	DECLARE @tranCount INT

	-- In case of running UT, check if this SP is launched if a first level transaction.
	-- If it's not the case (@@ROWCOUNT <> 1) then raise an error.
	SET @tranCount = @@TRANCOUNT

	DECLARE @logEvent XML
	DECLARE @logger XML = splogger.StartLog ( @pParentLog, 'splogger.SPTest_SQLException', @pLogLevel, 'Testing SPLogger SQL exception management')
		EXEC splogger.AddParam @logger OUT, '@pParam1', @pParam1
		EXEC splogger.AddParam @logger OUT, '@pParam2', @pParam2

	BEGIN TRY
		IF @trancount = 0
			BEGIN TRANSACTION
		ELSE
			SAVE TRANSACTION "splogger.SPTest_SQLException"

		SET @logEvent = splogger.NewEvent_Warning ( 100, 'This is going to fail if @pParam2 equals 0...')
		EXEC splogger.AddEvent @logger OUT, @logEvent
	
		-- Doing computation
		DECLARE @value DECIMAL
		SET @value = @pParam1 / @pParam2

		-- Logging the value
		SET @logEvent = splogger.NewEvent_Debug ( 'The result of @pParam1 / @pParam2 = ')
			EXEC splogger.AddParam @logEvent OUT, '@value', @value
		EXEC splogger.AddEvent @logger OUT, @logEvent	
	
		-- Exit. SHOULD BE used in GOTO in place of any RETURN
		label_exit:   
   
		IF @trancount = 0
			COMMIT       
         
		-- Close logging session. 
		-- Save log in database if not a sub-logger or UT Mode.
		-- So return the Log Id if not in UT, level_max if in UT		
        EXEC @retVal = splogger.FinishLog @logger, @pParentLog OUT
		RETURN @retVal    
	END TRY
	BEGIN CATCH
		-- In case of any exception
		-- Auto log all exception data as an Error		
		DECLARE @xstate INT = XACT_STATE()                        		

		-- So log the error and rollback 
		SET @logEvent = splogger.NewEvent_For_SqlError(3)
			EXEC splogger.AddParam @logEvent OUT, '@pParam1', @pParam1
			EXEC splogger.AddParam @logEvent OUT, '@pParam2', @pParam2	
		EXEC splogger.AddEvent @logger OUT, @logEvent

        IF @xstate = 1
        BEGIN
			IF @trancount = 0       
			BEGIN
				-- The transaction was initiated here and it's valid. 				
				ROLLBACK
			END
			ELSE 
			BEGIN 
				-- The transaction wasn't initialised here.
				ROLLBACK TRANSACTION "splogger.SPTest_SQLException"
			END
        END
        ELSE IF @xstate = -1     
		BEGIN
			-- Invalid transaction.
			-- Only one think to do...
			ROLLBACK
		END
		       
        -- Now the Rollback is done, 
		-- so finish the logger and save it to database (if not UT mode)
		-- before rethrow/raiserror
        EXEC @retVal = splogger.FinishLog @logger, @pParentLog OUT
        
        IF @trancount > 0 AND @pParentLog IS NULL
			-- A transaction was initied outside an not in UT mode
			-- so rethrow/raise
			-- 2012 and above rethrow the exception
			-- Under SQLServer 2008/2008R2 you should use RAISERROR()
			--;THROW  
			RAISERROR( N'An unexpected error has been raised', 16, 0 )
		ELSE
			-- No transaction was initied outside
			-- so return "- id" meaning error 
			-- and allow loading of log detail 
			RETURN @retVal
        		
	END CATCH    
END
GO

CREATE PROCEDURE splogger.SPTest @pLogLevel INT = 1, @pUTest XML = NULL OUT
AS
BEGIN
	/**
		
	 */
	SET NOCOUNT ON
	DECLARE @retVal INT 
	DECLARE @tranCount INT
	
	-- In case of running UT, check if this SP is launched if a first level transaction.
	-- If it's not the case (@@ROWCOUNT <> 1) then raise an error.
	SET @tranCount = @@TRANCOUNT

	-- Test data
	DECLARE @now DATETIME = GETDATE()
	DECLARE @xmldata XML = '<vehicles><vehicle maker="BMW" hp="321">Z3 Roadster M</vehicle><vehicle maker="Peugeot" hp="137">307 SW</vehicle></vehicles>'
	DECLARE @guid UNIQUEIDENTIFIER = NEWID()
	DECLARE @logEvent XML		

	-- Creating a main Logger
	DECLARE @logger XML = splogger.StartLog ( @pUTest, 'SPLogger Main', @pLogLevel, 'Testing SPLogger functionnalities')
		EXEC splogger.SetExpectedMaxDuration @logger OUT, 350, 'MS'
		EXEC splogger.AddParam @logger OUT, 'SPID', @@SPID
		EXEC splogger.AddParam @logger OUT, 'null valued param', NULL
		EXEC splogger.AddParam_Xml @logger OUT, 'NULL XML param', NULL
		EXEC splogger.AddParam_DateTime @logger OUT, 'Now', @now
		EXEC splogger.AddParam_GUID @logger OUT, 'GUID', @guid
	
	BEGIN TRY
		IF @trancount = 0
			BEGIN TRANSACTION
		ELSE
			SAVE TRANSACTION "splogger.SPTest"     

		--
		-- Starting a new timing bloc
		--
		EXEC splogger.StartTGroup @logger OUT, 'Group #1'

		-- Adding an INFO event
		SET @logEvent = splogger.NewEvent_Info ( 'This is an information event with param')
			EXEC splogger.AddParam @logEvent OUT, '@nbRows', 52
		EXEC splogger.AddEvent @logger OUT, @logEvent
	
		-- Adding a WARNING event
		SET @logEvent = splogger.NewEvent_Warning ( 251, 'Warning 251 raised three times in a row (have a look at "nb" attribute)')
		EXEC splogger.AddEvent @logger OUT, @logEvent
	
		SET @logEvent = splogger.NewEvent_Warning ( 251, 'Same warning again (code=251)')
		EXEC splogger.AddEvent @logger OUT, @logEvent

		SET @logEvent = splogger.NewEvent_Warning ( 251, 'and again (code=251)')
		EXEC splogger.AddEvent @logger OUT, @logEvent

		SET @logEvent = splogger.NewEvent_Warning ( 138, 'Warning 138')
		EXEC splogger.AddEvent @logger OUT, @logEvent

		SET @logEvent = splogger.NewEvent_Warning ( 251, 'and again Warning 251. BUT NOT IN A ROW (have a look at "nb" attribute)')
		EXEC splogger.AddEvent @logger OUT, @logEvent

		EXEC splogger.AddDebugTrace @logger OUT, 'What is the Now value', null, @now
	
		-- Adding a INFO event with XML as data param
		SET @logEvent = splogger.NewEvent_Info ( 'This is an information event with XML data as param')
			EXEC splogger.AddParam_XmlAsCDATA @logEvent OUT, '@vehicules', @xmldata
		EXEC splogger.AddEvent @logger OUT, @logEvent

		-- Adding a INFO event with XML as data param
		SET @logEvent = splogger.NewEvent_Info ( 'This is an information event with XML data as nested XML elements')
			EXEC splogger.AddParam_Xml @logEvent OUT, '@vehicules', @xmldata
		EXEC splogger.AddEvent @logger OUT, @logEvent

		-- Ending Group #1
		EXEC splogger.FinishTGroup @logger OUT	

		-- Event outside any timing group
		SET @logEvent = splogger.NewEvent_Info ( 'This is an information event outside of a timed-group')
		EXEC splogger.AddEvent @logger OUT, @logEvent

		--
		-- Starting a new timing bloc
		--
		EXEC splogger.StartTGroup @logger OUT, 'Group #2'

		--
		-- Adding a WARNING SQL Query event 
		--
		CREATE TABLE #spLoggerTest (
			Id INT IDENTITY NOT NULL,
			City NVARCHAR(128) NOT NULL,
			Country NVARCHAR(128) NOT NULL
			PRIMARY KEY (Id)
		)

		INSERT INTO #spLoggerTest (City, Country)
		VALUES ('Paris', 'France'),
			('London', 'Great-Britain'),
			('New-York', 'U.S.A.'),
			('Dublin', 'Ireland'),
			('Berlin', 'Germany'),
			('Sao Paulo', 'Brazil'),
			('Pekin', 'China')

		-- Starting a new timing bloc inside the bloc 'Group #2'
		EXEC splogger.StartTGroup @logger OUT, 'Group 2.1'
		BEGIN	-- Possible to improve lisibility

			-- Personnalised query
			EXEC splogger.AddSQLSelectTrace @logger OUT, 'SELECT * FROM #spLoggerTest ORDER BY Country', 'All cities and countries'

			-- Simple table query as warning (level=2) and the first 3 rows
			EXEC splogger.AddSQLTableTrace @logger OUT, '#spLoggerTest', 'First 3 cities as warning', 2, 3

			-- Personnalised query for no rows
			EXEC splogger.AddSQLSelectTrace @logger OUT, 'SELECT * FROM #spLoggerTest WHERE 1 = 0 ORDER BY Country', 'No cities and countries'

			EXEC splogger.FinishTGroup @logger OUT	-- Ending Group 2.1
		END

		-- Starting another timing bloc inside the bloc 'Group #2'
		EXEC splogger.StartTGroup @logger OUT, 'Group 2.2'
		BEGIN

			-- Calling sub procedure with their own logger. Creates sub-loggers
			DECLARE @i INT = 1
			WHILE @i < 4
			BEGIN
				SET @now = GETDATE()
				EXEC splogger.SPTest_SubLogger @logger OUT, @i, @now, 3		-- This specified log level (3) will be override by main logger log level
				SET @i = @i + 1
			END		

			EXEC splogger.FinishTGroup @logger OUT  -- Ending Group 2.2
		END

		EXEC splogger.FinishTGroup @logger OUT  -- Ending Group 2

		-- SQL Exception management
		EXEC splogger.SPTest_SQLException @logger OUT, 254, 3		
		
		-- A trace written only if running in debug mode (level=0)
		EXEC splogger.AddDebugTrace @logger OUT, 'What is the XML value', null, null, @xmldata

		-- A trace written only if running in debug mode (level=0)
		EXEC splogger.AddDebugTrace @logger OUT, 'What is the NULL value', null, null, null

		-- Exit. SHOULD BE used in GOTO in place of any RETURN
		label_exit:   
   
		IF @trancount = 0
			COMMIT       
            		
		-- Close logging session. 
		-- Save log in database if not in UT mode.
		-- So return the Log Id if not in UT, level_max if in UT		
        EXEC @retVal = splogger.FinishLog @logger, @pUTest OUT
		RETURN @retVal
	END TRY
	BEGIN CATCH
		-- In case of any exception
		-- Auto log all exception data as an Error		
		DECLARE @xstate INT = XACT_STATE()                        		

		-- So log the error and rollback 
		SET @logEvent = splogger.NewEvent_For_SqlError(3)	
			EXEC splogger.AddEvent @logger OUT, @logEvent

        IF @xstate = 1
        BEGIN
			IF @trancount = 0       
			BEGIN
				-- The transaction was initiated here and it's valid. 				
				ROLLBACK
			END
			ELSE 
			BEGIN 
				-- The transaction wasn't initialised here.
				ROLLBACK TRANSACTION "splogger.SPTest"  
			END
        END
        ELSE IF @xstate = -1     
		BEGIN
			-- Invalid transaction.
			-- Only one think to do...
			ROLLBACK
		END
		       
        -- Now the Rollback is done, 
		-- so finish the logger and save it to database (if not UT mode)
		-- before rethrow/raiserror
        EXEC @retVal = splogger.FinishLog @logger, @pUTest OUT
        
        IF @trancount > 0 AND @pUTest IS NULL
			-- A transaction was initied outside an not in UT mode
			-- so rethrow/raise
			-- 2012 and above rethrow the exception
			-- Under SQLServer 2008/2008R2 you should use RAISERROR()
			RAISERROR( N'An unexpected error has been raised', 16, 0 )
		ELSE
			-- No transaction was initied outside
			-- so return "- id" meaning error 
			-- and allow loading of log detail 
			RETURN @retVal
        		
	END CATCH    	
END
GO

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

EXEC splogger.SPTest @pLogLevel = 0
GO

SELECT TOP(1) * 
FROM SPLogger.splogger.LogHistory
ORDER BY Id DESC

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

if exists (select 1 from sysobjects where  id = object_id('splogger.SPTest_SubLogger') and type in ('P','PC'))
   drop procedure splogger.SPTest_SubLogger
go

if exists (select 1 from sysobjects where  id = object_id('splogger.SPTest_SQLException') and type in ('P','PC'))
   drop procedure splogger.SPTest_SQLException
go

if exists (select 1 from sysobjects where  id = object_id('splogger.SPTest') and type in ('P','PC'))
   drop procedure splogger.SPTest
go

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

