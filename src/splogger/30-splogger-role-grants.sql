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
		<CLIENT_CONN,,> : SQL Server connexion to map and grant to SPLogger 
		<IS_ADMIN,BIT,0> : Should be granted as SPLogger Admin

*/

USE [<SPLOGGER_DB, NVARCHAR, SPLogger>]
GO

CREATE USER [<CLIENT_CONN,,>_user] FOR LOGIN [<CLIENT_CONN,,>]
GO

ALTER USER [<CLIENT_CONN,,>_user] WITH DEFAULT_SCHEMA=[splogger]
GO

EXEC sp_addrolemember N'splogger_user', N'<CLIENT_CONN,,>_user'
GO

IF <IS_ADMIN,BIT,0> = 1
	EXEC sp_addrolemember N'splogger_admin', N'<CLIENT_CONN,,>_user'
GO