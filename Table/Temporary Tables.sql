--http://www.sqlservercentral.com/articles/Stairway+Series/107124/

SET NOCOUNT ON;

-- CREATE use and drop a temporary table
CREATE TABLE #Person(
	BusinessEntityId int,
	Title	nvarchar(8),
	FirstName	nvarchar(50),
	LastName	nvarchar(50));

INSERT INTO #Person
(BusinessEntityId,Title,FirstName,LastName)
	SELECT TOP 10 p.BusinessEntityID, p.Title,p.FirstName, p.LastName
	FROM Person.Person p;

SELECT * FROM #Person p;
DROP TABLE #Person;

SET NOCOUNT ON;
CREATE TABLE ##SalesOrderHeader(
	SalesOrderId int,
	SalesOrderDate datetime,
	CustomerId int);

INSERT INTO ##SalesOrderHeader (SalesOrderId,SalesOrderDate,CustomerId)
	SELECT soh.SalesOrderID, soh.OrderDate, c.CustomerID
	FROM Sales.SalesOrderHeader soh
	LEFT OUTER JOIN Sales.Customer c
	ON c.CustomerID = soh.CustomerID;

SELECT TOP 10 * FROM dbo.##SalesOrderHeader soh;

DROP TABLE dbo.##SalesOrderHeader;

SET NOCOUNT ON;
GO
CREATE PROC MyProc 
AS
CREATE TABLE #Level1 (Level int);
INSERT #Level1 VALUES (1);
SELECT @@NESTLEVEL as Level, @@SPID as SPID
SELECT * FROM #Level0;
SELECT * FROM #Level1;
GO
CREATE TABLE #Level0 (Level int);
INSERT #Level0 VALUES (0);
SELECT @@NESTLEVEL as Level, @@SPID as SPID
EXEC MyProc;
SELECT * FROM #Level0;
SELECT * FROM #Level1;  -- this line in the batch would error because it's only in the proc

DROP PROC dbo.MyProc;
DROP TABLE dbo.#Level0

-- nestlevel example
CREATE PROC usp_NestLevelValues AS
    SELECT @@NESTLEVEL AS 'Current Nest Level';
EXEC ('SELECT @@NESTLEVEL AS OneGreater'); 
EXEC sp_executesql N'SELECT @@NESTLEVEL as TwoGreater' ;
GO
SELECT @@nestlevel AS outside
EXEC usp_NestLevelValues;
GO

DROP PROC dbo.usp_NestLevelValues;