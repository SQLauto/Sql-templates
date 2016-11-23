-- find 2nd or Nth occurence of a value in a string

-- return letters to right of second -
select CarrierTrackingNumber, right(CarrierTrackingNumber,LEN(CarrierTrackingNumber)-CHARINDEX('-',CarrierTrackingNumber,CHARINDEX('-',CarrierTrackingNumber)+1))
from sales.SalesOrderDetail

select CHARINDEX('-',CarrierTrackingNumber) AS firstpos,
 CHARINDEX('-',CarrierTrackingNumber,CHARINDEX('-',CarrierTrackingNumber)+1) as secondpos
from sales.SalesOrderDetail