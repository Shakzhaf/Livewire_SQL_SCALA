SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[EXT].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER_LOAD]') IS NOT NULL 
DROP PROCEDURE [EXT].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER_LOAD]
GO

CREATE PROC [EXT].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER_LOAD] AS
/*===========================================================================
 PROCEDURE NAME:  [EXT].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER_LOAD]
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

       IF EXISTS ( SELECT * FROM sys.external_tables WHERE object_id = OBJECT_ID('[EXT].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER]') )
			DROP EXTERNAL TABLE   [EXT].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER]
			
       CREATE EXTERNAL TABLE   [EXT].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER]
		(              
			[TG] [nvarchar](200) NULL,
			[LSM] [nvarchar](200) NULL,
			[Market] [nvarchar](200) NULL,
			[IRS_TV_Pen] [nvarchar](200) NULL,
			[IRS_HHs] [nvarchar](200) NULL
		)

        

       WITH (DATA_SOURCE =[adlsLocal] ,
       LOCATION = '/ProductDataStores/LiveWire/India/PBRT/UL_Media_IN_PBRT_IRS_HHS.csv',FILE_FORMAT = [ADLS_DELIMITEDTEXT],
	   REJECT_TYPE = Percentage,REJECT_VALUE = 2, REJECT_SAMPLE_VALUE=10)

	    IF EXISTS (SELECT 1 FROM sys.stats st WHERE  [NAME] = 'RPT_IRS_HHS1')
		BEGIN
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER].[RPT_IRS_HHS1]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER].[RPT_IRS_HHS2]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER].[RPT_IRS_HHS3]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER].[RPT_IRS_HHS4]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER].[RPT_IRS_HHS5]
		END

       TRUNCATE TABLE [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER]

       INSERT INTO [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER]
	   Select *,getdate(),SYSTEM_USER,getdate(),SYSTEM_USER 
	   FROM [EXT].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER] WHERE TG<>'TG'

	    CREATE STATISTICS [RPT_IRS_HHS1] ON [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER](TG)
	   CREATE STATISTICS [RPT_IRS_HHS2] ON [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER](LSM)
	   CREATE STATISTICS [RPT_IRS_HHS3] ON [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER](Market)
	   CREATE STATISTICS [RPT_IRS_HHS4] ON [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER](IRS_TV_Pen)
	   CREATE STATISTICS [RPT_IRS_HHS5] ON [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER](IRS_HHs)

	   DROP EXTERNAL TABLE  [EXT].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER]

END TRY

BEGIN CATCH
              SELECT @ErrorMessage = ISNULL(ERROR_MESSAGE(), 'Error message unavailable.'),
                @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), ' [EXT].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER_LOAD] '),
                @ErrorState = ISNULL(ERROR_STATE(), 0)
         
              SET @return_message = 'Error while Processing ' + @ErrorProcedure + ' stored procedure. Error Message: ' + @ErrorMessage;
              
              THROW 50000, @return_message, @ErrorState;
                    
END CATCH
END



GO