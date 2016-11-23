-- 2014-12-02 list all tables in all DBs

if object_ID('TempDB..#AllTables','U') IS NOT NULL drop table #AllTables
CREATE TABLE #AllTables ([DB Name] sysname, [Schema Name] nvarchar(128) NULL, [Table Name] sysname, create_date datetime, modify_date datetime)
 
DECLARE @SQL NVARCHAR(MAX)
 
SELECT @SQL = COALESCE(@SQL,'') + 'USE ' + quotename(name) + '
insert into #AllTables 
select ' + QUOTENAME(name,'''') + ' as [DB Name], schema_name(schema_id) as [Table Schema], [Name] as [Table Name], Create_Date, Modify_Date
 from ' +
QUOTENAME(Name) + '.sys.Tables;' FROM sys.databases
ORDER BY name
--print @SQL 
EXECUTE(@SQL)

SELECT * FROM dbo.#AllTables AS at