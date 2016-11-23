– First Day Previous/Current/Next Months
SELECT
	DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0),
	'First Day of Previous Month' UNION ALL SELECT
	DATEADD(DAY, -(DAY(DATEADD(MONTH, 1, GETDATE())) - 1),
	DATEADD(MONTH, -1, GETDATE())),
	'First Day of Previous Month (2)' UNION ALL SELECT
	DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0),
	'First Day of Current Month' UNION ALL SELECT
	DATEADD(DAY, -(DAY(GETDATE()) - 1), GETDATE()),
	'First Day of Current Month (2)' UNION ALL SELECT
	DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0),
	'First Day of Next Month' UNION ALL SELECT
	DATEADD(DAY, -(DAY(DATEADD(MONTH, 1, GETDATE())) - 1),
	DATEADD(MONTH, 1, GETDATE())),
	'First Day of Next Month (2)'

	Result
SET:

                       
———————– ——————————-
2011-04-01 00:00:00.000 First Day of Previous Month
2011-04-01 15:47:36.660 First Day of Previous Month (2)
2011-05-01 00:00:00.000 First Day of Current Month
2011-05-01 15:47:36.660 First Day of Current Month (2)
2011-06-01 00:00:00.000 First Day of Next Month
2011-06-01 15:47:36.660 First Day of Next Month (2)
 
(6 row(s) affected)

The above queries can be generalized as below:DECLARE @DURATION INT = 2
SELECT
	DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + @DURATION, 0)
	AS '+2 Months'

SET @DURATION = -2
SELECT
	DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + @DURATION, 0)
	AS '-2 Months'

Result SET:

+2 Months
———————–
2011-07-01 00:00:00.000
 
(1 row(s) affected)
 
-2 Months
———————–
2011-03-01 00:00:00.000
 
(1 row(s) affected)

And, to
 get last day of a month USE:

– © 2011 – Vishal (http://SqlAndMe.com)
 
– Last Day Previous/Current/Next Months
SELECT      DATEADD(DAY, -(DAY(GETDATE())), GETDATE()),
            'Last Day of Previous Month'
UNION ALL SELECT
	DATEADD(MILLISECOND, -3,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)),
	'Last Day of Previous Month (2)' UNION ALL SELECT
	DATEADD(DAY, -(DAY(DATEADD(MONTH, 1, GETDATE()))),
	DATEADD(MONTH, 1, GETDATE())),
	'Last Day of Current Month' UNION ALL SELECT
	DATEADD(MILLISECOND, -3,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0)),
	'Last Day of Current Month (2)' UNION ALL SELECT
	DATEADD(DAY, -(DAY(DATEADD(MONTH, 0, GETDATE()))),
	DATEADD(MONTH, 2, GETDATE())),
	'Last Day of Next Month' UNION ALL SELECT
	DATEADD(SECOND, -1,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 2, 0)),
	'Last Day of Next Month (2)'

	Result
SET:

                       
———————– ——————————
2011-04-30 15:54:35.523 Last Day of Previous Month
2011-04-30 23:59:59.997 Last Day of Previous Month (2)
2011-05-31 15:54:35.523 Last Day of Current Month
2011-05-31 23:59:59.997 Last Day of Current Month (2)
2011-06-30 15:54:35.523 Last Day of Next Month
2011-06-30 23:59:59.000 Last Day of Next Month (2)
 
(6 row(s) affected)

The above queries can be generalized as below:DECLARE @DURATION INT = 2
SELECT
	DATEADD(MILLISECOND, -3,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + @DURATION + 1, 0))
	AS '+2 Months'

SET @DURATION = -2
SELECT
	DATEADD(MILLISECOND, -3,
	DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + @DURATION + 1, 0))
	AS '-2 Months'

Result SET:

+2 Months
———————–
2011-07-31 23:59:59.997
 
(1 row(s) affected)
 
-2 Months
———————–
2011-03-31 23:59:59.997
 
(1 row(s) affected)