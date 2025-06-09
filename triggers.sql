
/******************Trigger Assignments**************/
--Account(Account_number,Name,Balance)
--transaction_table----(Tran_ID,Account_number,Tran_Amount,Tran_Date,Tran_Type)

Use LUCIDEX;

Go

create table Account 
(Account_number int identity(1,1) primary key,
Name varchar(10),
Balance int);

create table transaction_table
(Tran_ID int identity(1,1) ,
Account_number int foreign key references Account(Account_number),
Tran_Amount int,
Tran_Date datetime,
Tran_Type varchar(10)); 

GO

-- Update Trigger -> --When account table is updated, 500 -> 700 =200 -> 'Deposit'
				  --When account table is updated, 500 -> 300 =200 -> 'Withdraw'

/*
CREATE TRIGGER TxType ON Account
AFTER Update
AS
BEGIN
	Declare @oldBalance int;
	Declare @newBalance int;
	SELECT @oldBalance = Balance FROM deleted;
	SELECT @newBalance = Balance FROM inserted; 
	IF @newBalance > @oldBalance                  -- Wont work since update can update many rows
		PRINT 'Deposit'
	ELSE IF @newBalance < @oldBalance 
		PRINT 'Withdraw'
END
*/

CREATE OR ALTER TRIGGER TxType ON Account
AFTER Update
AS
BEGIN
	Declare @oldBalance int;
	Declare @newBalance int;
	INSERT INTO transaction_table 
    SELECT 
        i.Account_number,
        ABS(i.Balance - d.Balance),
        GETDATE(),
        IIF(i.Balance > d.Balance, 'Deposit','Withdraw' )    
	FROM inserted i
    JOIN deleted d ON i.Account_number = d.Account_number
    WHERE i.Balance != d.Balance; --transaction not occured when there is no change in balance
END

-- DROP TRIGGER TxType
INSERT INTO Account Values('Ravi',1200);

SELECT * FROM Account;
SELECT * FROM transaction_table;

UPDATE Account Set Balance = 700 WHERE Account_number =1;

UPDATE Account Set Balance = 1300 WHERE Account_number =1;


-- DML operations are allowed only btween 8am-5pm
GO

-- DROP TRIGGER TimeDMLOperation
CREATE OR ALTER TRIGGER TimeDMLOperation ON Account 
INSTEAD OF INSERT, UPDATE, DELETE 
AS
BEGIN

	DECLARE @currentHour INT = Datepart(HOUR, GETDATE());
	PRINT @currentHour
	IF @currentHour < 8 OR @currentHour >= 17
		PRINT 'Action performed outside regular hours'
	ELSE
	BEGIN
		PRINT 'Action Alllowed'
		DECLARE @inserted INT =0, @deleted INT = 0

		SELECT @inserted = count(*) FROM inserted;
		SELECT @deleted = count(*) FROM deleted;

		IF(@inserted =0 AND @deleted!=0) 
		BEGIN
			DELETE FROM Account
			WHERE Account_number IN (Select Account_number FROM deleted) 
		END 
		ELSE IF(@inserted !=0 AND @deleted =0)
		BEGIN
			SET IDENTITY_INSERT Account ON;
			INSERT INTO Account (Account_number, [Name], Balance)
			Select Account_number, [Name], Balance From inserted; 
			SET IDENTITY_INSERT Account OFF;
		END
		ELSE 
		BEGIN
			DELETE FROM Account
			WHERE Account_number IN (Select Account_number FROM deleted) ;

			SET IDENTITY_INSERT Account ON;
			INSERT INTO Account (Account_number, [Name], Balance)
			Select Account_number, [Name], Balance From inserted;
			SET IDENTITY_INSERT Account OFF;
			-- we need to handle transactions in case of update
			INSERT INTO transaction_table (Account_number, Tran_Amount, Tran_Date, Tran_Type)
			SELECT 
				i.Account_number as Account_number,
				ABS(i.Balance - d.Balance) AS Tran_Amount,
				GETDATE() AS Tran_Date,
				IIF(i.Balance > d.Balance, 'Deposit','Withdraw' ) as Tran_Type
			FROM inserted i
			JOIN deleted d ON i.Account_number = d.Account_number
			WHERE i.Balance != d.Balance; 
		END
	END 
END

GO

--DROP TRIGGER TimeDMLOperation;

INSERT INTO Account Values('Sam',100);

SELECT * FROM transaction_table;

GO
-------------------------------------

-- Allow transactions to be inserted in the transaction table only if the txn amount > 25
-- table txn ( txnid, txnamount, txndate)

create table txn_table(
tnxid INT PRIMARY KEY,
txnamount int,
txndate datetime);
GO

CREATE OR ALTER TRIGGER RestrictTranAmount
ON txn_table
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO txn_table
    SELECT *
    FROM inserted
    WHERE txnamount > 25;
END;
GO

SELECT * FROM txn_table;
INSERT INTO txn_table Values (1, 10, getDate());  -- fails 
INSERT INTO txn_table Values (2, 30, getDate()); -- works

GO

-------------------------------------
GO


-- Update students totalmarks as soon as test scores are added to the test table
-- Test (TID, Module, Score,sid)
-- Student (SID, SName, totalMarks)

CREATE TABLE Student(
	sid INT PRIMARY KEY,
	Sname VARCHAR(100),
	totalMarks INT
);

CREATE TABLE Test (
	TID INT PRIMARY KEY,
	Module VARCHAR(100),
	Score INT,
	sid INT FOREIGN KEY REFERENCES Student (sid)
);
GO

CREATE TRIGGER UpdateStudentMarks
ON Test
AFTER INSERT
AS
BEGIN
    UPDATE Student
    SET totalMarks = (
        SELECT SUM(Score)
        FROM Test T
        WHERE T.sid = S.sid
    )
    FROM Student S
    INNER JOIN inserted i -- join means only select id of students whose data was updated
		ON S.sid = i.sid; 
END;
GO

SELECT * FROM Student;
SELECT * FROM Test;
-- DELETE FROM Test

INSERT INTO Student VALUES (1, 'Alice Smith', 0);

INSERT INTO Test VALUES (1, 'Math', 85, 1);
INSERT INTO Test VALUES (2, 'Science', 75, 1);

-------------------------------------
Go

CREATE TABLE Sales (
     SalesID INT, PID INT, Qty INT, Name VARCHAR(50))
     
CREATE TABLE Stock (
     PID INT, PName VARCHAR(50), Qty INT)

 /* Create a single Instead Of Trigger on Stock table for Insert, Update and Delete and notify DBA
    which DML statement has caused the trigger to get fired
    for e.g,
      INSERT INTO Stock VALUES (....)
       -your output should be:-
       Trigger got fired in INSERT Statement */
Go

CREATE OR ALTER TRIGGER StockDMLAction ON Stock 
INSTEAD OF INSERT, UPDATE, DELETE 
AS
BEGIN
	DECLARE @inserted INT =0, @deleted INT = 0

	SELECT @inserted = count(*) FROM inserted;
	SELECT @deleted = count(*) FROM deleted;

	IF(@inserted =0 AND @deleted!=0) 
	BEGIN
		PRINT 'Trigger got fired in DELETE Statement';
		DELETE FROM Stock
		WHERE PID IN (Select PID FROM deleted) 
	END 
	ELSE IF(@inserted !=0 AND @deleted =0)
	BEGIN
		PRINT 'Trigger got fired in INSERT Statement';
		INSERT INTO Stock
		Select * From inserted 
	END
	ELSE 
	BEGIN
		PRINT 'Trigger got fired in UPDATE Statement'
		DELETE FROM Stock
		WHERE PID IN (Select PID FROM deleted) ;

		INSERT INTO Stock
		Select * From inserted ;
	END 
END


GO 

-------------------------------------------

/* Create a trigger that will populate an Archive table
   which would hold all the historical records\data
   from the base table.
     --Base Table Structure:-
         BTable(ID, FName, LName, Salary)
     --Archive Table
         ATable(ID, FName, LName, Salary, Flag, TTime, user)
   Dataset in the Flag column of ATable should be
   as follows:-
       I       for Insert
       D       for Delete
       U_Old   for record which got replaced with UPDATE  
       U_New   for record which was updated with UPDATE */

CREATE TABLE BTable (
   ID INT, FName VARCHAR(50), LName VARCHAR(50), 
   Salary MONEY);
   
CREATE TABLE ATable (
   ID INT, FName VARCHAR(50), LName VARCHAR(50), Salary MONEY,
   Flag VARCHAR(10), TTime DATETIME, UserNm VARCHAR(MAX));

-- DROP TABLE ATable;

Select * from BTable
Select * from ATable

GO

CREATE OR ALTER TRIGGER CreateArchive
ON BTable
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	
	DECLARE @inserted INT =0, @deleted INT = 0;
	DECLARE @currDate DATETIME = getDate();
	DECLARE @user VARCHAR(100) = SYSTEM_USER;

	SELECT @inserted = count(*) FROM inserted;
	SELECT @deleted = count(*) FROM deleted;

	IF(@inserted !=0 AND @deleted =0)
	BEGIN
		INSERT INTO ATable 
			SELECT *, 'I', @currDate, @user
			FROM inserted i
    END
	ELSE IF(@inserted =0 AND @deleted!=0) 
	BEGIN
		INSERT INTO ATable
		SELECT *, 'D', @currDate, @user
		FROM deleted d
	END
    ELSE
	BEGIN
		INSERT INTO ATable
			SELECT *, 'U_Old', @currDate, @user
			FROM deleted d;
		
		INSERT INTO ATable SELECT *,'U_New', @currDate, @user
			FROM inserted i;
	END
END;
GO

SELECT * FROM BTable;
SELECT * FROM ATable;

INSERT INTO BTable (ID, FName, LName, Salary)
VALUES 
    (1, 'Alice', 'Smith', 50000),
    (2, 'Bob', 'Johnson', 60000);

-- DELETE FROM BTable
-- DELETE FROM ATable 
UPDATE BTable
SET Salary = 55000, LName = 'Brown'
WHERE ID = 1;

DELETE FROM BTable WHERE ID=1;