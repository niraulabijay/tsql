----------------------------------------------------------------------------------------------------------------------------------------
/* SQL Starter Script ** CANDIDATES - USE THIS IN YOUR SUBMISSION **
Here’s the problem: Let's say we had a table of all US Presidents, with the date they took office and the date they died.
Let's say I want to get the periods of time (start date / end date) where at least 3 US Presidents or former US Presidents
were alive at the same time, sorted in order of
1.) the most number of presidents/former presidents alive at one time and
2.) the longest period of time. Here's a sample resultset I am looking for:
NumberOfPresidentsAlive StartDate EndDate NumberOfDays
6 1/1/1853 12/31/1853 364
6 5/5/1854 5/6/1854 1
5 1/1/1854 3/1/1854 59
....
Note that the periods of time should be based on calendar date and that both efficiency and elegancy are highly desired properties of the solution.
However imperfect, solutions are expected to be authored by the submitter. For bonus points, include a column with a comma separated list of the
president's names.
*/
use TEST_DB;
GO

IF OBJECT_ID('tempdb..#President') IS NOT NULL DROP TABLE #President;
Create table #President
(
PresidentID INT IDENTITY(1,1) PRIMARY KEY,
Name varchar(60),
StartDate date,
DiedDate date
) WITH (DATA_COMPRESSION=PAGE);
go
-- Data Source: https://en.wikipedia.org/wiki/List_of_Presidents_of_the_United_States_by_date_of_death
Insert into #President(Name,StartDate,DiedDate)
values
('George Washington','4/1/1789','12/14/1799')
,('Thomas Jefferson','3/4/1801','7/4/1826')
,('John Adams','3/4/1797','7/4/1826')
,('James Monroe','3/4/1817','7/4/1831')
,('James Madison','3/4/1809','6/28/1836')
,('William Henry Harrison','3/4/1841','4/4/1841')
,('Andrew Jackson','3/4/1829','6/8/1845')
,('John Quincy Adams','3/4/1825','2/23/1848')
,('James K. Polk','3/4/1845','6/15/1849')
,('Zachary Taylor','3/4/1849','7/9/1850')
,('John Tyler','4/4/1841','1/18/1862')
,('Martin Van Buren','3/4/1837','7/24/1862')
,('Abraham Lincoln','3/4/1861','4/15/1865')
,('James Buchanan','3/4/1857','6/1/1868')
,('Franklin Pierce','3/4/1853','10/8/1869')
,('Millard Fillmore','7/9/1850','3/8/1874')
,('Andrew Johnson','4/15/1865','7/31/1875')
,('James A. Garfield','3/4/1881','9/19/1881')
,('Ulysses S. Grant','3/4/1869','7/23/1885')
,('Chester A. Arthur','9/19/1881','11/18/1886')
,('Rutherford B. Hayes','3/4/1877','1/17/1893')
,('Benjamin Harrison','3/4/1889','3/13/1901')
,('William McKinley','3/4/1897','9/14/1901')
,('Grover Cleveland','3/4/1885','6/24/1908')
--,('Grover Cleveland','3/4/1893', '6/24/1908'),
,('Theodore Roosevelt','9/14/1901','1/6/1919')
,('Warren G. Harding','3/4/1921','7/2/1923')
,('Woodrow Wilson','3/4/1913','2/3/1924')
,('William Howard Taft','3/4/1909','3/8/1930')
,('Calvin Coolidge','7/2/1923','1/5/1933')
,('Franklin D. Roosevelt','3/4/1933','4/12/1945')
,('John F. Kennedy','1/20/1961','11/22/1963')
,('Herbert Hoover','3/4/1929','10/20/1964')
,('Dwight D. Eisenhower','1/20/1953','3/28/1969')
,('Harry S. Truman','4/12/1945','12/26/1972')
,('Lyndon B. Johnson','11/22/1963','1/22/1973')
,('Richard Nixon','1/20/1969','4/22/1994')
,('Ronald Reagan','1/20/1981','6/5/2004')
,('Gerald Ford','7/9/1974','12/26/2006')
,('Jimmy Carter','1/20/1977',Null)
,('George H. W. Bush','1/20/1989',Null)
,('Bill Clinton','1/20/1993',Null)
,('George W. Bush','1/20/2001',Null)
,('Barack Obama','1/20/2009',Null)
,('Donald Trump','1/20/2017',Null);


/*
Select * From #President ORDER BY StartDate,DiedDate;

SELECT * FROM #President WHERE DATEPART(Year, DiedDate) = 1853;

Declare @StartDate date;
Declare @EndDate date;
Declare @alivePresidents INT = 1;
DECLARE @finalData TABLE(Number INT, StartDate Date, EndDate Date);
SELECT @StartDate = MIN(StartDate) FROM #President;

WHILE @StartDate < @EndDate
BEGIN
	PRINT 'Here'
	SELECT COUNT(*) FROM #President WHERE DiedDate > @StartDate
	SET @StartDate = '2020-10-10'
END
*/
DECLARE @allDates TABLE(EventDate Date);

INSERT INTO @allDates SELECT DISTINCT StartDate AS EventDate FROM #President
    UNION
SELECT DISTINCT DiedDate FROM #President WHERE DiedDate IS NOT NULL;

-- SELECT * FROM @allDates

DECLARE @eventDates TABLE(EventDate Date, NextEventDate Date);
INSERT INTO @eventDates SELECT EventDate, 
           LEAD(EventDate) OVER (ORDER BY EventDate) AS NextEventDate
    FROM @allDates;

-- select * FROM @orderedEventDates

DECLARE @periodOfTime TABLE(StartDate Date, EndDate Date);
INSERT INTO @periodOfTime SELECT EventDate AS StartDate, 
           DATEADD(day, -1, NextEventDate) AS EndDate
    FROM @eventDates
    WHERE NextEventDate IS NOT NULL


-- SELECT * FROM @periodOfTime;

 
SELECT C.NumberOfPresidentsAlive, 
       C.StartDate, 
       C.EndDate, 
       DATEDIFF(day, C.StartDate, C.EndDate) + 1 AS NumberOfDays
FROM (   SELECT StartDate, P.EndDate,
           (SELECT COUNT(*) FROM #President PR 
            WHERE PR.StartDate <= P.StartDate AND (PR.DiedDate > P.StartDate OR PR.DiedDate IS NULL)) AS NumberOfPresidentsAlive
    FROM @periodOfTime P
) As C
WHERE C.NumberOfPresidentsAlive >= 3
ORDER BY C.NumberOfPresidentsAlive DESC, NumberOfDays DESC;


GO
-------------------------------------------------------------------------------------------------------------------------------------------

--Interview SQL Question
use TEST_DB;


Create table Visitor(
	VID int,
	VName varchar(30));

Create table Tour(
	VID int,
	City varchar(30),
	tDate date);

Insert Into Visitor Values
(1, 'Sam'),
(2, 'Mark'),
(3, 'Louis');

Insert Into Tour Values
(1, 'Redmond', '02-01-2020'),
(1, 'Louisville', '02-01-2019'),
(2, 'Seattle', '10-11-2019'),
(3, 'Sanroman', '01-01-2020'),
(3, 'Portland', '04-01-2019'),
(3, 'Chicago', '05-01-2018');

Select * From Visitor;
Select * From Tour;

-- Visitors who have count(city) > 2
SELECT V.VName, count(*) as visit_count 
	from Tour as T
	JOIN Visitor V
		ON V.VID = T.VID
	GROUP BY V.VName
	HAVING count(*) > 2;

--  give visitor names who visited 1 year ago and also visited 2 
--  cities (i.e.today`s date -> 04/23/20 so give naames who visited on or before 04/22/2019) 

-- PRINT CAST('04/23/20' as date)
-- PRINT DATEADD(Year,-1,CAST('04/23/20' as date)) 

-- Method 1
SELECT V.VName
	FROM (
		SELECT VID, count(*) as v_count 
			from Tour 
			WHERE tDate < DATEADD(Year,-1,CAST('04/23/20' as date)) 
			Group By VID
	) as visitor_counts
	LEFT JOIN Visitor V
		ON V.VID = visitor_counts.VID
	WHERE v_count = 2;

-- Method 2
SELECT V.VName, count(*) as visit_count 
	from Tour as T
	JOIN Visitor V
		ON V.VID = T.VID
	WHERE T.tDate < DATEADD(Year,-1,CAST('04/23/20' as date))
	GROUP BY V.VName
	HAVING count(*) = 2;


-------------------------------------------------------------------------------------------------------------------------------------------

/* 
Product Table
Columns
Category
Product
Price
*/

CREATE TABLE Product(
	Category VARCHAR(100),
	Product Varchar(100),
	Price INt
);

/*
Question: I am looking for Top 10 Products From each Category
based on Price ASC
*/

SELECT * FROM(
	SELECT *, ROW_NUMBER() OVER (PARTITION BY Category Order By Price) as PriceRank 
		FROM Product) as RankedProducts
	WHERE PriceRank <= 10;

-- DROP TABLE Product;
GO

/*
2. We have a table Prodcut(Category,    Sub Category,    Price), get the Category and Subcategory for TOP 10 Subcategory for each category by the descending order of Price.
*/

CREATE TABLE Product2(
	Category VARCHAR(100),
	Subcategory VARCHAR(100),
	Product Varchar(100),
	Price INt
);

SELECT * FROM(
	SELECT *, ROW_NUMBER() OVER (PARTITION BY Category Order By PriceSum) as PriceRank 
		FROM (SELECT Category, Subcategory, SUM(Price) as PriceSum FROM Product2 GROUP BY Category, Subcategory) as AggCategory
	) as RankedProducts
	WHERE PriceRank <= 10;


GO
/*
3. We have a dynamic table, we don’t know how many rows this table is. Find the 35th records of this table in the default order.
*/
-- Using adventureworks db for testing this;
USE AdventureWorks2017;

SELECT *
	FROM Person.Person
	ORDER BY 1
	OFFSET 34 ROWS
	FETCH NEXT 1 ROW ONLY; 


/*
Retreive the next two rows of data starting from 3rd position.
*/


SELECT *
	FROM Person.Person
	ORDER BY 1
	OFFSET 3 ROWS
	FETCH NEXT 2 ROW ONLY; 

