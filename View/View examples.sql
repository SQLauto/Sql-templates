-- All views in a DB
USE <database_name>;  
GO  
SELECT name AS view_name   
  ,SCHEMA_NAME(schema_id) AS schema_name  
  ,OBJECTPROPERTYEX(object_id,'IsIndexed') AS IsIndexed  
  ,OBJECTPROPERTYEX(object_id,'IsIndexable') AS IsIndexable  
  ,create_date  
  ,modify_date  
FROM sys.views;

-- http://www.c-sharpcorner.com/UploadFile/f0b2ed/views-in-sql-server/

-- UDF user defined view
-- create two tables
CREATE TABLE dbo.Employee_Details
(
    Emp_Id  [int] identity(1,1) NOT null,
    Emp_name	 [nvarchar](50) NOT NULL,
    Emp_city	 [nvarchar](50) NOT NULL,
    Emp_Salary	 [int] NOT NULL,
    CONSTRAINT PK_Employee_Details PRIMARY KEY CLUSTERED
    (
	   Emp_Id ASC
    )
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
		  ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
)
ON [PRIMARY]
GO

-- insert some data
INSERT INTO dbo.Employee_Details VALUES('Rajan','Delhi',27000)
-- ...

SELECT * FROM dbo.Employee_Details ed

-- another table Employee_Contact
CREATE TABLE dbo.Employee_Contact
(
    Emp_Id int NOT NULL,
    MobileNo	 [nvarchar](50) NOT NULL
)

ALTER TABLE dbo.Employee_Contact WITH CHECK ADD CONSTRAINT FK_Employee_Contact_Employee_Details FOREIGN KEY(Emp_Id)
    REFERENCES dbo.Employee_Details(Emp_Id);
ALTER TABLE dbo.Employee_Contact CHECK CONSTRAINT FK_Employee_Contact_Employee_Details

-- insert values into Employee_Contact
INSERT INTO Employee_Contact VALUES(1,'9813220191');
INSERT INTO Employee_Contact VALUES(2,'9813220192');
INSERT INTO Employee_Contact VALUES(3,'9813220193');
INSERT INTO Employee_Contact VALUES(4,'9813220194');
INSERT INTO Employee_Contact VALUES(5,'9813220195');
INSERT INTO Employee_Contact VALUES(6,'9813220196');
INSERT INTO Employee_Contact VALUES(7,'9813220197');
INSERT INTO Employee_Contact VALUES(8,'9813220198');
INSERT INTO Employee_Contact VALUES(9,'9813220199');
INSERT INTO Employee_Contact VALUES(10,'9813220135');
--
SELECT * FROM dbo.Employee_Contact ec

CREATE VIEW Employee_View1
AS
SELECT * FROM dbo.Employee_Details ed

CREATE VIEW Employee_View2
AS
SELECT ed.Emp_Id, ed.Emp_name, ed.Emp_city from dbo.Employee_Details ed

CREATE VIEW Employee_View3
AS
SELECT * FROM dbo.Employee_Details ed WHERE ed.Emp_Id > 3;

-- various table columns in view
CREATE VIEW Employee_View4
AS
SELECT ed.Emp_Id, ed.Emp_name, ed.Emp_Salary, ec.MobileNo from dbo.Employee_Details ed
LEFT OUTER JOIN dbo.Employee_Contact ec
ON ed.Emp_Id = ec.Emp_Id
WHERE ed.Emp_Id > 2;

-- retrieve data from view
SELECT * FROM dbo.Employee_View4 ev
SELECT ev.Emp_Id, ev.Emp_name, ev.Emp_Salary from dbo.Employee_View4 ev

DROP VIEW dbo.Employee_View1
-- rename
sp_rename Employee_ViewNew,Employee_View4

sp_helptext Employee_View4

-- Altering a view
ALTER VIEW dbo.Employee_View4
AS
SELECT ed.Emp_Id, ed.Emp_name, ed.Emp_Salary, ec.MobileNo from dbo.Employee_Details ed
LEFT OUTER JOIN dbo.Employee_Contact ec
ON ed.Emp_Id = ec.Emp_Id
WHERE ed.Emp_Id > 5 AND ed.Emp_city = 'Alwar'

-- Refreshing a view
-- consider adding new column to ed
CREATE VIEW Employee_View1
AS
SELECT * FROM dbo.Employee_Details ed
-- now add column to Employee_Details table
ALTER TABLE dbo.Employee_Details ADD MY_sal [nvarchar](50)
-- retrieve data
SELECT * FROM dbo.Employee_Details ed
SELECT * FROM dbo.Employee_View1 ev

-- scheme of the view is already defined so don't see MY_sal in view query
EXEC sp_refreshview Employee_View1
-- now you should
SELECT * FROM dbo.Employee_Details ed;
SELECT * FROM dbo.Employee_View1 ev;

-- Schemabinding a view
-- to prevent unexpected results
-- note cannot use * in schemabinding
CREATE VIEW Employee_Details3
WITH SCHEMABINDING
AS
SELECT ed.Emp_Id, ed.Emp_name, ed.Emp_Salary, ed.Emp_city from dbo.Employee_Details ed

-- now try to change data type of Emp_Salary to decimal in base table using explorer

-- Encrypt a view
-- is not visible with SP_helptext
CREATE VIEW Employee_Details4
WITH ENCRYPTION
AS
SELECT ed.Emp_Id, ed.Emp_name, ed.Emp_Salary, ed.Emp_city FROM dbo.Employee_Details ed

sp_helptext Employee_details4

-- Check Option - ensure all update and insert satisfy view's condition
CREATE VIEW dbo.Employee_Details7
AS
SELECT * FROM dbo.Employee_Details ed
WHERE ed.Emp_Salary > 30000
GO

-- note view is > 30k but we can insert salary < 30k?
INSERT INTO Employee_Details7 values('ram','mumbai',25000,'Pan');
SELECT * FROM dbo.Employee_Details7 ed
SELECT * FROM dbo.Employee_Details ed
-- prevent with check option
ALTER VIEW dbo.Employee_Details7
AS
SELECT * FROM dbo.Employee_Details ed
WHERE ed.Emp_Salary > 30000
WITH check OPTION
GO
-- now try
INSERT INTO dbo.Employee_Details7 VALUES('ram','mumbai',25000,'pan');
-- fails, good

--DML query in view
SELECT * FROM Employee_Details7
ALTER VIEW dbo.Employee_Details7
AS
SELECT ed.Emp_Id, ed.Emp_name, ed.Emp_city, ed.Emp_Salary FROM dbo.Employee_Details ed
WHERE ed.Emp_Salary > 30000

SELECT * FROM Employee_Details7
-- implement dml queries
INSERT INTO Employee_Details7 values('ram','mumbai',35000)
UPDATE Employee_Details7 SET Emp_name = 'Raju' WHERE Emp_Id = 5;
DELETE FROM dbo.Employee_Details7 WHERE Emp_Id = 6  --author overlooked Employee_Contact delete
SELECT * FROM dbo.Employee_Details7 ed

-- Information schemas
SELECT * FROM INFORMATION_SCHEMA.VIEW_TABLE_USAGE vtu
WHERE vtu.TABLE_NAME = N'Employee_Details';

SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
WHERE tc.TABLE_NAME = N'Employee_Details'

-- Catalog Views - self describing info of a DB

SELECT * FROM sys.views v

SELECT * FROM sys.databases d