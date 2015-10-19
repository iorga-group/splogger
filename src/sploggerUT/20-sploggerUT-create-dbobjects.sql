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
 */

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT.AssertEquals')
          and type in ('P','PC'))
   drop procedure sploggerUT.AssertEquals
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT.AssertFalse')
          and type in ('P','PC'))
   drop procedure sploggerUT.AssertFalse
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT.AssertNotEquals')
          and type in ('P','PC'))
   drop procedure sploggerUT.AssertNotEquals
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT._AssertENE')
          and type in ('P','PC'))
   drop procedure sploggerUT._AssertENE
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT.SetDateTimeValue')
          and type in ('P','PC'))
   drop procedure sploggerUT.SetDateTimeValue
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT.SetIntValue')
          and type in ('P','PC'))
   drop procedure sploggerUT.SetIntValue
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT.SetNVarcharValue')
          and type in ('P','PC'))
   drop procedure sploggerUT.SetNVarcharValue
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT.SetDateValue')
          and type in ('P','PC'))
   drop procedure sploggerUT.SetDateValue
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT.SetFloatValue')
          and type in ('P','PC'))
   drop procedure sploggerUT.SetFloatValue
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT._SetValue')
          and type in ('P','PC'))
   drop procedure sploggerUT._SetValue
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT.AssertTrue')
          and type in ('P','PC'))
   drop procedure sploggerUT.AssertTrue
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT.CheckUnitTestInTransaction')
          and type in ('P','PC'))
   drop procedure sploggerUT.CheckUnitTestInTransaction
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT.SaveUnitTest')
          and type in ('P','PC'))
   drop procedure sploggerUT.SaveUnitTest
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT.SetSqlSelectValue')
          and type in ('P','PC'))
   drop procedure sploggerUT.SetSqlSelectValue
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT.SetXmlValue')
          and type in ('P','PC'))
   drop procedure sploggerUT.SetXmlValue
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT.StartUnitTest')
          and type in ('IF', 'FN', 'TF'))
   drop function sploggerUT.StartUnitTest
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT._AddAssertResult')
          and type in ('P','PC'))
   drop procedure sploggerUT._AddAssertResult
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT._ComputeGetValue')
          and type in ('P','PC'))
   drop procedure sploggerUT._ComputeGetValue
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT._GetDateTimeValue')
          and type in ('IF', 'FN', 'TF'))
   drop function sploggerUT._GetDateTimeValue
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT._GetDateValue')
          and type in ('IF', 'FN', 'TF'))
   drop function sploggerUT._GetDateValue
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT._GetFloatValue')
          and type in ('IF', 'FN', 'TF'))
   drop function sploggerUT._GetFloatValue
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT._GetIntValue')
          and type in ('IF', 'FN', 'TF'))
   drop function sploggerUT._GetIntValue
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT._GetNVarcharValue')
          and type in ('IF', 'FN', 'TF'))
   drop function sploggerUT._GetNVarcharValue
go

if exists (select 1
          from sysobjects
          where  id = object_id('sploggerUT._ParseExpr')
          and type in ('P','PC'))
   drop procedure sploggerUT._ParseExpr
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('sploggerUT.UnitTestHistory')
            and   name  = 'IDX_2_4D'
            and   indid > 0
            and   indid < 255)
   drop index sploggerUT.UnitTestHistory.IDX_2_4D
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('sploggerUT.UnitTestHistory')
            and   name  = 'IDX_2_3_4D'
            and   indid > 0
            and   indid < 255)
   drop index sploggerUT.UnitTestHistory.IDX_2_3_4D
go

if exists (select 1
            from  sysobjects
           where  id = object_id('sploggerUT.UnitTestHistory')
            and   type = 'U')
   drop table sploggerUT.UnitTestHistory
go

create table sploggerUT.UnitTestHistory (
   Id                   int                  identity,
   DbName               nvarchar(128)        not null,
   UnitTestKey          nvarchar(128)        not null,
   RunAt                smalldatetime        not null,
   IsSuccessfull        bit                  not null,
   UnitTestDetail       xml                  not null,
   constraint PK_UNITTESTHISTORY primary key (Id)
)
go

create index IDX_2_3_4D on sploggerUT.UnitTestHistory (
DbName ASC,
UnitTestKey ASC,
RunAt DESC
)
go

create index IDX_2_4D on sploggerUT.UnitTestHistory (
DbName ASC,
RunAt DESC
)
go


create procedure sploggerUT._ParseExpr @pUTest XML OUT, @pExpression NVARCHAR(MAX), @pParsedExpression NVARCHAR(MAX) OUT, @pFillValues BIT = 0
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
        =
        = Internal use only. Use suffixed procedures
        =
        
        Prepared an expression by replacing access to value templates by the correct "splogger._GetxxxValue" call.
        
        @param   pUTest   XML OUT  A reference to the Unit Test
        @param   pExpression NVARCHAR(MAX)   Input expression to be parsed to replace templates by "splogger._GetxxxValue" calls
        @param   pParsedExpression   NVARCHAR(MAX) OUT   Expression where all templates have been replaced and ready to by executed
        @param   pFillValues BIT (default=0)   If equals to 1 (true), the templates are not replace but their evaluated value are inserted in them. Allowing comprehension of the failed status.
        
     */    
	DECLARE @token NVARCHAR(255)
    DECLARE @utKey NVARCHAR(128)
    DECLARE @rootUtKey NVARCHAR(128)
    DECLARE @valueDataType NVARCHAR(20)
	DECLARE @posStart INT
	DECLARE @posEnd INT
	DECLARE @tokenDTpos INT
    
    SET @pParsedExpression = ''
    SET @posStart = CHARINDEX('{{', @pExpression)

	WHILE @posStart > 0
	BEGIN		
		-- Write outside token string part
		SET @pParsedExpression = @pParsedExpression + SUBSTRING(@pExpression, 1, @posStart - 1)
		
		-- Search token end
		SET @posEnd = CHARINDEX('}}', @pExpression)

		-- Token parsing and transformation
		SET @token = SUBSTRING(@pExpression, @posStart + 2, @posEnd - @posStart - 2)		
		SET @tokenDTpos = CHARINDEX(':', @token)

		IF @tokenDTpos = 0
		BEGIN
            -- No Data Type specified, user the declared one
            SET @utKey = @token
            -- Get rootKey
            SET @tokenDTpos = CHARINDEX('#', @utKey)
            IF @tokenDTpos > 0
                SET @rootUtKey = SUBSTRING(@utKey, 1, @tokenDTpos - 1)
            ELSE
                SET @rootUtKey = @utKey
                			
            SET @valueDataType = @pUTest.value('(/unit-test[1]/run-values/run-value[@key=sql:variable("@rootUtKey")]/@datatype)[1]', 'NVARCHAR(20)')   
            IF @valueDataType = 'resultset'
            BEGIN
                IF LOWER(SUBSTRING(@utKey, @tokenDTpos + 1, 128)) = 'rowcount' 
                    SET @valueDataType = 'int'                           
                ELSE
                    SET @valueDataType = 'nvarchar'                           
            END
		END
		ELSE
		BEGIN
            -- A Data Type is specified, use dedicated function
            SET @utKey = SUBSTRING(@token, 1, @tokenDTpos - 1)
            SET @valueDataType = SUBSTRING(@token, @tokenDTpos + 1, LEN(@token) - @tokenDTpos)
            
            -- Get rootKey
            SET @tokenDTpos = CHARINDEX('#', @utKey)
            IF @tokenDTpos > 0
                SET @rootUtKey = SUBSTRING(@utKey, 1, @tokenDTpos - 1)
            ELSE
                SET @rootUtKey = @utKey
		END
        
        -- Generate value access call
        IF @pFillValues = 0
        BEGIN			
		    SET @pParsedExpression = @pParsedExpression + 'sploggerUT._Get'+@valueDataType+'Value(@pUTest, '''+@utKey+''')'                        
            SET @pUTest.modify('replace value of (/unit-test[1]/run-values/run-value[@key=sql:variable("@rootUtKey")]/@checked)[1] with (1)') 
        END
        ELSE
        BEGIN
            SET @pParsedExpression = @pParsedExpression + '{{'+@utKey+':'+@valueDataType+'='+sploggerUT._GetNVarcharValue(@pUTest, @utKey)+'}}'
        END

		-- Search for the next token
		SET @pExpression = SUBSTRING(@pExpression, @posEnd + 2, LEN(@pExpression) - @posEnd)
		SET @posStart = CHARINDEX('{{', @pExpression)
	END

    -- Complete the expression
	IF LEN(@pExpression) > 0
		SET @pParsedExpression = @pParsedExpression + @pExpression    
END
go


CREATE PROCEDURE sploggerUT.AssertTrue @pUTest XML OUT, @pExpressionToVerify NVARCHAR(MAX), @pDescription NVARCHAR(255) = NULL  
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
        
        Ckeck if the result of an expression is TRUE.
        
        The @pExpressionToVerify can be any T-SQL expression resulting in a boolean value.
        To reference runtime saved values, a templating mecanism can be used.
        The supported format for the template are :
        
           {{<utkey>}} : return the value of the saved <utkey> in its declared datatype
           {{<utkey>:<target-datatype>}} : return the value of the saved <utkey> converted in the <target-datatype>
        
        For "resultset" value, additionnal templates are supported :
        
           {{<utkey>#rowcount}} : return the "rowcount" value for the "resultset" saved under <utkey>
           {{<utkey>#scalar:<target-datatype>}} : return the value of the first column of the first row in the "resultset" saved under <utkey> converted in the <target-datatype> (NVARCHAR by default)
           {{<utkey>#<row>,<col>:<target-datatype>}} : return the value of the <col>th column of the <row>th row in the "resultset" saved under <utkey> converted in the <target-datatype>  (NVARCHAR by default)
        
        @param   pUTest   XML OUT  a reference to the Unit Test
        @param   pExpressionToVerify   NVARCHAR(MAX)   the expression to evaluate and check. 
        @param   pDescription   NVARCHAR(255) (default=NULL)   description of the expression which replace the expression as description in assertion if defined
        
     */
    SET NOCOUNT ON
    
    DECLARE @assertRes XML
    DECLARE @expressionResult BIT 
    DECLARE @expressionInvalid BIT = 0
    DECLARE @parsedExpression NVARCHAR(MAX)
    DECLARE @expressionWithValue NVARCHAR(MAX) = NULL
    
    -- Evaluate the boolean expression
    BEGIN TRY
        -- Convert input expression to executable expression
        EXEC sploggerUT._ParseExpr @pUTest OUT, @pExpressionToVerify, @parsedExpression OUT
        -- SQL execution of the prepared expression
        DECLARE @sSQL NVARCHAR(max) = N'IF ('+@parsedExpression+') SET @expressionResult = 1 ELSE SET @expressionResult = 0'    	                
        EXEC sp_executesql @sSQL, N'@expressionResult BIT OUTPUT, @pUTest XML', @expressionResult OUTPUT, @pUTest     
    END TRY
	BEGIN CATCH
        -- Inserting an ERROR Event instead of SQLTrace Event
        SET @expressionResult = 0
        SET @expressionInvalid = 1
        -- TAssertion failed. Replace bindings by value to help comprehension of the expression
        EXEC sploggerUT._ParseExpr @pUTest OUT, @pExpressionToVerify, @expressionWithValue OUT, 1
        -- Looging SQL error
        SET @assertRes = splogger.NewEvent_For_SqlError(3)
            EXEC splogger.AddParam @assertRes OUT, 'sploggerUT.AssertTrue:expression', @pExpressionToVerify
            EXEC splogger.AddParam @assertRes OUT, 'sploggerUT.AssertTrue:parsed', @parsedExpression
            EXEC splogger.AddParam @assertRes OUT, 'sploggerUT.AssertTrue:with-value', @expressionWithValue
	    EXEC splogger.AddEvent @pUTest OUT, @assertRes        
	END CATCH
    
    -- Testing result
    IF @expressionResult = 1
    BEGIN 
        -- Assertion verified       
        SET @assertRes = '<assertion type="formula" failed="0"><expression><![CDATA['+ISNULL(@pDescription, @pExpressionToVerify)+']]></expression></assertion>'
    END
    ELSE
    BEGIN 
        -- TAssertion failed. Replace bindings by value to help comprehension of the expression
        IF @expressionWithValue IS NULL
            EXEC sploggerUT._ParseExpr @pUTest OUT, @pExpressionToVerify, @expressionWithValue OUT, 1
        
        -- Create assertion tag with complementaty informations on failure
        IF @expressionInvalid = 1
            SET @assertRes = '<assertion type="formula" failed="1" expression-invalid="1"><expression><![CDATA['+ISNULL(@pDescription, @pExpressionToVerify)+']]></expression><evaluated-expression><![CDATA['+@expressionWithValue+']]></evaluated-expression></assertion>'
        ELSE
            SET @assertRes = '<assertion type="formula" failed="1"><expression><![CDATA['+ISNULL(@pDescription, @pExpressionToVerify)+']]></expression><evaluated-expression><![CDATA['+@expressionWithValue+']]></evaluated-expression></assertion>'
            
        -- Mark the Unit Test as failed    
        SET @pUTest.modify('replace value of (/unit-test[1]/@level_max) with (3)')
    END
    
    -- Adding assert response to UT
    SET @pUTest.modify('insert (sql:variable("@assertRes")) into (/unit-test[1]/assertions[1])')      
END
go


CREATE PROCEDURE sploggerUT._SetValue @pUTest XML OUT, @pUTKey NVARCHAR(128), @pDescription NVARCHAR(255), @pDataType NVARCHAR(20), @pRunValue NVARCHAR(MAX)
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
        =
        = Internal use only. Use specialised procedures
        =
        
        This method is used to save a runtime value to allow "Assert" statements to be call on it.
        This method should not be called directly but through call to the specialised one (@see)
        
        @param   pUTest   XML OUT  A reference to the Unit Test
        @param   pUTKey   NVARCHAR(128)   Identifiant of the value
        @param   pDescription   NVARCHAR(255)   Description of the contain of this value 
        @param   pDataType   NVARCHAR(20)   Datatype of the value
        @param   pRunValue   NVARCHAR(MAX)   Run value to save
        
        @see SetDateTimeValue, SetDateValue, SetFloatValue, SetIntValue, SetNVarcharValue, SetXmlValue and SetSqlSelectValue
        
     */
    SET NOCOUNT ON
    
    -- Be sure that Unit test run in its own transaction
    DECLARE @inTranChecked INT = @pUTest.value('(/unit-test[1]/@in_tran_checked)', 'INT') 
    IF @inTranChecked = 0
    BEGIN
        RAISERROR( N'sploggerUT._SetValue - The cheching for Unit Test to run in a top level transaction haven''t be done.', 16, 0 )
        RETURN
    END
        
    IF CHARINDEX('#', @pUTKey) > 0
    BEGIN
        RAISERROR( N'sploggerUT._SetValue - Hash sign (#) is not allowed in key value. Will conflict with "AssertTrue" functionnality.', 16, 0 )
        RETURN
    END     
        
    -- 
    -- Write the value
    --
	DECLARE @xmlUTValue XML 
    IF @pRunValue IS NULL
        SET @xmlUTValue = '<run-value key="'+@pUTKey+'" datatype="'+@pDataType+'" isnull="1" checked="0"><description><![CDATA['+@pDescription+']]></description></run-value>'       
    ELSE
        SET @xmlUTValue = '<run-value key="'+@pUTKey+'" datatype="'+@pDataType+'" isnull="0" checked="0"><description><![CDATA['+@pDescription+']]></description><value><![CDATA['+@pRunValue+']]></value></run-value>'       
    -- Adding to UT        
    SET @pUTest.modify('insert (sql:variable("@xmlUTValue")) into (/unit-test[1]/run-values[1])')      
END
go


create procedure sploggerUT._AddAssertResult @pUTest XML OUT, @pIsFailed BIT, @pUTKey NVARCHAR(128), @pType NVARCHAR(2), @pFailedText NVARCHAR(MAX) = NULL, @pRunValue NVARCHAR(MAX), @pExpectedValue NVARCHAR(MAX)
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
        =
        = Internal use only. Use suffixed procedures
        =
        
        Save the result of an assertion. If the status is failed, then the Unit Test is flag as failed too.
        
        @param   pUTest   XML OUT  a reference to the Unit Test
        @param   pIsFailed   BIT   flag that this Assert have failed
        @param   pUTKey   NVARCHAR(128)   Identifiant of the value
        @param   pType   NVARCHAR(2)   type of comparison eq=Equals or ne=NotEquals
        @param   pFailedText   NVARCHAR(MAX) (default=NULL)   If this Assertion failed, this is the failure explanation
        @param   pRunValue   NVARCHAR(MAX)   run value used in comparison
        @param   pExpectedValue   NVARCHAR(MAX)   expected value used in comparison
        
        Note: NULL values are saved as "{null}" in assertion result.
     */   
    DECLARE @assertRes XML   
    
    -- Formatting values
    IF @pRunValue IS NULL
        SET @pRunValue = '{null}'
    IF @pExpectedValue IS NULL
        SET @pExpectedValue = '{null}'        
    
    -- Autodetect of XML value
    DECLARE @xmlTest XML
    
    IF SUBSTRING(@pRunValue, 1, 1) = '<' AND SUBSTRING(@pRunValue, LEN(@pRunValue), 1) = '>'
    BEGIN
        BEGIN TRY
            SET @xmlTest = CONVERT(XML,@pRunValue)            
        END TRY
        BEGIN CATCH
            SET @pRunValue = '<![CDATA['+@pRunValue+']]>'
        END CATCH
    END    
    ELSE
        SET @pRunValue = '<![CDATA['+@pRunValue+']]>'
        
    IF SUBSTRING(@pExpectedValue, 1, 1) = '<' AND SUBSTRING(@pExpectedValue, LEN(@pExpectedValue), 1) = '>'
    BEGIN
        BEGIN TRY
            SET @xmlTest = CONVERT(XML,@pExpectedValue)            
        END TRY
        BEGIN CATCH
            SET @pExpectedValue = '<![CDATA['+@pExpectedValue+']]>'
        END CATCH
    END    
    ELSE
        SET @pExpectedValue = '<![CDATA['+@pExpectedValue+']]>'    
    
    -- Creating the assert response
    IF @pIsFailed = 0 
    BEGIN
        SET @assertRes = '<assertion type="'+@pType+'" key="'+@pUTKey+'" failed="0"><run-value>'+@pRunValue+'</run-value><expected-value>'+@pExpectedValue+'</expected-value></assertion>'
    END
    ELSE
    BEGIN
        -- This is a assertion failed
        SET @assertRes = '<assertion type="'+@pType+'" key="'+@pUTKey+'" failed="1"><failure-text><![CDATA['+@pFailedText+']]></failure-text><run-value>'+@pRunValue+'</run-value><expected-value>'+@pExpectedValue+'</expected-value></assertion>'
        SET @pUTest.modify('replace value of (/unit-test[1]/@level_max) with (3)')
    END
                
    -- Adding assert response to UT
    SET @pUTest.modify('insert (sql:variable("@assertRes")) into (/unit-test[1]/assertions[1])')    
END
go


CREATE PROCEDURE sploggerUT._ComputeGetValue @pUTest XML, @pUTKeyExpr NVARCHAR(255), @pRuntimeValue NVARCHAR(MAX) OUT
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
        =
        = Internal use only. Use suffixed procedures
        =
        
        Return runtime saved values, a templating mecanism can be used for @pUTKeyExpr, as a NVARCHAR
        The supported format for the template are :
        
           "<utkey>" : return the value of the saved <utkey> in its declared datatype
        
        For "resultset" value, additionnal templates are supported :
        
           "<utkey>#rowcount" : return the "rowcount" value for the "resultset" saved under <utkey>
           "<utkey>#scalar" : return the value of the first column of the first row in the "resultset" saved under <utkey>
           "<utkey>#<row>,<col>" : return the value of the <col>th column of the <row>th row in the "resultset" saved under <utkey>
        
        @param   pUTest   XML   A reference to the Unit Test
        @param   pUTKeyExpr   NVARCHAR(255)   Identifiant of the value
        
        @return   NVARCHAR(MAX) 
        
     */
    DECLARE @logEvent XML 
    DECLARE @utKey NVARCHAR(128) = SUBSTRING(@pUTKeyExpr, 1, 128)
    DECLARE @xpath NVARCHAR(255) = NULL
    DECLARE @xpathPos INT = charindex('#', @pUTKeyExpr)
        
    IF @xpathPos > 0
    BEGIN
        -- There is a complementary data access path
        SET @utKey = SUBSTRING(@pUTKeyExpr, 1, @xpathPos - 1)
        SET @xpath = SUBSTRING(@pUTKeyExpr, @xpathPos + 1, 255)
    END
        
    IF @pUTest.exist('(/unit-test[1]/run-values/run-value[@key=sql:variable("@utKey")])') = 0
    BEGIN
        -- Missing value. The UT run has not retrieved a value for @utKey		
        RETURN N'sploggerUT:## Missing value. No run value for "'+@utKey+'" ##'
    END 

    DECLARE @eltXml XML = @pUTest.query('(/unit-test[1]/run-values/run-value[@key=sql:variable("@utKey")][1])')        
    SET @pRuntimeValue = NULL

    -- Checking if is null  
    DECLARE @valueIsNull BIT = @eltXml.value('(/run-value[1]/@isnull)', 'BIT')    
	IF @valueIsNull = 1 
	BEGIN
        RETURN NULL
	END
    
	-- Checking run-values after convertion to datatype 
	DECLARE @declaredDataType NVARCHAR(20) = @eltXml.value('(/run-value[1]/@datatype)', 'NVARCHAR(20)')    	
              
    IF @declaredDataType = 'resultset' 
	BEGIN        
        IF @xpath IS NULL OR LOWER(@xpath) = 'rowcount'		
        BEGIN
            -- This is a special check based on rowcount
            SET @pRuntimeValue = @eltXml.value('(/run-value[1]/@rowcount)', 'NVARCHAR(MAX)')    	
        END
        ELSE IF LOWER(@xpath) = 'scalar'		
        BEGIN
            -- This is a special check based on first Column of first Row value 
            SET @pRuntimeValue = @eltXml.value('(/run-value[1]/resultset[1]/row[1]/*[1]/text())[1]', 'NVARCHAR(MAX)')    	
        END
        ELSE 	
        BEGIN
            -- This is a special check based on "C" Column of "R" Row value 
            -- Ex: 2,4 => Row 2, Col 4
            SET @xpathPos = charindex(',', @xpath)
            DECLARE @rowIdx INT = CONVERT(INT, SUBSTRING(@xpath, 1, @xpathPos - 1))
            DECLARE @colIdx INT = CONVERT(INT, SUBSTRING(@xpath, @xpathPos + 1, 20))            
            SET @pRuntimeValue = @eltXml.value('(/run-value[1]/resultset[1]/row[sql:variable("@rowIdx")]/*[sql:variable("@colIdx")]/text())[1]', 'NVARCHAR(MAX)')  
        END
	END
	ELSE IF @declaredDataType = 'xml' 
	BEGIN
        -- Read XML content
        SET @eltXml = @eltXml.query('(/run-value[1]/value/*)[1]')
        
        IF @xpath IS NULL
        BEGIN
            -- No XPath, so return all xml data
            SET @pRuntimeValue = CONVERT(NVARCHAR(MAX), @eltXml)
        END
        ELSE 	
        BEGIN
            DECLARE @sSQL NVARCHAR(MAX) = N'SET @pRuntimeValue = @eltXml.value( ''(/*[1]'+@xpath+')[1]'', ''NVARCHAR(MAX)'')'    	                
            EXEC sp_executesql @sSQL, N'@pRuntimeValue NVARCHAR(MAX) OUTPUT, @eltXml XML', @pRuntimeValue OUTPUT, @eltXml                 
        END
	END
	ELSE
	BEGIN
        IF @xpath IS NOT NULL
        BEGIN
            -- XPath/Complement are only allowed on ResultSet and XML values		
            RETURN N'sploggerUT:## Complementary path not allowed for "'+@declaredDataType+'" value of "'+@utKey+'" ##'
        END     
		-- Not a ResultSet or Xml. Getting Value
		SET @pRuntimeValue = @eltXml.value('(/run-value[1]/value[text()])[1]', 'NVARCHAR(MAX)')    
	END    
END
go


CREATE PROCEDURE sploggerUT._AssertENE @pUTest XML OUT, @pUTKeyExpr NVARCHAR(255), @pTestIsEquals BIT, @pExpectedValue NVARCHAR(MAX), @pRunUtKey NVARCHAR(128) = NULL
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
        =
        = Internal use only. Use suffixed procedures
        =
        
        Ckeck if the run value for the specified key is equals/inequals to the expected one.
        
        To reference runtime saved values, a templating mecanism can be used for @pUTKeyExpr   
        The supported format for the template are :
        
           "<utkey>" : return the value of the saved <utkey> in its declared datatype
           "<utkey>:<target-datatype>" : return the value of the saved <utkey> converted in the <target-datatype>
        
        For "resultset" value, additionnal templates are supported :
        
           "<utkey>#rowcount" : return the "rowcount" value for the "resultset" saved under <utkey>
           "<utkey>#scalar:<target-datatype>" : return the value of the first column of the first row in the "resultset" saved under <utkey> converted in the <target-datatype> (NVARCHAR by default)
           "<utkey>#<row>,<col>:<target-datatype>" : return the value of the <col>th column of the <row>th row in the "resultset" saved under <utkey> converted in the <target-datatype>  (NVARCHAR by default)
        
        @param   pUTest   XML OUT  A reference to the Unit Test
        @param   pUTKeyExpr   NVARCHAR(255)   Identifiant of the value
        @param   pTestIsEquals   BIT   check for Equality or Inequality ?
        @param   pExpectedValue   NVARCHAR(MAX)   The expected value. This value is converted to the <utKey> "datatype" (declared or specified) before comparison.
        @param   pRunUtKey   NVARCHAR(128) (default=NULL)   Key use to memorize the run value for future use. In formula using XPath for example
     */ 
    SET NOCOUNT ON
    
    DECLARE @rootUtKey NVARCHAR(128)                        -- "Key" part of the @pUTKeyExpr
    DECLARE @utKeyCompl NVARCHAR(128)                       -- "Key + Compl" part of the @pUTKeyExpr    
    DECLARE @declaredDataType NVARCHAR(20) = 'nvarchar'     -- "DataType" part of the @pUTKeyExpr
    DECLARE @splitIndex INT = CHARINDEX(':', @pUTKeyExpr)

    -- Does the @pUTKeyExpr contains a "datatype" part ?
	IF @splitIndex = 0
	BEGIN
        -- No "datatype" part specified
        SET @utKeyCompl = @pUTKeyExpr
        -- Get rootUtKey. There is a complementary path ?
        SET @splitIndex = CHARINDEX('#', @utKeyCompl)
        IF @splitIndex > 0
            SET @rootUtKey = SUBSTRING(@utKeyCompl, 1, @splitIndex - 1)
        ELSE
            SET @rootUtKey = @utKeyCompl
        
        -- Get the declared datatype    			
        SET @declaredDataType = @pUTest.value('(/unit-test[1]/run-values/run-value[@key=sql:variable("@rootUtKey")]/@datatype)[1]', 'NVARCHAR(20)')   
        -- Specific RS case
        IF @declaredDataType = 'resultset'
        BEGIN
            IF LOWER(SUBSTRING(@utKeyCompl, @splitIndex + 1, 128)) = 'rowcount'     -- Ask for rows count
                SET @declaredDataType = 'int'                           
            ELSE
                SET @declaredDataType = 'nvarchar'                           
        END
	END
	ELSE
	BEGIN
        -- A Data Type is specified, to force use of specific read function
        SET @utKeyCompl = SUBSTRING(@pUTKeyExpr, 1, @splitIndex - 1)
        SET @declaredDataType = SUBSTRING(@pUTKeyExpr, @splitIndex + 1, LEN(@pUTKeyExpr) - @splitIndex)        
        -- Get rootUtKey. There is a complementary path ?
        SET @splitIndex = CHARINDEX('#', @utKeyCompl)
        IF @splitIndex > 0
            SET @rootUtKey = SUBSTRING(@utKeyCompl, 1, @splitIndex - 1)
        ELSE
            SET @rootUtKey = @utKeyCompl
	END
    
    DECLARE @runtimeValue NVARCHAR(MAX) 
    
	BEGIN TRY		    
        -- Reading value as String
        EXEC sploggerUT._ComputeGetValue @pUTest, @utKeyCompl, @runtimeValue OUT
    
        -- Do internal checks...
        IF CHARINDEX('sploggerUT:##', @runtimeValue) > 0
        BEGIN
            -- Missing value or CAST error. The UT run has not retrieved a value for @pUTKeyExpr
            -- The value returned is the error message
    		-- Assertion => Failed
            EXEC sploggerUT._AddAssertResult @pUTest OUT, 1, @utKeyCompl, @runtimeValue, NULL, @pExpectedValue
            GOTO ASSERTION_BEFORE_EXIT
        END

        -- Checking if is null  
    	IF @runtimeValue IS NULL
    	BEGIN
            IF @pExpectedValue IS NULL 
    		    GOTO ASSERTION_EQUAL
            ELSE
                GOTO ASSERTION_NOT_EQUAL
    	END
        
        -- Checking datatyped values      

		IF @declaredDataType = 'nvarchar' 
		BEGIN
			IF @runtimeValue <> @pExpectedValue 
				GOTO ASSERTION_NOT_EQUAL
		END
		ELSE IF @declaredDataType = 'int' 
		BEGIN
			IF CONVERT(INT,@runtimeValue) <> CONVERT(INT,@pExpectedValue)
				GOTO ASSERTION_NOT_EQUAL
		END
		ELSE IF @declaredDataType = 'date' 
		BEGIN
			IF CONVERT(DATE,@runtimeValue, 120) <> CONVERT(DATE,@pExpectedValue,120)
				GOTO ASSERTION_NOT_EQUAL
		END
		ELSE IF @declaredDataType = 'datetime' 
		BEGIN
			IF CONVERT(DATETIME,@runtimeValue, 126) <> CONVERT(DATETIME,@pExpectedValue,126)
				GOTO ASSERTION_NOT_EQUAL
		END
		ELSE IF @declaredDataType = 'float' 
		BEGIN
			IF CONVERT(FLOAT,@runtimeValue) <> CONVERT(FLOAT,@pExpectedValue)
				GOTO ASSERTION_NOT_EQUAL
		END
		ELSE IF @declaredDataType = 'xml' 
		BEGIN
            -- For XML. Compare as NVARCHAR
			IF @runtimeValue <> @pExpectedValue
				GOTO ASSERTION_NOT_EQUAL
		END
	END TRY 
	BEGIN CATCH
		-- An error had been thrown during datatype convertion
        DECLARE @errMsg NVARCHAR(2048) = ERROR_MESSAGE()
        SET @errMsg = @errMsg + ' (SQLCode='+CONVERT(VARCHAR(20), ERROR_NUMBER())+')'
        
        IF @pTestIsEquals = 1
            EXEC sploggerUT._AddAssertResult @pUTest OUT, 1, @utKeyCompl, N'eq', @errMsg, @runtimeValue, @pExpectedValue
        ELSE
            EXEC sploggerUT._AddAssertResult @pUTest OUT, 1, @utKeyCompl, N'ne', @errMsg, @runtimeValue, @pExpectedValue
            
        GOTO ASSERTION_FIN
	END CATCH

	GOTO ASSERTION_EQUAL
        
ASSERTION_NOT_EQUAL:

    IF @pTestIsEquals = 1
    	-- Assertion => Failed
        EXEC sploggerUT._AddAssertResult @pUTest OUT, 1, @utKeyCompl, N'eq', N'The run value DOES NOT match the expected value.', @runtimeValue, @pExpectedValue
    ELSE
        -- Assertion => OK	
        EXEC sploggerUT._AddAssertResult @pUTest OUT, 0, @utKeyCompl, N'ne', null, @runtimeValue, @pExpectedValue             
        
    GOTO ASSERTION_FIN
        
ASSERTION_EQUAL:

    IF @pTestIsEquals = 1
    	-- Assertion => OK	
        EXEC sploggerUT._AddAssertResult @pUTest OUT, 0, @utKeyCompl, N'eq', null, @runtimeValue, @pExpectedValue             
    ELSE
        -- Assertion => Failed
        EXEC sploggerUT._AddAssertResult @pUTest OUT, 1, @utKeyCompl, N'ne', N'The run value DOES match the expected value.', @runtimeValue, @pExpectedValue
    
ASSERTION_FIN:
  
	SET @pUTest.modify('replace value of (/unit-test[1]/run-values/run-value[@key=sql:variable("@rootUtKey")]/@checked)[1] with (1)')  
    
ASSERTION_BEFORE_EXIT:

    -- Memorize the run value for future use. In formula for example
    IF @pRunUtKey IS NOT NULL
    BEGIN
        DECLARE @description NVARCHAR(255) = 'splogger:run-time value of "'+@pUTKeyExpr+'"'
        EXEC sploggerUT._SetValue @pUTest OUT, @pRunUtKey, @description, @declaredDataType, @runtimeValue                
    END
END
go


CREATE PROCEDURE sploggerUT.AssertEquals @pUTest XML OUT, @pUTKeyExpr NVARCHAR(255), @pExpectedValue NVARCHAR(MAX), @pRunUtKey NVARCHAR(128) = NULL
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
        
        Ckeck if the run value for the specified key is equals to the expected one.
        
        To reference runtime saved values, a templating mecanism can be used for @pUTKeyExpr   
        The supported format for the template are :
        
           "<utkey>" : return the value of the saved <utkey> in its declared datatype
           "<utkey>:<target-datatype>" : return the value of the saved <utkey> converted in the <target-datatype>
        
        For "resultset" value, additionnal templates are supported :
        
           "<utkey>#rowcount" : return the "rowcount" value for the "resultset" saved under <utkey>
           "<utkey>#scalar:<target-datatype>" : return the value of the first column of the first row in the "resultset" saved under <utkey> converted in the <target-datatype> (NVARCHAR by default)
           "<utkey>#<row>,<col>:<target-datatype>" : return the value of the <col>th column of the <row>th row in the "resultset" saved under <utkey> converted in the <target-datatype>  (NVARCHAR by default)
        
        @param   pUTest   XML OUT  A reference to the Unit Test
        @param   pUTKeyExpr   NVARCHAR(255)   Identifiant of the value
        @param   pExpectedValue   NVARCHAR(MAX)   The expected value. This value is converted to the <utKey> "datatype" (declared or specified) before comparison.
        @param   pRunUtKey   NVARCHAR(128) (default=NULL)   Key use to memorize the run value for future use. In formula using XPath for example
        
        @see   _AssertENE
     */ 
    EXEC sploggerUT._AssertENE @pUTest OUT, @pUTKeyExpr, 1, @pExpectedValue, @pRunUtKey
END
go


CREATE PROCEDURE sploggerUT.AssertFalse @pUTest XML OUT, @pExpressionToVerify NVARCHAR(MAX), @pDescription NVARCHAR(255) = NULL   
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
        
        Ckeck if the result of an expression is TRUE.
        
        The @pExpressionToVerify can be any T-SQL expression resulting in a boolean value.
        To reference runtime saved values, a templating mecanism can be used.
        The supported format for the template are :
        
           {{<utkey>}} : return the value of the saved <utkey> in its declared datatype
           {{<utkey>:<target-datatype>}} : return the value of the saved <utkey> converted in the <target-datatype>
        
        For "resultset" value, additionnal templates are supported :
        
           {{<utkey>#rowcount}} : return the "rowcount" value for the "resultset" saved under <utkey>
           {{<utkey>#scalar:<target-datatype>}} : return the value of the first column of the first row in the "resultset" saved under <utkey> converted in the <target-datatype> (NVARCHAR by default)
           {{<utkey>#<row>,<col>:<target-datatype>}} : return the value of the <col>th column of the <row>th row in the "resultset" saved under <utkey> converted in the <target-datatype>  (NVARCHAR by default)
        
        @param   pUTest   XML OUT  a reference to the Unit Test
        @param   pExpressionToVerify   NVARCHAR(MAX)   the expression to evaluate and check. 
        @param   pDescription   NVARCHAR(255) (default=NULL)   description of the expression which replace the expression as description in assertion if defined
     */     
    SET NOCOUNT ON
    SET @pExpressionToVerify = 'NOT ('+@pExpressionToVerify+')'
    EXEC sploggerUT.AssertTrue @pUTest OUT, @pExpressionToVerify, @pDescription
END
go


CREATE PROCEDURE sploggerUT.AssertNotEquals @pUTest XML OUT, @pUTKeyExpr NVARCHAR(255), @pExpectedValue NVARCHAR(MAX), @pRunUtKey NVARCHAR(128) = NULL
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
        
        Ckeck if the run value for the specified key is NOT equals to the expected one.
        
        To reference runtime saved values, a templating mecanism can be used for @pUTKeyExpr   
        The supported format for the template are :
        
           "<utkey>" : return the value of the saved <utkey> in its declared datatype
           "<utkey>:<target-datatype>" : return the value of the saved <utkey> converted in the <target-datatype>
        
        For "resultset" value, additionnal templates are supported :
        
           "<utkey>#rowcount" : return the "rowcount" value for the "resultset" saved under <utkey>
           "<utkey>#scalar:<target-datatype>" : return the value of the first column of the first row in the "resultset" saved under <utkey> converted in the <target-datatype> (NVARCHAR by default)
           "<utkey>#<row>,<col>:<target-datatype>" : return the value of the <col>th column of the <row>th row in the "resultset" saved under <utkey> converted in the <target-datatype>  (NVARCHAR by default)
        
        @param   pUTest   XML OUT  A reference to the Unit Test
        @param   pUTKeyExpr   NVARCHAR(255)   Identifiant of the value
        @param   pExpectedValue   NVARCHAR(MAX)   The expected value. This value is converted to the <utKey> "datatype" (declared or specified) before comparison.
        @param   pRunUtKey   NVARCHAR(128) (default=NULL)   Key use to memorize the run value for future use. In formula using XPath for example
        
        @see   _AssertENE
     */ 
    EXEC sploggerUT._AssertENE @pUTest OUT, @pUTKeyExpr, 0, @pExpectedValue, @pRunUtKey
END
go


CREATE PROCEDURE sploggerUT.CheckUnitTestInTransaction @pUtest XML OUT
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
        
        Check that the current Unit Test if any, is running in a transaction.
        This protection SHOULD BE the first call of any procedure that support Unit Testing
        If an Unit Test is in progress and no transaction is in progress too (normally initialised in Unit Test Boby) then throws an error
        
        @param   pUTest   XML OUT  a reference to the Unit Test
        
        @return   the current value of @@TRANCOUNT
        
        @see   SoC..
     */
    DECLARE @tranCount INT = @@TRANCOUNT
    
    -- If not Unit test in progress, just continue
    IF @pUtest IS NULL OR splogger.GetRunningLevel(@pUtest) <> -8   
        RETURN @tranCount
        
    -- Else if no transaction in progress (normally initialised in Unit Test Boby throws an error    
    IF @tranCount <> 1 
    BEGIN
        RAISERROR( N'sploggerUT.CheckUnitTestInTransaction - Unit Test target procedure SHOULD BE call in a first level transaction (@@TRANCOUNT = 1).', 16, 0 )
        RETURN
    END
    
    -- Tagging as in its own transaction check has been done
    SET @pUTest.modify('replace value of (/unit-test[1]/@in_tran_checked) with ("1")')   
    
    RETURN @tranCount
END
go


CREATE PROCEDURE sploggerUT.SaveUnitTest @pUTest XML
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
        
        Save the result of the Unit Test into the dedicated database table
        
        @param   pUTest   XML   Unit test to save
        
        @see   StartUnitTest
     */
    SET NOCOUNT ON
    
    IF @pUTest.exist('(/unit-test[1])') = 0
    BEGIN
        RAISERROR ( N'%s - sploggerUT.SaveUnitTest - Root element is not an Unit Test.', 16, 0) WITH NOWAIT            
        RETURN
    END
    
    BEGIN TRY          
        DECLARE @isSuccessfull BIT
        DECLARE @runAt DATETIME = @pUTest.value('(/unit-test[1]/@start_time)', 'DATETIME')        
        DECLARE @level_max INT = @pUTest.value('(/unit-test[1]/@level_max)', 'INT') 
        
        -- Checking if Unit test excetion was done without error (at UT level)
        IF @level_max > 2
        BEGIN
            SET @pUTest.modify('replace value of (/unit-test[1]/@successfull) with ("0")')   
            SET @isSuccessfull = 0
        END    
        ELSE
        BEGIN                                  
            SET @isSuccessfull = @pUTest.value('(/unit-test[1]/@successfull)', 'BIT') 
        END
                                             
        -- Remove unused attributes                                             
        SET @pUTest.modify('delete /unit-test[1]/@start_time')
        SET @pUTest.modify('delete /unit-test[1]/@level_max')                                             
        SET @pUTest.modify('delete /unit-test[1]/@level') 
                                             
        -- Auto-detection system for timed-group support - Remove for ended log
        IF @pUTest.exist('(/unit-test[1]/@container)') = 1
        BEGIN
            SET @pUTest.modify('delete /unit-test[1]/@container')
        END             
            
        -- Delete all checked assertions               
        SET @pUTest.modify('delete /unit-test[1]/run-values/run-value[@checked="1"]')  
        IF @pUTest.exist('(/unit-test[1]/run-values/run-value)') = 0
        BEGIN
            -- If no more unchecked run values, delete their container
            SET @pUTest.modify('delete /unit-test[1]/run-values')  
        END
                       
        -- Database insertion of a new LogHistory record            
		DECLARE @tranCount INT = @@TRANCOUNT
    
        IF @tranCount > 0
        BEGIN
            -- Checks if any transaction is in progress. 
            -- If this is the cas, warns that the log record will be lost if the current transaction will be rollbacked.
            DECLARE @tranWarnEvent XML = splogger.NewEvent_Warning( -100, 'Be carefull. this Unit Test has been saved in UnittestHistory inside an active transaction. This log COULD BE LOST in case of a ROLLBACK in the coming transaction activity.')
            EXEC splogger.AddParam @tranWarnEvent OUT, '@@TRANCOUNT', @tranCount 
            EXEC splogger.AddEvent @pUTest OUT, @tranWarnEvent                                             
        END
    
        -- Database insertion
        DECLARE @UTKey NVARCHAR(128) = @pUTest.value('(/unit-test[1]/@utkey)', 'NVARCHAR(128)')         
        
        INSERT INTO sploggerUT.UnittestHistory( DbName, UnitTestKey, RunAt, IsSuccessfull, UnitTestDetail )
            VALUES ( DB_NAME(), @UTKey, @runAt, @isSuccessfull, @pUTest )
        
        RETURN @@IDENTITY                
    END TRY
    BEGIN CATCH
        -- Raise error
        DECLARE @ts VARCHAR(20) = CONVERT( VARCHAR(20), GETUTCDATE(), 116 )
        DECLARE @errNum INT = ERROR_NUMBER()
        DECLARE @errMsg NVARCHAR(2048) = ERROR_MESSAGE()
        RAISERROR ( N'%s - sploggerUT.SaveUnitTest - Error #%d : %s', 16, 0, @ts, @errNum, @errMsg ) WITH NOWAIT        
    END CATCH        
END
go


CREATE PROCEDURE sploggerUT.SetDateTimeValue @pUTest XML OUT, @pUTKey NVARCHAR(128), @pDescription NVARCHAR(255), @pRunValue DATETIME
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
        
        This method is used to save a DATETIME runtime value to allow "Assert" statements to be call on it.
        This method is only active during Unit Testing
        
        @param   pUTest   XML OUT  A reference to the Unit Test
        @param   pUTKey   NVARCHAR(128)   Identifiant of the value
        @param   pDescription   NVARCHAR(255)   Description of the contain of this value 
        @param   pRunValue   DATETIME   Run value to save. The value is formatted as YYYY-MM-DDTHH:MI:SS.MS
        
        @see   _SetValue
     */
    -- If no Unit test running or not an Unit Test call just a sub-task (sub-loffer)
    IF @pUTest IS NULL OR splogger.GetRunningLevel(@pUTest) <> -8
        RETURN
    
    DECLARE @valueStr NVARCHAR(25) = CONVERT(NVARCHAR(25), @pRunValue, 126)
    EXEC sploggerUT._SetValue @pUTest OUT, @pUTKey, @pDescription, 'datetime', @valueStr
END
go


CREATE PROCEDURE sploggerUT.SetDateValue @pUTest XML OUT, @pUTKey NVARCHAR(128), @pDescription NVARCHAR(255), @pRunValue DATE
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
        
        This method is used to save a DATE runtime value to allow "Assert" statements to be call on it.
        This method is only active during Unit Testing
        
        @param   pUTest   XML OUT  A reference to the Unit Test
        @param   pUTKey   NVARCHAR(128)   Identifiant of the value
        @param   pDescription   NVARCHAR(255)   Description of the contain of this value 
        @param   pRunValue   DATE   Run value to save.The value is formatted as YYYY-MM-DD
        
        @see   _SetValue
     */
    -- If no Unit test running or not an Unit Test call just a sub-task (sub-loffer)
    IF @pUTest IS NULL OR splogger.GetRunningLevel(@pUTest) <> -8
        RETURN
    
    DECLARE @valueStr NVARCHAR(25) = CONVERT(NVARCHAR(25), @pRunValue, 120)
    EXEC sploggerUT._SetValue @pUTest OUT, @pUTKey, @pDescription, 'date', @valueStr
END
go


CREATE PROCEDURE sploggerUT.SetFloatValue @pUTest XML OUT, @pUTKey NVARCHAR(128), @pDescription NVARCHAR(255), @pRunValue FLOAT
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
        
        This method is used to save a FLOAT runtime value to allow "Assert" statements to be call on it.
        This method is only active during Unit Testing
        
        @param   pUTest   XML OUT  A reference to the Unit Test
        @param   pUTKey   NVARCHAR(128)   Identifiant of the value
        @param   pDescription   NVARCHAR(255)   Description of the contain of this value 
        @param   pRunValue  FLOAT  Rrun value to save
        
        @see   _SetValue
     */
    -- If no Unit test running or not an Unit Test call just a sub-task (sub-loffer)
    IF @pUTest IS NULL OR splogger.GetRunningLevel(@pUTest) <> -8
        RETURN
    
    EXEC sploggerUT._SetValue @pUTest OUT, @pUTKey, @pDescription, 'float', @pRunValue
END
go


CREATE PROCEDURE sploggerUT.SetIntValue @pUTest XML OUT, @pUTKey NVARCHAR(128), @pDescription NVARCHAR(255), @pRunValue INT
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
        
        This method is used to save a INT runtime value to allow "Assert" statements to be call on it.
        This method is only active during Unit Testing
        
        @param   pUTest   XML OUT  A reference to the Unit Test
        @param   pUTKey   NVARCHAR(128)   Identifiant of the value
        @param   pDescription   NVARCHAR(255)   Description of the contain of this value 
        @param   pRunValue   INT   Run value to save
        
        @see   _SetValue
     */
    -- If no Unit test running or not an Unit Test call just a sub-task (sub-loffer)
    IF @pUTest IS NULL OR splogger.GetRunningLevel(@pUTest) <> -8
        RETURN
    
    EXEC sploggerUT._SetValue @pUTest OUT, @pUTKey, @pDescription, 'int', @pRunValue
END
go


CREATE PROCEDURE sploggerUT.SetNVarcharValue @pUTest XML OUT, @pUTKey NVARCHAR(128), @pDescription NVARCHAR(255), @pRunValue NVARCHAR(MAX)
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
        
        This method is used to save a NVARCHAR runtime value to allow "Assert" statements to be call on it.
        This method is only active during Unit Testing
        
        @param   pUTest   XML OUT  A reference to the Unit Test
        @param   pUTKey   NVARCHAR(128)   Identifiant of the value
        @param   pDescription   NVARCHAR(255)   Description of the contain of this value 
        @param   pRunValue   NVARCHAR(MAX)   Run value to save
        
        @see   _SetValue
     */
    -- If no Unit test running or not an Unit Test call just a sub-task (sub-loffer)
    IF @pUTest IS NULL OR splogger.GetRunningLevel(@pUTest) <> -8
        RETURN
    
    EXEC sploggerUT._SetValue @pUTest OUT, @pUTKey, @pDescription, 'nvarchar', @pRunValue
END
go


CREATE PROCEDURE sploggerUT.SetSqlSelectValue @pUTest XML OUT, @pUTKey NVARCHAR(128), @pDescription NVARCHAR(255), @pSelectSQL NVARCHAR(MAX), @pDbName NVARCHAR(128) = NULL                                    
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
        Before running the query, {{database}} markers will be replace by @pDbName value
        An attribute "rowcount" is automatically added to the "run-value"
        This method is only active during Unit Testing.
        
        @param   pUTest   XML OUT  A reference to the Unit Test
        @param   pUTKey   NVARCHAR(128)   Identifiant of the value
        @param   pDescription   NVARCHAR(255)   Description of the contain of this value 
        @param   pSelectSQL   NVARCHAR(MAX)   The SELECT statement to execute and save the RESULTSET
        @param   pDbName   NVARCHAR(128)  (default=NULL)   Current database name (hosting the SP). If NULL, that means SPLogger is dedicated to the current database (created inside) 
        
        Important: Only SELECT statement are allowed
     */
    SET NOCOUNT ON
    
    -- If no Unit test running or not an Unit Test call just a sub-task (sub-loffer)
    IF @pUTest IS NULL OR splogger.GetRunningLevel(@pUTest) <> -8
        RETURN
   
    -- Replacing {{database}} tokens by running database
    -- If no @pDbName passed as parameter, that means SPLogger is dedicated to the current database (created inside)    
    IF @pDbName IS NULL
        SET @pDbName = DB_NAME()
            
    SET @pSelectSQL = REPLACE( @pSelectSQL, '{{database}}', @pDbName)
   
    -- Event's initialisation.
    -- The query expression is saved as an <![CDATA[]]> query element's value
    DECLARE @newUTValue XML = '<run-value key="'+@pUTKey+'" datatype="resultset" rowcount="0" checked="0"><description><![CDATA['+@pDescription+']]></description></run-value>'       
    
    -- Checks validity of input parameters
    IF UPPER(SUBSTRING(@pSelectSQL, 1, 7)) <> 'SELECT '
    BEGIN
        -- Inserting an ERROR Event instead of SQLTrace Event
        SET @newUTValue = splogger.NewEvent_Error ( -55000, N'sploggerUT.SetSqlSelectValue - The SQL query SHOULD BE a SELECT query.')
            EXEC splogger.AddParam @newUTValue OUT, 'query', @pSelectSQL
	    EXEC splogger.AddEvent @pUTest OUT, @newUTValue        
        RETURN
    END
       
    BEGIN TRY        
        DECLARE @xmlRS XML  
        -- Wrap the SQL query to convert result set to XML
    	DECLARE @sSQL NVARCHAR(max) = N'SET @xmlRS = ('+@pSelectSQL+' FOR XML RAW(''row''), ELEMENTS, ROOT(''resultset''))'    	
        
        -- Execute the wrapped SQL query 
        EXEC sp_executesql @sSQL, N'@xmlRS XML OUTPUT', @xmlRS OUTPUT 
        
        -- Adding the rowcount to the Event
        DECLARE @rowCount INT = @xmlRS.value('count(/resultset/row)', 'int')  
        SET @newUTValue.modify('replace value of (/*[1]/@rowcount) with (sql:variable("@rowCount"))')   
               
        -- Adding the result set to the Event
        SET @newUTValue.modify('insert (sql:variable("@xmlRS")) into (/run-value[1])')
        
        -- Adding the new Event to the logger
        SET @pUTest.modify('insert (sql:variable("@newUTValue")) into (/unit-test[1]/run-values[1])')      
	END TRY
	BEGIN CATCH
        -- Inserting an ERROR Event instead of SQLTrace Event
        SET @newUTValue = splogger.NewEvent_For_SqlError(3)
            EXEC splogger.AddParam @newUTValue OUT, 'query', @pSelectSQL
	    EXEC splogger.AddEvent @pUTest OUT, @newUTValue        
	END CATCH	
END
go


CREATE PROCEDURE sploggerUT.SetXmlValue @pUTest XML OUT, @pUTKey NVARCHAR(128), @pDescription NVARCHAR(255), @pRunValue XML
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
        
        This method is used to save a XML runtime value to allow "Assert" statements to be call on it.
        This method is only active during Unit Testing
        
        @param   pUTest   XML OUT  A reference to the Unit Test
        @param   pUTKey   NVARCHAR(128)   Identifiant of the value
        @param   pDescription   NVARCHAR(255)   Description of the contain of this value 
        @param   pRunValue   XML   Run value to save
        
     */
    SET NOCOUNT ON
    
    -- If no Unit test running or not an Unit Test call just a sub-task (sub-loffer)
    IF @pUTest IS NULL OR splogger.GetRunningLevel(@pUTest) <> -8
        RETURN
    
    -- Be sure that Unit test run in its own transaction
    DECLARE @inTranChecked INT = @pUTest.value('(/unit-test[1]/@in_tran_checked)', 'INT') 
    IF @inTranChecked = 0
    BEGIN
        RAISERROR( N'sploggerUT._SetOrCheckValue - The cheching for Unit Test to run in a top level transaction haven''t be done.', 16, 0 )
        RETURN
    END
        
    -- 
    -- Write the value
    --
	DECLARE @xmlUTValue XML 
    IF @pRunValue IS NULL
    BEGIN
        SET @xmlUTValue = '<run-value key="'+@pUTKey+'" datatype="xml" isnull="1" checked="0"><description><![CDATA['+@pDescription+']]></description><value></value></run-value>'       
    END
    ELSE
    BEGIN
        SET @xmlUTValue = '<run-value key="'+@pUTKey+'" datatype="xml" isnull="0" checked="0"><description><![CDATA['+@pDescription+']]></description><value></value></run-value>'       
        SET @xmlUTValue.modify('insert (sql:variable("@pRunValue")) into (/run-value[1]/value[1])')
    END
    -- Adding to UT        
    SET @pUTest.modify('insert (sql:variable("@xmlUTValue")) into (/unit-test[1]/run-values[1])')    
END
go


create function sploggerUT.StartUnitTest (@pUTKey NVARCHAR(128), @pDescription NVARCHAR(255))
RETURNS XML
begin
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
        
        Initialize a Unit Test (a main logger).
        The level attibute equals to "-8" means "Unit Test" when used as ParentLog
        
        @param   pUTKey   NVARCHAR(128)   Identifiant of the unit test.
        @param   pDescription   NVARCHAR(255)   Unit test description.
        
        @see   SaveUnitTest
     */     
    DECLARE @UTester XML = '<unit-test utkey="'+@pUTKey+'" start_time="'+CONVERT( VARCHAR(25), GETUTCDATE(), 126 )+'" level="-8" level_max="-1" successfull="1" in_tran_checked="0">'
            +'<description><![CDATA['+@pDescription+']]></description>'
            +'<run-values></run-values>'
            +'<assertions></assertions>'
            +'</unit-test>'
            
    RETURN @UTester
end
go


CREATE FUNCTION sploggerUT._GetDateTimeValue (@pUTest XML, @pUTKeyExpr NVARCHAR(255))
RETURNS DATETIME
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
        =
        = Internal use only. Use suffixed procedures
        =
        
        Return runtime saved values, a templating mecanism can be used for @pUTKeyExpr, as a DATETIME
        The supported format for the template are :
        
           "<utkey>" : return the value of the saved <utkey> in its declared datatype
        
        For "resultset" value, additionnal templates are supported :
        
           "<utkey>#rowcount" : return the "rowcount" value for the "resultset" saved under <utkey>
           "<utkey>#scalar" : return the value of the first column of the first row in the "resultset" saved under <utkey>
           "<utkey>#<row>,<col>" : return the value of the <col>th column of the <row>th row in the "resultset" saved under <utkey>
        
        @param   pUTest   XML   A reference to the Unit Test
        @param   pUTKeyExpr   NVARCHAR(255)   Identifiant of the value
        
        @return   DATETIME
        
     */
    RETURN CONVERT(DATETIME, sploggerUT._GetNVarcharValue(@pUTest, @pUTKeyExpr), 126)    
END
go


CREATE FUNCTION sploggerUT._GetDateValue (@pUTest XML, @pUTKeyExpr NVARCHAR(255))
RETURNS DATE
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
        =
        = Internal use only. Use suffixed procedures
        =
        
        Return runtime saved values, a templating mecanism can be used for @pUTKeyExpr, as a DATE
        The supported format for the template are :
        
           "<utkey>" : return the value of the saved <utkey> in its declared datatype
        
        For "resultset" value, additionnal templates are supported :
        
           "<utkey>#rowcount" : return the "rowcount" value for the "resultset" saved under <utkey>
           "<utkey>#scalar" : return the value of the first column of the first row in the "resultset" saved under <utkey>
           "<utkey>#<row>,<col>" : return the value of the <col>th column of the <row>th row in the "resultset" saved under <utkey>
        
        @param   pUTest   XML   A reference to the Unit Test
        @param   pUTKeyExpr   NVARCHAR(255)   Identifiant of the value
        
        @return   DATE
        
     */
    RETURN CONVERT(DATE, sploggerUT._GetNVarcharValue(@pUTest, @pUTKeyExpr), 120)    
END
go


CREATE FUNCTION sploggerUT._GetFloatValue (@pUTest XML, @pUTKeyExpr NVARCHAR(255))
RETURNS FLOAT
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
        =
        = Internal use only. Use suffixed procedures
        =
        
        Return runtime saved values, a templating mecanism can be used for @pUTKeyExpr, as a FLOAT
        The supported format for the template are :
        
           "<utkey>" : return the value of the saved <utkey> in its declared datatype
        
        For "resultset" value, additionnal templates are supported :
        
           "<utkey>#rowcount" : return the "rowcount" value for the "resultset" saved under <utkey>
           "<utkey>#scalar" : return the value of the first column of the first row in the "resultset" saved under <utkey>
           "<utkey>#<row>,<col>" : return the value of the <col>th column of the <row>th row in the "resultset" saved under <utkey>
        
        @param   pUTest   XML   A reference to the Unit Test
        @param   pUTKeyExpr   NVARCHAR(255)   Identifiant of the value
        
        @return   FLOAT
        
     */
    RETURN CONVERT(FLOAT, sploggerUT._GetNVarcharValue(@pUTest, @pUTKeyExpr))    
END
go


CREATE FUNCTION sploggerUT._GetIntValue (@pUTest XML, @pUTKeyExpr NVARCHAR(255))
RETURNS INT
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
        =
        = Internal use only. Use suffixed procedures
        =
        
        Return runtime saved values, a templating mecanism can be used for @pUTKeyExpr, as a INT
        The supported format for the template are :
        
           "<utkey>" : return the value of the saved <utkey> in its declared datatype
        
        For "resultset" value, additionnal templates are supported :
        
           "<utkey>#rowcount" : return the "rowcount" value for the "resultset" saved under <utkey>
           "<utkey>#scalar" : return the value of the first column of the first row in the "resultset" saved under <utkey>
           "<utkey>#<row>,<col>" : return the value of the <col>th column of the <row>th row in the "resultset" saved under <utkey>
        
        @param   pUTest   XML   A reference to the Unit Test
        @param   pUTKeyExpr   NVARCHAR(255)   Identifiant of the value
        
        @return   INT
        
     */
    RETURN CONVERT(INT, sploggerUT._GetNVarcharValue(@pUTest, @pUTKeyExpr))    
END
go


CREATE FUNCTION sploggerUT._GetNVarcharValue (@pUTest XML, @pUTKeyExpr NVARCHAR(255))
RETURNS NVARCHAR(MAX)
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
        =
        = Internal use only. Use suffixed procedures
        =
        
        Return runtime saved values, a templating mecanism can be used for @pUTKeyExpr, as a NVARCHAR
        The supported format for the template are :
        
           "<utkey>" : return the value of the saved <utkey> in its declared datatype
        
        For "resultset" value, additionnal templates are supported :
        
           "<utkey>#rowcount" : return the "rowcount" value for the "resultset" saved under <utkey>
           "<utkey>#scalar" : return the value of the first column of the first row in the "resultset" saved under <utkey>
           "<utkey>#<row>,<col>" : return the value of the <col>th column of the <row>th row in the "resultset" saved under <utkey>
        
        @param   pUTest   XML   A reference to the Unit Test
        @param   pUTKeyExpr   NVARCHAR(255)   Identifiant of the value
        
        @return   NVARCHAR(MAX) 
        
     */
    DECLARE @logEvent XML 
    DECLARE @utKey NVARCHAR(128) = SUBSTRING(@pUTKeyExpr, 1, 128)
    DECLARE @xpath NVARCHAR(255) = NULL
    DECLARE @xpathPos INT = charindex('#', @pUTKeyExpr)
        
    IF @xpathPos > 0
    BEGIN
        -- There is a complementary data access path
        SET @utKey = SUBSTRING(@pUTKeyExpr, 1, @xpathPos - 1)
        SET @xpath = SUBSTRING(@pUTKeyExpr, @xpathPos + 1, 255)
    END
        
    IF @pUTest.exist('(/unit-test[1]/run-values/run-value[@key=sql:variable("@utKey")])') = 0
    BEGIN
        -- Missing value. The UT run has not retrieved a value for @utKey		
        RETURN N'sploggerUT:## Missing value. No run value for "'+@utKey+'" ##'
    END 

    DECLARE @eltXml XML = @pUTest.query('(/unit-test[1]/run-values/run-value[@key=sql:variable("@utKey")][1])')     
    DECLARE @runtimeValue NVARCHAR(MAX) = NULL

    -- Checking if is null  
    DECLARE @valueIsNull BIT = @eltXml.value('(/run-value[1]/@isnull)', 'BIT')    
	IF @valueIsNull = 1 
	BEGIN
        RETURN NULL
	END
    
	-- Checking run-values after convertion to datatype 
	DECLARE @declaredDataType NVARCHAR(20) = @eltXml.value('(/run-value[1]/@datatype)', 'NVARCHAR(20)')    	
              
    IF @declaredDataType = 'resultset' 
	BEGIN        
        IF @xpath IS NULL OR LOWER(@xpath) = 'rowcount'		
        BEGIN
            -- This is a special check based on rowcount
            SET @runtimeValue = @eltXml.value('(/run-value[1]/@rowcount)', 'NVARCHAR(MAX)')    	
        END
        ELSE IF LOWER(@xpath) = 'scalar'		
        BEGIN
            -- This is a special check based on first Column of first Row value 
            SET @runtimeValue = @eltXml.value('(/run-value[1]/resultset[1]/row[1]/*[1]/text())[1]', 'NVARCHAR(MAX)')    	
        END
        ELSE 	
        BEGIN
            -- This is a special check based on "C" Column of "R" Row value 
            -- Ex: 2,4 => Row 2, Col 4
            SET @xpathPos = charindex(',', @xpath)
            DECLARE @rowIdx INT = CONVERT(INT, SUBSTRING(@xpath, 1, @xpathPos - 1))
            DECLARE @colIdx INT = CONVERT(INT, SUBSTRING(@xpath, @xpathPos + 1, 20))            
            SET @runtimeValue = @eltXml.value('(/run-value[1]/resultset[1]/row[sql:variable("@rowIdx")]/*[sql:variable("@colIdx")]/text())[1]', 'NVARCHAR(MAX)')  
        END
	END
	ELSE IF @declaredDataType = 'xml' 
	BEGIN
        -- Read XML content
        SET @eltXml = @eltXml.query('(/run-value[1]/value/*)[1]')
        
        IF @xpath IS NULL
        BEGIN
            -- No XPath, so return all xml data
            SET @runtimeValue = CONVERT(NVARCHAR(MAX), @eltXml)
        END
        ELSE 	
        BEGIN
            -- XPath in formula in not supported yet
            RETURN N'sploggerUT:## XPath "'+@xpath+'" in formula in not supported yet. ##'
        END
	END
	ELSE
	BEGIN
        IF @xpath IS NOT NULL
        BEGIN
            -- XPath/Complement are only allowed on ResultSet and XML values		
            RETURN N'sploggerUT:## Complementary path not allowed for "'+@declaredDataType+'" value of "'+@utKey+'" ##'
        END     
		-- Not a ResultSet or Xml. Getting Value
		SET @runtimeValue = @eltXml.value('(/run-value[1]/value[text()])[1]', 'NVARCHAR(MAX)')    
	END
        
    RETURN @runtimeValue
END
go


-- Creating tagging synonym
CREATE synonym [sploggerUT].[UnitTestHistory 1.3] for [sploggerUT].[UnitTestHistory]
GO

