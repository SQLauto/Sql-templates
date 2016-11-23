-- simple example of GRANT, DENY and REVOKE
USE SampleDb
GO

CREATE ROLE TestRole;
GO

CREATE USER TestUser WITHOUT LOGIN

EXEC sys.sp_addrolemember
	@rolename = 'TestRole',
	@membername = 'TestUser';
GO

CREATE SCHEMA test;
GO
CREATE TABLE Test.TestTable(TableID int);
GO
GRANT SELECT ON object::Test.TestTable TO TestRole;
GO
CREATE TABLE Test.TestTable2(TableID int);
GO


--test harness to verify how permissions work for test.testatable
EXECUTE AS USER = 'TestUser';
GO
SELECT * FROM test.TestTable AS tt
GO
REVERT;
GO
-- test for testtable2
EXECUTE AS USER = 'TestUser';
GO
--should fail...
SELECT * FROM Test.TestTable2 AS tt
GO
REVERT;
GO

--Seeing the permissions
-- Query sys.database_permissions to see applicable permissions
SELECT dp.class_desc, s.name AS 'Schema', o.name AS 'Object', dp.permission_name, 
       dp.state_desc, prin.[name] AS 'User'
FROM sys.database_permissions dp
  JOIN sys.database_principals prin
    ON dp.grantee_principal_id = prin.principal_id
  JOIN sys.objects o
    ON dp.major_id = o.object_id
  JOIN sys.schemas s
    ON o.schema_id = s.schema_id
WHERE LEFT(o.name, 9) = 'TestTable'
  AND dp.class_desc = 'OBJECT_OR_COLUMN'
UNION ALL
SELECT dp.class_desc, s.name AS 'Schema', '-----' AS 'Object', dp.permission_name, 
       dp.state_desc, prin.[name] AS 'User'
FROM sys.database_permissions dp
  JOIN sys.database_principals prin
    ON dp.grantee_principal_id = prin.principal_id
  JOIN sys.schemas s
    ON dp.major_id = s.schema_id
WHERE dp.class_desc = 'SCHEMA';

-- REVOKE undoes a permission whether it is GRANT or DENY

-- undo the permission using REVOKE
REVOKE SELECT ON OBJECT::Test.TestTable FROM TestRole;
-- then check permissions query above


-- DENY blocks access and trumps all other access
-- typical to use at a more granular level i.e. allow schema but deny to table XYZ
-- permission at schema level
GRANT SELECT ON SCHEMA::Test TO TestRole;
GO
-- now apply a DENY more explicitly
DENY SELECT ON OBJECT::Test.TestTable TO TestUser;

-- so check the permission query again to see the permissions granted which include a DENY

EXECUTE AS USER = 'TestUser'
GO
SELECT * FROM Test.TestTable AS tt;
SELECT * FROM Test.TestTable2 AS tt;
REVERT;
GO