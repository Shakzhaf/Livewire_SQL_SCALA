/****** Object:  StoredProcedure [STG].[UL_MEDIA_IN_SOG_LOAD]    Script Date: 4/29/2022 5:35:34 AM ******/

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[STG].[UL_MEDIA_IN_SOG_LOAD]') IS NOT NULL
DROP PROCEDURE [STG].[UL_MEDIA_IN_SOG_LOAD]
GO

CREATE PROC [STG].[UL_MEDIA_IN_SOG_LOAD] AS

/*===========================================================================
PROCEDURE NAME:  [STG].[UL_MEDIA_IN_SOG_LOAD]
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
TRUNCATE TABLE [DW].[UL_MEDIA_IN_SOG]

INSERT INTO [DW].[UL_MEDIA_IN_SOG]
(
[Primary_Brand_Key],
[Campaign],
[TG],
[Market],
[LSM],
[SOG_Level],
[TV_Penetration],
[IRS_HHs],
[Source_Of_Growth],
[SOG_HHs]
)
SELECT 
[Primary_Brand_Key],
[Campaign],
[TG],
[Market],
[LSM],
[SOG_Level],
TRY_CAST(replace(TV_Penetration,'%','') as FLOAT)/100 as [TV_Penetration], 
TRY_CAST(replace(IRS_HHs,'%','') as FLOAT) as [IRS_HHs], 
TRY_CAST(replace(Source_Of_Growth,'%','') as FLOAT) as [Source_Of_Growth], 
TRY_CAST(replace(SOG_HHs,'%','')  as FLOAT) as [SOG_HHs] 
FROM  [STG].[UL_MEDIA_IN_SOG]

IF OBJECT_ID('DW.BKP_UL_MEDIA_IN_SOG') IS NOT NULL 
DROP TABLE DW.BKP_UL_MEDIA_IN_SOG

select * into DW.BKP_UL_MEDIA_IN_SOG
from DW.UL_MEDIA_IN_SOG

END TRY

BEGIN CATCH
      
SELECT @ERRORMESSAGE = ISNULL(ERROR_MESSAGE(), 'ERROR MESSAGE UNAVAILABLE.'),
	@ERRORPROCEDURE = ISNULL(ERROR_PROCEDURE(), '[STG].[UL_MEDIA_IN_SOG_LOAD]'),
	@ERRORSTATE = ISNULL(ERROR_STATE(), 0)
	  
SET @RETURN_MESSAGE = 'ERROR WHILE PROCESSING ' + @ERRORPROCEDURE + ' STORED PROCEDURE. ERROR MESSAGE: ' + @ERRORMESSAGE;
		
THROW 50000, @RETURN_MESSAGE, @ERRORSTATE;

END CATCH 

END



GO