
SELECT top 100000 ROW_NUMBER() OVER (ORDER BY sv.number) AS num
FROM master.dbo.spt_values sv
CROSS JOIN master.dbo.spt_values sv2