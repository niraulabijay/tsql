--Find the reverse of an int
DECLARE @num INT;
DECLARE @rev INT = 0;
DECLARE @rem INT  = 0;
SET @num = 543;

DECLARE @original int = @num;

WHILE @num>0
BEGIN
	SET @rem = @num%10; -- extract last digit as a remainder when divided by 10
	SET @num = @num/10; -- interger division by 10 removes the last digit
	
	PRINT @rem
	PRINT @num
	
	SET @rev = @rev*10 + @rem
END
SELECT @original as [Initial Number], @rev as Reverse

GO

--Find if the number is palindrome or not (121 is a palindrome, 123 is not)
DECLARE @num INT;
DECLARE @rev INT = 0;
DECLARE @rem INT  = 0;
SET @num = 54345;

DECLARE @original int = @num;

WHILE @num>0
BEGIN
	SET @rem = @num%10;  -- extract last digit as a remainder when divided by 10
	SET @num = @num/10;
	
	PRINT @rem
	PRINT @num
	
	SET @rev = @rev*10 + @rem -- append remainder to the get reverse
END

SELECT IIF(@original = @rev, 'Palindrone', 'Not Palindrome') as Result

GO

/*Loop through each row in the Employee table and check each employees sick leave hours
If they have been sick more than 40 hours, print a message that says
“Very prone the sickness”
If they have less than 40 hours but more than 20, print a message that says
“Moderately prone to sickness”
If they have less than 20 hours, print a message that says
“Rarely sick at all”*/
-- SELECT * FROM HumanResources.Employee
USE AdventureWorks2017;

SELECT BusinessEntityID, SickleaveHours, CASE WHEN SickLeaveHours > 40 THEN 'Very Prone to sickness'
											  WHEN SickLeaveHours > 20 THEN 'Moderately prone to sickness'
											  ELSE 'Rarely sick at all' 
											  END AS [Sick Status]
	FROM HumanResources.Employee


GO

/* give me the factorial of the number pass by user*/

DECLARE @num INT;
DECLARE @fact INT = 1;
DECLARE @count INT  = 2;
SET @num = 5;


WHILE @count <= @num
BEGIN
	SET @fact = @fact*@count;
	SET @count = @count+1;	
	PRINT @fact
	PRINT @count
END

SELECT @num as [Input], @fact as Factorial;

GO

/* user will pass any number write a code to check the number is prime or not*/


DECLARE @num INT;
DECLARE @divisible INT = 0;
DECLARE @count INT  = 1;
SET @num = 23;


WHILE @count <= @num/2  -- Loop only till half of the original number as we dont need to check it is divisible by itself
BEGIN
	IF(@num % @count = 0)
		SET @divisible = @divisible + 1;
	SET @count = @count+1;
END

SELECT @num as [Input], IIF(@divisible>1,'Not Prime','Prime') as [Result];

GO 


/* user will pass any string write a code to check the string is palindrom or not*/

-- Easy way
DECLARE @input VARCHAR(100) = 'Madam';
DECLARE @rev VARCHAR(100) = REVERSE(@input);

SELECT @input as Input, IIF(LOWER(@input) = LOWER(@rev),'Palindrome', 'NOT Palindrome') as Result;

GO

-- Traditional way

DECLARE @input VARCHAR(100) = 'Madam';
DECLARE @rev VARCHAR(100) = '';

DECLARE @divisible INT = 0;
DECLARE @count INT  = 0;

DECLARE @original VARCHAR(100) = @input;

WHILE @count < LEN(@original) -- loop through length of the string
BEGIN
	SET @rev = @rev + RIGHT(@input, 1) -- Take the last character and append to reverse var
	SET @input = LEFT(@input, LEN(@input)-1) -- Remove the last character
	SET @count = @count+1;
END
print @rev
SELECT @original as Input, IIF(LOWER(@original) = LOWER(@rev),'Palindrome', 'NOT Palindrome') as Result;

GO

USE LUCIDEX;


Create table cOrder(
Oid int identity(1,1),
Oqty int,
Odate date,
PricePerQty int);


Insert Into cOrder (Oqty, Odate, PricePerQty)
Values(10, '2019-10-20', 100),
	  (10, '2019-11-20', 120),
	  (10, '2019-11-20', 140),
	  (10, '2019-12-20', 200),
	  (10, '2019-10-20', 400),
	  (10, '2019-11-20', 220),
	  (10, '2019-09-20', 230),
	  (10, '2019-09-20', 430),
	  (10, '2019-12-20', 500);
Go

Select * From cOrder;
--Questions
--Corder(Oid, Oqty, Odate, Priceperqty)
--I need 2 derived coloumns 
 --1) Total Price and 2) Net Price after discount
-- if order is before oct then gove a discount of $50 total order amount
---If Order is beteen Oct to Nov give the discount of $ 100 on total order amount
--If Order is beteen Nov to Dec give the discount of $ 150 on total order amount
-- Else if after Dec give $ 200 discount on total order amount

USE LUCIDEX;

SELECT Oid, Oqty, Odate, PricePerQty, Oqty*PricePerQty As TotalPrice, 
			CASE WHEN DATEPART(Month, Odate) > 11 THEN Oqty*PricePerQty - 200
				 WHEN DATEPART(Month, Odate) > 10 THEN Oqty*PricePerQty - 150
				 WHEN DATEPART(Month, Odate) > 9 THEN Oqty*PricePerQty - 100
				 ELSE Oqty*PricePerQty - 50
				 END As NetPrice
	FROM cOrder;


--categorize the order if qty<150 then Level 1 if between 150 to 250 then level 2 more tham level3 

-- I changed qty to PricePerQty since qty shows level 1 only 
SELECT Oid, Oqty, Odate, PricePerQty, Oqty*PricePerQty As TotalPrice, 
			CASE WHEN PricePerQty > 250 THEN 'Level 3'
				 WHEN PricePerQty > 150 THEN 'Level 2'
				 ELSE 'Level 1'
				 END As OrderLevel
	FROM cOrder;
