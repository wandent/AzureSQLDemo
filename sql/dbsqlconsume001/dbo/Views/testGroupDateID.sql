
CREATE   VIEW testGroupDateID
WITH SCHEMABINDING
AS 
 SELECT DateID, Count_big(*) as cont from dbo.RidesFull
 Group by DateID

GO

