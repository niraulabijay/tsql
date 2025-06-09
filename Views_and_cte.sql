use AdventureWorks2017;
go
/*
1.	Create a VIEW to display SalesPerson, SalesAmount, 
MaxSalesBySalesPerson (out of all sales by a sales person max sales amount), 
MinSalesBySalesPerson (out of all sales by a sales person min sales amount), 
TotalSalesBySalesPerson (sum of all sales by a sales person), 
OrganizationAvgSales (average of all transactions for all sales person), 
OrganizationTotalSales (sum of all transactions for all sales person). 
Details should not be lost there are 13 rows in the table and output should 
have 13 rows. 
*/

/*
SELECT DISTINCT SalesPersonID from Sales.SalesOrderHeader WHERE SalesPersonID IS NOT NULL; -- 17 rows

SELECT   DISTINCT SalesPersonID FROm Sales.Store;
SELECT * FROM Sales.Store;
Select TOP 5 * FROM Sales.SalesPerson;
Select TOP 5 * FROM Sales.SalesTerritory;
Select * FROM Sales.SalesOrderHeader WHERE SalesOrderID=43659;
Select SUM(LineTotal) FROM Sales.SalesOrderDetail WHERE SalesOrderID = 43659;

Select S.Name FROM Sales.SalesOrderHeader SH LEFT JOIN Sales.Store S ON SH.SalesPersonID = S.SalesPersonID;

SELECT MAX(SubTotal), MIN(SubTotal) FROM Sales.SalesOrderHeader WHERE SalesPersonID=278;
         85982.4771        22.794
*/

Go

CREATE OR ALTER VIEW aggregateSales 
AS 
SELECT SS.SalesPersonID, PP.FirstName, PP.LastName, 
	   MAX(SOH.SubTotal) AS MaxSalesBySalesPerson, 
	   MIN(SOH.SubTotal) As MinSalesBySalesPerson,
	   SUM(SOH.SubTotal) As TotalSalesBySalesPerson,
	   (SELECT AVG(SubTotal) FROM Sales.SalesOrderHeader) As OrganizationAvgSales,
	   (SELECT SUM(SubTotal) FROM Sales.SalesOrderHeader) As OrganizationTotalSales
	FROM Sales.SalesOrderHeader SOH
	JOIN Sales.Store SS  -- This join reduces total to 13 rows
		ON SS.SalesPersonID = SOH.SalesPersonID
	JOIN Sales.SalesPerson SP
		ON SS.SalesPersonID = SP.BusinessEntityID
	JOIN Person.Person PP
		ON PP.BusinessEntityID = SP.BusinessEntityID
	GROUP BY SS.SalesPersonID, PP.FirstName, PP.LastName

go

SELECT * FROM aggregateSales;

go
-- *****************************************************************
/*
2. Create another VIEW referencing above VIEW without details 
(one row for each employee)
 no need of individual sales transaction details required.
 */

-- Use Sales.SalesOrderHeader table
-- Calculate totalsales for each salesperson in each year

--expected output:
/*SPID	YEAR	TOTALSALES TotalOrgSalesinthatyear
1		2018	1000		3000
1		2017	1500		5000
2		2018	2000		3000
3		2017	3500		5000
*/
CREATE OR ALTER VIEW aggregateSalesByYear WITH ENCRYPTION
AS 
SELECT SOH.SalesPersonID, DATEPART(Year, SOH.OrderDate) as [Year], 
	   SUM(SOH.SubTotal) As TotalSales,
	   (SELECT SUM(SubTotal) FROM Sales.SalesOrderHeader WHERE DATEPART(Year, OrderDate) = DATEPART(Year, SOH.OrderDate)) As TotalOrgSalesinthatyear
	FROM Sales.SalesOrderHeader SOH
	JOIN Sales.SalesPerson SP
		ON SP.BusinessEntityID = SOH.SalesPersonID
	GROUP BY DATEPART(Year, SOH.OrderDate), SOH.SalesPersonID

go

SELECT * FROM aggregateSalesByYear Order By SalesPersonID, [Year];

GO

/*****************************************************************
-- PRINT 1 to 100 without using Loops */

WITH counterLogic (counter) 
AS
(
	SELECT counter = CAST(1 as INT) UNION ALL  -- anchor
	SELECT counter+1 FROM counterLogic   -- recursive part
		WHERE counter < 100   -- terminating logic
)
SELECT * FROM counterLogic;
GO
/******************************************************************
-- Print factorial of 1 to 10 */

WITH PrintFactorial (num, factorial)
AS
(
	SELECT num = CAST(1 as INT), factorial = CAST(1 as INT) UNION ALL -- anchor
	SELECT num = num+1, factorial=factorial*(num+1) FROM PrintFactorial -- recursive
		WHERE num < 10 -- terminating
)
SELECT * FROM PrintFactorial;
GO
/*******************************************************************
-- PRINT A to Z using recursive CTE */

WITH counterLogic (counter, alphabet) 
AS
(
	SELECT counter = CAST(65 as INT), alphabet = char(CAST(65 as INT)) -- anchor
	UNION ALL  
	SELECT counter+1, alphabet = char(counter+1) FROM counterLogic         -- recursive part
		WHERE counter < 90                    -- terminating 
)
SELECT alphabet FROM counterLogic;

GO
/******************************************************************
-- Print first 10 fibonacci numbers */

WITH fibonacci (counter, num1, num2) 
AS
(
	SELECT counter = CAST(1 as INT), num1 = CAST(0 as INT), num2 = CAST(1 as INT)
	UNION ALL
	SELECT counter+1, num1=num2, num2=num1+num2 FROM fibonacci
	WHERE counter < 10
)
SELECT num2 as sequence FROM fibonacci;
GO

/*********************************************************************/
-- Create an Employee table.  
USE LUCIDEX
GO

CREATE TABLE dbo.MyEmployees  
(  
EmployeeID smallint NOT NULL,  
FirstName nvarchar(30)  NOT NULL,  
LastName  nvarchar(40) NOT NULL,  
Title nvarchar(50) NOT NULL,  
DeptID smallint NOT NULL,  
ManagerID int NULL,  
 CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC)   
);  
-- Populate the table with values.  
INSERT INTO dbo.MyEmployees VALUES   
 (1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL)  
,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1)  
,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273)  
,(275, N'Michael', N'Blythe', N'Sales Representative',3,274)  
,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274)  
,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273)  
,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285)  
,(16,  N'David',N'Bradley', N'Marketing Manager', 4, 273)  
,(23,  N'Mary', N'Gibson', N'Marketing Specialist', 4, 16);  
 
select * from dbo.MyEmployees

/*Using a recursive common table expression to display multiple levels of recursion 
to show hierarchy of managers and employees who report to them */
GO

WITH employeeHeirarchy (EmpId, FullName, Title, Heirarchy, manager)
AS
(
	SELECT EmployeeID, CAST(CONCAT(FirstName,LastName) AS VARCHAR(100)) AS FullName, Title, Heirarchy = 1, CAST('' as VARCHAR(100)) 
		FROM dbo.MyEmployees 
		WHERE ManagerID IS NULL
	UNION ALL
		SELECT e.EmployeeID, CAST(CONCAT(FirstName,LastName) AS VARCHAR(100)) as FullName, e.Title, Heirarchy = h.Heirarchy+1, h.FullName 
			FROM dbo.MyEmployees e
			INNER JOIN employeeHeirarchy h
				ON e.ManagerID = h.EmpId
)
SELECT * FROM employeeHeirarchy
GO

/*********************THE END**************************/