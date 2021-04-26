CREATE   VIEW dbo.testIndexedRides 
WITH SCHEMABINDING
AS
 SELECT MedallionID, Count_big(*) as cont from dbo.RidesFull
 Group by MedallionID
 Union ALL
 SELECT DateID, Count_big(*) as cont from dbo.RidesFull
 Group by DateID
 Union All
 SELECT GeographyID, Count_big(*) as cont from dbo.RidesFull
 Group by GeographyID

GO

