--2013-10-07 tables with no primary key

USE < database_name>;
GO
SELECT
	SCHEMA_NAME(schema_id) AS schema_name,
	name AS table_name
FROM sys.tables
WHERE OBJECTPROPERTY(object_id, 'TableHasPrimaryKey') = 0
ORDER BY schema_name, table_name;
GO