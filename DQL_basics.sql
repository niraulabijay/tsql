/*
Assignment : HumanResources.Employee table
*/

USE AdventureWorks2017
go

-- find all jobtitle that starts with e and ends with r
SELECT DISTINCT JobTitle FROM HumanResources.Employee WHERE JobTitle LIKE 'e%r';
go

-- find the jobtitle that have 3rd letter as a
SELECT DISTINCT JobTitle FROM HumanResources.Employee WHERE JobTitle LIKE '__a%';
go

-- Find all employees whose jobtitle starts with a,m,s and ends with e,s
SELECT * FROM HumanResources.Employee WHERE JobTitle LIKE '[a,m,s]%[e,s]';
go

-- Find all employees whose jobtitle does not start with P
SELECT * FROM HumanResources.Employee WHERE JobTitle NOT LIKE '[p]%';
go

-- Find all jobtitle's that have atleast 3 a's 
-- ??
-- ?? can be achieved with length fcn, not sure with wildcard only though
SELECT * FROM HumanResources.Employee WHERE JobTitle LIKE '%a%a%a%';

go

-- find all jobtitle's that have letter 'a' exactly 3 times
-- ??
-- ?? can be achieved with length fcn, not sure with wildcard only though
SELECT * FROM HumanResources.Employee WHERE JobTitle LIKE '%a%a%a%' AND JobTitle NOT LIKE '%a%a%a%a%';

go

-- jobtitle should have keyword 'Designer' or 'Manager'
SELECT DISTINCT JobTitle FROM HumanResources.Employee WHERE JobTitle LIKE '%Designer%' OR JobTitle LIKE '%Manager%';
go
-- Find all jobtitles starting with either a,f or s
SELECT DISTINCT JobTitle FROM HumanResources.Employee WHERE JobTitle LIKE '[a,f,s]%';
go
-- Find all jobtitles starting anywhere between a to s
SELECT DISTINCT JobTitle FROM HumanResources.Employee WHERE JobTitle LIKE '[a-s]%';
go
-- Find the jobtitle that have atleast 2 underscores


-- whose title has 4th character as 'k' and 5th last character as 'a'
SELECT DISTINCT JobTitle FROM HumanResources.Employee WHERE JobTitle LIKE '___k%a____';
go
-- jobtitles have one % and end with an _
SELECT DISTINCT JobTitle FROM HumanResources.Employee  WHERE JobTitle LIKE '%[%]%' AND JobTitle LIKE '%[_]';
go

--jobtitles that do not start with E but end with E
-- Select * FROM HumanResources.Employee
SELECT DISTINCT JobTitle FROM HumanResources.Employee WHERE JobTitle NOT LIKE 'e%' AND JobTitle LIKE '%e';
go

-- title does not start with a,b,c,e but if it starts with s it has to end with r
SELECT DISTINCT JobTitle FROM HumanResources.Employee WHERE JobTitle NOT LIKE '[abce]%' AND (JobTitle NOT LIKE 's%' OR JobTitle LIKE 's%r');
go


------------------------------------------------------------------

/*
Photo Assignment 1
*/

Use LUCIDEX;
go

CREATE TABLE MovieReview(
  ReviewID INT PRIMARY KEY,
  MovieName VARCHAR(100) NOT NULL,
  Hero VARCHAR(100),
  Heroine VARCHAR(100),
  Review VARCHAR(1000) NOT NULL
)
GO

INSERT INTO MovieReview VALUES
(1, 'Eraser', 'Arnold', 'Vanessa', 'Vanessa does not have much role in movie, but Arnold did a good job'),
(2, 'Titanic', 'Leonardo', 'Kate', 'Initially I felt Kate might look older than hero but after watching I did not feel the same'),
(3, 'Zootopia', 'Ginnifer', 'Jason', 'Animation and screen play was good, not many 3D effects')
GO

-- Find names of the movies in which review mentioned both Hero and Heroine names.
SELECT * FROM MovieReview WHERE Review LIKE '%'+Hero+'%' AND Review LIKE '%'+Heroine+'%';

go


------------------------------------------------------------------
/*
Photo Assignment 2
*/

CREATE Table Person (
    PersonID INT PRIMARY KEY,
    Name VARCHAR(100),
    Gender TINYINT,
    Salary DECIMAL(10, 2),
    MaritalStatus CHAR(1)
);


-- ALTER TABLE Person ADD CONSTRAINT Val_Gender WHERE Gender in (1,0) 

ALTER TABLE Person ADD CONSTRAINT Val_Gender CHECK (Gender in (1,0));

ALTER TABLE Person ADD CONSTRAINT Val_MaritalStatus CHECK (MaritalStatus in ('M','S','W'));
 
CREATE TABLE Provider (
    ProviderID INT PRIMARY KEY,
    ProviderName VARCHAR(100),
    ProviderSpecialty VARCHAR(100),
    DateOfBirth DATE,
    Gender TINYINT CHECK (Gender IN (0, 1)),
    Phone CHAR(10)
);

CREATE TABLE AddressData (
	AddressId INT NOT NULL PRIMARY KEY,
	City VARCHAR(100),
    ZIP CHAR(5),
    Street VARCHAR(100),
    StreetType VARCHAR(50),
    StreetNumber INT,
    StreetDirection VARCHAR(10),
    State CHAR(2)
);

-- SELECT * FROM AddressData

ALTER TABLE Provider
	ADD AddressId INT;
ALTER TABLE Provider
	ADD CONSTRAINT FK_Address FOREIGN KEY (AddressId) REFERENCES AddressData(AddressId);