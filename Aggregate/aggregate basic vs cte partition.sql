--ex of aggregate basic, CTE aggregate with partition by
USE AdventureWorks2012
GO

SELECT * FROM sales.SpecialOffer so;
-- basic aggregate
SELECT so.type, count(so.Type)
FROM Sales.SpecialOffer so
GROUP BY so.Type
HAVING COUNT(so.Type)>2
ORDER BY 2;

-- if you need to refer to the result of a window function in other query clauses,
-- you have to do so indirectly by using a table expression, such as a CTE
WITH cnt(a,b) as(
SELECT DISTINCT so.type, COUNT(so.Type) OVER(PARTITION BY so.Type)
FROM Sales.SpecialOffer so
)
SELECT a AS type, b AS [count] FROM cnt c
WHERE b > 2
ORDER BY b