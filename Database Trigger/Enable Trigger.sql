--08-27-2013
--enable or disable trigger simple

USE AdventureWorks2012
GO

ALTER TABLE HumanResources.Department ENABLE TRIGGER iCheckModifedDate


USE AdventureWorks2012
GO
ENABLE TRIGGER trAuditTableChanges ON DATABASE;
GO


--08-27-2013
--if disable then enable
--IF EXISTS (SELECT
--	*
--FROM sys.triggers
--WHERE name = N'iCheckModifedDate' AND is_disabled = 1)
--ALTER TABLE HumanResources.Department ENABLE TRIGGER iCheckModifedDate