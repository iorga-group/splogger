/*
	Use the Specify Values for Template Parameters 
	command (Ctrl-Shift-M) to fill in the parameter 
	values below.
*/
BEGIN 
	/**
		<UT-Description,,>
	 */
	SET NOCOUNT ON

	IF @@TRANCOUNT > 0
	BEGIN
		-- To garantie that test data inserted for the UT will be roolbacked after execution
		-- no transaction should be in progress before start
		RAISERROR( N'sploggerUT - Unit Test can NOT be nested inside a running transaction.', 16, 0 )	
	END

	-- Creating the UT object
	DECLARE @UTester XML = sploggerUT.StartUnitTest('<UT-Name,,>', '<UT-Description,,>')

	BEGIN TRY
		DECLARE @retVal INT

		/**************************
		 * Prepare and execute SP 
		 **************************/

		-- Starting the UT dedicated transaction
		BEGIN TRANSACTION
		
		-- If needed, you can insert, here, some test datas

		

		-- Executing the SP in UT mode
		EXEC @retVal = [<UT-SP-schema,,>].[<UT-SP-Name,,>] <UT-SP-Params,,>, @UTester OUT

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
