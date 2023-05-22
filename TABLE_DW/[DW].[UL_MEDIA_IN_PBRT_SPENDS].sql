CREATE TABLE [DW].[UL_MEDIA_IN_PBRT_SPENDS]
(
	[Medium] [nvarchar](255) NULL,
	[Category] [nvarchar](255) NULL,
	[Segment] [nvarchar](255) NULL,
	[Primary_Brand_Key] [nvarchar](255) NULL,
	[Month] [nvarchar](255) NULL,
	[Year] [int] NULL,
	[Market] [nvarchar](255) NULL,
	[Campaign] [nvarchar](255) NULL,
	[IB_TYPE] [nvarchar](255) NULL,
	[LSM] [nvarchar](255) NULL,
	[Amount_Spent_INR] [decimal](15, 7) NULL,
	[Provisional_Column1] [nvarchar](255) NULL,
	[Provisional_Column2] [nvarchar](255) NULL,
	[Provisional_Column3] [nvarchar](255) NULL,
	[Provisional_Column4] [nvarchar](255) NULL,
	[Provisional_Column5][nvarchar](255) NULL
)

-- DROP TABLE [DW].[UL_MEDIA_IN_PBRT_SPENDS]