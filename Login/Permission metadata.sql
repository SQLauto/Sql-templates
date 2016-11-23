SELECT DB_NAME() AS 'Database', p.name, p.type_desc, dbp.state_desc,
       dbp.permission_name, so.name, so.type_desc
FROM sys.database_permissions dbp
       LEFT JOIN sys.objects so ON dbp.major_id = so.object_id
       LEFT JOIN sys.database_principals p ON dbp.grantee_principal_id = p.principal_id
WHERE p.name = 'ProdDataEntry'
ORDER BY so.name, dbp.permission_name;

SELECT * FROM sys.fn_builtin_permissions(DEFAULT);
SELECT * FROM sys.fn_builtin_permissions('SERVER') ORDER BY permission_name;
SELECT * FROM sys.fn_builtin_permissions('DATABASE') ORDER BY permission_name;