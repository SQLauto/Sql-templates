-- Number of columns in a table
SELECT count(*)
FROM sys.columns c WHERE c.object_id=object_id('Person.Person')


SELECT count(*)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ScrapReason'
AND INFORMATION_SCHEMA.COLUMNS.TABLE_SCHEMA = 'Production'

SELECT * FROM INFORMATION_SCHEMA.COLUMNS c