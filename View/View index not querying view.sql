-- taken from msdn
SET NUMERIC_ROUNDABORT OFF;
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT,
    QUOTED_IDENTIFIER, ANSI_NULLS ON;
GO
-- Creat view with schemabinding
IF OBJECT_ID('Sales.vOrders','view') IS NOT NULL
DROP VIEW Sales.vOrders;
GO
CREATE VIEW Sales.vOrders
WITH SCHEMABINDING
AS
    SELECT SUM(od.UnitPrice*od.OrderQty*(1.00-od.UnitPriceDiscount)) AS Revenue,
	   o.OrderDate, od.ProductID, COUNT_BIG(*) AS COUNT
    FROM Sales.SalesOrderDetail AS od, Sales.SalesOrderHeader AS o
    WHERE od.SalesOrderID = o.SalesOrderID
    GROUP BY o.OrderDate, od.ProductID
GO
-- Create an index on the view
CREATE UNIQUE CLUSTERED INDEX IDX_V1
    ON Sales.vOrders (OrderDate, ProductID);
GO
-- This query can use the indexed view een though the view is not specified in the FROM
-- hmm
SELECT SUM(od.UnitPrice*od.OrderQty*(1.00-od.UnitPriceDiscount)) AS Rev,
    o.OrderDate, od.ProductID
FROM Sales.SalesOrderDetail AS od
    JOIN Sales.SalesOrderHeader AS o ON od.SalesOrderID = o.SalesOrderID
	   AND od.ProductID BETWEEN 700 AND 800
	   AND o.OrderDate >= CONVERT(datetime,'05/01/2002',101)
GROUP BY o.OrderDate, od.ProductID
ORDER BY Rev DESC;
GO
--This query can use the above indexed view.
SELECT  OrderDate, SUM(UnitPrice*OrderQty*(1.00-UnitPriceDiscount)) AS Rev
FROM Sales.SalesOrderDetail AS od
    JOIN Sales.SalesOrderHeader AS o ON od.SalesOrderID=o.SalesOrderID
        AND DATEPART(mm,OrderDate)= 3
        AND DATEPART(yy,OrderDate) = 2002
GROUP BY OrderDate
ORDER BY OrderDate ASC;
GO

DROP INDEX Sales.vOrders.IDX_V1