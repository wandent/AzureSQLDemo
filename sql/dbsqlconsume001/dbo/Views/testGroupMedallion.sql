CREATE   VIEW testGroupMedallion 
WITH SCHEMABINDING
AS 
 SELECT MedallionID, Count_big(*) as cont from dbo.RidesFull
 Group by MedallionID

GO

