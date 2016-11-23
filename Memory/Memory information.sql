--Available memory
select cast(available_physical_memory_kb/1024 as varchar(40)) + ' MB' AS [Available]
from sys.dm_os_sys_memory

SELECT dosm.total_physical_memory_kb/1024 AS [AvailPhysical]
FROM sys.dm_os_sys_memory dosm
-- current values
EXEC sp_configure;

-- get total physical memory installed on sql server
SELECT [total_physical_memory_kb] / 1024 AS [Total_Physical_Memory_In_MB]
    ,[available_page_file_kb] / 1024 AS [Available_Physical_Memory_In_MB]
    ,[total_page_file_kb] / 1024 AS [Total_Page_File_In_MB]
    ,[available_page_file_kb] / 1024 AS [Available_Page_File_MB]
    ,[kernel_paged_pool_kb] / 1024 AS [Kernel_Paged_Pool_MB]
    ,[kernel_nonpaged_pool_kb] / 1024 AS [Kernel_Nonpaged_Pool_MB]
    ,[system_memory_state_desc] AS [System_Memory_State_Desc]
FROM [master].[sys].[dm_os_sys_memory]

-- get minimum and max size of memory configured for sql server
SELECT [name] AS [Name]
    ,[configuration_id] AS [Number]
    ,[minimum] AS [Minimum]
    ,CAST(CAST([maximum] AS float)*9.53674e-7 AS int) AS [Maximum] --in GB
    ,[is_dynamic] AS [Dynamic]
    ,[is_advanced] AS [Advanced]
    ,[value] AS [ConfigValue]
    ,[value_in_use] AS [RunValue]
    ,[description] AS [Description]
FROM [master].[sys].[configurations]
WHERE NAME IN ('Min server memory (MB)', 'Max server memory (MB)')

http://www.sqlservercentral.com/blogs/glennberry/2009/10/29/suggested-max-memory-settings-for-sql-server-2005_2F00_2008/
-- db properties memory usually 2147483647 max by default
-- tried this on laptop prob more important on a production box
EXEC  sp_configure'Show Advanced Options',1;
GO
RECONFIGURE;
GO

-- Set max server memory for sys with 4GB
EXEC  sp_configure'max server memory (MB)',3200;
GO
RECONFIGURE;
GO


