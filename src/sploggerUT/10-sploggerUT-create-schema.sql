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

	Warning ! Before running this script you SHOULD remplace all the Template parameters :
 
		<SPLOGGER_DB, NVARCHAR, SPLogger> : SPLogger dedicated database
*/

USE [<SPLOGGER_DB, NVARCHAR, SPLogger>]
GO

-- Create database roles
CREATE ROLE [sploggerUT_user] AUTHORIZATION [dbo]
GO

CREATE ROLE [sploggerUT_admin] AUTHORIZATION [dbo]
GO

-- Create database schema for public accessible objects
CREATE SCHEMA [sploggerUT] AUTHORIZATION [dbo]
GO

-- Grant rights for [splogger_user] (caller) role
GRANT EXECUTE, SELECT ON SCHEMA::sploggerUT TO [sploggerUT_user]
GO

-- The Role Unit Test can also execute Logger SPs
GRANT EXECUTE ON SCHEMA::splogger TO [sploggerUT_user]
GO

-- Grant rights for [splogger_admin] role
-- Admin can only manage the history table
GRANT SELECT, DELETE ON SCHEMA::sploggerUT TO [sploggerUT_admin]
GO

