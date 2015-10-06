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

if exists (select 1 from sysobjects where  id = object_id('splogger.SPTest_SubLogger') and type in ('P','PC'))
   drop procedure splogger.SPTest_SubLogger
go

CREATE PROCEDURE splogger.SPTest_SubLogger @pParentLog XML OUT, @pParam1 INT, @pParam2 DATE, @pLogLevel INT = 0
AS 
BEGIN
	DECLARE @logEvent XML
	DECLARE @pLogger XML = splogger.StartLog ( @pParentLog, 'SPTest_SubLogger', @pLogLevel, 'Testing SPLogger sub-logger functionnalities')
		EXEC splogger.AddParam @pLogger OUT, '@pParam1', @pParam1
		EXEC splogger.AddParam_DateTime @pLogger OUT, '@pParam2', @pParam2

	-- Adding an INFO event
	SET @logEvent = splogger.NewEvent_Info ( 'This is an information event without param')
	EXEC splogger.AddEvent @pLogger OUT, @logEvent

	-- Personnalised query
	DECLARE @sqlQ NVARCHAR(2000) = 'SELECT * FROM #spLoggerTest WHERE Id % '+CONVERT(VARCHAR, @pParam1)+' = 0 ORDER BY Country'	
	EXEC splogger.AddSQLSelectTrace @pLogger OUT, @sqlQ, 1

	-- Finishing logger
	EXEC splogger.FinishLog @pLogger, @pParentLog OUT
END
GO

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

if exists (select 1 from sysobjects where  id = object_id('splogger.SPTest_SQLException') and type in ('P','PC'))
   drop procedure splogger.SPTest_SQLException
go

CREATE PROCEDURE splogger.SPTest_SQLException @pParentLog XML OUT, @pParam1 INT, @pParam2 INT, @pLogLevel INT = 3
AS 
BEGIN
	DECLARE @logEvent XML
	DECLARE @pLogger XML = splogger.StartLog ( @pParentLog, 'SPTest_SQLException', @pLogLevel, 'Testing SPLogger SQL exception management')

	SET @logEvent = splogger.NewEvent_Warning ( 100, 'This is going to fail if @pParam2 equals 0...')
		EXEC splogger.AddParam @logEvent OUT, '@pParam2', @pParam2
	EXEC splogger.AddEvent @pLogger OUT, @logEvent

	BEGIN TRY
		DECLARE @value DECIMAL
		SET @value = @pParam1 / @pParam2
		SET @logEvent = splogger.NewEvent_Debug ( '@pParam1 / pParam2 = ....')
			EXEC splogger.AddParam @logEvent OUT, '@value', @value
		EXEC splogger.AddEvent @pLogger OUT, @logEvent	
	END TRY
	BEGIN CATCH
		SET @logEvent = splogger.NewEvent_For_SqlError ( 3 )	
			EXEC splogger.AddParam @logEvent OUT, '@pParam1', @pParam1
			EXEC splogger.AddParam @logEvent OUT, '@pParam2', @pParam2
		EXEC splogger.AddEvent @pLogger OUT, @logEvent	
	END CATCH
	
	-- Finishing logger
	EXEC splogger.FinishLog @pLogger, @pParentLog OUT
END
GO

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

if exists (select 1 from sysobjects where  id = object_id('splogger.SPTest') and type in ('P','PC'))
   drop procedure splogger.SPTest
go

CREATE PROCEDURE splogger.SPTest @pLogLevel INT = 1
AS
BEGIN
	SELECT splogger.About()

	BEGIN TRY
		DECLARE @now DATETIME = GETDATE()
		DECLARE @xmldata XML = '<vehicles><vehicle maker="BMW" hp="321">Z3 Roadster M</vehicle><vehicle maker="Peugeot" hp="137">307 SW</vehicle></vehicles>'
		DECLARE @guid UNIQUEIDENTIFIER = NEWID()
		DECLARE @logEvent XML

		BEGIN TRANSACTION

		-- Creating a main Logger
		DECLARE @logger XML = splogger.StartLog ( null, 'SPLogger Main', @pLogLevel, 'Testing SPLogger functionnalities')
			EXEC splogger.SetExpectedMaxDuration @logger OUT, 350, 'MS'
			EXEC splogger.AddParam @logger OUT, 'SPID', @@SPID
			EXEC splogger.AddParam_DateTime @logger OUT, 'Now', @now
			EXEC splogger.AddParam_GUID @logger OUT, 'GUID', @guid
	
		EXEC splogger.StartTGroup @logger OUT, 'Group 1'

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

		EXEC splogger.FinishTGroup @logger OUT	-- Ending Group 1

		SET @logEvent = splogger.NewEvent_Info ( 'This is an information event outside of a timed-group')
		EXEC splogger.AddEvent @logger OUT, @logEvent

		EXEC splogger.StartTGroup @logger OUT, 'Group 2'

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

		EXEC splogger.StartTGroup @logger OUT, 'Group 2.1'

		-- Personnalised query
		EXEC splogger.AddSQLSelectTrace @logger OUT, 'SELECT * FROM #spLoggerTest ORDER BY Country'

		-- Simple table query
		EXEC splogger.AddSQLTableTrace @logger OUT, '#spLoggerTest', 2, 3

		EXEC splogger.FinishTGroup @logger OUT	-- Ending Group 2.1

		EXEC splogger.StartTGroup @logger OUT, 'Group 2.2'

		-- Calling sub procedure with their own logger. Creates sub-loggers
		DECLARE @i INT = 1
		WHILE @i < 4
		BEGIN
			SET @now = GETDATE()
			EXEC splogger.SPTest_SubLogger @logger OUT, @i, @now, 3		-- This specified log level (3) will be override by main logger log level
			SET @i = @i + 1
		END

		EXEC splogger.FinishTGroup @logger OUT  -- Ending Group 2.2

		EXEC splogger.FinishTGroup @logger OUT  -- Ending Group 2

		-- SQL Exception management
		EXEC splogger.SPTest_SQLException @logger OUT, 254, 3		

		COMMIT
	END TRY
	BEGIN CATCH
		SET @logEvent = splogger.NewEvent_For_SqlError ( 3 )	
		EXEC splogger.AddEvent @logger OUT, @logEvent	
		ROLLBACK
	END CATCH

	EXEC splogger.AddDebugTrace @logger OUT, 'What is the XML value', null, null, @xmldata

	-- Cloture du logger principal après fin de la transaction principale			
	EXEC splogger.FinishLog @logger

	-- Affichage
	SELECT * from splogger.LogHistory
	ORDER BY Id DESC
END
GO

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

EXEC splogger.SPTest @pLogLevel = 0
GO

EXEC splogger.SPTest_SQLException NULL, 58, 0
GO

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- Cleaning task
if exists (select 1 from sysobjects where  id = object_id('splogger.SPTest_SubLogger') and type in ('P','PC'))
   drop procedure splogger.SPTest_SubLogger
go

if exists (select 1 from sysobjects where  id = object_id('splogger.SPTest_SQLException') and type in ('P','PC'))
   drop procedure splogger.SPTest_SQLException
go

if exists (select 1 from sysobjects where  id = object_id('splogger.SPTest') and type in ('P','PC'))
   drop procedure splogger.SPTest
go