CREATE TABLE [dbo].[tbl_AdaptiveIndexDefrag_Working] (
    [dbID]             INT            NOT NULL,
    [objectID]         INT            NOT NULL,
    [indexID]          INT            NOT NULL,
    [partitionNumber]  SMALLINT       NOT NULL,
    [dbName]           NVARCHAR (128) NULL,
    [schemaName]       NVARCHAR (128) NULL,
    [objectName]       NVARCHAR (256) NULL,
    [indexName]        NVARCHAR (256) NULL,
    [fragmentation]    FLOAT (53)     NULL,
    [page_count]       INT            NULL,
    [is_primary_key]   BIT            NULL,
    [fill_factor]      INT            NULL,
    [is_disabled]      BIT            NULL,
    [is_padded]        BIT            NULL,
    [is_hypothetical]  BIT            NULL,
    [has_filter]       BIT            NULL,
    [allow_page_locks] BIT            NULL,
    [compression_type] NVARCHAR (60)  NULL,
    [range_scan_count] BIGINT         NULL,
    [record_count]     BIGINT         NULL,
    [type]             TINYINT        NULL,
    [scanDate]         DATETIME       NULL,
    [defragDate]       DATETIME       NULL,
    [printStatus]      BIT            DEFAULT ((0)) NULL,
    [exclusionMask]    INT            DEFAULT ((0)) NULL,
    CONSTRAINT [PK_AdaptiveIndexDefrag_Working] PRIMARY KEY CLUSTERED ([dbID] ASC, [objectID] ASC, [indexID] ASC, [partitionNumber] ASC)
);


GO

