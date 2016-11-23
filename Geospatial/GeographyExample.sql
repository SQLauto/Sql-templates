--messing with geospatial stuff
IF OBJECT_ID ( 'dbo.SpatialTable', 'U' ) IS NOT NULL 
    DROP TABLE dbo.SpatialTable;
GO

CREATE TABLE SpatialTable 
    ( id int IDENTITY (1,1),
    GeogCol1 geography, 
    GeogCol2 AS GeogCol1.STAsText() );
GO

INSERT INTO SpatialTable (GeogCol1)
VALUES (geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326));

INSERT INTO SpatialTable (GeogCol1)
VALUES (geography::STGeomFromText('POLYGON((-122.358 47.653 , -122.348 47.649, -122.348 47.658, -122.358 47.658, -122.358 47.653))', 4326));
GO

SELECT * FROM dbo.SpatialTable st;


INSERT INTO dbo.SpatialTable (GeogCol1)
VALUES (geography::Point(35.091325,-85.334160, 4326));

--chattanooga geolocation
SELECT geography::STGeomFromText('POINT(-85.334160 35.091352)',4326)



DECLARE @geog GEOGRAPHY
SET @geog = Geography::STLineFromText('LINESTRING (-122.360 47.656,-122.343 47.656)', 4326);
SELECT @geog;
set @geog = Geography::Parse('LINESTRING (-122.360 47.656,-122.343 47.656)')
SELECT @geog;
set @geog = 'LINESTRING (-122.360 47.656, -122.343 47.656)'
SELECT @geog;


DECLARE @geom GEOMETRY
SET @geom = geometry::STLineFromText('LINESTRING (100 100, 20 180, 180 180)', 0)

select @geom.STLength() as "Length"
GO

USE AdventureWorks2012;
GO

DECLARE @or geography, @dest geography;
SET @or = (SELECT a.SpatialLocation FROM person.Address a WHERE a.AddressID = 30);
SET @dest = (SELECT a.SpatialLocation FROM person.Address a WHERE a.AddressID = 28);
SELECT @or.STDistance(@dest)/1609.344;
SELECT *
FROM person.Address a
WHERE city = N'Dallas';


DECLARE @g geography;
DECLARE @h geography;
SET @g = geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656)', 4326);
SET @h = geography::STGeomFromText('POINT(-122.34900 47.65100)', 4326);
SELECT @g.STDistance(@h);


--distance from chattanooga to carlise
--chattanooga
DECLARE @CMO geography;
DECLARE @CAR geography;
DECLARE @dist float(10);
SET @cmo = geography::STGeomFromText('POINT(-85.334160 35.091352)',4326)
--carlise?
SET @car = geography::STGeomFromText('POINT(-77.112775 40.234753)',4326)

--distance crow? 1 mile = 1609.344 meters
SET @dist = @CMO.STDistance(@car)/1609.344;
--SELECT @cmo.STDistance(@car)/1609.344;

IF (@cmo.STDistance(@car)/1609.344) > 10
BEGIN
	PRINT 'WARNING - distance between plants is ' + CAST(@dist AS varchar(10));
END

ELSE
	PRINT 'nope'