/****** Object:  StoredProcedure [STG].[UL_MEDIA_IN_PBRT_HULACD_MASTER]    Script Date: 4/29/2022 5:35:34 AM ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[STG].[UL_MEDIA_IN_PBRT_HULACD_MASTER_LOAD]') IS NOT NULL
DROP PROCEDURE [STG].[UL_MEDIA_IN_PBRT_HULACD_MASTER_LOAD]
GO

CREATE PROC [STG].[UL_MEDIA_IN_PBRT_HULACD_MASTER_LOAD] AS

/*===========================================================================
PROCEDURE NAME:  [STG].[UL_MEDIA_IN_PBRT_HULACD_MASTER_LOAD]
DESCRIPTION:     SP TO LOAD DW TABLE FOR HANA PRIMARY SALES DATA
PARAMETERS:      NONE
REVISION HISTORY

DATE         NAME                 COMMENTS
-----------  -------------------  ----------------------------------------
2023-03-29	  Shakhaf			INITIAL VERSION

===========================================================================*/

BEGIN
SET NOCOUNT ON

-- DECLARE LOCAL VARIABLES
DECLARE @RETURN_MESSAGE    NVARCHAR(MAX)
	    ,@ERRORMESSAGE     NVARCHAR(4000)
        ,@ERRORPROCEDURE   NVARCHAR(255)
	    ,@ERRORSTATE       INT
	    
BEGIN TRY
TRUNCATE TABLE [DW].[UL_MEDIA_IN_PBRT_HULACD_MASTER]

INSERT INTO [DW].[UL_MEDIA_IN_PBRT_HULACD_MASTER]
(
[Year],
[Month],
[Length],
[Brand],
[Product],
[Advertiser],
[Brand_Cat],
[Segment],
[Business],
[Advertiser_Group],
[Hul_Nhul],
[Product_Cat],
[Primary_Brand_Key],
[Market],
[Average_Length],
[TVR],
[Norm30sec_Grp],
[Norm30sec_GrpxAverage_Length]
)
SELECT 
cast([Year] as int) as [Year],
[Month],
cast([Length] as int) as [Length],
[Brand],
[Product],
[Advertiser],
[Brand_Cat],
[Segment],
[Business],
[Advertiser_Group],
[Hul_Nhul],
[Product_Cat],
[Primary_Brand_Key],
[Market],
cast([Average_Length] as int) as [Average_Length],
CONVERT(DECIMAL(7,2),[TVR]),
TRY_CONVERT(DECIMAL(11,6), CAST([Norm30sec_Grp] AS FLOAT)),
cast([Norm30sec_GrpxAverage_Length] as real) as [Norm30sec_GrpxAverage_Length]
FROM  [STG].[UL_MEDIA_IN_PBRT_HULACD_MASTER]

END TRY

BEGIN CATCH
      
SELECT @ERRORMESSAGE = ISNULL(ERROR_MESSAGE(), 'ERROR MESSAGE UNAVAILABLE.'),
	@ERRORPROCEDURE = ISNULL(ERROR_PROCEDURE(), '[STG].[UL_MEDIA_IN_PBRT_HULACD_MASTER_LOAD]'),
	@ERRORSTATE = ISNULL(ERROR_STATE(), 0)
	  
SET @RETURN_MESSAGE = 'ERROR WHILE PROCESSING ' + @ERRORPROCEDURE + ' STORED PROCEDURE. ERROR MESSAGE: ' + @ERRORMESSAGE;
		
THROW 50000, @RETURN_MESSAGE, @ERRORSTATE;

END CATCH 

END



GO


