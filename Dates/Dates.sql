-- Current date at midnight no time
SELECT DATEADD(DAY,DATEDIFF(DAY,0,GETDATE()),0)
-- how it works
SELECT DATEDIFF(DAY,0,GETDATE())  --41702
SELECT DATEADD(DAY,41702,0)


-- DATEDIFF calculates difference in terms of days between an anchor datetime value 0 (Jan 1 1900 midnight) and
-- the input datetime value GETDATE().  Call that difference 'diff'
-- DATEADD then adds diff days to the anchor datetime value.  Because the anchor's time is midnight and you add whole
-- days you get the target date at midnight
SELECT DATEADD(
DAY,
DATEDIFF(DAY,0,GETDATE()),
0);

-- Calculate difference between two dates 
-- create a table 
CREATE TABLE Registration
(
    userid  int IDENTITY(1,1),
    Highdate	 datetime2,
    LowDate	 datetime2
)

INSERT INTO Registration
VALUES  ('2011-08-30 11:34:29.403','2012-06-30 11:34:29.403'),
	   ('2011-08-30 11:40:32.213','2011-09-20 11:40:32.213'),
	   ('2011-09-01 10:07:59.637','2011-09-10 10:07:59.637')
SELECT userid,DATEDIFF(dd,r.Highdate,r.LowDate)
FROM dbo.Registration r

-- if you want the date difference between two dates in the same column consider this
SELECT *--r1.Highdate,DATEDIFF(day,r1.highdate,r2.Highdate) AS diff
FROM dbo.Registration r1
INNER JOIN dbo.Registration r2
ON r2.userid=r1.userid+1

SELECT r1.Highdate,DATEDIFF(day,r1.highdate,r2.Highdate) AS diff
FROM dbo.Registration r1
INNER JOIN dbo.Registration r2
ON r2.userid=r1.userid+1

-- time zone calculations using datetimeoffset
DECLARE @Time1 datetimeoffset
DECLARE @Time2 datetimeoffset
DECLARE @minutesDiff int

SET @Time1 = '2012-02-10 09:15:00-05:00'    -- NY time is UTC -05:00
SET @Time2 = '2012-02-10 10:30:00-08:00'    -- LA times is UTC -08:00 so 1030am la = 130pm ny

SET @minutesDiff = DATEDIFF(minute,@Time1,@Time2)

SELECT @minutesDiff

-- DATETIMEOFFSET for UTC times
DECLARE @time time(4) = SYSUTCDATETIME();  -- or = '12:15:04.1237';
DECLARE @datetimeoffset datetimeoffset(3) = @time;
SELECT @datetimeoffset;
SELECT @time AS '@time', SWITCHOFFSET(@datetimeoffset,'-05:00') AS '@datetimeoffset'
-- if you want only the time...
SELECT @time AS '@time', convert(time(0),SWITCHOFFSET(@datetimeoffset,'-05:00')) AS '@datetimeoffset'

DECLARE @test AS datetimeoffset;
SET @test = GETUTCDATE()
SELECT  @test
-- east coast time
SELECT SWITCHOFFSET(@test,'-05:00')
-- japan time
SELECT SWITCHOFFSET(@test,'+09:00')
-- japan time plus a day
SELECT DATEADD(dd,1,SWITCHOFFSET(@test,'+09:00'))

-- TODATETIMEOFFSET function change to given time zone
SELECT TODATETIMEOFFSET(GETDATE(),'-04:00')
SELECT TODATETIMEOFFSET(GETDATE(),'-05:00')
SELECT datediff(hour,TODATETIMEOFFSET(GETDATE(),'-05:00'),TODATETIMEOFFSET(GETDATE(),'-04:00'))

-- select only time or date from datetime entity
DECLARE @mydate AS datetime2

SET @mydate = '2011-11-10 12:00:00'
SELECT CONVERT(time(0),@mydate)
SELECT convert(date,@mydate)

-- calculate the first day of the month
SELECT DATEDIFF(MONTH,0,GETDATE())
SELECT DATEADD(
MONTH,
DATEDIFF(MONTH,0,GETDATE()),0);
-- determine number of months since Jan 1 1900
SELECT DATEDIFF(MONTH,0,GETDATE())
-- add those months to base date
SELECT DATEADD(MONTH,1378,0)

-- calculate last day of the current month
-- add a month to the difference (gives first day of next month) then subtract a day to get last day of current month
SELECT DATEADD(
MONTH,
DATEDIFF(MONTH,0,GETDATE())+1,0)-1
-- or
SELECT eomonth(GETDATE(),0)
DECLARE @date datetime = GETDATE();
SELECT eomonth(@date,1);  --end of next month
-- calculate first day of the year by changing unit to year
SELECT DATEADD(
YEAR,
DATEDIFF(YEAR,0,GETDATE()),0);

-- Calculate the last day of the year
SELECT DATEADD(
YEAR,
DATEDIFF(YEAR,0,GETDATE())+1,0)-1;

-- Calculate the start of the hour
SELECT DATEADD(
HOUR,
DATEDIFF(HOUR,0,GETDATE()),0);

-- Calculate the last minute of the hour
SELECT DATEADD( minute, -1,
  DATEADD(
  hour,
  DATEDIFF(hour, 0, GETDATE()) +1,
  0) );

SELECT DATEDIFF(HOUR,0,GETDATE())+1 -- hours between base date and now
SELECT DATEADD(HOUR,1000861,0)  -- add an hour to hours between base date and now
SELECT DATEADD(MINUTE,-1,'2014-03-06 13:00:00.000')  -- subtract a minute