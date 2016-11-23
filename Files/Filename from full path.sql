-- filename in a directory

DECLARE @filename nvarchar(max)
DECLARE @ReversedPath nvarchar(max)

SET @ReversedPath = REVERSE('c:\temp\testing.txt')
SELECT @ReversedPath
SELECT CHARINDEX('\',@ReversedPath)
SELECT @filename = RIGHT('c:\temp\testing.txt',charindex('\',@ReversedPath)-1)
SELECT @filename



-- =============================================
-- Author:        Paul Griffin
-- Create date:   18 January 2015
-- Description:   Returns a filename with extension
--                from a full path:
--                    D:\Temp\Resources\Images\My.Picture.jpg
--                ==> My.Picture.jpg
-- =============================================
CREATE FUNCTION [dbo].[GetFileName]
(
    @Path NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @FileName NVARCHAR(MAX)
    DECLARE @ReversedPath NVARCHAR(MAX)

    SET @ReversedPath = REVERSE(@Path)
    SELECT @FileName = RIGHT(@Path, CHARINDEX('\', @ReversedPath)-1)

    RETURN @FileName
END