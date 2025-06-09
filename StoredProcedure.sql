/*1.  Write a SP that would accept StartRange and EndRange of BusinessEntityID and return all
   the records that fall in that specific range and JobTitle of an employee that exactly
   falls in the middle of the range
   (Columns Requested : BusinessEntityID, JobTitle, FirstName, LastName)
   Also, SP must be encrypted
*/
use AdventureWorks2017
GO

CREATE OR ALTER PROC sp_rangeEmployee (@StartRange INT, @EndRange INT) WITH ENCRYPTION , RECOMPILE
AS
BEGIN
	SELECT e.BusinessEntityID, e.JobTitle, p.FirstName, p.LastName
		FROM HumanResources.Employee e
		JOIN Person.Person p
			ON e.BusinessEntityID = p.BusinessEntityID
		WHERE e.BusinessEntityID > @StartRange AND e.BusinessEntityID < @EndRange
END


EXEC sp_rangeEmployee @StartRange = 200, @EndRange = 500;

GO
/*
2. Create a SP that will accept a table Name and get me all the column names along with their data-types and sizes.
--(Hints - sys.tables, sys.columns, sys.types, sys.schemas)
	select * from sys.tables
	select * from sys.columns
	select * from sys.schemas
	select * from sys.types
*/

CREATE OR ALTER PROC sp_tableWithColumns 
AS
BEGIN
	SELECT s.name, t.name, c.name, tp.name, 
		CASE WHEN tp.name IN ('varchar', 'nvarchar', 'char', 'nchar') THEN c.max_length * IIF(t.name IN ('nvarchar', 'nchar'), 2, 1)
			 WHEN tp.name IN ('decimal', 'numeric') THEN CASE WHEN c.precision > 29 THEN 17 WHEN c.precision > 19 THEN 13 WHEN c.precision > 9 THEN 9 ELSE 5 END
			 WHEN tp.name = 'money' THEN 8
			 ELSE c.max_length
			 END as size		 
		FROM sys.tables t
		JOIN sys.schemas s
			ON t.schema_id = s.schema_id
		JOIN sys.columns c
			ON t.object_id = c.object_id
		LEFT JOIN sys.types tp
			ON c.system_type_id = tp.system_type_id
END

EXEC sp_tableWithColumns

GO
/*
3. Create a SP that will accept Schema Name and Table Name and
   return me the corresponding info of their columns based on what user passes the input.
*/

CREATE OR ALTER PROC sp_tableWithColumnsDynamic (@SchemaName VARCHAR(50), @TableName VARCHAR(50)) 
AS
BEGIN
	SELECT s.name, t.name, c.* 
		FROM sys.tables t
		JOIN sys.schemas s
			ON t.schema_id = s.schema_id
		JOIN sys.columns c
			ON t.object_id = c.object_id
		WHERE s.name = @SchemaName AND t.name = @TableName
END

EXEC sp_tableWithColumnsDynamic @SchemaName = 'HumanResources', @TableName = 'Employee'

GO
/*
4. Write a SP to print first 50 Fibonacci numbers.
*/

CREATE OR ALTER PROC sp_FibonacciSequence
AS
BEGIN

    DECLARE @n1 INT = 0;
    DECLARE @n2 INT = 1;
    DECLARE @next INT;
    DECLARE @c INT = 1;

    PRINT @n1

    SET @c = @c + 1;
    PRINT @n2

    WHILE @c < 50
    BEGIN
        SET @next = @n1 + @n2;
        SET @c = @c + 1;
        PRINT @next;
        SET @n1 = @n2;
        SET @n2 = @next;
    END;
END;

EXEC sp_FibonacciSequence;

GO
/*
5. Write a SP take a string as an input and check if its Palindrome or not.
*/
CREATE OR ALTER PROC sp_CheckPalindrome (@input VARCHAR(100))
AS
BEGIN
    IF LOWER(@input) = REVERSE(LOWER(@input))
	BEGIN
        PRINT 'Palindrome';
	END
    ELSE
	BEGIN
        PRINT 'Not Palindrome';
	END
END;

EXEC sp_CheckPalindrome 'Madam'
EXEC sp_CheckPalindrome 'Hello'

GO
/*
6. Write a SP take a number as an input and check if its Armstrong number or not.
*/

CREATE PROCEDURE sp_CheckArmstrong @input INT
AS
BEGIN
    DECLARE @original INT = @input;
	DECLARE @inputLenght INT = LEN(CAST(@input AS VARCHAR(20)));
    DECLARE @sum BIGINT = 0;
    DECLARE @digit INT;

	WHILE @input > 0
	BEGIN
		SET @digit = @input % 10;
		SET @input = @input / 10;
		SET @sum = @sum + POWER(@digit, @inputLenght);
	END

    -- Check if Armstrong number
    IF @Sum = @original
        PRINT 'Armstrong';
    ELSE
        PRINT 'Not Armstrong';
END;

EXEC sp_CheckArmstrong 153;


/*
7. Create a SP that will accept a table Name and get me all the column names along with their data-types and sizes. 
*/
GO

CREATE OR ALTER PROC sp_tableWithColumnsQues7 @tableName Varchar(50) 
AS
BEGIN
	SELECT  c.name, tp.name, 
		CASE WHEN tp.name IN ('varchar', 'nvarchar', 'char', 'nchar') THEN c.max_length * IIF(t.name IN ('nvarchar', 'nchar'), 2, 1)
			 WHEN tp.name IN ('decimal', 'numeric') THEN CASE WHEN c.precision > 29 THEN 17 WHEN c.precision > 19 THEN 13 WHEN c.precision > 9 THEN 9 ELSE 5 END
			 WHEN tp.name = 'money' THEN 8
			 ELSE c.max_length
			 END as size		 
		FROM sys.tables t
		JOIN sys.columns c
			ON t.object_id = c.object_id
		LEFT JOIN sys.types tp
			ON c.system_type_id = tp.system_type_id
		WHERE t.name=@tableName
END

EXEC sp_tableWithColumnsQues7 'Employee'

