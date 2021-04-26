
CREATE   VIEW testGroupGeographyID
WITH SCHEMABINDING
AS
SELECT GeographyID, count_big(*) as cont from dbo.RidesFull
 Group by GeographyID

GO

