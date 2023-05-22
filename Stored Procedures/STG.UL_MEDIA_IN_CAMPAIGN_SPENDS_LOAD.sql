/****** Object:  StoredProcedure [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS_LOAD]    Script Date: 4/29/2022 5:35:34 AM ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS_LOAD]') IS NOT NULL
DROP PROCEDURE [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS_LOAD]
GO

CREATE PROC [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS_LOAD] AS

/*===========================================================================
PROCEDURE NAME:  [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS_LOAD]
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
TRUNCATE TABLE [DW].[UL_MEDIA_IN_CAMPAIGN_SPENDS]

INSERT INTO [DW].[UL_MEDIA_IN_CAMPAIGN_SPENDS]
(
		[Medium]
      ,[Category]
      ,[Segment]
      ,[Primary_Brand_Key]
      ,[Month]
      ,[Year]
      ,[Market]
      ,[Campaign]
      ,[IB_TYPE]
      ,[LSM]
      ,[Type]
      ,[Value]
)
SELECT 
	[Medium]
      ,[Category]
      ,[Segment]
      ,[Primary_Brand_Key]
      ,[Month]
      ,cast([Year] as int) as [Year]
      ,[Market]
      ,[Campaign]
      ,[IB_TYPE]
      ,[LSM]
      ,[Type]
      ,CAST(Round(Value,2)as FLOAT) as [Value]
FROM  [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS]

IF OBJECT_ID('DW.BKP_UL_MEDIA_IN_CAMPAIGN_SPENDS') IS NOT NULL 
DROP TABLE DW.BKP_UL_MEDIA_IN_CAMPAIGN_SPENDS

select * into DW.BKP_UL_MEDIA_IN_CAMPAIGN_SPENDS
from DW.UL_MEDIA_IN_CAMPAIGN_SPENDS

END TRY

BEGIN CATCH
      
SELECT @ERRORMESSAGE = ISNULL(ERROR_MESSAGE(), 'ERROR MESSAGE UNAVAILABLE.'),
	@ERRORPROCEDURE = ISNULL(ERROR_PROCEDURE(), '[STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS_LOAD]'),
	@ERRORSTATE = ISNULL(ERROR_STATE(), 0)
	  
SET @RETURN_MESSAGE = 'ERROR WHILE PROCESSING ' + @ERRORPROCEDURE + ' STORED PROCEDURE. ERROR MESSAGE: ' + @ERRORMESSAGE;
		
THROW 50000, @RETURN_MESSAGE, @ERRORSTATE;

END CATCH 

END



GO


