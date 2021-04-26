CREATE   VIEW testGroupMedallionCode
WITH SCHEMABINDING
AS
SELECT MedallionCode, count_big(*) as cont from dbo.RidesFull
 Group by MedallionCode

GO

