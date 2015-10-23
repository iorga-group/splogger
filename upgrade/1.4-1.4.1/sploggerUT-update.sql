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
          where  id = object_id('sploggerUT.SaveUnitTest')
          and type in ('P','PC'))
   drop procedure sploggerUT.SaveUnitTest
go


CREATE PROCEDURE sploggerUT.SaveUnitTest @pUTest XML, @pDbName NVARCHAR(128) = NULL
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
        
        Save the result of the Unit Test into the dedicated database table
        
        @param   pUTest   XML   Unit test to save
        @param   pDbName   NVARCHAR(128) (default to DB_NAME())  User database name (hosting the proxy SP). If NULL, that means SPLogger is dedicated to the current database (all schema objects are created inside user database) 
        
        @see   StartUnitTest
     */
    SET NOCOUNT ON
    
    IF @pUTest.exist('(/unit-test[1])') = 0
    BEGIN
        RAISERROR ( N'%s - sploggerUT.SaveUnitTest - Root element is not an Unit Test.', 16, 0) WITH NOWAIT            
        RETURN
    END
    
    BEGIN TRY          
        DECLARE @isSuccessfull BIT
        DECLARE @runAt DATETIME = @pUTest.value('(/unit-test[1]/@start_time)', 'DATETIME')        
        DECLARE @level_max INT = @pUTest.value('(/unit-test[1]/@level_max)', 'INT') 
        
        -- Checking if Unit test excetion was done without error (at UT level)
        IF @level_max > 2
        BEGIN
            SET @pUTest.modify('replace value of (/unit-test[1]/@successfull) with ("0")')   
            SET @isSuccessfull = 0
        END    
        ELSE
        BEGIN                                  
            SET @isSuccessfull = @pUTest.value('(/unit-test[1]/@successfull)', 'BIT') 
        END
                                             
        -- Remove unused attributes                                             
        SET @pUTest.modify('delete /unit-test[1]/@start_time')
        SET @pUTest.modify('delete /unit-test[1]/@level_max')                                             
        SET @pUTest.modify('delete /unit-test[1]/@level') 
                                             
        -- Auto-detection system for timed-group support - Remove for ended log
        IF @pUTest.exist('(/unit-test[1]/@container)') = 1
        BEGIN
            SET @pUTest.modify('delete /unit-test[1]/@container')
        END             
            
        -- Delete all checked assertions               
        SET @pUTest.modify('delete /unit-test[1]/run-values/run-value[@checked="1"]')  
        IF @pUTest.exist('(/unit-test[1]/run-values/run-value)') = 0
        BEGIN
            -- If no more unchecked run values, delete their container
            SET @pUTest.modify('delete /unit-test[1]/run-values')  
        END
                       
        -- Database insertion of a new LogHistory record            
		DECLARE @tranCount INT = @@TRANCOUNT
    
        IF @tranCount > 0
        BEGIN
            -- Checks if any transaction is in progress. 
            -- If this is the cas, warns that the log record will be lost if the current transaction will be rollbacked.
            DECLARE @tranWarnEvent XML = splogger.NewEvent_Warning( -100, 'Be carefull. this Unit Test has been saved in UnittestHistory inside an active transaction. This log COULD BE LOST in case of a ROLLBACK in the coming transaction activity.')
            EXEC splogger.AddParam @tranWarnEvent OUT, '@@TRANCOUNT', @tranCount 
            EXEC splogger.AddEvent @pUTest OUT, @tranWarnEvent                                             
        END
    
        -- Database insertion
        DECLARE @UTKey NVARCHAR(128) = @pUTest.value('(/unit-test[1]/@utkey)', 'NVARCHAR(128)')         
        
        INSERT INTO sploggerUT.UnittestHistory( DbName, UnitTestKey, RunAt, IsSuccessfull, UnitTestDetail )
            VALUES ( ISNULL(@pDbName, DB_NAME()), @UTKey, @runAt, @isSuccessfull, @pUTest )
        
        RETURN @@IDENTITY                
    END TRY
    BEGIN CATCH
        -- Raise error
        DECLARE @ts VARCHAR(20) = CONVERT( VARCHAR(20), GETUTCDATE(), 116 )
        DECLARE @errNum INT = ERROR_NUMBER()
        DECLARE @errMsg NVARCHAR(2048) = ERROR_MESSAGE()
        RAISERROR ( N'%s - sploggerUT.SaveUnitTest - Error #%d : %s', 16, 0, @ts, @errNum, @errMsg ) WITH NOWAIT        
    END CATCH        
END
go

-- drop old tagging synonym
DROP synonym [sploggerUT].[UnitTestHistory 1.4]
GO

-- Creating tagging synonym
CREATE synonym [sploggerUT].[UnitTestHistory 1.4.1] for [sploggerUT].[UnitTestHistory]
GO
