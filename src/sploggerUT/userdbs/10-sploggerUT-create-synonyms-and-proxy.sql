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

	Warning ! Before running this script you SHOULD remplace all the Template parameters :
 
 		<USER_DB, NVARCHAR, > : User database name where to create user side SPLogger schema and synonyms
		<USER_SCHEMA, NVARCHAR, sploggerUT> : User side SPLoggerUT schema
		<USER_SCHEMA_OWNER, NVARCHAR, dbo> : User side SPLogger schema owner
		<SPLOGGER_DB, NVARCHAR, SPLogger> : SPLogger dedicated database

 */

USE [<USER_DB, NVARCHAR, >]
GO

-- Create database roles
CREATE ROLE [sploggerUT_user] AUTHORIZATION [<USER_SCHEMA_OWNER, NVARCHAR, dbo>]
GO

-- UT role can use Logger proxies
EXEC sp_addrolemember N'splogger_user', N'sploggerUT_user'
GO

CREATE SCHEMA [<USER_SCHEMA, NVARCHAR, sploggerUT>] AUTHORIZATION [<USER_SCHEMA_OWNER, NVARCHAR, dbo>]
GO

-- Grant rights execute for [splogger_user] (caller) role 
-- This is used to allow Proxies
GRANT EXECUTE ON SCHEMA::[<USER_SCHEMA, NVARCHAR, sploggerUT>] TO [sploggerUT_user]
GO

--
-- Create synonyms
--
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, sploggerUT>].[UnitTestHistory] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[sploggerUT].[UnitTestHistory]
GO

CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, sploggerUT>].[AssertEquals] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[sploggerUT].[AssertEquals]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, sploggerUT>].[AssertNotEquals] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[sploggerUT].[AssertNotEquals]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, sploggerUT>].[AssertTrue] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[sploggerUT].[AssertTrue]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, sploggerUT>].[AssertFalse] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[sploggerUT].[AssertFalse]
GO

CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, sploggerUT>].[StartUnitTest] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[sploggerUT].[StartUnitTest]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, sploggerUT>].[SaveUnitTest] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[sploggerUT].[SaveUnitTest]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, sploggerUT>].[CheckUnitTestInTransaction] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[sploggerUT].[CheckUnitTestInTransaction]
GO

CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, sploggerUT>].[SetDateTimeValue] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[sploggerUT].[SetDateTimeValue]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, sploggerUT>].[SetDateValue] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[sploggerUT].[SetDateValue]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, sploggerUT>].[SetFloatValue] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[sploggerUT].[SetFloatValue]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, sploggerUT>].[SetIntValue] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[sploggerUT].[SetIntValue]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, sploggerUT>].[SetNVarcharValue] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[sploggerUT].[SetNVarcharValue]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, sploggerUT>].[SetXmlValue] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[sploggerUT].[SetXmlValue]
GO

--
-- Creating Proxy procedure to SPLoggerUT SetSqlSelectValue procedure
--

CREATE PROCEDURE [<USER_SCHEMA, NVARCHAR, sploggerUT>].SetSqlSelectValue @pUTest XML OUT, @pUTKey NVARCHAR(128), @pDescription NVARCHAR(255), @pSelectSQL NVARCHAR(MAX)
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
        
        This method is used to save the RESULTSET of a SQL Select statement to allow "Assert" statements to be call on it.        
        An attribute "rowcount" is automatically added to the "run-value"
        This method is only active during Unit Testing.

		Before running the query, {{database}} markers will be replace by the current database name
        
        @param   pUTest   XML OUT  A reference to the Unit Test
        @param   pUTKey   NVARCHAR(128)   Identifiant of the value
        @param   pDescription   NVARCHAR(255)   Description of the contain of this value 
        @param   pSelectSQL   NVARCHAR(MAX)   The SELECT statement to execute and save the RESULTSET
        @param   pDbName   NVARCHAR(128)  (default=NULL)   Current database name (hosting the SP). If NULL, that means SPLogger is dedicated to the current database (created inside) 
        
        Important: Only SELECT statement are allowed
     */
	DECLARE @dbName NVARCHAR(128) = DB_NAME()
    EXEC [<SPLOGGER_DB, NVARCHAR, SPLoggerUT>].[sploggerUT].[SetSqlSelectValue] @pUTest OUT, @pUTKey, @pDescription, @pSelectSQL, @dbName    
END
go

