--Configure the Excel spreadsheet as a linked server. This is how to do it:
--Define the linked server using the following code snippet 
--(C:\SQL2012DIRecipes\CH01\AddExcelLinkedServer.Sql):
EXECUTE master.dbo.sp_addlinkedserver
@SERVER = 'Excel'
,@SRVPRODUCT = 'ACE 12.0'
,@PROVIDER = 'Microsoft.ACE.OLEDB.12.0'
,@DATASRC = 'C:\SQL2012DIRecipes\CH01\CarSales.xlsx'
,@PROVSTR = 'Excel 12.0';
--Query the source data, only using the linked server name and worksheet (or range) name in four-part notation using a T-SQL snippet like 
--(C:\SQL2012DIRecipes\CH01\SelectEXcelLinkedServer.Sql):
SELECT ID, Marque
INTO XLLinkedLoad
FROM Excel...Stock$;