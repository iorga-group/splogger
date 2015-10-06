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
  		
		<SPLOGGER_DB, NVARCHAR, SPLogger> : SPLogger dedicated database
		<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole> : SPLogger dedicated role

*/

USE [<SPLOGGER_DB, NVARCHAR, SPLogger>]
GO

GRANT SELECT ON [splogger].[LogHistory] TO [public]
GO

CREATE ROLE [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>] AUTHORIZATION [dbo]
GO

GRANT DELETE ON [splogger].[LogHistory] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT INSERT ON [splogger].[LogHistory] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT SELECT ON [splogger].[LogHistory] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT UPDATE ON [splogger].[LogHistory] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GO

GRANT EXECUTE ON [splogger].[About] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[StartLog] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[NewEvent_Warning] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[NewEvent_Info] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[NewEvent_For_SqlError] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[NewEvent_Error] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[NewEvent_Debug] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
--GRANT EXECUTE ON [splogger].[_NewEvent] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[GetRunningLevel] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[FinishLog] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[SetExpectedMaxDuration] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[AddParam] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[AddParam_DateTime] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[AddParam_Xml] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[AddParam_GUID] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[AddParam_XmlAsCDATA] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[AddDebugTrace] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[AddEvent] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[AddSQLSelectTrace] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[AddSQLTableTrace] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]

GRANT EXECUTE ON [splogger].[StartTGroup] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [splogger].[FinishTGroup] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GO