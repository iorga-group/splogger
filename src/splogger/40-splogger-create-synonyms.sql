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
		<USER_SCHEMA, NVARCHAR, splogger> : User side SPLogger schema
		<USER_SCHEMA_OWNER, NVARCHAR, dbo> : User side SPLogger schema owner
		<SPLOGGER_DB, NVARCHAR, SPLogger> : SPLogger dedicated database

 */

USE [<USER_DB, NVARCHAR, >]
GO

CREATE SCHEMA [<USER_SCHEMA, NVARCHAR, splogger>] AUTHORIZATION [<USER_SCHEMA_OWNER, NVARCHAR, dbo>]
GO

CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[About] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[About]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[StartLog] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[StartLog]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[AddEvent] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[AddEvent]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[NewEvent_Warning] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[NewEvent_Warning]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[NewEvent_Info] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[NewEvent_Info]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[NewEvent_For_SqlError] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[NewEvent_For_SqlError]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[NewEvent_Error] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[NewEvent_Error]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[NewEvent_Debug] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[NewEvent_Debug]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[FinishLog] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[FinishLog]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[AddParam] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[AddParam]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[AddParam_DateTime] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[AddParam_DateTime]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[AddParam_Xml] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[AddParam_Xml]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[AddParam_XmlAsCDATA] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[AddParam_XmlAsCDATA]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[AddParam_GUID] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[AddParam_GUID]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[GetRunningLevel] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[GetRunningLevel]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[AddDebugTrace] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[AddDebugTrace]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[SetExpectedMaxDuration] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[SetExpectedMaxDuration]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[StartTGroup] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[StartTGroup]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[FinishTGroup] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[FinishTGroup]
GO

--
-- Creating Proxy procedure to SPLogger SQL trace procedure
--

CREATE PROCEDURE [<USER_SCHEMA, NVARCHAR, splogger>].AddSQLSelectTrace @pLogger XML OUT, @pSelectSQL NVARCHAR(MAX), @pLogLevel INT = 0                                    
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
        @param   pLogLevel   INT (default 0=DEBUG)   The log level of the Event
        
        Important:
           * The level of the event to create is compared to the current log level of the targeted Logger to prevent an unecessary query execution.
           * Only SELECT statement are allowed
     */
	DECLARE @dbName NVARCHAR(128) = DB_NAME()
    EXEC [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[AddSQLSelectTrace] @pLogger OUT, @pSelectSQL, @pLogLevel, @dbName    
END
go


CREATE PROCEDURE [<USER_SCHEMA, NVARCHAR, splogger>].AddSQLTableTrace @pLogger XML OUT, @pSQLTableName NVARCHAR(128), @pLogLevel INT = 0, @pRowLimit INT = 0
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
        @param   pLogLevel   INT (default 0=DEBUG)   The log level of the Event
        @param   pRowLimit   INT (default to 0=ALL rows)   Limit number of rows to return (TOP(x))        
        
        @see   AddSQLSelectTrace
     */
    DECLARE @dbName NVARCHAR(128) = DB_NAME()
    EXEC [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[AddSQLTableTrace] @pLogger OUT, @pSQLTableName, @pLogLevel, @pRowLimit, @dbName    
END
go
