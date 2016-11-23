-- using bulk insert with a format file
-- https://msdn.microsoft.com/en-us/library/ms188365

CREATE TABLE t_float(c1 float(53), c2 decimal (5,4));
DROP TABLE dbo.t_float
-- paste in the values of the .dat with a tab
-- 8.0000000000000002E-2	   8.0000000000000002E-2
BULK INSERT SampleDb.dbo.t_float
FROM 'C:\tempz\t_float-c.dat' WITH (FORMATFILE='C:\tempz\t_floatformat-c-xml.xml');
GO

SELECT * FROM dbo.t_float tf