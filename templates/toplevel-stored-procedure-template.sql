/*
	Use the Specify Values for Template Parameters 
	command (Ctrl-Shift-M) to fill in the parameter 
	values below.
*/

IF EXISTS (SELECT 1 FROM sysobjects WHERE id = object_id('<ProcedureName, sysname, ProcedureName>') AND type IN ('P','PC'))
   DROP PROCEDURE <ProcedureName, sysname, ProcedureName>
GO

CREATE PROCEDURE [<SchemaName, sysname, dbo>].[<ProcedureName, sysname,>] 
		-- Your parameters
		<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>,		
		@pLogLevel INT = 2	-- SPLogger: Warn level by default
AS
BEGIN
	/**		
		Author:		<Author,,Name>
		Create date: <Create Date,,>
		Description:	<Description,,>
	 */
	SET NOCOUNT ON
	DECLARE @retVal INT 
	DECLARE @tranCount INT = @@TRANCOUNT

	-- Initialisation du Log
    DECLARE @logEvent XML
	DECLARE @logger XML = splogger.StartLog( null, '<ProcedureName, sysname,>', @pLogLevel, '<Description,,>')
		-- If needed: EXEC splogger.SetExpectedMaxDuration @logger OUT, -1
		EXEC splogger.AddParam @logger OUT, '@tranCount', @tranCount
		EXEC splogger.AddParam @logger OUT, '<@Param1, sysname, @p1>', <@Param1, sysname, @p1>

	BEGIN TRY
		IF @trancount = 0
			BEGIN TRANSACTION
		ELSE
			SAVE TRANSACTION "<Save_Point_Name, VARCHAR, SavePoint_000>"    
		
		--=-=-=-=-= Start	



		--=-=-=-=-= End

		-- Exit. SHOULD BE used in GOTO in place of any RETURN
		label_exit:   
   
		IF @trancount = 0
			COMMIT       
            
		-- Close logging session. Save log in database
		-- and return the Log Id or "- Id" if level_max > 2
        EXEC @retVal = splogger.FinishLog @logger
		RETURN @retVal
	END TRY
	BEGIN CATCH
		-- In case of any exception
		-- Auto log all exception data as an Error		
		DECLARE @xstate INT = XACT_STATE()                        		

		SET @logEvent = splogger.NewEvent_For_SqlError(3)	
			EXEC splogger.AddEvent @logger OUT, @logEvent

        IF @xstate = 1
        BEGIN
			IF @trancount = 0       
				-- The transaction was initiated here and it's valid. 
				ROLLBACK
			ELSE 
				-- The transaction wasn't initialised here.
				ROLLBACK TRANSACTION "<Save_Point_Name, VARCHAR, SavePoint_000>"
        END
        ELSE IF @xstate = -1     
		BEGIN
			-- Invalid transaction.
			-- Only one think to do...
			ROLLBACK
		END
		       
        -- Now the Rollback is done, 
		-- so finish the logger and save it to database 
		-- before rethrow/raiserror
        EXEC @retVal = splogger.FinishLog @logger
        
		IF @trancount > 0
			-- A transaction was initied outside
			-- so rethrow/raise
			-- 2012 and above rethrow the exception
			-- Under SQLServer 2008/2008R2 you should use RAISERROR()
			;THROW  
		ELSE
			-- No transaction was initied outside
			-- so return "- id" meaning error 
			-- and allow loading of log detail 
			RETURN @retVal
        		
	END CATCH    
END
GO
