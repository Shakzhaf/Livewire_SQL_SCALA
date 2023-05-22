/****** Object:  StoredProcedure [STG].[UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER_LOAD]    Script Date: 4/29/2022 5:35:34 AM ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[STG].[UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER_LOAD]') IS NOT NULL
DROP PROCEDURE [STG].[UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER_LOAD]
GO

CREATE PROC [STG].[UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER_LOAD] AS

/*===========================================================================
PROCEDURE NAME:  [STG].[UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER_LOAD]
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
TRUNCATE TABLE [DW].[UL_MEDIA_IN_PBRT_BRAND_HIERARCHY]

INSERT INTO [DW].[UL_MEDIA_IN_PBRT_BRAND_HIERARCHY]
(
[Big_C],
[Small_C],
[Sub_Category],
[Segment],
[Sub_Segment],
[SOV],
[SOV_SOM],
[Primary_Brand],
[Brand],
[PBRT_KEY],
[Global_Campaign_Name],
[Core_MD_Supporters],
[Purpose_Promo_Thematic],
[Innovation_Renovation],
[Business_Group]
)
SELECT 
[Big_C],
[Small_C],
[Sub_Category],
[Segment],
[Sub_Segment],
[SOV],
[SOV_SOM],
[Primary_Brand],
[Brand],
[PBRT_KEY],
[Global_Campaign_Name],
[Core_MD_Supporters],
[Purpose_Promo_Thematic],
[Innovation_Renovation],
[Business_Group]
FROM  [STG].[UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER]

END TRY

BEGIN CATCH
      
SELECT @ERRORMESSAGE = ISNULL(ERROR_MESSAGE(), 'ERROR MESSAGE UNAVAILABLE.'),
	@ERRORPROCEDURE = ISNULL(ERROR_PROCEDURE(), '[STG].[UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER_LOAD]'),
	@ERRORSTATE = ISNULL(ERROR_STATE(), 0)
	  
SET @RETURN_MESSAGE = 'ERROR WHILE PROCESSING ' + @ERRORPROCEDURE + ' STORED PROCEDURE. ERROR MESSAGE: ' + @ERRORMESSAGE;
		
THROW 50000, @RETURN_MESSAGE, @ERRORSTATE;

END CATCH 

END



GO


