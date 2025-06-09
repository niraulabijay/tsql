CREATE DATABASE StarSchemaAssignment;
go

Use StarSchemaAssignment;
/*
===========================================================
STAR SCHEMA ASSIGNMENT
===========================================================

INSTRUCTIONS:
- Create the required dimension and fact tables
- Apply all necessary constraints
- Insert provided data
- Answer the aggregation queries (Q1 - Q5) at the bottom
*/

-- ====================================
-- PART 1: CREATE DIMENSION TABLES
-- ====================================

-- Create 5 Dimension Tables:
-- 1. DimDate (DateKey, FullDate, Month, Quarter, Year)
--    - CHECK Month BETWEEN 1 AND 12
--    - DEFAULT Quarter = 1, CHECK Quarter BETWEEN 1 AND 4
CREATE TABLE DimDate (
	DateKey INT NOT NULL PRIMARY KEY DEFAULT(-1),
	FullDate Date NOT NULL,
	Month INT CHECK (Month > 0 AND Month <13),
	Quarter INT CHECK (Quarter >= 1 AND Quarter <= 4) DEFAULT  (1),
	Year INT
);
go
-- DROP TABLE DimDate;


-- 2. DimEmployee (EmployeeID, FirstName, LastName, Gender, JobTitle)
--    - CHECK Gender IN ('M', 'F')
--    - DEFAULT JobTitle = 'Unknown'
CREATE TABLE DimEmployee (
	EmployeeID INT NOT NULL PRIMARY KEY DEFAULT(-1),
	FirstName VARCHAR(20) NOT NULL,
	LastName Varchar(20),
	Gender CHAR(1) CHECK (Gender IN ('M','F')),
	Jobtitle VARCHAR(10) DEFAULT('Unknown')
);
-- DROP TABLE DimEmployee


-- 3. DimProduct (ProductID, ProductName, Category, Price)
--    - CHECK Price > 0 AND <= 10000
--    - DEFAULT Category = 'General'
CREATE TABLE DimProduct (
	ProductID INT NOT NULL PRIMARY KEY DEFAULT(-1),
	ProductName VARCHAR(30) NOT NULL,
	Category VARCHAR(30) DEFAULT('General'),
	Price DECIMAL(10,2)
);
go

ALTER TABLE DimProduct
	ADD CONSTRAINT CHK_PRICE CHECK (Price >0 AND Price <=10000);
-- ALTER TABLE DimProduct DROP CONSTRAINT CHK_PRICE;
-- DROP TABLE DimProduct
go

-- 4. DimStore (StoreID, StoreName, Region)
--    - CHECK Region IN ('East', 'West', 'North', 'South')
--    - DEFAULT Region = 'East'
CREATE TABLE DimStore(
	StoreID INT NOT NULL PRIMARY KEY DEFAULT(-1),
	StoreName VARCHAR(30) NOT NULL,
	Region VARCHAR(10) CHECK (Region IN ('East', 'West', 'North', 'South')) DEFAULT ('East')
);
-- DROP TABLE DimStore
go

-- 5. DimCustomer (CustomerID, FullName, Age, Gender, Email)
--    - CHECK Age BETWEEN 0 AND 120
--    - DEFAULT Gender = 'U'

CREATE TABLE DimCustomer (
	CustomerID INT NOT NULL Primary Key DEFAULT(-1),
	FullName Varchar(40) NOT NULL,
	Age INT CHECK (Age >=0 AND Age<=120),
	Gender CHAR(1) DEFAULT('U'),
	Email VARCHAR(30) CHECK (Email LIKE '%@%')
);

--ALTER TABLE DimCustomer ADD Email VARCHAR(30) CHECK (Email LIKE '%@%');

-- DROP TABLE DimCustomer
go

-- Add all appropriate NOT NULL constraints
-- Make sure each table has a PRIMARY KEY

-- ====================================
-- PART 2: CREATE FACT TABLE
-- ====================================

-- Create FactSales table with:
-- - SalesID (Primary Key)
-- - Foreign Keys to all 5 dimension tables
-- - SaleAmount (Decimal), Quantity (Int), TransactionType (Varchar)

-- DROP TABLE FactSales
CREATE TABLE FactSales(
	DateKey INT FOREIGN KEY REFERENCES DimDate(DateKey) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT,
	EmployeeID INT FOREIGN KEY REFERENCES DimEmployee(EmployeeID) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT,
	ProductID INT FOREIGN KEY REFERENCES DimProduct(ProductID) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT,
	StoreID INT FOREIGN KEY REFERENCES DimStore(StoreID) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT,
	CustomerID INT FOREIGN KEY REFERENCES DimCustomer(CustomerID) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT,

	SalesID INT NOT NULL PRIMARY KEY,
	SaleAmount DECIMAL(20,2),
	Quantity INT,
	TransactionType VARCHAR(30)
);

SELECT * FROM FactSales;

-- DROP TABLE FactSales

-- Foreign keys must include:
--   ON DELETE SET DEFAULT
--   ON UPDATE SET DEFAULT

-- This requires default records in each dimension table (use -1)

-- ====================================
-- PART 3: INSERT SCRIPTS
-- ====================================

-- Use the insert scripts provided in 'star_schema_assignment.sql'
-- Each DIM table must include:
--   - A default record with ID = -1
--   - At least 2 valid records
-- Include variations to test CHECK constraints
SELECT * FROM DimDate;

SELECT * From DimEmployee;

SELECT * FROM DimProduct;
DELETE FROM DimProduct WHERE ProductID=304;

SELECT * FROM DimStore;

SELECT * FROM DimCustomer;

-- ====================================
-- PART 4: QUERY SECTION
-- ====================================

-- Q1: Count the number of employees with JobTitle starting with 'A'
-- Write your query below:

SELECT COUNT(*) AS EmpCount FROM DimEmployee WHERE Jobtitle LIKE 'A%';

-- Q2: Count the number of products priced above $50
-- Write your query below:

SELECT COUNT(*) AS ProductCount FROM DimProduct WHERE Price > 50;
-- SELECT * FROM DimProduct;

-- Q3: Count the number of customers aged between 18 and 35
-- Write your query below:

SELECT COUNT(*) AS StoreCount FROM DimCustomer WHERE Age > 18 AND Age < 35;

-- Q4: List all distinct years from the DimDate table
-- Write your query below:

SELECT DISTINCT Year FROM DimDate;
-- SELECT * FROM DimDate

-- Q5: Count the number of stores grouped by Region
-- Write your query below:

-- SELECT * FROM DimStore
SELECT Region, COUNT(StoreName) AS StoreCount FROM DimStore GROUP BY Region;


