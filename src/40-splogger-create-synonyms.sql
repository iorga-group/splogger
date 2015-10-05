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
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[AddSQLSelectTrace] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[AddSQLSelectTrace]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[AddSQLTableTrace] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[AddSQLTableTrace]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[AddDebugTrace] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[AddDebugTrace]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[SetExpectedMaxDuration] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[SetExpectedMaxDuration]
GO
