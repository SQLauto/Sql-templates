--======================================
--  Create T-SQL Trigger Template
--======================================
USE <database_name, sysname, AdventureWorks>
GO

IF OBJECT_ID ('<schema_name, sysname, Sales>.<trigger_name, sysname, uStore>','TR') IS NOT NULL
   DROP TRIGGER <schema_name, sysname, Sales>.<trigger_name, sysname, uStore> 
GO

CREATE TRIGGER <schema_name, sysname, Sales>.<trigger_name, sysname, uStore> 
   ON  <schema_name, sysname, Sales>.<table_name, sysname, Store> 
   AFTER <data_modification_statements, , UPDATE>
AS <T-SQL_statement, , UPDATE Sales.Store SET ModifiedDate = GETDATE() FROM inserted WHERE inserted.CustomerID = Sales.Store.CustomerID>
GO

--* 2013-09-18
--* AW real examples below
--*
USE AdventureWorks2012
GO
--create a table to keep the log of changes from a trigger
IF(OBJECT_ID('dbo.TableAudits')) IS NOT NULL
DROP TABLE dbo.TableAudits
CREATE TABLE dbo.TableAudits
(
UserName nvarchar(100),
AuditEvent nvarchar(100),
TSQLStateent nvarchar(2000),
AuditDate datetime
)
GO

--create a trigger
USE AdventureWorks2012;
GO
IF EXISTS (SELECT
	*
FROM sys.triggers
WHERE parent_class = 0 AND name = 'trAuditTableChanges')
DROP TRIGGER trAuditTableChanges
ON DATABASE;
GO
CREATE TRIGGER trAuditTableChanges
ON DATABASE
FOR ALTER_TABLE
AS
DECLARE @Data XML
SET @Data = EVENTDATA()
INSERT TableAudits (AuditDate, UserName, AuditEvent, TSQLStateent)
	VALUES (GETDATE(), CONVERT(nvarchar(100), CURRENT_USER), @Data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)'), @Data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(2000)'))
 ;
GO

--alter the table to trigger the trigger
ALTER TABLE HumanResources.Employee
ADD Age INT;

--see what happened
SELECT
	*
FROM dbo.TableAudits

--modify the trigger to show better user data
USE AdventureWorks2012
GO
ALTER TRIGGER trAuditTableChanges
ON DATABASE
FOR ALTER_TABLE
AS
DECLARE @Data XML
SET @Data = EVENTDATA()
INSERT TableAudits (AuditDate, UserName, AuditEvent, TSQLStateent)
	VALUES (GETDATE(), CONVERT(nvarchar(100), SYSTEM_USER), @Data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)'), @Data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(2000)'))
 ;

--enable or disable trigger
USE AdventureWorks2012
GO
ENABLE TRIGGER trAuditTableChanges ON DATABASE;