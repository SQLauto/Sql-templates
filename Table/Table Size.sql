DECLARE @AWTables TABLE (SchemaTable varchar(100));
DECLARE @TableName varchar(100);
--insert table names into the table variable
INSERT @AWTables(SchemaTable)
	SELECT t.TABLE_SCHEMA + '.' + t.TABLE_NAME
	FROM INFORMATION_SCHEMA.TABLES t
	WHERE t.TABLE_TYPE = 'BASE TABLE'
	ORDER BY t.TABLE_SCHEMA + '.' + t.TABLE_NAME;
--report on each table using sp_spaceused
-- runs while there are rows remaining in the @awtables
WHILE (SELECT COUNT(*) FROM @AWTables a) > 0
BEGIN
	-- the @tablename local variable is populated with the top 1 table name from @awtables
	SELECT TOP(1) @TableName = a.SchemaTable
	FROM @AWTables a
	ORDER BY a.SchemaTable;
	EXEC sys.sp_spaceused @TableName;
	DELETE @AWTables
	WHERE SchemaTable = @TableName;
END;