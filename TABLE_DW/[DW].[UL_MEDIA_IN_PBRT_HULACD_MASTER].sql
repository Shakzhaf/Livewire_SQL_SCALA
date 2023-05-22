CREATE TABLE [DW].[UL_MEDIA_IN_PBRT_HULACD_MASTER]
(
	[Year] [int] NULL,
	[Month] [nvarchar](20) NULL,
	[Length] [int] NULL,
	[Brand] [nvarchar](255) NULL,
	[Product] [nvarchar](255) NULL,
	[Advertiser] [nvarchar](255) NULL,
	[Brand_Cat] [nvarchar](255) NULL,
	[Segment] [nvarchar](255) NULL,
	[Business] [nvarchar](255) NULL,
	[Advertiser_Group] [nvarchar](255) NULL,
	[Hul_Nhul] [nvarchar](255) NULL,
	[Product_Cat] [nvarchar](255) NULL,
	[Primary_Brand_Key] [nvarchar](255) NULL,
	[Market] [nvarchar](255) NULL,
	[Average_Length] [int] NULL,
	[TVR] [decimal](7, 2) NULL,
	[Norm30sec_Grp] [decimal](11, 6) NULL,
	[Norm30sec_GrpxAverage_Length] [real] NULL
) 

-- Drop Table [DW].[UL_MEDIA_IN_PBRT_HULACD_MASTER]