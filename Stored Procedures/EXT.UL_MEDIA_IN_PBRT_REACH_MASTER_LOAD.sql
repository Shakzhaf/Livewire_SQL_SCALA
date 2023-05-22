SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[EXT].[UL_MEDIA_IN_PBRT_REACH_MASTER_LOAD]') IS NOT NULL 
DROP PROCEDURE [EXT].[UL_MEDIA_IN_PBRT_REACH_MASTER_LOAD]
GO

CREATE PROC [EXT].[UL_MEDIA_IN_PBRT_REACH_MASTER_LOAD] AS
/*===========================================================================
 PROCEDURE NAME:  [EXT].[UL_MEDIA_IN_PBRT_REACH_MASTER_LOAD]
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

       IF EXISTS ( SELECT * FROM sys.external_tables WHERE object_id = OBJECT_ID('[EXT].[UL_MEDIA_IN_PBRT_REACH]') )
			DROP EXTERNAL TABLE   [EXT].[UL_MEDIA_IN_PBRT_REACH]
			
       CREATE EXTERNAL TABLE   [EXT].[UL_MEDIA_IN_PBRT_REACH]
		(              
			[Medium] [nvarchar](255) NULL,
			[Category] [nvarchar](255) NULL,
			[Segment] [nvarchar](255) NULL,
			[Primary_Brand_Key] [nvarchar](255) NULL,
			[Month] [nvarchar](255) NULL,
			[Year] [nvarchar](255) NULL,
			[Market] [nvarchar](255) NULL,
			[Campaign] [nvarchar](255) NULL,
			[TG] [nvarchar](255) NULL,
			[LSM] [nvarchar](255) NULL,
			[Reach_Freq] [nvarchar](255) NULL,
			[Reach] [nvarchar](255) NULL,
			[Provisional_Column1] [nvarchar](255) NULL,
			[Provisional_Column2] [nvarchar](255) NULL,
			[Provisional_Column3] [nvarchar](255) NULL,
			[Provisional_Column4] [nvarchar](255) NULL,
			[Provisional_Column5] [nvarchar](255) NULL

		)


        

       WITH (DATA_SOURCE =[adlsLocal] ,
       LOCATION = '/ProductDataStores/LiveWire/India/PBRT/UL_Media_IN_PBRT_Reach.csv',FILE_FORMAT = [ADLS_DELIMITEDTEXT],
	   REJECT_TYPE = Percentage,REJECT_VALUE = 2, REJECT_SAMPLE_VALUE=10)

	    IF EXISTS (SELECT 1 FROM sys.stats st WHERE  [NAME] = 'RPT_PBRT_REACH1')
		BEGIN
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH1]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH2]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH3]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH4]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH5]
        DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH6]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH7]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH8]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH9]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH10]
        DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH11]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH12]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH13]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH14]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH15]
		DROP STATISTICS [STG].[UL_MEDIA_IN_PBRT_REACH].[RPT_PBRT_REACH16]
		END

       TRUNCATE TABLE [STG].[UL_MEDIA_IN_PBRT_REACH]

       INSERT INTO [STG].[UL_MEDIA_IN_PBRT_REACH]
	   Select *,getdate(),SYSTEM_USER,getdate(),SYSTEM_USER 
	   FROM [EXT].[UL_MEDIA_IN_PBRT_REACH] WHERE Medium<>'Medium'

	   CREATE STATISTICS [RPT_PBRT_REACH1] ON [STG].[UL_MEDIA_IN_PBRT_REACH](Medium)
	   CREATE STATISTICS [RPT_PBRT_REACH2] ON [STG].[UL_MEDIA_IN_PBRT_REACH](Category)
	   CREATE STATISTICS [RPT_PBRT_REACH3] ON [STG].[UL_MEDIA_IN_PBRT_REACH](Segment)
	   CREATE STATISTICS [RPT_PBRT_REACH4] ON [STG].[UL_MEDIA_IN_PBRT_REACH](Primary_Brand_Key)
	   CREATE STATISTICS [RPT_PBRT_REACH5] ON [STG].[UL_MEDIA_IN_PBRT_REACH](Month)
       CREATE STATISTICS [RPT_PBRT_REACH6] ON [STG].[UL_MEDIA_IN_PBRT_REACH](Year)
	   CREATE STATISTICS [RPT_PBRT_REACH7] ON [STG].[UL_MEDIA_IN_PBRT_REACH](Market)
	   CREATE STATISTICS [RPT_PBRT_REACH8] ON [STG].[UL_MEDIA_IN_PBRT_REACH](Campaign)
	   CREATE STATISTICS [RPT_PBRT_REACH9] ON [STG].[UL_MEDIA_IN_PBRT_REACH](TG)
	   CREATE STATISTICS [RPT_PBRT_REACH10] ON [STG].[UL_MEDIA_IN_PBRT_REACH](Reach_Freq)
       CREATE STATISTICS [RPT_PBRT_REACH11] ON [STG].[UL_MEDIA_IN_PBRT_REACH](Reach)
	   CREATE STATISTICS [RPT_PBRT_REACH12] ON [STG].[UL_MEDIA_IN_PBRT_REACH](Provisional_Column1)
	   CREATE STATISTICS [RPT_PBRT_REACH13] ON [STG].[UL_MEDIA_IN_PBRT_REACH](Provisional_Column2)
	   CREATE STATISTICS [RPT_PBRT_REACH14] ON [STG].[UL_MEDIA_IN_PBRT_REACH](Provisional_Column3)
	   CREATE STATISTICS [RPT_PBRT_REACH15] ON [STG].[UL_MEDIA_IN_PBRT_REACH](Provisional_Column4)
	   CREATE STATISTICS [RPT_PBRT_REACH16] ON [STG].[UL_MEDIA_IN_PBRT_REACH](Provisional_Column5)

	   DROP EXTERNAL TABLE  [EXT].[UL_MEDIA_IN_PBRT_REACH]

END TRY

BEGIN CATCH
              SELECT @ErrorMessage = ISNULL(ERROR_MESSAGE(), 'Error message unavailable.'),
                @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), ' [EXT].[UL_MEDIA_IN_PBRT_REACH_MASTER_LOAD] '),
                @ErrorState = ISNULL(ERROR_STATE(), 0)
         
              SET @return_message = 'Error while Processing ' + @ErrorProcedure + ' stored procedure. Error Message: ' + @ErrorMessage;
              
              THROW 50000, @return_message, @ErrorState;
                    
END CATCH
END



GO