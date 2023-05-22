/****** Object:  StoredProcedure [STG].[UL_MEDIA_IN_PBRT_REACH]    Script Date: 4/29/2022 5:35:34 AM ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[STG].[UL_MEDIA_IN_PBRT_SPENDS_LOAD]') IS NOT NULL
DROP PROCEDURE [STG].[UL_MEDIA_IN_PBRT_SPENDS_LOAD]
GO

CREATE PROC [STG].[UL_MEDIA_IN_PBRT_SPENDS_LOAD] AS

/*===========================================================================
PROCEDURE NAME:  [STG].[UL_MEDIA_IN_PBRT_SPENDS_LOAD]
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
TRUNCATE TABLE [DW].[UL_MEDIA_IN_PBRT_SPENDS]

INSERT INTO [DW].[UL_MEDIA_IN_PBRT_SPENDS]
(
[Medium],
[Category],
[Segment],
[Primary_Brand_Key],
[Month],
[Year],
[Market],
[Campaign],
[IB_TYPE],
[LSM],
[Amount_Spent_INR],
[Provisional_Column1],
[Provisional_Column2],
[Provisional_Column3],
[Provisional_Column4],
[Provisional_Column5]
)
SELECT 
[Medium],
[Category],
[Segment],
[Primary_Brand_Key],
[Month],
cast([Year] as int) as [Year],
[Market],
[Campaign],
[IB_TYPE],
[LSM],
-- TRY_CONVERT(DECIMAL(15,2), 
Cast(Amount_Spent_INR AS DECIMAL(15,7)),
-- CONVERT([Amount_Spent_INR] as DECIMAL(15,2)),
[Provisional_Column1],
[Provisional_Column2],
[Provisional_Column3],
[Provisional_Column4],
[Provisional_Column5]
FROM  [STG].[UL_MEDIA_IN_PBRT_SPENDS]


END TRY

BEGIN CATCH
      
SELECT @ERRORMESSAGE = ISNULL(ERROR_MESSAGE(), 'ERROR MESSAGE UNAVAILABLE.'),
	@ERRORPROCEDURE = ISNULL(ERROR_PROCEDURE(), '[STG].[UL_MEDIA_IN_PBRT_SPENDS_LOAD]'),
	@ERRORSTATE = ISNULL(ERROR_STATE(), 0)
	  
SET @RETURN_MESSAGE = 'ERROR WHILE PROCESSING ' + @ERRORPROCEDURE + ' STORED PROCEDURE. ERROR MESSAGE: ' + @ERRORMESSAGE;
		
THROW 50000, @RETURN_MESSAGE, @ERRORSTATE;

END CATCH 

END



GO


