-- Get a list of files in a directory
--------------------------------------------------------------------
IF OBJECT_ID (N'dbo.ListPaths') IS NOT NULL
   DROP PROCEDURE dbo.ListPaths
GO
CREATE PROCEDURE dbo.ListPaths
@FileSpec VARCHAR(2000),
@order VARCHAR (80) = '/O-D'--sort by date time oldest first
/*
produce a table with a single column consisting of the path of every file, including subdirectories, of the directory specified You can specify the order in the order parameter
             N  By name (alphabetic)       S  By size (smallest first)
             E  By extension (alphabetic)  D  By date/time (oldest first)
             G  Group directories first    -  Prefix to reverse order

*/
AS
DECLARE @myfiles TABLE (MyID INT IDENTITY(1,1) PRIMARY KEY, FullPath VARCHAR(2000))
DECLARE @CommandLine VARCHAR(4000)
IF @order IS NOT NULL -- abort if the order is silly
   BEGIN
   SELECT @CommandLine =LEFT('dir "' + @FileSpec + '" /A-D /B /S '+@order,4000)
   /*
     /A          Displays files with specified attributes.
     attributes   D  Directories                R  Read-only files
                  H  Hidden files               A  Files ready for archiving
                  S  System files               -  Prefix meaning not
     /B          Uses bare format (no heading information or summary).
     /S          Displays files in specified directory and all subdirectories.
   */
   INSERT INTO @MyFiles (FullPath)
       EXECUTE xp_cmdshell @CommandLine
   DELETE FROM @MyFiles WHERE fullpath IS NULL OR fullpath='File Not Found'
   END
SELECT fullpath FROM @MyFiles
-------------------------------------------------------------
GO
EXECUTE listpaths 'C:\Workbench\*.txt'