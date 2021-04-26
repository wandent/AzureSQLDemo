
------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE usp_AdaptiveIndexDefrag_Exceptions @exceptionMask_DB NVARCHAR(255) = NULL,
	@exceptionMask_days NVARCHAR(27) = NULL,
	@exceptionMask_tables NVARCHAR(500) = NULL,
	@exceptionMask_indexes NVARCHAR(500) = NULL
AS
/*
usp_AdaptiveIndexDefrag_Exceptions.sql - pedro.lopes@microsoft.com (http://aka.ms/AID)
To insert info into the Exceptions table, use the following guidelines:
For @exceptionMask_DB, enter only one database name at a time.
For @exceptionMask_days, enter weekdays in short form, between commas.
	* NOTE: Keep only the weekdays you DO NOT WANT to ALLOW defrag. *
	Order is not mandatory, but weekday short names are important AS IS ('Sun,Mon,Tue,Wed,Thu,Fri,Sat').
	* NOTE: If you WANT to NEVER allow defrag, set as NULL or leave blank *
For @exceptionMask_tables (optional) enter table names separated by commas ('table_name_1, table_name_2, table_name_3').
For @exceptionMask_indexes (optional) enter index names separated by commas ('index_name_1, index_name_2, index_name_3').
	If you want to exclude all indexes in a given table, enter its name but don't add index names.
Example:
EXEC usp_AdaptiveIndexDefrag_Exceptions @exceptionMask_DB = 'AdventureWorks2008R2',
	@exceptionMask_days = 'Mon,Wed',
	@exceptionMask_tables = 'Employee',
	@exceptionMask_indexes = 'AK_Employee_LoginID'
*/
SET NOCOUNT ON;

IF @exceptionMask_DB IS NULL OR QUOTENAME(@exceptionMask_DB) NOT IN (SELECT QUOTENAME(name) FROM sys.databases)
RAISERROR('Syntax error. Please input a valid database name.', 15, 42) WITH NOWAIT;

IF @exceptionMask_days IS NOT NULL AND
	(@exceptionMask_days NOT LIKE '___' AND
	@exceptionMask_days NOT LIKE '___,___' AND
	@exceptionMask_days NOT LIKE '___,___,___' AND
	@exceptionMask_days NOT LIKE '___,___,___,___' AND
	@exceptionMask_days NOT LIKE '___,___,___,___,___' AND
	@exceptionMask_days NOT LIKE '___,___,___,___,___,___' AND
	@exceptionMask_days NOT LIKE '___,___,___,___,___,___,___')
RAISERROR('Syntax error. Please input weekdays in short form, between commas, or leave NULL to always exclude.', 15, 42) WITH NOWAIT;

IF @exceptionMask_days LIKE '[___,___,___,___,___,___,___]'
RAISERROR('Warning. You chose to permanently exclude a table and/or index from being defragmented.', 0, 42) WITH NOWAIT;

IF @exceptionMask_tables IS NOT NULL AND @exceptionMask_tables LIKE '%.%'
RAISERROR('Syntax error. Please do not input schema with table name(s).', 15, 42) WITH NOWAIT;

DECLARE @debugMessage NVARCHAR(4000), @sqlcmd NVARCHAR(4000), @sqlmajorver int

/* Find sql server version */
SELECT @sqlmajorver = CONVERT(int, (@@microsoftversion / 0x1000000) & 0xff);
		
BEGIN TRY
	--Always exclude from defrag?
	IF @exceptionMask_days IS NULL OR @exceptionMask_days = ''
		BEGIN
			SET @exceptionMask_days = 127
		END
	ELSE
		BEGIN
			-- 1=Sunday, 2=Monday, 4=Tuesday, 8=Wednesday, 16=Thursday, 32=Friday, 64=Saturday, 127=AllWeek
			SET @exceptionMask_days = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@exceptionMask_days,',','+'),'Sun',1),'Mon',2),'Tue',4),'Wed',8),'Thu',16),'Fri',32),'Sat',64);
		END
	--Just get everything as it should be
	SET @exceptionMask_tables = CHAR(39) + REPLACE(REPLACE(@exceptionMask_tables, ' ', ''),',', CHAR(39) + ',' + CHAR(39)) + CHAR(39)
	SET @exceptionMask_indexes = CHAR(39) + REPLACE(REPLACE(@exceptionMask_indexes, ' ', ''),',', CHAR(39) + ',' + CHAR(39)) + CHAR(39)

	--Get the exceptions insert command
	IF @sqlmajorver > 9
	BEGIN	
		SELECT @sqlcmd = 'MERGE dbo.tbl_AdaptiveIndexDefrag_Exceptions AS target
USING (SELECT ' + CONVERT(NVARCHAR,DB_ID(@exceptionMask_DB)) + ' AS dbID, si.[object_id] AS objectID, si.index_id AS indexID,
''' + @exceptionMask_DB + ''' AS dbName, OBJECT_NAME(si.[object_id], ' + CONVERT(NVARCHAR,DB_ID(@exceptionMask_DB)) + ') AS objectName, si.[name] AS indexName,
' + CONVERT(NVARCHAR,@exceptionMask_days) + ' AS exclusionMask
FROM ' + QUOTENAME(@exceptionMask_DB) + '.sys.indexes si
INNER JOIN ' + QUOTENAME(@exceptionMask_DB) + '.sys.objects so ON si.object_id = so.object_id
WHERE so.is_ms_shipped = 0 AND si.index_id > 0 AND si.is_hypothetical = 0
	AND si.[object_id] NOT IN (SELECT sit.[object_id] FROM [' + @exceptionMask_DB + '].sys.internal_tables AS sit)' -- Exclude Heaps, Internal and Hypothetical objects
	+ CASE WHEN @exceptionMask_tables IS NOT NULL THEN ' AND OBJECT_NAME(si.[object_id], ' + CONVERT(NVARCHAR,DB_ID(@exceptionMask_DB)) + ') IN (' + @exceptionMask_tables + ')' ELSE '' END
	+ CASE WHEN @exceptionMask_indexes IS NOT NULL THEN ' AND si.[name] IN (' + @exceptionMask_indexes + ')' ELSE '' END
+ ') AS source
ON (target.[dbID] = source.[dbID] AND target.objectID = source.objectID AND target.indexID = source.indexID)
WHEN MATCHED THEN
	UPDATE SET exclusionMask = source.exclusionMask
WHEN NOT MATCHED THEN
	INSERT (dbID, objectID, indexID, dbName, objectName, indexName, exclusionMask)
	VALUES (source.dbID, source.objectID, source.indexID, source.dbName, source.objectName, source.indexName, source.exclusionMask);';
	END
	ELSE
	BEGIN	
			SELECT @sqlcmd = 'DELETE FROM dbo.tbl_AdaptiveIndexDefrag_Exceptions
WHERE dbID = ' + CONVERT(NVARCHAR,DB_ID(@exceptionMask_DB))
+ CASE WHEN @exceptionMask_tables IS NOT NULL THEN ' AND [objectName] IN (' + @exceptionMask_tables + ')' ELSE '' END
+ CASE WHEN @exceptionMask_indexes IS NOT NULL THEN ' AND [indexName] IN (' + @exceptionMask_indexes + ');' ELSE ';' END +
'INSERT INTO dbo.tbl_AdaptiveIndexDefrag_Exceptions
SELECT ' + CONVERT(NVARCHAR,DB_ID(@exceptionMask_DB)) + ' AS dbID, si.[object_id] AS objectID, si.index_id AS indexID,
''' + @exceptionMask_DB + ''' AS dbName, OBJECT_NAME(si.[object_id], ' + CONVERT(NVARCHAR,DB_ID(@exceptionMask_DB)) + ') AS objectName, si.[name] AS indexName,
' + CONVERT(NVARCHAR,@exceptionMask_days) + ' AS exclusionMask
FROM ' + QUOTENAME(@exceptionMask_DB) + '.sys.indexes si
INNER JOIN ' + QUOTENAME(@exceptionMask_DB) + '.sys.objects so ON si.object_id = so.object_id
WHERE so.is_ms_shipped = 0 AND si.index_id > 0 AND si.is_hypothetical = 0
	AND si.[object_id] NOT IN (SELECT sit.[object_id] FROM [' + @exceptionMask_DB + '].sys.internal_tables AS sit)' -- Exclude Heaps, Internal and Hypothetical objects
	+ CASE WHEN @exceptionMask_tables IS NOT NULL THEN ' AND OBJECT_NAME(si.[object_id], ' + CONVERT(NVARCHAR,DB_ID(@exceptionMask_DB)) + ') IN (' + @exceptionMask_tables + ')' ELSE '' END
	+ CASE WHEN @exceptionMask_indexes IS NOT NULL THEN ' AND si.[name] IN (' + @exceptionMask_indexes + ')' ELSE '' END;
	END;
	EXEC sp_executesql @sqlcmd;
END TRY		
BEGIN CATCH	
	SET @debugMessage = 'Error ' + CONVERT(NVARCHAR(20),ERROR_NUMBER()) + ': ' + ERROR_MESSAGE() + ' (Line Number: ' + CAST(ERROR_LINE() AS NVARCHAR(10)) + ')';
	RAISERROR(@debugMessage, 0, 42) WITH NOWAIT;
END CATCH;

GO

