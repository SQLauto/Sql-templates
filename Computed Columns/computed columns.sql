-- computed columns
SELECT OBJECT_NAME(object_id) AS object_name,
	name as column_name,
	column_id,
	definition,
	is_persisted
FROM sys.computed_columns