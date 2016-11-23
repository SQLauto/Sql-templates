-- Hierarchy demo

USE AdventureWorks2012;
GO

--Adding column for demo cleanup later
ALTER TABLE HumanResources.Employee
ADD [ManagerID] int NULL;
GO

--CEO won't have a manager (except shareholders)
UPDATE HumanResources.Employee
SET ManagerID = 1
WHERE BusinessEntityID <> 1;

-- Show employee/manager relationship
SELECT e.BusinessEntityID, e.HireDate,
		e.ManagerID, e2.HireDate
FROM HumanResources.Employee e
LEFT OUTER JOIN HumanResources.Employee e2
ON E.ManagerID = E2.BusinessEntityID;
--(not the manager) WHERE e.BusinessEntityID > 1

ALTER TABLE HumanResources.Employee
DROP COLUMN [ManagerID];
GO