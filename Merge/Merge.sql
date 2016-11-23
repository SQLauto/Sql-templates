-- MERGE combines the normal insert, update and delete operations along with the select operation
-- that provides the source and target data for the merge.  Combines 4 statements into 1.  5 if you
-- use the OUTPUT clause and even more with INSERT OVER DML

-- simple stocks and trades example
CREATE TABLE Stock(Symbol varchar(10) PRIMARY KEY, Qty int CHECK(Qty>0));
CREATE TABLE Trade(Symbol varchar(10) PRIMARY KEY, Delta int CHECK(Delta <> 0));
-- insert shares of stock.  10 shares for adventure works 5 for  blue yonder air
INSERT INTO Stock VALUES('ADVW',10);
INSERT INTO Stock VALUES('BYA',5);
-- 3 trades made today.  buy 5, sell 5 and buy 3 new ones
INSERT INTO Trade VALUES('ADVW',5);
INSERT INTO Trade VALUES('BYA',-5);
INSERT INTO Trade VALUES('NWT',3);

SELECT * FROM dbo.Stock AS s;
SELECT * FROM dbo.Trade AS t;

--  You want the trades to update your stock.  You'd no longer own BYA, advw up by 10 and a new nwt
-- That means sql would join Stock and Trade to detect changes, insert, update and delete operations 
-- to apply those changes back to the Stock table.  All this can be done with MERGE
MERGE dbo.Stock
    USING dbo.Trade
    ON Stock.Symbol = Trade.Symbol
    WHEN MATCHED AND (Stock.Qty + Trade.Delta = 0) THEN
	   --delete stock if entirely sold
	   DELETE
    WHEN MATCHED THEN
	   --update stock qty (delete takes precedence over update)
	   UPDATE SET Stock.Qty += Trade.Delta
    WHEN NOT MATCHED BY TARGET THEN  --equivalent to WHEN NOT MATCHED  can only use this once
	   -- add the newly purchased stock
	   INSERT VALUES(Trade.Symbol,Trade.Delta);
-- SQL Server has very particular rules governing the use of multiple merge clauses.  You are permitted
-- to have one or two WHEN MATCHED clauses but no more.  If there are two WHEN MATCHED clauses, the 1st
-- one must be qualified with an AND condition.  Also one clause must specify an UPDATE and the other
-- must specify a DELETE.  As demonstrated MERGE will choose one of the two WHEN MATCHED clauses to 
-- execute based on whether the AND condition evaluates to true for any given row.
SELECT * FROM dbo.Stock AS s;

-- Using MERGE for Table Replication
-- 
-- Creating two tables and a stored procedure that uses MERGE to synchronize them
CREATE TABLE Original(PK int PRIMARY key,FName varchar(10), Number int);
CREATE TABLE Replica(PK int PRIMARY key, FName varchar(10),Number int);
GO
CREATE PROCEDURE uspSyncReplica AS
    MERGE Replica AS R
	   USING Original AS O ON O.PK = R.PK
	   WHEN MATCHED AND (O.FName != R.FName OR O.Number != R.Number) THEN
		  UPDATE SET R.FName = O.FName, R.Number = O.Number
	   WHEN NOT MATCHED THEN	
		  INSERT VALUES(O.PK,O.FName,O.Number)
	   WHEN NOT MATCHED BY SOURCE THEN
		  DELETE;

-- both are empty populate some data
INSERT Original VALUES(1,'Sara',10);
INSERT Original VALUES(2,'Steven',20);
-- call uspSyncReplica to bring Replica up to date
EXEC dbo.uspSyncReplica
GO
SELECT * FROM dbo.Original AS o;
SELECT * FROM dbo.Replica AS r;

-- now perform some changes on Original to mix insert, update and delete to take them out of sync
INSERT INTO Original VALUES(3,'Andrew',100);
UPDATE Original SET Original.FName = 'Stephen',Number += 10 WHERE PK = 2;
DELETE FROM dbo.Original WHERE pk = 1;
GO
SELECT * FROM dbo.Original AS o;
SELECT * FROM dbo.Replica AS r;
-- invoke SP again to sync
EXEC dbo.uspSyncReplica
GO
SELECT * FROM dbo.Original AS o;
SELECT * FROM dbo.Replica AS r;

-- MERGE Output
TRUNCATE TABLE dbo.Original
TRUNCATE TABLE dbo.Replica
DROP PROCEDURE dbo.uspSyncReplica
GO
CREATE PROCEDURE uspSyncReplica AS

MERGE Replica AS R
    USING Original AS O ON O.PK = R.PK
    WHEN MATCHED AND (O.FName != R.FName OR O.Number != R.Number) THEN
	   UPDATE SET R.FName = O.FName, R.Number = O.Number
    WHEN NOT MATCHED THEN
	   INSERT VALUES(O.PK,O.FName,O.Number)
    WHEN NOT MATCHED BY SOURCE THEN
	   DELETE
    OUTPUT $ACTION, INSERTED.*, DELETED.*;
EXEC dbo.uspSyncReplica
GO