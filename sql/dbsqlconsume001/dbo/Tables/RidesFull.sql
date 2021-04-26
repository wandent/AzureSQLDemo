CREATE TABLE [dbo].[RidesFull] (
    [MedallionID]              INT             NULL,
    [MedallionBKey]            NVARCHAR (MAX)  NULL,
    [MedallionCode]            NVARCHAR (MAX)  NULL,
    [DateID]                   INT             NULL,
    [Date]                     DATETIME2 (7)   NULL,
    [DateBKey]                 NVARCHAR (MAX)  NULL,
    [DayOfMonth]               NVARCHAR (MAX)  NULL,
    [DaySuffix]                NVARCHAR (MAX)  NULL,
    [DayName]                  NVARCHAR (MAX)  NULL,
    [DayOfWeek]                NVARCHAR (MAX)  NULL,
    [DayOfWeekInMonth]         NVARCHAR (MAX)  NULL,
    [DayOfWeekInYear]          NVARCHAR (MAX)  NULL,
    [DayOfQuarter]             NVARCHAR (MAX)  NULL,
    [DayOfYear]                NVARCHAR (MAX)  NULL,
    [WeekOfMonth]              NVARCHAR (MAX)  NULL,
    [WeekOfQuarter]            NVARCHAR (MAX)  NULL,
    [WeekOfYear]               NVARCHAR (MAX)  NULL,
    [Month]                    NVARCHAR (MAX)  NULL,
    [MonthName]                NVARCHAR (MAX)  NULL,
    [MonthOfQuarter]           NVARCHAR (MAX)  NULL,
    [Quarter]                  NVARCHAR (MAX)  NULL,
    [QuarterName]              NVARCHAR (MAX)  NULL,
    [Year]                     NVARCHAR (MAX)  NULL,
    [YearName]                 NVARCHAR (MAX)  NULL,
    [MonthYear]                NVARCHAR (MAX)  NULL,
    [MMYYYY]                   NVARCHAR (MAX)  NULL,
    [FirstDayOfMonth]          DATE            NULL,
    [LastDayOfMonth]           DATE            NULL,
    [FirstDayOfQuarter]        DATE            NULL,
    [LastDayOfQuarter]         DATE            NULL,
    [FirstDayOfYear]           DATE            NULL,
    [LastDayOfYear]            DATE            NULL,
    [IsHolidayUSA]             BIT             NULL,
    [IsWeekday]                BIT             NULL,
    [HolidayUSA]               NVARCHAR (MAX)  NULL,
    [HackneyLicenseID]         INT             NULL,
    [PickupTimeID]             INT             NULL,
    [DropoffTimeID]            INT             NULL,
    [PickupGeographyID]        INT             NULL,
    [DropoffGeographyID]       INT             NULL,
    [PickupLatitude]           FLOAT (53)      NULL,
    [PickupLongitude]          FLOAT (53)      NULL,
    [PickupLatLong]            NVARCHAR (MAX)  NULL,
    [DropoffLatitude]          FLOAT (53)      NULL,
    [DropoffLongitude]         FLOAT (53)      NULL,
    [DropoffLatLong]           NVARCHAR (MAX)  NULL,
    [PassengerCount]           INT             NULL,
    [TripDurationSeconds]      INT             NULL,
    [TripDistanceMiles]        FLOAT (53)      NULL,
    [PaymentType]              NVARCHAR (MAX)  NULL,
    [FareAmount]               DECIMAL (19, 4) NULL,
    [SurchargeAmount]          DECIMAL (19, 4) NULL,
    [TaxAmount]                DECIMAL (19, 4) NULL,
    [TipAmount]                DECIMAL (19, 4) NULL,
    [TollsAmount]              DECIMAL (19, 4) NULL,
    [TotalAmount]              DECIMAL (19, 4) NULL,
    [GeographyID]              INT             NULL,
    [PrecipitationInches]      FLOAT (53)      NULL,
    [AvgTemperatureFahrenheit] FLOAT (53)      NULL
);


GO

CREATE NONCLUSTERED INDEX [nc_test_rides_medallion]
    ON [dbo].[RidesFull]([MedallionID] ASC) WITH (FILLFACTOR = 100);


GO

CREATE STATISTICS [st_ridesfull_date]
    ON [dbo].[RidesFull]([MedallionCode], [DateID], [DateBKey], [HackneyLicenseID]) WHERE ([DateBkey]>'20210213' AND [DateBKey]<'20210414');


GO

