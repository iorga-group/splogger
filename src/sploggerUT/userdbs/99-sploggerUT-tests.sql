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
	EXEC @tranCount = sploggerUT.CheckUnitTestInTransaction @pParentLog OUT

	DECLARE @logEvent XML
	DECLARE @logger XML = splogger.StartLog ( @pParentLog, 'SPTest_SubLogger', @pLogLevel, 'Testing SPLogger sub-logger functionnalities')
		EXEC splogger.AddParam @logger OUT, '@pParam1', @pParam1
		EXEC splogger.AddParam_DateTime @logger OUT, '@pParam2', @pParam2

	BEGIN TRY
		IF @trancount = 0
			BEGIN TRANSACTION
		ELSE
			SAVE TRANSACTION "splogger.SPTest_SubLogger"
		
		-- Personnalised query
		DECLARE @sqlQ NVARCHAR(2000) = 'SELECT * FROM #spLoggerTest WHERE Id % '+CONVERT(VARCHAR, @pParam1)+' = 0 ORDER BY Country'	
		EXEC splogger.AddSQLSelectTrace @logger OUT, @sqlQ, 1

		-- Becarefull sploggerUT procedures use the parent logger (UT) and not the current logger !
		SET @sqlQ = 'SELECT * FROM #spLoggerTest WHERE Id % '+CONVERT(VARCHAR(12), @pParam1)+' = 0 ORDER BY Country'
		EXEC sploggerUT.SetSqlSelectValue @pParentLog OUT, 'sqlquery', 'Countries rows based on Id modulo.', @sqlQ 

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
	EXEC @tranCount = sploggerUT.CheckUnitTestInTransaction @pParentLog OUT

	DECLARE @logEvent XML
	DECLARE @logger XML = splogger.StartLog ( @pParentLog, 'SPTest_SQLException', @pLogLevel, 'Testing SPLogger SQL exception management')
		EXEC splogger.AddParam @logger OUT, '@pParam1', @pParam1
		EXEC splogger.AddParam @logger OUT, '@pParam2', @pParam2

	BEGIN TRY
		IF @trancount = 0
			BEGIN TRANSACTION
		ELSE
			SAVE TRANSACTION "SPTest_SQLException"

		SET @logEvent = splogger.NewEvent_Warning ( 100, 'This is going to fail if @pParam2 equals 0...')
		EXEC splogger.AddEvent @logger OUT, @logEvent
	
		-- Doing computation
		DECLARE @value DECIMAL
		SET @value = @pParam1 / @pParam2

		-- Setting value for UT
		EXEC sploggerUT.SetIntValue @pParentLog OUT, 'opresult', 'The result of @pParam1 / @pParam2', @value

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
				ROLLBACK TRANSACTION "SPTest_SQLException"
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

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- TEST #1
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

BEGIN 
	/**
		Testing SP
	 */
	SET NOCOUNT ON

	IF @@TRANCOUNT > 0
	BEGIN
		-- To garantie that test data inserted for the UT will be roolbacked after execution
		-- no transaction should be in progress before start
		RAISERROR( N'sploggerUT - Unit Test can NOT be nested inside a running transaction.', 16, 0 )	
	END

	-- Creating the UT object
	DECLARE @UTester XML = sploggerUT.StartUnitTest('Demo Test #1', 'Testing SP')

	BEGIN TRY
		DECLARE @retVal INT

		/**************************
		 * Prepare and execute SP 
		 **************************/

		-- Starting the UT dedicated transaction
		BEGIN TRANSACTION
		
		-- If needed, you can insert, here, some test datas

		

		-- Executing the SP in UT mode
		EXEC @retVal = [splogger].[SPTest_SQLException] @UTester OUT, 55, 5

		-- Rolling back all test datas
		ROLLBACK TRANSACTION

		/**************************
		 * Eval the assertions
		 **************************/

		-- Check if SP exit on error or not. "level_max" is automatically filled when the UT ends
		-- (You can also check for the value of @retVal)
		EXEC sploggerUT.AssertTrue @UTester OUT, '{{level_max}} < 3', 'Does the SP run successfully ?'

		-- Implements, here, all your Assets.
		-- The UT will be mark as failed if any of the following assets failed.
		EXEC sploggerUT.AssertEquals @Utester OUT, 'opresult', 11
		
	END TRY
	BEGIN CATCH	
		-- Rolling back all test datas	
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION		               

		-- An unexpected error has been raised during the execution
		-- So log the error
		DECLARE @logEvent XML = splogger.NewEvent_For_SqlError(3)	
			EXEC splogger.AddEvent @UTester OUT, @logEvent		
	END CATCH    	

	-- Save the result of the UT into its dedicated database table.
	EXEC sploggerUT.SaveUnitTest @UTester
END
GO 

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- TEST #2
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

BEGIN 
	/**
		Testing SP
	 */
	SET NOCOUNT ON

	IF @@TRANCOUNT > 0
	BEGIN
		-- To garantie that test data inserted for the UT will be roolbacked after execution
		-- no transaction should be in progress before start
		RAISERROR( N'sploggerUT - Unit Test can NOT be nested inside a running transaction.', 16, 0 )	
	END

	-- Creating the UT object
	DECLARE @UTester XML = sploggerUT.StartUnitTest('Demo Test #2', 'Testing SP - divide by 0 error.')

	BEGIN TRY
		DECLARE @retVal INT

		/**************************
		 * Prepare and execute SP 
		 **************************/

		-- Starting the UT dedicated transaction
		BEGIN TRANSACTION
		
		-- If needed, you can insert, here, some test datas
		DECLARE @today DATE = getDate()
		

		-- Executing the SP in UT mode
		EXEC @retVal = splogger.SPTest_SubLogger @UTester OUT, 28, @today

		-- Rolling back all test datas
		ROLLBACK TRANSACTION

		/**************************
		 * Eval the assertions
		 **************************/

		-- Check if SP exit on error or not. "level_max" is automatically filled when the UT ends
		-- (You can also check for the value of @retVal)
		EXEC sploggerUT.AssertTrue @UTester OUT, '{{level_max}} = 3', 'Does the SP run failed ?'

		-- Implements, here, all your Assets.
		-- The UT will be mark as failed if any of the following assets failed.
		--EXEC sploggerUT.AssertEquals @Utester OUT, 'opresult', 11
		
	END TRY
	BEGIN CATCH	
		-- Rolling back all test datas	
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION		               

		-- An unexpected error has been raised during the execution
		-- So log the error
		DECLARE @logEvent XML = splogger.NewEvent_For_SqlError(3)	
			EXEC splogger.AddEvent @UTester OUT, @logEvent		
	END CATCH    	

	-- Save the result of the UT into its dedicated database table.
	EXEC sploggerUT.SaveUnitTest @UTester
END
GO 

SELECT * 
FROM SPLogger.sploggerUT.UnitTestHistory
ORDER BY Id DESC


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

if exists (select 1 from sysobjects where  id = object_id('splogger.SPTest_SubLogger') and type in ('P','PC'))
   drop procedure splogger.SPTest_SubLogger
go

if exists (select 1 from sysobjects where  id = object_id('splogger.SPTest_SQLException') and type in ('P','PC'))
   drop procedure splogger.SPTest_SQLException
go

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

