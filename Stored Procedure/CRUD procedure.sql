use AdventureWorks2012;
GO

-- creating and using CRUD procs

CREATE TABLE [dbo].[Customer](
       [CustomerID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
       [FirstName] [varchar](20) NULL,
       [LastName] [varchar](20) NULL,
       [Email] [varchar](20) NULL,
       [PhoneNumber] [int] NULL
 
)

IF OBJECT_ID('usp_CustomerCreate') IS NOT NULL
BEGIN 
DROP PROC usp_CustomerCreate 
END
GO
CREATE PROCEDURE usp_CustomerCreate
       @FirstName varchar(20),
       @LastName varchar(20),
       @Email    varchar(20),
       @PhoneNumber int
     
AS
BEGIN
INSERT INTO Customer  (
       FirstName,
       LastName,
       Email,
       PhoneNumber)
    VALUES (
       @FirstName,
       @LastName,
       @Email,
       @PhoneNumber)
DECLARE @CustomerID int;
SET @CustomerID = SCOPE_IDENTITY()
 
SELECT 
       FirstName = @FirstName,
       LastName = @LastName,
       Email    = @Email,
       PhoneNumber =@PhoneNumber
FROM Customer 
WHERE  CustomerID = @CustomerID
END

-- Create customer
EXEC usp_CustomerCreate
	@FirstName = 'Jane',
	@LastName = 'Doe',
	@Email = 'Jane.Doe@email.com',
	@PhoneNumber = 12345

-- READ procedure based on primary key specified in the input parameter

IF OBJECT_ID('usp_CustomerRead') IS NOT NULL
BEGIN
	DROP PROC usp_CustomerRead
END
GO
CREATE PROC usp_CustomerRead
	@CustomerID int
AS
BEGIN
	SELECT CustomerID, FirstName, LastName, Email, PhoneNumber
	FROM Customer
	WHERE (Customer.CustomerID = @CustomerID)
END
GO

EXEC usp_CustomerRead
	@CustomerID = 1

-- UPDATE procedures perform an update on the table based on the primary key for a record
-- specified in the WHERE clause of the statement.  has 1 param for every column in table

IF OBJECT_ID('usp_CustomerUpdate') IS NOT NULL
BEGIN
	DROP PROC usp_CustomerUpdate
END
GO
CREATE PROC usp_CustomerUpdate
			@CustomerID int,
			@FirstName varchar(20),
			@LastName varchar(20),
			@Email varchar(20),
			@PhoneNumber int
AS
BEGIN
UPDATE Customer
SET
    --CustomerID - this column value is auto-generated
    FirstName = @FirstName, -- varchar
    LastName = @LastName, -- varchar
    Email = @Email, -- varchar
    PhoneNumber = @PhoneNumber -- int
WHERE CustomerID = @CustomerID
END
GO

EXEC usp_CustomerUpdate
	@CustomerID = 1,
	@FirstName = 'Jane',
	@LastName = 'Smith',
	@Email = 'Jane.Smith@gmail.com',
	@PhoneNumber = 8675309

-- DELETE proc deletes a row specified in WHERE clause
IF OBJECT_ID('usp_CustomerDelete') IS NOT NULL
BEGIN
	DROP PROC usp_CustomerDelete
END
GO
CREATE PROC usp_CustomerDelete
		@CustomerID int
AS
BEGIN
	DELETE FROM Customer
	WHERE CustomerID = @CustomerID
END
GO

EXEC usp_CustomerDelete
	@CustomerID = 2