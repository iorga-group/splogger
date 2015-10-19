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

GRANT SELECT ON [sploggerUT].[UnitTestHistory] TO [public]
GO

GRANT DELETE ON [sploggerUT].[UnitTestHistory] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT INSERT ON [sploggerUT].[UnitTestHistory] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT SELECT ON [sploggerUT].[UnitTestHistory] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT UPDATE ON [sploggerUT].[UnitTestHistory] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GO

GRANT EXECUTE ON [sploggerUT].[AssertEquals] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [sploggerUT].[AssertNotEquals] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [sploggerUT].[AssertFalse] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [sploggerUT].[AssertTrue] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GO

GRANT EXECUTE ON [sploggerUT].[CheckUnitTestInTransaction] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GO

GRANT EXECUTE ON [sploggerUT].[StartUnitTest] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [sploggerUT].[SaveUnitTest] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GO

GRANT EXECUTE ON [sploggerUT].[SetDateTimeValue] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [sploggerUT].[SetDateValue] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [sploggerUT].[SetFloatValue] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [sploggerUT].[SetIntValue] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [sploggerUT].[SetNVarcharValue] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [sploggerUT].[SetSqlSelectValue] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GRANT EXECUTE ON [sploggerUT].[SetXmlValue] TO [<SPLOGGER_ROLE, NVARCHAR, SPLoggerRole>]
GO