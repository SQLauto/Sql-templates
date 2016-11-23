--The OPENROWSET command is suited to ad hoc querying. However, you may be evaluating data connection 
--possibilities with a view to eventually using a linked server. In this case, you may prefer to use the 
--OPENDATASOURCE command as a kind of “halfway house” to linked servers (described in the next recipe). 
--This sets the scene for you to update your code to replace OPENDATASOURCE with a four-part linked server 
--reference.  Inevitably, there are many variations on this particular theme (which only selects all the data
--from a source worksheet and uses only the ACE driver), so here are a few of them. As the objective is 
--to import data into SQL Server, I will let you choose whether to include this code in either a 
--SELECT..INTO or an INSERT INTO ...SELECT clause. Of course, you can use the Jet driver if you prefer. 
--If you are using  Excel 2007/2010, you must set the extended properties in the T-SQL to Excel 12.0.

SELECT ID, Marque FROM OPENDATASOURCE(
'Microsoft.ACE.OLEDB.12.0',
'Data Source = C:\SQL2012DIRecipes\CH01\CarSales.xlsx;Extended Properties = Excel 12.0')...Stock$;

SELECT ID AS InventoryNumber, LEFT(Marque,20) AS VehicleType
INTO RollsRoyce
FROM OPENDATASOURCE(
'Microsoft.ACE.OLEDB.12.0',
'Data Source = C:\SQL2012DIRecipes\CH01\CarSales.xls;Extended Properties = Excel 8.0')...Stock$
WHERE MAKE LIKE '%royce%'
ORDER BY Marque;

-- select all data in a named range
SELECT ID, Marque
FROM OPENDATASOURCE(
'Microsoft.ACE.OLEDB.12.0',
'Data Source = C:\SQL2012DIRecipes\CH01\CarSales.xls;Extended Properties = Excel 8.0')... TinyRange;


-- suggest further reading in sql 2012 di recipes and
-- https://msdn.microsoft.com/en-us/library/ms190479.aspx