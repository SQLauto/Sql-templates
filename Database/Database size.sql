SELECT DB_NAME(database_id) AS database_name
        , database_id
        , [file_id]
    , type_desc
    , data_space_id
    , name AS logical_file_name
    , physical_name
        , (SIZE*8/1024) AS size_mb
        , CASE max_size
                WHEN -1 THEN 'unlimited'
                ELSE CAST((CAST (max_size AS BIGINT)) * 8 / 1024 AS VARCHAR(10))
        END AS max_size_mb
    , CASE is_percent_growth
                WHEN 1 THEN CAST(growth AS VARCHAR(3)) + ' %'
                WHEN 0 THEN CAST(growth*8/1024 AS VARCHAR(10)) + ' mb'
        END AS growth_increment
    , is_percent_growth
FROM sys.master_files
ORDER BY 1, type_desc DESC, [file_id];

-- returns I/O details of given database mdf and ldf file. It display information like number of reads,
-- total bytes read, number of writes, total bytes write, file size on disk, etc.
Select DB_NAME(database_id)DBName,file_id,sample_ms,num_of_reads,num_of_bytes_read,io_stall_read_ms,
num_of_writes,num_of_bytes_written,io_stall_write_ms,io_stall,size_on_disk_bytes,file_handle 
from sys.dm_io_virtual_file_stats(DB_ID('SQLGD'),1)	
Union
Select DB_NAME(database_id)DBName,file_id,sample_ms,num_of_reads,num_of_bytes_read,io_stall_read_ms,
num_of_writes,num_of_bytes_written,io_stall_write_ms,io_stall,size_on_disk_bytes,file_handle 
from sys.dm_io_virtual_file_stats(DB_ID('SQLGD'),2)



-- From Diagnostics folder
-- File names and paths for TempDB and all user databases in instance  (Query 20) (Database Filenames and Paths)
SELECT DB_NAME([database_id]) AS [Database Name], 
       [file_id], name, physical_name, type_desc, state_desc,
	   is_percent_growth, growth,
	   CONVERT(bigint, growth/128.0) AS [Growth in MB], 
       CONVERT(bigint, size/128.0) AS [Total Size in MB]
FROM sys.master_files WITH (NOLOCK)
WHERE [database_id] > 4 
AND [database_id] <> 32767
OR [database_id] = 2
ORDER BY DB_NAME([database_id]) OPTION (RECOMPILE);

-- Things to look at:
-- Are data files and log files on different drives?
-- Is everything on the C: drive?
-- Is TempDB on dedicated drives?
-- Is there only one TempDB data file?
-- Are all of the TempDB data files the same size?
-- Are there multiple data files for user databases?
-- Is percent growth enabled for any files (which is bad)?