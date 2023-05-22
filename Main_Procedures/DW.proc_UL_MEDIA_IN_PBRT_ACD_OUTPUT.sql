SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[DW].[proc_UL_MEDIA_IN_PBRT_ACD_OUTPUT]') IS NOT NULL
DROP PROCEDURE [DW].[proc_UL_MEDIA_IN_PBRT_ACD_OUTPUT]
GO

CREATE PROC [DW].[proc_UL_MEDIA_IN_PBRT_ACD_OUTPUT]  as 



IF OBJECT_ID('[DW].[UL_MEDIA_IN_PBRT_ACD_OUTPUT]') IS NOT NULL 
DROP TABLE [DW].[UL_MEDIA_IN_PBRT_ACD_OUTPUT];

select 	[Year]
      ,[Month]
	--   ,[Product]
      -- ,[Advertiser]
      -- ,[Brand_Cat]
      -- ,[Segment]
      -- ,[Business]
      -- ,[Advertiser_Group]
      -- ,[Hul_Nhul]
      -- ,[Product_Cat]
	  ,[Primary_Brand_Key]      
      ,[Market],
   COALESCE(sum(Norm30sec_GrpxAverage_Length)/NULLIF(sum(Norm30sec_Grp),0),0) as ACD
   into [DW].[UL_MEDIA_IN_PBRT_ACD_OUTPUT]
from DW.UL_MEDIA_IN_PBRT_HULACD_MASTER
--where Primary_Brand_Key='SunsilkShampoo'
group by Primary_Brand_Key, Market,
[Year]
      ,[Month]
	--   [Product]
      -- ,[Advertiser]
      -- ,[Brand_Cat]
      -- ,[Segment]
      -- ,[Business]
      -- ,[Advertiser_Group]
      -- ,[Hul_Nhul]
      -- ,[Product_Cat] 