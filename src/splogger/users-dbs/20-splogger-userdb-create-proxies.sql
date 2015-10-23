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

--
-- Creating Proxy procedure to SPLogger SQL trace procedure
--

if exists (select 1
          from sysobjects
          where  id = object_id('<USER_SCHEMA, NVARCHAR, splogger>.AddSQLSelectTrace')
          and type in ('P','PC'))
   drop procedure [<USER_SCHEMA, NVARCHAR, splogger>].AddSQLSelectTrace
go


CREATE PROCEDURE [<USER_SCHEMA, NVARCHAR, splogger>].AddSQLSelectTrace @pLogger XML OUT, @pSelectSQL NVARCHAR(MAX), @pDescription NVARCHAR(255) = NULL, @pLogLevel INT = 0
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
        @param   pDescription   NVARCHAR(255)  (default NULL)   description of the logged value(s)
        @param   pLogLevel   INT (default 0=DEBUG)   The log level of the Event
        @param   pDbName   NVARCHAR(128)  (default=NULL)   current database name (hosting the SP). If NULL, that means SPLogger is dedicated to the current database (created inside) 
        
        Important:
           * The level of the event to create is compared to the current log level of the targeted Logger to prevent an unecessary query execution.
           * Only SELECT statement are allowed
     */
	DECLARE @dbName NVARCHAR(128) = DB_NAME()
    EXEC [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[AddSQLSelectTrace] @pLogger OUT, @pSelectSQL, @pDescription, @pLogLevel, @dbName    
END
go


if exists (select 1
          from sysobjects
          where  id = object_id('<USER_SCHEMA, NVARCHAR, splogger>.AddSQLTableTrace')
          and type in ('P','PC'))
   drop procedure [<USER_SCHEMA, NVARCHAR, splogger>].AddSQLTableTrace
go

CREATE PROCEDURE [<USER_SCHEMA, NVARCHAR, splogger>].AddSQLTableTrace @pLogger XML OUT, @pSQLTableName NVARCHAR(128), @pDescription NVARCHAR(255) = NULL, @pLogLevel INT = 0, @pRowLimit INT = 0
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
        @param   pDescription   NVARCHAR(255)  (default NULL)   description of the logged value(s)
        @param   pLogLevel   INT (default 0=DEBUG)   The log level of the Event
        @param   pRowLimit   INT (default to 0=ALL rows)   Limit number of rows to return (TOP(x))
        @param   pDbName   NVARCHAR(128)  (default=NULL)   current database name (hosting the SP). If NULL, that means SPLogger is dedicated to the current database (created inside)         
        
        @see   AddSQLSelectTrace
     */
    DECLARE @dbName NVARCHAR(128) = DB_NAME()
    EXEC [<SPLOGGER_DB, NVARCHAR, SPLogger>].[splogger].[AddSQLTableTrace] @pLogger OUT, @pSQLTableName, @pDescription, @pLogLevel, @pRowLimit, @dbName    
END
go

if exists (select 1
          from sysobjects
          where  id = object_id('<USER_SCHEMA, NVARCHAR, splogger>.FinishLog')
          and type in ('P','PC'))
   drop procedure [<USER_SCHEMA, NVARCHAR, splogger>].FinishLog
go

CREATE PROCEDURE [<USER_SCHEMA, NVARCHAR, splogger>].FinishLog @pLogger XML, @pParentLogger XML = NULL OUT, @pAlwaysSave BIT = 1
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
        
        Logger or SubLogger finalisation.
        Task duration (between StartLog and FinishLog) is computed and added as attribute to the log/sub-log element.
        
        @param   pLogger   XML   Logger to finalise
        @param   pParentLogger   XML OUT   (default to NULL)  Parent logger if any. Be carefull this parameter SHOULD be passed as OUTPUT
        @param   pDbName   NVARCHAR(128) (default to DB_NAME())  User database name (hosting the proxy SP). If NULL, that means SPLogger is dedicated to the current database (all schema objects are created inside user database) 
        @param   pAlwaysSave   BIT   (default 1)   If to level looger, should the log be always save in database (default), or only if it reached the level log defined. "false" is usefull for interactive calls, "true" is usefull for planned batches
        
        @return   ...   
        
           - if logger is disabled (log level = -1), the return value is 0 (zero)
        
           - If it's a main logger, 
              if level_max don't reach the log level minimal, the return value is 0 (zero)
              else if SP finished without ERROR (level_max < 3), the return value is the Id of the inserted LogHistory row. 
              else if SP finished in ERROR (level_max = 3), the return value is "- Id" (negative value) of the inserted LogHistory row. 
        
              It can be use in caller app to load task log information.
        
           - If it's a sub-logger, the return value is the "level_max" reached. This return value SHOULD be return by SP and checked in caller SP
        
        @see   StartLog
     */
	 DECLARE @dbName NVARCHAR(128) = DB_NAME()
	 EXEC [<SPLOGGER_DB, NVARCHAR, SPLogger>].splogger.FinishLog @pLogger, @pParentLogger OUT, @pAlwaysSave, @dbName    
END
GO