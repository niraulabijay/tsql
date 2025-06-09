
-- ==============================================
-- INSERT SCRIPTS FOR STAR SCHEMA ASSIGNMENT
-- ==============================================
Use StarSchemaAssignment;
-- ===== DimDate =====
-- Default row (used for ON DELETE/UPDATE SET DEFAULT)
INSERT INTO DimDate (DateKey, FullDate, Month, Quarter, Year)
VALUES (-1, '1900-01-01', 1, 1, 1900); -- Required default value

-- Valid data rows
INSERT INTO DimDate (DateKey, FullDate, Month, Quarter, Year)
VALUES (101, '2023-01-01', 1, 1, 2023);
INSERT INTO DimDate (DateKey, FullDate, Month, Quarter, Year)
VALUES (102, '2023-06-15', 6, 2, 2023);
INSERT INTO DimDate (DateKey, FullDate, Month, Quarter, Year)
VALUES (103, '2023-09-10', 9, 3, 2023);
-- This will fail CHECK constraint (Month > 12)
-- INSERT INTO DimDate VALUES (104, '2023-13-01', 13, 1, 2023); -- Test Check Constraint

-- ===== DimEmployee =====
INSERT INTO DimEmployee (EmployeeID, FirstName, LastName, Gender, JobTitle)
VALUES (-1, 'Default', 'Employee', 'M', 'Unknown'); -- Required default value

-- Valid data
INSERT INTO DimEmployee VALUES (201, 'Alice', 'Andrews', 'F', 'Analyst');
INSERT INTO DimEmployee VALUES (202, 'Bob', 'Baker', 'M', 'Accountant');
INSERT INTO DimEmployee VALUES (203, 'Cathy', 'Cole', 'F', DEFAULT); -- Test default JobTitle
-- This will fail Gender constraint
-- INSERT INTO DimEmployee VALUES (204, 'Test', 'Person', 'X', 'Tester'); -- Test Check Constraint

-- ===== DimProduct =====
INSERT INTO DimProduct (ProductID, ProductName, Category, Price)
VALUES (-1, 'DefaultProduct', DEFAULT, 0.01); -- Required default value and default Category

-- Valid data
INSERT INTO DimProduct VALUES (301, 'Laptop', 'Electronics', 899.99);
INSERT INTO DimProduct VALUES (302, 'Desk Lamp', 'Furniture', 49.99);
INSERT INTO DimProduct VALUES (303, 'Whiteboard', DEFAULT, 59.99); -- Test default Category
-- This will fail price check
-- INSERT INTO DimProduct VALUES (304, 'BrokenItem', 'Junk', -10); -- Test Check Constraint

-- ===== DimStore =====
INSERT INTO DimStore (StoreID, StoreName, Region)
VALUES (-1, 'DefaultStore', DEFAULT); -- Required default value and default Region

-- Valid data
INSERT INTO DimStore VALUES (401, 'EastMart', 'East');
INSERT INTO DimStore VALUES (402, 'NorthMart', 'North');
INSERT INTO DimStore VALUES (403, 'WestMart', 'West');
-- Invalid region
-- INSERT INTO DimStore VALUES (404, 'CentralStore', 'Central'); -- Test Check Constraint

-- ===== DimCustomer =====
INSERT INTO DimCustomer (CustomerID, FullName, Age, Gender, Email)
VALUES (-1, 'Default Customer', 0, DEFAULT, 'unknown@example.com'); -- Required default value and default Gender

-- Valid customers
INSERT INTO DimCustomer VALUES (501, 'John Doe', 28, 'M', 'john@example.com');
INSERT INTO DimCustomer VALUES (502, 'Jane Smith', 34, 'F', 'jane@example.com');
INSERT INTO DimCustomer VALUES (503, 'Emily Clarke', 22, 'F', 'emily@example.com');
INSERT INTO DimCustomer VALUES (504, 'Michael Brown', 45, 'M', 'michael@example.com');
INSERT INTO DimCustomer VALUES (505, 'Lisa Taylor', 31, 'F', 'lisa@example.com');
INSERT INTO DimCustomer VALUES (506, 'Daniel Wilson', 36, 'M', 'daniel@example.com');
INSERT INTO DimCustomer VALUES (507, 'Samantha Lee', 18, 'F', 'samantha@example.com');
INSERT INTO DimCustomer VALUES (508, 'George Martin', 29, 'M', 'george@example.com');
INSERT INTO DimCustomer VALUES (509, 'Olivia Johnson', 38, 'F', 'olivia@example.com');
INSERT INTO DimCustomer VALUES (510, 'David Clark', 65, 'M', 'david@example.com');
INSERT INTO DimCustomer VALUES (511, 'Grace Miller', 26, 'F', 'grace@example.com');
INSERT INTO DimCustomer VALUES (512, 'Henry Adams', 33, 'M', 'henry@example.com');
-- Invalid age
-- INSERT INTO DimCustomer VALUES (513, 'Old Joe', 130, 'M', 'joe@old.com'); -- Test Check Constraint

-- ===== FactSales =====
-- Insert facts with real keys
INSERT INTO FactSales (SalesID, DateKey, EmployeeID, ProductID, StoreID, CustomerID, SaleAmount, Quantity, TransactionType)
VALUES (1, 101, 201, 301, 401, 501, 500.00, 1, 'Online');

INSERT INTO FactSales (SalesID, DateKey, EmployeeID, ProductID, StoreID, CustomerID, SaleAmount, Quantity, TransactionType)
VALUES (2, 102, 202, 302, 402, 502, 60.00, 2, 'In-Store');
