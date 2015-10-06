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

	UPGRADING FROM SPLogger 1.0 to 1.1 (for each user databases)

	=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

	Warning ! Before running this script you SHOULD remplace all the Template parameters :
 
 		<USER_DB, NVARCHAR, > : User database name where to create user side SPLogger schema and synonyms
		<USER_SCHEMA, NVARCHAR, splogger> : User side SPLogger schema
		<SPLOGGER_DB, NVARCHAR, SPLogger> : SPLogger dedicated database

*/

USE [<USER_DB, NVARCHAR, >]
GO

CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[StartTGroup] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[StartTGroup]
CREATE SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[FinishTGroup] FOR [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[FinishTGroup]

