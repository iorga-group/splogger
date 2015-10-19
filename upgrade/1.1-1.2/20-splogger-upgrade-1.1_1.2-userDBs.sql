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

	UPGRADING FROM SPLogger 1.1 to 1.2 (for each user databases)

	=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

	Warning ! Before running this script you SHOULD remplace all the Template parameters :
 
 		<USER_DB, NVARCHAR, > : User database name where to create user side SPLogger schema and synonyms
		<USER_SCHEMA, NVARCHAR, splogger> : User side SPLogger schema
		<SPLOGGER_DB, NVARCHAR, SPLogger> : SPLogger dedicated database

*/

USE [<USER_DB, NVARCHAR, >]
GO

DROP SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[AddSQLSelectTrace]
DROP SYNONYM [<USER_SCHEMA, NVARCHAR, splogger>].[AddSQLTableTrace]
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
