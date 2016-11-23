---------------------------------------------------------------------
-- Efficient Interval Management in Microsoft SQL Server
-- Itzik Ben-Gan, SolidQ
-- Last modified: August 13, 2013
--
-- Relational Interval Tree model by Hans-Peter, Kriegel Marco, Pötke Thomas Seidl
--     See academic papaer: [RI]   Managing Intervals Efficiently in Object-Relational Databases (http://www.dbs.ifi.lmu.de/Publikationen/Papers/VLDB2000.pdf)
-- Further optimizations (static RI-tree) and date and time mapping by Laurent Martin
--     See articles: [SRI1] A Static Relational Interval Tree (http://www.solidq.com/sqj/Pages/2011-September-Issue/A-Static-Relational-Interval-Tree.aspx)
--                   [SRI2] Advanced interval queries with the Static Relational Interval Tree (https://www.solidq.com/sqj/Pages/Relational/Advanced-interval-queries-with-the-Static-Relational-Interval-Tree.aspx)
--                   [SRI3] Using the Static Relational Interval Tree with time intervals (http://www.solidq.com/sqj/Pages/Relational/Using-the-Static-Relational-Interval-Tree-with-time-intervals.aspx)
-- Overview of RI-tree model and static RI-tree improvements by Itzik Ben-Gan
--     See article: [RIBG] Interval Queries in SQL Server (http://sqlmag.com/t-sql/sql-server-interval-queries)

---------------------------------------------------------------------

---------------------------------------------------------------------
-- DB, Helper Function, Staging Data
---------------------------------------------------------------------

-- Code creating sample database, helper function and staging data

-- create sample database IntervalsDB
SET NOCOUNT ON;
USE master;
IF DB_ID('IntervalsDB') IS NOT NULL DROP DATABASE IntervalsDB;
CREATE DATABASE IntervalsDB;
GO

USE IntervalsDB;
GO

-- create helper function dbo.GetNums
-- purpose: table function returning sequence of integers between inputs @low and @high
CREATE FUNCTION dbo.GetNums(@low AS BIGINT, @high AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
    L0   AS (SELECT c FROM (SELECT 1 UNION ALL SELECT 1) AS D(c)),
    L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
    L2   AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
    L3   AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
    L4   AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
    L5   AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
    Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
            FROM L5)
  SELECT TOP(@high - @low + 1) @low + rownum - 1 AS n
  FROM Nums
  ORDER BY rownum;
GO

-- create staging table dbo.Stage with 10,000,000 intervals
CREATE TABLE dbo.Stage
(
  id    INT NOT NULL,
  lower INT NOT NULL,
  upper INT NOT NULL,
  CONSTRAINT PK_Stage PRIMARY KEY(id),
  CONSTRAINT CHK_Stage_upper_gteq_lower CHECK(upper >= lower)
);

DECLARE
  @numintervals AS INT = 10000000,
  @minlower     AS INT = 1,
  @maxupper     AS INT = 10000000,
  @maxdiff      AS INT = 20;

WITH C AS
(
  SELECT
    n AS id,
    @minlower + (ABS(CHECKSUM(NEWID())) % (@maxupper - @minlower - @maxdiff + 1)) AS lower,
    ABS(CHECKSUM(NEWID())) % (@maxdiff + 1) AS diff
  FROM dbo.GetNums(1, @numintervals) AS Nums
)
INSERT INTO dbo.Stage WITH(TABLOCK) (id, lower, upper)
  SELECT id, lower, lower + diff AS upper
  FROM C;

---------------------------------------------------------------------
-- Traditional Interval Representation
---------------------------------------------------------------------

-- Create and populate Intervals table
-- 41 seconds
CREATE TABLE dbo.Intervals
(
  id    INT NOT NULL,
  lower INT NOT NULL,
  upper INT NOT NULL,
  CONSTRAINT CHK_Intervals_upper_gteq_lower CHECK(upper >= lower)
);

INSERT INTO dbo.Intervals WITH(TABLOCK) (id, lower, upper)
  SELECT id, lower, upper
  FROM dbo.Stage;

ALTER TABLE dbo.Intervals ADD CONSTRAINT PK_Intervals PRIMARY KEY(id);

CREATE INDEX idx_lower ON dbo.Intervals(lower) INCLUDE(upper);
CREATE INDEX idx_upper ON dbo.Intervals(upper) INCLUDE(lower);
GO

-- query
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- middle of data
-- logical reads: 11414, CPU time: 499 ms
DECLARE @l AS INT = 5000000, @u AS INT = 5000020;

SELECT id
FROM dbo.Intervals
WHERE lower <= @u AND upper >= @l
OPTION (RECOMPILE); -- used to allow variable sniffing and prevent plan reuse
GO

-- beginning of data
-- logical reads: 3, CPU time: 0 ms
DECLARE @l AS INT = 80, @u AS INT = 100;

SELECT id
FROM dbo.Intervals
WHERE lower <= @u AND upper >= @l
OPTION (RECOMPILE);
GO

-- end of data
-- logical reads: 3, CPU time: 0 ms
DECLARE @l AS INT = 10000000 - 100, @u AS INT = 10000000 - 80;

SELECT id
FROM dbo.Intervals
WHERE lower <= @u AND upper >= @l
OPTION (RECOMPILE);
GO

---------------------------------------------------------------------
-- Relational Interval Tree ([RI], [SRI1], [SRI2], [SRI3], [RIBG])
---------------------------------------------------------------------

-- Definition of forkNode function
-- Based on [RI]
IF OBJECT_ID(N'dbo.forkNode', N'FN') IS NOT NULL DROP FUNCTION dbo.forkNode;
GO
CREATE FUNCTION dbo.forkNode(@lower AS INT, @upper AS INT) RETURNS INT
  WITH SCHEMABINDING
AS
BEGIN
  DECLARE @node AS INT = 1073741824; -- root = 2^(h-1), h = height of tree, #values: 2^h - 1
  DECLARE @step AS INT = @node / 2;

  WHILE @step >= 1
  BEGIN
    IF @upper < @node
      SET @node -= @step;
    ELSE IF @lower > @node
      SET @node += @step;
    ELSE
      BREAK;
    SET @step /= 2;
  END;
  RETURN @node;
END;
GO

-- example
SELECT dbo.forkNode(11, 13);

-- Create and populate IntervalsRIT table
-- Based on [SRI1]
-- 64 seconds
CREATE TABLE dbo.IntervalsRIT
(
  id    INT NOT NULL,
  node  AS upper - upper % POWER(2, CAST(LOG((lower - 1) ^ upper, 2) AS INT)) PERSISTED NOT NULL,
  lower INT NOT NULL,
  upper INT NOT NULL,
  CONSTRAINT CHK_IntervalsRIT_upper_gteq_lower CHECK(upper >= lower)
);

INSERT INTO dbo.IntervalsRIT WITH(TABLOCK) (id, lower, upper)
  SELECT id, lower, upper
  FROM dbo.Stage;

ALTER TABLE dbo.IntervalsRIT ADD CONSTRAINT PK_IntervalsRIT PRIMARY KEY(id);
CREATE INDEX idx_lower ON dbo.IntervalsRIT(node, lower);
CREATE INDEX idx_upper ON dbo.IntervalsRIT(node, upper);
GO

-- Definitions of leftNodes and rightNodes functions
-- Based on [RI]

-- rightNodes function
IF OBJECT_ID(N'dbo.leftNodes', N'TF') IS NOT NULL DROP FUNCTION dbo.leftNodes;
GO
CREATE FUNCTION dbo.leftNodes(@lower AS INT, @upper AS INT)
  RETURNS @T TABLE
  (
    node INT NOT NULL PRIMARY KEY
  )
AS
BEGIN
  DECLARE @node AS INT = 1073741824;
  DECLARE @step AS INT = @node / 2;

  -- descend from root node to lower
  WHILE @step >= 1
  BEGIN
    -- right node
    IF @lower < @node
      SET @node -= @step;
    -- left node
    ELSE IF @lower > @node
    BEGIN
      INSERT INTO @T(node) VALUES(@node);
      SET @node += @step;
    END
    -- lower
    ELSE
      BREAK;
    SET @step /= 2;
  END;

  RETURN;
END;
GO

-- rightNodes function
IF OBJECT_ID(N'dbo.rightNodes', N'TF') IS NOT NULL DROP FUNCTION dbo.rightNodes;
GO
CREATE FUNCTION dbo.rightNodes(@lower AS INT, @upper AS INT)
  RETURNS @T TABLE
  (
    node INT NOT NULL PRIMARY KEY
  )
AS
BEGIN
  DECLARE @node AS INT = 1073741824;
  DECLARE @step AS INT = @node / 2;

  -- descend from root node to upper
  WHILE @step >= 1
  BEGIN
    -- left node
    IF @upper > @node
      SET @node += @step
    -- right node
    ELSE IF @upper < @node
    BEGIN
      INSERT INTO @T(node) VALUES(@node);
      SET @node -= @step
    END
    -- upper
    ELSE
      BREAK;
    SET @step /= 2;
  END;

  RETURN;
END;
GO

-- test
SELECT dbo.forkNode(11, 13);

-- Intersection query
-- Based on [RI]

-- logical reads: 81 (IntervalsRIT) + 2 (@T - leftNodes) + 2 (@T - rightNodes), CPU time: 16 ms
DECLARE @l AS INT = 5000000, @u AS INT = 5000020;

SELECT I.id
FROM dbo.IntervalsRIT AS I
  JOIN dbo.leftNodes(@l, @u) AS L
    ON I.node = L.node
    AND I.upper >= @l

UNION ALL

SELECT I.id
FROM dbo.IntervalsRIT AS I
  JOIN dbo.rightNodes(@l, @u) AS R
    ON I.node = R.node
    AND I.lower <= @u

UNION ALL

SELECT id
FROM dbo.IntervalsRIT
WHERE node BETWEEN @l AND @u

OPTION (RECOMPILE);
GO

-- optimization of computation of leftNodes and rightNodes
-- A variation based on [RIBG]

-- Create and populate BitMasks table
-- Based on [SRI1]
CREATE TABLE dbo.BitMasks
(
  b1 INT NOT NULL,
  b3 INT NOT NULL
);

INSERT INTO dbo.BitMasks(b1, b3)
  SELECT -POWER(2, n), POWER(2, n)
  FROM (VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),
              (11),(12),(13),(14),(15),(16),(17),(18),(19),(20),
              (21),(22),(23),(24),(25),(26),(27),(28),(29),(30)) AS Nums(n);
GO

-- Definitions of Ancestors function
-- A variation based on [SRI1]

IF OBJECT_ID(N'dbo.rightNodes', N'TF') IS NOT NULL DROP FUNCTION dbo.rightNodes;
GO
CREATE FUNCTION dbo.Ancestors(@node AS INT) RETURNS TABLE
AS
RETURN
  SELECT @node & b1 | b3 as node
  FROM dbo.BitMasks
  WHERE b3 > @node & -@node;
GO

-- ancestors
SELECT node FROM dbo.Ancestors(13) AS A;

-- left nodes
SELECT node FROM dbo.Ancestors(13) AS AWHERE node < 13;

-- right nodes
SELECT node FROM dbo.Ancestors(13) AS AWHERE node > 13;

-- Intersection query with inline function

-- logical reads: 81 (IntervalsRIT) + 2 (BitMasks), CPU time: 0 ms
DECLARE @l AS INT = 5000000, @u AS INT = 5000020;

SELECT I.id
FROM dbo.IntervalsRIT AS I
  JOIN dbo.Ancestors(@l) AS L
    ON L.node < @l
    AND I.node = L.node
    AND I.upper >= @l

UNION ALL

SELECT I.id
FROM dbo.IntervalsRIT AS I
  JOIN dbo.Ancestors(@u) AS R
    ON R.node > @u
    AND I.node = R.node
    AND I.lower <= @u

UNION ALL

SELECT id
FROM dbo.IntervalsRIT
WHERE node BETWEEN @l AND @u

OPTION (RECOMPILE);
GO

-- further optimization
-- logical reads: 66 (IntervalsRIT) + 2 (BitMasks), CPU time: 0 ms
DECLARE @l AS INT = 5000000, @u AS INT = 5000020;

SELECT I.id
FROM dbo.IntervalsRIT AS I
  JOIN dbo.Ancestors(@l) AS L
    ON L.node < @l
    AND L.node >= (SELECT MIN(node) FROM dbo.IntervalsRIT)
    AND I.node = L.node
    AND I.upper >= @l

UNION ALL

SELECT I.id
FROM dbo.IntervalsRIT AS I
  JOIN dbo.Ancestors(@u) AS R
    ON R.node > @u
    AND R.node <= (SELECT MAX(node) FROM dbo.IntervalsRIT)
    AND I.node = R.node
    AND I.lower <= @u

UNION ALL

SELECT id
FROM dbo.IntervalsRIT
WHERE node BETWEEN @l AND @u

OPTION (RECOMPILE);