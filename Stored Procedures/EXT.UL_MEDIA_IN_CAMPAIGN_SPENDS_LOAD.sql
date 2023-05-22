SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[EXT].[UL_MEDIA_IN_CAMPAIGN_SPENDS_LOAD]') IS NOT NULL 
DROP PROCEDURE [EXT].[UL_MEDIA_IN_CAMPAIGN_SPENDS_LOAD]
GO

CREATE PROC [EXT].[UL_MEDIA_IN_CAMPAIGN_SPENDS_LOAD] AS
/*===========================================================================
 PROCEDURE NAME:  [EXT].[UL_MEDIA_IN_CAMPAIGN_SPENDS_LOAD]
 DESCRIPTION:     SP to load Brand Hierarchy Master Data from EXT to STG
 PARAMETERS:      NONE
 REVISION HISTORY

 Date         Name                 Comments
 -----------  -------------------  ----------------------------------------
 2022-09-02	  Shakhaf				Initial
===========================================================================*/
BEGIN
SET NOCOUNT ON


DECLARE @return_message   NVARCHAR(MAX)
DECLARE @ErrorMessage     NVARCHAR(4000)
DECLARE @ErrorProcedure   NVARCHAR(126)
DECLARE @ErrorState       INT

BEGIN TRY

       IF EXISTS ( SELECT * FROM sys.external_tables WHERE object_id = OBJECT_ID('[EXT].[UL_MEDIA_IN_CAMPAIGN_SPENDS]') )
			DROP EXTERNAL TABLE   [EXT].[UL_MEDIA_IN_CAMPAIGN_SPENDS]

       CREATE EXTERNAL TABLE   [EXT].[UL_MEDIA_IN_CAMPAIGN_SPENDS]
		(              
            [Medium] [nvarchar](200) NULL,
            [Category] [nvarchar](200) NULL,
            [Segment] [nvarchar](200) NULL,
            [Primary_Brand_Key] [nvarchar](200) NULL,
            [Month] [nvarchar](200) NULL,
            [Year] [nvarchar](200) NULL,
            [Market] [nvarchar](200) NULL,
            [Campaign] [nvarchar](200) NULL,
            [IB_TYPE] [nvarchar](200) NULL,
            [LSM] [nvarchar](200) NULL,
            [Type] [nvarchar](200) NULL,
            [Value] [nvarchar](200) NULL

		)

        

       WITH (DATA_SOURCE =[adlsLocal] ,
       LOCATION = '/ProductDataStores/LiveWire/India/PBRT/Campaign_Reach/UL_Media_IN_CampaignSpends.csv',FILE_FORMAT = [ADLS_DELIMITEDTEXT],
	   REJECT_TYPE = Percentage,REJECT_VALUE = 2, REJECT_SAMPLE_VALUE=10)

	    IF EXISTS (SELECT 1 FROM sys.stats st WHERE  [NAME] = 'RPT_CAMPAIGN_SPENDS1')
		BEGIN
		DROP STATISTICS [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS].[RPT_CAMPAIGN_SPENDS1]
		DROP STATISTICS [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS].[RPT_CAMPAIGN_SPENDS2]
		DROP STATISTICS [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS].[RPT_CAMPAIGN_SPENDS3]
		DROP STATISTICS [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS].[RPT_CAMPAIGN_SPENDS4]
		DROP STATISTICS [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS].[RPT_CAMPAIGN_SPENDS5]
		DROP STATISTICS [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS].[RPT_CAMPAIGN_SPENDS6]
		DROP STATISTICS [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS].[RPT_CAMPAIGN_SPENDS7]
        DROP STATISTICS [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS].[RPT_CAMPAIGN_SPENDS8]
		DROP STATISTICS [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS].[RPT_CAMPAIGN_SPENDS9]
		DROP STATISTICS [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS].[RPT_CAMPAIGN_SPENDS10]
		DROP STATISTICS [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS].[RPT_CAMPAIGN_SPENDS11]
		DROP STATISTICS [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS].[RPT_CAMPAIGN_SPENDS12]
		END

       TRUNCATE TABLE [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS]

       INSERT INTO [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS]
       Select *,getdate(),SYSTEM_USER,getdate(),SYSTEM_USER 
	   FROM [EXT].[UL_MEDIA_IN_CAMPAIGN_SPENDS] WHERE Medium<>'Medium'

	   CREATE STATISTICS [RPT_CAMPAIGN_SPENDS1] ON [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS](Medium)
	   CREATE STATISTICS [RPT_CAMPAIGN_SPENDS2] ON [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS](Category)
       CREATE STATISTICS [RPT_CAMPAIGN_SPENDS3] ON [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS](Segment)
	   CREATE STATISTICS [RPT_CAMPAIGN_SPENDS4] ON [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS](Primary_Brand_Key)
	   CREATE STATISTICS [RPT_CAMPAIGN_SPENDS5] ON [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS](Month)
	   CREATE STATISTICS [RPT_CAMPAIGN_SPENDS6] ON [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS](Year)
	   CREATE STATISTICS [RPT_CAMPAIGN_SPENDS7] ON [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS](Market)
	   CREATE STATISTICS [RPT_CAMPAIGN_SPENDS8] ON [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS](Campaign)
       CREATE STATISTICS [RPT_CAMPAIGN_SPENDS9] ON [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS](IB_TYPE)
       CREATE STATISTICS [RPT_CAMPAIGN_SPENDS10] ON [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS](LSM)
	   CREATE STATISTICS [RPT_CAMPAIGN_SPENDS11] ON [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS](Type)
	   CREATE STATISTICS [RPT_CAMPAIGN_SPENDS12] ON [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS](Value)

	   DROP EXTERNAL TABLE  [EXT].[UL_MEDIA_IN_CAMPAIGN_SPENDS]

END TRY

BEGIN CATCH
              SELECT @ErrorMessage = ISNULL(ERROR_MESSAGE(), 'Error message unavailable.'),
                @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), ' [STG].[UL_MEDIA_IN_CAMPAIGN_SPENDS_LOAD] '),
                @ErrorState = ISNULL(ERROR_STATE(), 0)
         
              SET @return_message = 'Error while Processing ' + @ErrorProcedure + ' stored procedure. Error Message: ' + @ErrorMessage;
              
              THROW 50000, @return_message, @ErrorState;
                    
END CATCH
END

GO
