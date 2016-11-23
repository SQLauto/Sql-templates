-- Convert a date in all possible formats
-- loops through all conversion styles 0-255
-- many skipped due to try catch, showing which return a valid conversion

DECLARE @myDateTime AS datetime
SET @myDateTime = '2015-05-15T18:30:00.340';

DECLARE @index int;
SET @index = 0;
WHILE @index < 255
BEGIN
    
    BEGIN TRY
	   DECLARE @cDate varchar(25)
	   SET @cDate = CONVERT(nvarchar, GETDATE(), @index)
	   PRINT cast(@index AS varchar) + '  ' + @cDate
    END try

    begin catch
    end catch

    set @index = @index + 1;

END