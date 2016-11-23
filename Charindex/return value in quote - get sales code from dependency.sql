-- GET SALES CODE FROM DEPENDENCY
DECLARE @dep varchar(60);
SET @dep = '$root.thisandthis eq ''this''';

-- first blank
SELECT CHARINDEX(' ',@dep,0)

--first '
SELECT CHARINDEX(' ',@dep,CHARINDEX(' ',@dep,0)+1)

SELECT CHARINDEX('''',@dep,0)


--SELECT SUBSTRING(@dep,CHARINDEX('''',@dep,0)+1,5)

SELECT SUBSTRING(@dep,CHARINDEX('''',@dep,0)+1,LEN(@dep)-(CHARINDEX('''',@dep,0)+1))


SELECT LEN(@dep)