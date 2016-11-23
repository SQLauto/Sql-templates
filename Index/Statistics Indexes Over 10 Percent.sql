--2013-09-10 AW - all indexes that have fragmentation >=10%

USE AdventureWorks2012
GO
SELECT
	DB_NAME(ips.database_id) DBName,
	OBJECT_NAME(ips.object_id) ObjName,
	i.name InxName,
	ips.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID('AdventureWorks2012'),
DEFAULT, DEFAULT, DEFAULT, DEFAULT) ips
INNER JOIN sys.indexes i
	ON ips.index_id = i.index_id AND
	ips.object_id = i.object_id
WHERE ips.object_id > 99 AND
ips.avg_fragmentation_in_percent >= 10 AND
ips.index_id > 0