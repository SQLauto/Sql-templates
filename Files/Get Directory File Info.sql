 CREATE PROCEDURE dbo.GetDirectoryFileInfo
/****************************************************************************************
 PURPOSE:
 This utility stored procedure returns the long filename, CreateDate, LastModifiedDate,
 and the file size in Bytes from any given directory or UNC.

 INPUT PARAMETERS:
 The unquoted \\MachineName\Path or d:\Path where "d:" is the drive letter. Wildcards
 may be used for file names and extensions.  Only path information is allowed. Inclusion
 of anything not interpreted as a valid path will cause an empty result set to be 
 returned for security reasons.

 OUTPUTS:
 Column name      DataType     Description
 -----------      --------     ----------------------------------------------------------
 RowNum           INTEGER      Sequential number
 FileName         VARCHAR(256) Filename and extension from the DIR command
 CreateDate       DATETIME     Date the file was created on
 LastModifiedDate DATETIME     Date the file was last modified
 Bytes            BIGINT       The number of bytes the file contains

 If the path is not found, is empty, the parameter passed was not an actual path, or
 the permissions to access a legitimate path does not exist for MS-SQL Server, the stored
 procedure will return an empty result set.  This is partially for security reasons...
 if a hacker gets no return, they don't know if they're on the right track or not.

 REVISION HISTORY:
 Rev 00 - 09 Apr 2005 - Jeff Moden - Initial creation and unit test
****************************************************************************************/
--===== Declare I/O parameters
 @pPath VARCHAR(512) --The path info and wildcards to be used with a DIR command

     AS

--=======================================================================================
--===== Presets
--=======================================================================================
--===== Supress the autodisplay of rowcounts for appearance and speed
    SET NOCOUNT ON

--===== Declare local variables
DECLARE @Command VARCHAR (300) --Holds the dynamic DOS command for the DIR command 

--===== If the temp table that holds the Directory output is not null, drop the table
     IF OBJECT_ID('TempDB..#DosOutput') IS NOT NULL
        DROP TABLE #DosOutput

--===== Create the temp table that holds the Directory output
 CREATE TABLE #DosOutput 
        (
         RowNum INT IDENTITY(1,1),
         Data VARCHAR(300)
        )

--===== If the temp table that holds the file information is not null, drop the table
     IF OBJECT_ID('TempDB..#FileInfo') IS NOT NULL
        DROP TABLE #FileInfo

--=======================================================================================
--===== Get the directory information and the LastModifiedDate for lines with files only.
--=======================================================================================

--===== Setup to do a "DIR" with the following switches
     -- /TW  = Date/Time file was last written to (LastModifiedDate)
     -- /-C  = List number of bytes without commas 
     -- Enclose the @pPath variable in quotes to all for paths with spaces.
    SET @Command = 'DIR "' + @pPath + '" /TW /-C'

--===== Execute the "DIR" command and save the output in #DosOutput
     -- (order preserved by the Primary Key)
 INSERT INTO #DosOutput (Data)
   EXEC Master.dbo.xp_CmdShell @Command

--===== Parse the Dos output into the file info table.
     -- The criteria in the WHERE clause ensures only file info is returned
 SELECT 
        IDENTITY(INT,1,1) AS RowNum,
        SUBSTRING(Data,40,256) AS [FileName],
        CAST(NULL AS DATETIME) AS CreateDate, --Populated on next step
        CONVERT(DATETIME,SUBSTRING(Data,1,23)) AS LastModifiedDate,
        CAST(SUBSTRING(Data,22,17) AS BIGINT) AS Bytes
   INTO #FileInfo
   FROM #DosOutput
  WHERE SUBSTRING(Data,15,1) = ':' --Row has a date/time on it
    AND Data NOT LIKE '%<DIR>%'    --Row is not a directory listing

--=======================================================================================
--===== Update each file's info with the CreateDate 
--=======================================================================================

--===== Setup to do a "DIR" with the following switches
     -- /TC  = Date/Time File was created (CreateDate)
     -- Enclose the @pPath variable in quotes to prevent SQL Injection attacks
    SET @Command = 'DIR "' + @pPath + '" /TC'

--===== Clear the #DosOutput table
TRUNCATE TABLE #DosOutput

--===== Execute the "DIR" command and save the output in #DosOutput
     -- (order preservation not important here)
 INSERT INTO #DosOutput (Data)
   EXEC Master.dbo.xp_CmdShell @Command

--===== Parse the DOS output table for the CreateDate and add it to the
     -- file info table.
 UPDATE #FileInfo
    SET CreateDate = CONVERT(DATETIME,SUBSTRING(do.Data,1,23))
   FROM #FileInfo fi,
        #DosOutput do
  WHERE fi.FileName = SUBSTRING(do.Data,40,256) --Filenames match
    AND SUBSTRING(do.Data,15,1) = ':' --Row has a date/time on it
    AND do.Data NOT LIKE '%<DIR>%'    --Row is not a directory listing

--=======================================================================================
--===== Return a result set to the calling object
--=======================================================================================
 SELECT * FROM #FileInfo

--===== Exit the proc with no error reporting for security reasons
 RETURN
GO

EXEC dbo.GetDirectoryFileInfo
	@pPath = 'c:\temp\'

EXEC dbo.GetDirectoryFileInfo
	@pPath = 'c:\temp\*.txt'

	DROP TABLE #TempTble



-- use a function to insert 1 if file exists to temporary table
create table #TempTbl( test int)
CREATE FUNCTION dbo.fn_FileExists(@path varchar(512))
RETURNS BIT
AS
BEGIN
	DECLARE @result int
	EXEC master.dbo.xp_fileexist @path, @result OUTPUT
	RETURN cast(@result AS bit)
END;
GO

-- Declares a variable and sets it to null.
-- This variable is used to return the results of the function.

DECLARE @ret nvarchar(15)= NULL; 

-- Executes the dbo.ufnGetSalesOrderStatusText function.
--The function requires a value for one parameter, @path. 

EXEC @ret = dbo.fn_FileExists @path = 'c:\temp\eula.txt'; 
--Returns the result in the message tab.
INSERT INTO dbo.#TempTbl (test)
VALUES(@ret)

SELECT * FROM dbo.#TempTbl tt;


EXEC MASTER.dbo.xp_cmdshell 'dir C:\temp\ /a-d /b'

--Create the table to store file list
CREATE TABLE #myFileList (FileNumber INT IDENTITY,FileName VARCHAR(256))
--Insert file list from directory to SQL Server
DECLARE @Path varchar(256) = 'dir C:\temp\'
DECLARE @Command varchar(1024) =  @Path + ' /A-D  /B'
INSERT INTO #myFileList
EXEC MASTER.dbo.xp_cmdshell @Command
--Check the list
SELECT * FROM #myFileList
WHERE filename LIKE '%.jpg'
GO
--Clean up
DROP TABLE #myFileList
GO