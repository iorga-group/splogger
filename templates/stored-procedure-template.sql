/*
	Use the Specify Values for Template Parameters 
	command (Ctrl-Shift-M) to fill in the parameter 
	values below.
*/

IF EXISTS (SELECT 1 FROM sysobjects WHERE id = object_id('<ProcedureName, sysname, ProcedureName>') AND type IN ('P','PC'))
   DROP PROCEDURE <ProcedureName, sysname, ProcedureName>
GO

CREATE PROCEDURE [<SchemaName, sysname, dbo>].[<ProcedureName, sysname,>] 
		@pParentLogger XML = NULL OUT,		-- SPLogger: Parent logger by REF if called by another SP
		-- Your parameters
		<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>,		
		@pLogLevel INT = 2					-- SPLogger: Warn level by default if not called by another SP
AS
BEGIN
	/**		
		Author:		<Author,,Name>
		Create date: <Create Date,,>
		Description:	<Description,,>
	 */
	SET NOCOUNT ON
	DECLARE @tranCount INT = @@TRANCOUNT

	-- Initialisation du Log
    DECLARE @logEvent XML
	DECLARE @logger XML = splogger.StartLog( @pParentLogger, '<ProcedureName, sysname,>', @pLogLevel, '<Description,,>')
		-- If needed: EXEC splogger.SetExpectedMaxDuration @logger OUT, -1
		EXEC splogger.AddParam @logger OUT, '@tranCount', @tranCount
		EXEC splogger.AddParam @logger OUT, '<@Param1, sysname, @p1>', <@Param1, sysname, @p1>

	BEGIN TRY
		IF @trancount = 0
			BEGIN TRANSACTION
		ELSE
			SAVE TRANSACTION <Save_Point_Name, VARCHAR, SavePoint_000>     
		
		--=-=-=-=-= Start	



		--=-=-=-=-= End

		-- Exit. SHOULD BE used in GOTO in place of any RETURN
		label_exit:   
   
		IF @trancount = 0
			COMMIT       
            
		-- Close logging session. Save log in database 
        EXEC splogger.FinishLog @logger, @pParentLogger OUT
	END TRY
	BEGIN CATCH
		-- In case of any exception
		-- Auto log all exception data as an Error		
		DECLARE @xstate INT = XACT_STATE()                        		

        IF @xstate = 1
        BEGIN
			IF @trancount = 0       
			BEGIN
				-- The transaction was initiated here and it's valid. 
				-- So log the error and rollback 
				SET @logEvent = splogger.NewEvent_For_SqlError(3)	
				EXEC splogger.AddEvent @logger OUT, @logEvent
				ROLLBACK
			END
			ELSE 
			BEGIN 
				-- The transaction wasn't initialised here.
				-- So just rollback to the save point and rethrow it
				ROLLBACK TRANSACTION <Save_Point_Name, VARCHAR, SavePoint_000>
			END
        END
        ELSE IF @xstate = -1     
		BEGIN
			-- Invalid transaction.
			-- Only one think to do...
			ROLLBACK
		END
		       
        -- Now the Rollback is done, 
		-- so finish the logger (and save it to database if not a sub-logger)
        EXEC splogger.FinishLog @logger, @pParentLogger OUT
        
        -- 2012 and above rethrow the exception
		-- Under SQLServer 2008/2008R2 you should use RAISERROR()
		;THROW  
        		
	END CATCH    
END
GO

EXEC  [<SchemaName, sysname, dbo>].[<ProcedureName, sysname,>]
GO 