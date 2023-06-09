SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER_LOAD]') IS NOT NULL
DROP PROCEDURE [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER_LOAD]
GO

CREATE PROC [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER_LOAD] AS

/*===========================================================================
PROCEDURE NAME:  [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER_LOAD]
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
TRUNCATE TABLE [DW].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER]

INSERT INTO [DW].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER]
(
[TG], 
[LSM], 
[Market], 
[IRS_TV_Pen], 
[IRS_HHs]
)
SELECT 
[TG], 
[LSM], 
[Market], 
cast(replace([IRS_TV_Pen],'%','') as float),
cast ([IRS_HHs] as float)
-- CONVERT(DECIMAL(20,9),[IRS_HHs])
FROM  [STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER]



END TRY

BEGIN CATCH
      
SELECT @ERRORMESSAGE = ISNULL(ERROR_MESSAGE(), 'ERROR MESSAGE UNAVAILABLE.'),
	@ERRORPROCEDURE = ISNULL(ERROR_PROCEDURE(), '[STG].[UL_MEDIA_IN_PBRT_IRS_HHS_MASTER_LOAD]'),
	@ERRORSTATE = ISNULL(ERROR_STATE(), 0)
	  
SET @RETURN_MESSAGE = 'ERROR WHILE PROCESSING ' + @ERRORPROCEDURE + ' STORED PROCEDURE. ERROR MESSAGE: ' + @ERRORMESSAGE;
		
THROW 50000, @RETURN_MESSAGE, @ERRORSTATE;

END CATCH 

END



GO


