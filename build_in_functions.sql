/*
=========================================================
 SQL Assignment: Advanced Use of Built-in Functions
 Database: AdventureWorks2017
=========================================================

Objective:
Test your understanding of SQL built-in functions including 
Date Functions, String Functions, Logical Functions, and 
Mathematical Functions through real-world-style problems.

Instructions:
Write your SQL queries below each question using AdventureWorks2017.
*/

use AdventureWorks2017;

-- Q1: Extract Month Names
-- From Sales.SalesOrderHeader, return the full month name from OrderDate.

--SELECT * FROM Sales.SalesOrderHeader
SELECT DATENAME(Month,OrderDate) as MonthName FROM Sales.SalesOrderHeader;


-- Q2: Days Until End of Month
-- Calculate number of days between today (GETDATE()) and end of the current month.

SELECT DATEDIFF(Day, GETDATE(), EOMONTH(GETDATE()));


-- Q3: Case-Sensitive Filtering
-- From Person.Person, return rows where FirstName contains 'a' but not 'A'.

-- SELECT * FROM Person.Person WHERE FirstName LIKE '%a%' AND FIRSTNAME NOT LIKE '%A%' -- Doesnot work
-- SELECT * FROM Person.Person
-- REPLACE Case insensitive, doesnot work
-- SELECT * FROM Person.Person WHERE PATINDEX(FirstName,'%A%') = 0;
SELECT * FROM Person.Person WHERE LEN(FirstName COLLATE Latin1_General_BIN ) - LEN(Replace(FirstName COLLATE Latin1_General_BIN ,'A','')) = 0 AND LEN(FirstName COLLATE Latin1_General_BIN ) - LEN(Replace(FirstName COLLATE Latin1_General_BIN ,'a','')) > 0;  

-- Q4: Email Domain Extractor
-- From Person.EmailAddress, extract everything after '@' in EmailAddress.
-- SELECT PatIndex('%@%',EmailAddress) FROM Person.EmailAddress
SELECT Substring(EmailAddress, PatIndex('%@%',EmailAddress)+1,LEN(EmailAddress)) FROM Person.EmailAddress;

-- Q5: Dynamic Age Calculation
-- From HumanResources.Employee, calculate current age using BirthDate.
-- SELECT * FROM HumanResources.Employee
SELECT DATEDIFF(Year,BirthDate,GETDATE()) AS AGE, BirthDate FROM HumanResources.Employee; 

-- Q6: Conditional Salary Increase
-- In HumanResources.EmployeePayHistory, increase rate by:
-- 10% if DepartmentID = 10
-- 5% if DepartmentID = 20
-- SELECT * FROM HumanResources.Employee
-- SELECT * FROM HumanResources.EmployeePayHistory

DepartmentID  ??

-- Q7: Pad and Concatenate IDs
-- From Sales.Customer, generate AW0000CustomerID format (6-digit zero-padded).

--SELECT CustomerID, CONCAT('AW0000',CustomerID) AS CustomID FROM Sales.Customer
--SELECT LEN(12345);
SELECT CustomerID, CONCAT('AW',REPLICATE('0',6-LEN(CustomerID)),CustomerID) As CustomID FROM Sales.Customer;

-- Q8: Round Off to Nearest 100
-- From Sales.SalesOrderHeader, round TotalDue to the nearest 100.
-- SELECT * FROM Sales.SalesOrderHeader
SELECT TotalDue, ROUND(TotalDue,2) AS RoundedTotalDue FROM Sales.SalesOrderHeader;

-- Q9: Leap Year Checker
-- From YEAR(OrderDate) in Sales.SalesOrderHeader, return only leap years.
-- SELECT * FROM Sales.SalesOrderHeader
-- UPDATE Sales.SalesOrderHeader SET OrderDate='2000-05-31 00:00:00.000' FROM Sales.SalesOrderHeader WHERE SalesOrderID=43659;
-- UPDATE Sales.SalesOrderHeader SET OrderDate='1900-05-31 00:00:00.000' FROM Sales.SalesOrderHeader WHERE SalesOrderID=43660;
-- Above 2 queries modifies data to add year 2000 (leap year) and year 1900 (not a leap year)
SELECT YEAR(OrderDate) AS OrderYear FROM Sales.SalesOrderHeader WHERE (Year(OrderDate)%4 = 0 AND Year(OrderDate)%100 != 0) OR (Year(OrderDate)%100 = 0 AND Year(OrderDate)%400 = 0);

-- Q10: Weekday Name Formatter
-- From Person.Person using ModifiedDate, return text like: "Modified on Monday."
-- SELECT * FROM Person.Person;

SELECT CONCAT('Modified on',' ',DateName(Weekday,ModifiedDate)) AS ModifiedWeekDay, ModifiedDate FROM Person.Person;

-- Last Challenge:
-- Combine 3 or more functions to show:
-- "Customer AW000150 gets a 20% discount for spending over $1000."

-- DONT UNDERSTAND WHAT THE QUESTION IS ASKING ?? 
SELECT CustomerID, CONCAT('Customer',' ','AW',REPLICATE('0',6-LEN(CustomerID)),CustomerID, ' ','gets a 20% discount for spending over $1000.') As CustomID FROM Sales.Customer;




----------------------------------------------------------------------------------------------------------------------------
USE LUCIDEX;
GO
CREATE SCHEMA D8;
GO
-- Customer (Cid, Cname, City, grade, salesman)
CREATE TABLE D8.Customer(
	Cid INT NOT NULL PRIMARY KEY,
	Cname VARCHAR(30),
	City Varchar(30),
	grade INT,
	salesman_id INT
);
-- DROP TABLE D8.Customer

-- Order (ord_no, purch_amt,ord_date,customer_id,salesman_id)
CREATE TABLE D8.[Order](
	ord_no INT NOT NULL PRIMARY KEY,
	purch_amt INT,
	ord_date Date,
	customer_id INT FOREIGN KEY REFERENCES D8.Customer(Cid),
	salesman_id INT
);
-- DROP TABLE D8.[Order]
GO

INSERT INTO D8.Customer (Cid, Cname, City, grade, salesman_id) VALUES
(1, 'Alice Johnson', 'Fresno', 3, 101),
(2, 'Bob Smith', 'Clovis', 2, 102),
(3, 'Charlie Brown', 'Madera', 1, 103),
(4, 'David Williams', 'Fresno', 3, 101),
(5, 'Eva Davis', 'Clovis', 2, 104),
(6, 'Frank Miller', 'Madera', 1, 105);


INSERT INTO D8.[Order] (ord_no, purch_amt, ord_date, customer_id, salesman_id) VALUES
(1001, 1500, '2012-08-17', 1, 101),
(1002, 2500, '2012-08-17', 2, 102),
(1003, 3500, '2012-08-17', 3, 103),
(1004, 4500, '2012-08-17', 4, 101),
(1005, 5500, '2012-08-17', 5, 104),
(1006, 6500, '2012-08-17', 6, 105),
(1007, 2000, '2012-08-18', 1, 101),
(1008, 3000, '2012-08-18', 2, 102),
(1009, 4000, '2012-08-18', 3, 103),
(1010, 5000, '2012-08-18', 4, 101),
(1011, 6000, '2012-08-18', 5, 104),
(1012, 7000, '2012-08-18', 6, 105);


GO

-- Q1.	Write a SQL statement which selects the highest grade for each of the cities of the customers.
SELECT City, MAX(grade) as HighestGrade FROM D8.Customer GROUP BY City;

-- Q1.	Write a SQL statement to find the highest purchase amount ordered by each customer on a particular date with their ID, order date and highest purchase amount.
SELECT customer_id, ord_date, MAX(purch_amt) AS HighestPurchaseAmount FROM D8.[Order] GROUP BY customer_id,ord_date; 

-- 2.	Write a SQL statement to find the highest purchase amount on a date '2012-08-17' for each salesman with their ID.
SELECT salesman_id, MAX(purch_amt) AS HighestPurchaseAmount FROM D8.[Order] WHERE ord_date = '2012-08-17' GROUP BY salesman_id

-- 3.	Write a SQL statement to find the highest purchase amount with their ID and order date, for only those customers who have highest purchase amount in a day is more than 2000.
SELECT customer_id, ord_date, MAX(purch_amt) AS HighestPurchaseAmount FROM D8.[Order] GROUP BY customer_id, ord_date HAVING MAX(purch_amt) > 2000;

-- 4.	Write a SQL statement to find the highest purchase amount with their ID and order date, for those customers who have a higher purchase amount in a day is within the range 2000 and 6000.
SELECT customer_id, ord_date, MAX(purch_amt) AS HighestPurchaseAmount FROM D8.[Order] GROUP BY customer_id, ord_date HAVING MAX(purch_amt) > 2000 AND MAX(purch_amt) < 6000;

-- 5.	Write a SQL statement to find the highest purchase amount with their ID and order date, for only those customers who have a higher purchase amount in a day is within the list 2000, 3000, 5760 and 6000. 
SELECT customer_id, ord_date, MAX(purch_amt) AS HighestPurchaseAmount FROM D8.[Order] GROUP BY customer_id, ord_date HAVING MAX(purch_amt) IN (2000,3000,5760,6000);

-- 6.	Write a query that counts the number of salesmen with their order date and ID registering orders for each day. 
SELECT salesman_id, ord_date, Count(*) FROM D8.[Order] GROUP BY salesman_id, ord_date;


-- 7.	Write a SQL query to calculate the average purchase amount of each customer.
SELECT customer_id, AVG(purch_amt) AS AveragePurchaseAount FROM D8.[Order] GROUP BY customer_id;
