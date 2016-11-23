-- msdn doc sucks
-- simple case
SELECT SalesOrderID, OrderDate,
    CASE
      WHEN ShipDate IS NULL THEN 'Awaiting Shipment'
      ELSE 'Shipped'
    END AS ShippingStatus
FROM SalesLT.SalesOrderHeader;