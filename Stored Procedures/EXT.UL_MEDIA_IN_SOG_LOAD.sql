SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[EXT].[UL_MEDIA_IN_SOG_LOAD]') IS NOT NULL 
DROP PROCEDURE [EXT].[UL_MEDIA_IN_SOG_LOAD]
GO

CREATE PROC [EXT].[UL_MEDIA_IN_SOG_LOAD] AS
/*===========================================================================
 PROCEDURE NAME:  [EXT].[UL_MEDIA_IN_SOG_LOAD]
 DESCRIPTION:     SP to load TDP Cell Data
 PARAMETERS:      NONE
 REVISION HISTORY

 Date         Name                 Comments
 -----------  -------------------  ----------------------------------------
 2023-01-24	  Shakhaf				Initial
===========================================================================*/
BEGIN
SET NOCOUNT ON


DECLARE @return_message   NVARCHAR(MAX)
DECLARE @ErrorMessage     NVARCHAR(4000)
DECLARE @ErrorProcedure   NVARCHAR(126)
DECLARE @ErrorState       INT

BEGIN TRY

       IF EXISTS ( SELECT * FROM sys.external_tables WHERE object_id = OBJECT_ID('[EXT].[UL_MEDIA_IN_SOG]') )
			DROP EXTERNAL TABLE   [EXT].[UL_MEDIA_IN_SOG]

       CREATE EXTERNAL TABLE   [EXT].[UL_MEDIA_IN_SOG]
		(              
			[Primary_Brand_Key] [nvarchar](200) NULL,
			[Campaign] [nvarchar](200) NULL,
			[TG] [nvarchar](200) NULL,
			[Market] [nvarchar](200) NULL,
			[LSM] [nvarchar](200) NULL,
			[SOG_Level] [nvarchar](200) NULL,
			[TV_Penetration] [nvarchar](200) NULL,
            [IRS_HHs] [nvarchar](200) NULL,
            [Source_Of_Growth] [nvarchar](200) NULL,
            [SOG_HHs] [nvarchar](200) NULL
		)
       WITH (DATA_SOURCE =[adlsLocal] ,
       LOCATION = '/ProductDataStores/LiveWire/India/PBRT/Campaign_Reach/UL_Media_IN_SOG.csv',FILE_FORMAT = [ADLS_DELIMITEDTEXT],
	   REJECT_TYPE = Percentage,REJECT_VALUE = 2, REJECT_SAMPLE_VALUE=10)

	    IF EXISTS (SELECT 1 FROM sys.stats st WHERE  [NAME] = 'RPT_SOP1')
		BEGIN
		DROP STATISTICS [STG].[UL_MEDIA_IN_SOG].[RPT_SOP1]
		DROP STATISTICS [STG].[UL_MEDIA_IN_SOG].[RPT_SOP2]
		DROP STATISTICS [STG].[UL_MEDIA_IN_SOG].[RPT_SOP3]
		DROP STATISTICS [STG].[UL_MEDIA_IN_SOG].[RPT_SOP4]
		DROP STATISTICS [STG].[UL_MEDIA_IN_SOG].[RPT_SOP5]
		DROP STATISTICS [STG].[UL_MEDIA_IN_SOG].[RPT_SOP6]
		DROP STATISTICS [STG].[UL_MEDIA_IN_SOG].[RPT_SOP7]
        DROP STATISTICS [STG].[UL_MEDIA_IN_SOG].[RPT_SOP8]
        DROP STATISTICS [STG].[UL_MEDIA_IN_SOG].[RPT_SOP9]
        DROP STATISTICS [STG].[UL_MEDIA_IN_SOG].[RPT_SOP10]
		END

       TRUNCATE TABLE [STG].[UL_MEDIA_IN_SOG]

       INSERT INTO [STG].[UL_MEDIA_IN_SOG]
	   Select *,getdate(),SYSTEM_USER,getdate(),SYSTEM_USER 
	   FROM [EXT].[UL_MEDIA_IN_SOG] WHERE Primary_Brand_Key<>'Primary_Brand_Key'

	   CREATE STATISTICS [RPT_SOP1] ON [STG].[UL_MEDIA_IN_SOG](Primary_Brand_Key)
	   CREATE STATISTICS [RPT_SOP2] ON [STG].[UL_MEDIA_IN_SOG](Campaign)
	   CREATE STATISTICS [RPT_SOP3] ON [STG].[UL_MEDIA_IN_SOG](TG)
	   CREATE STATISTICS [RPT_SOP4] ON [STG].[UL_MEDIA_IN_SOG](Market)
	   CREATE STATISTICS [RPT_SOP5] ON [STG].[UL_MEDIA_IN_SOG](LSM)
	   CREATE STATISTICS [RPT_SOP6] ON [STG].[UL_MEDIA_IN_SOG](SOG_Level)
	   CREATE STATISTICS [RPT_SOP7] ON [STG].[UL_MEDIA_IN_SOG](TV_Penetration)
	   CREATE STATISTICS [RPT_SOP8] ON [STG].[UL_MEDIA_IN_SOG](IRS_HHs)
	   CREATE STATISTICS [RPT_SOP9] ON [STG].[UL_MEDIA_IN_SOG](Source_Of_Growth)
	   CREATE STATISTICS [RPT_SOP10] ON [STG].[UL_MEDIA_IN_SOG](SOG_HHs)

	   DROP EXTERNAL TABLE  [EXT].[UL_MEDIA_IN_SOG]

END TRY

BEGIN CATCH
              SELECT @ErrorMessage = ISNULL(ERROR_MESSAGE(), 'Error message unavailable.'),
                @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), ' [EXT].[UL_MEDIA_IN_SOG_LOAD] '),
                @ErrorState = ISNULL(ERROR_STATE(), 0)
         
              SET @return_message = 'Error while Processing ' + @ErrorProcedure + ' stored procedure. Error Message: ' + @ErrorMessage;
              
              THROW 50000, @return_message, @ErrorState;
                    
END CATCH
END

GO
