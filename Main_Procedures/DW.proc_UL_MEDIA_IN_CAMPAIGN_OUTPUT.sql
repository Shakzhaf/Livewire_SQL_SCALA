USE [DB_PBRT]
GO
/****** Object:  StoredProcedure [DW_stg].[proc_UL_MEDIA_IN_SOG]    Script Date: 11/05/2022 17:01:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [DW].[proc_UL_MEDIA_IN_CAMPAIGN_OUTPUT]
as 

IF OBJECT_ID('tempDB..#campaign_v1') IS NOT NULL
BEGIN
DROP TABLE #campaign_v1
END

select distinct b.Big_C, b.Small_C,b.Sub_Category,b.Segment as Segment, b.Sub_Segment as Sub_Segment,
b.Primary_Brand as Primary_Brand,
b.Brand as Brand_Name,
 A.Primary_Brand_Key,
B.Global_Campaign_Name,
CASE WHEN A.Type = 'Post_Reach' THEN 'Post'
WHEN A.Type = 'Pre_Reach' THEN 'Pre' END as Type,
A.Month, A.Year, 

A.TG as Brand_TG,

CASE WHEN A.TG like '%U'THEN 'Urban'
WHEN A.TG like '% R' then 'Rural'
WHEN A.TG like '%U+R' then 'Urban + Rural' END AS Market_Type,

A.Market,

SUBSTRING(TG,CHARINDEX('LSM',TG)-1,LEN(TG)) as Base_Definition

into #campaign_v1 
from DW.BKP_UL_MEDIA_IN_CAMPAIGN_REACH (NOLOCK) a 
left join
DW.UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER b (NOLOCK)
on --a.Category = b.Small_C and 
a.Primary_Brand_Key = b.PBRT_KEY

UNION


select distinct b.Big_C, b.Small_C,b.Sub_Category,b.Segment as Segment, b.Sub_Segment as Sub_Segment,
b.Primary_Brand as Primary_Brand,
b.Brand as Brand_Name,
 A.Primary_Brand_Key,
B.Global_Campaign_Name,
CASE WHEN A.Type = 'Post_Reach' THEN 'Post'
WHEN A.Type = 'Pre_Reach' THEN 'Pre' END as Type,
A.Month, A.Year, 

A.TG as Brand_TG,

CASE WHEN A.TG like '%U'THEN 'Urban'
WHEN A.TG like '% R' then 'Rural'
WHEN A.TG like '%U+R' then 'Urban + Rural' END AS Market_Type,

'India' as Market,

SUBSTRING(TG,CHARINDEX('LSM',TG)-1,LEN(TG)) as Base_Definition

from DW.BKP_UL_MEDIA_IN_CAMPAIGN_REACH (NOLOCK) a 
left join
DW.UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER b (NOLOCK)
on --a.Category = b.Small_C and 
a.Primary_Brand_Key = b.PBRT_KEY

--group by A.Primary_Brand_Key, A.Year, A.Month, A.Category, Medium ,A.Market,b.Sub_Category, b.Segment ,
 --b.Sub_Segment, b.Big_C, b.Small_C,b.Primary_Brand, LSM

 --select * from DW.UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER
 --where PBRT_KEY like '%Surf Excel%'

 --select * from #campaign_v1 where Primary_Brand_Key like '%Boost%'

 /*
 select * from #campaign_v1 
 where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
 order by Market, Type
 */

 IF OBJECT_ID('tempDB..#campaign_v2') IS NOT NULL
BEGIN
DROP TABLE #campaign_v2
END

 select a.*, 
 c.IRS_HHs,
 c.SOG_Level,
 c.Source_Of_Growth,
 c.SOG_HHs
 into #campaign_v2
  from #campaign_v1 a
 left join
DW.BKP_UL_MEDIA_IN_SOG c (NOLOCK)
on 
a.Primary_Brand_Key = c.Primary_Brand_Key
and a.Market=c.Market
and a.Brand_TG=c.TG
and a.Global_Campaign_Name=c.Campaign

/*
 select * from #campaign_v2 
 where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
 order by Market, Type
 */

   IF OBJECT_ID('tempDB..#campaign_ind_hhs_calc') IS NOT NULL
BEGIN
DROP TABLE #campaign_ind_hhs_calc
END

  select 
  Primary_Brand_Key,Month,Year,Type,'India' as Market,
  Big_C,Small_C,Sub_Category,Segment,Sub_Segment,Primary_Brand,Brand_Name,
  Global_Campaign_Name,Brand_TG,Market_Type,Base_Definition,
  sum(IRS_HHs) as IRS_HHs,sum(SOG_HHs) as SOG_HHs
  --SOG_Level, Source_Of_Growth
  into #campaign_ind_hhs_calc
   from #campaign_v2 a
 where  Market IN('AP / Telangana', 'Assam / North East / Sikkim', 'Bihar/Jharkhand', 'Delhi', 'Digital Market Cluster', 'Guj / D&D / DNH', 
'Karnataka', 'Kerala', 'Mah / Goa', 'MP/Chhattisgarh', 'Odisha', 'Pun / Har / Cha / HP / J&K',
'Rajasthan', 'TN/Pondicherry', 'UP/Uttarakhand', 'West Bengal')

   group by Primary_Brand_Key,Month,Year,Type, Big_C,Small_C,Sub_Category,Segment,Sub_Segment,Primary_Brand,Brand_Name,
  Global_Campaign_Name,Brand_TG,Market_Type,Base_Definition--,SOG_Level, Source_Of_Growth
    order by Market, Type

/*
 select * from #campaign_v2 
 where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
   and Type='Pre'
 order by Market, Type
 
 */

update #campaign_v2
set IRS_HHs=b.IRS_HHs, SOG_HHs=b.SOG_HHs
from #campaign_v2 a
inner join #campaign_ind_hhs_calc b
on a.Primary_Brand_Key = b.Primary_Brand_Key
and a.Market=b.Market
and a.Month=b.Month and a.Year=b.Year
and a.Brand_TG=b.Brand_TG
and a.Global_Campaign_Name=b.Global_Campaign_Name
and a.Market='India'

/*
 select * from #campaign_v2 
 where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
 order by Market, Type
 */


   IF OBJECT_ID('tempDB..#campaign_v3') IS NOT NULL
BEGIN
DROP TABLE #campaign_v3
END
    
select Category,Segment,Primary_Brand_Key,Month, Year, Market, Campaign, IB_TYPE, LSM, Type,
ROUND(sum(case when (Medium in ('TV')   )  then Value when IB_TYPE ='CWBS' then 0 else 0 end)/100000,3) as TV_Spends,
ROUND(sum(case when (Medium in ('Print')  ) then Value when IB_TYPE ='CWBS' then 0 else 0 end)/100000,3) as Print_Spends,
ROUND(sum(case when (Medium in ('Radio')   ) then Value when IB_TYPE ='CWBS' then 0 else 0 end)/100000,3) as Radio_Spends,
ROUND(sum(case when (Medium in ('Cinema')   ) then Value  when IB_TYPE ='CWBS' then 0 else 0 end)/100000,3) as Cinema_Spends,
ROUND(sum(case when (Medium in ('OOH')   ) then Value when IB_TYPE ='CWBS' then 0  else 0 end)/100000,3) as OOH_Spends,
ROUND(sum(case when (Medium in ('YT')   ) then Value when IB_TYPE ='CWBS' then 0  else 0 end)/100000,3) as YouTube_Spends,
ROUND(sum(case when (Medium in ('OTT')  ) then Value  when IB_TYPE ='CWBS' then 0 else 0 end)/100000,3) as OTT_Spends,
ROUND(sum(case when (Medium in ('FB')   ) then Value when IB_TYPE ='CWBS' then 0  else 0 end)/100000,3) as FB_Spends,
ROUND(sum(case when (Medium in ('Mobile')  ) then Value  when IB_TYPE ='CWBS' then 0 else 0 end)/100000,3) as Mobile_Spends

into #campaign_v3
from [DW].[BKP_UL_MEDIA_IN_CAMPAIGN_SPENDS] (NOLOCK)
--where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   --and Month='Dec' and Year='2021'
group by Category,Segment,Primary_Brand_Key,Month, Year, Market, Campaign, IB_TYPE, LSM, Type
order by Primary_Brand_Key, Market;


IF OBJECT_ID('tempDB..#campaign_spend_total') IS NOT NULL
BEGIN
DROP TABLE #campaign_spend_total
END

select a.*,
(sum(TV_spends)+sum(Print_Spends)+sum(Radio_Spends)+sum(Cinema_Spends)+sum(Mobile_Spends)
		 +sum(Youtube_Spends)+sum(OTT_Spends)+sum(FB_Spends)+sum(OOH_Spends)) as Total_Spends,

		 (sum(Youtube_Spends)+sum(OTT_Spends)+sum(FB_Spends)) as Digital_Spends,

		(sum(Print_Spends)+sum(Radio_Spends)+sum(Cinema_Spends)+sum(Mobile_Spends)+sum(OOH_Spends))
		 as NTV_Spends
		 into #campaign_spend_total
		 from #campaign_v3 a
		
		 group by Category,Segment,Primary_Brand_Key,Month, Year, Market, Campaign, IB_TYPE, LSM, Type,
		 TV_Spends, Print_Spends, Radio_Spends, Cinema_Spends, OOH_Spends, YouTube_Spends, OTT_Spends,
		 FB_Spends, Mobile_Spends



/*
select * from #campaign_v3 
where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
 order by Market

 select * from #campaign_spend_total
where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
 order by Market

*/

IF OBJECT_ID('tempDB..#campaign_v4') IS NOT NULL
BEGIN
DROP TABLE #campaign_v4
END

select *,
CASE WHEN Type = 'Post_Spends' THEN 'Post'
WHEN Type = 'Pre_Spends' THEN 'Pre' END as Type_Spends_Short 
into #campaign_v4
from #campaign_spend_total


IF OBJECT_ID('tempDB..#campaign_v5') IS NOT NULL
BEGIN
DROP TABLE #campaign_v5
END

select distinct a.*,
b.TV_Spends,b.Print_Spends, b.Radio_Spends, b.Cinema_Spends, b.OOH_Spends, b.YouTube_Spends, b.OTT_Spends,
b.FB_Spends, b.Mobile_Spends, b.Total_Spends, b.Digital_Spends, b.NTV_Spends
into #campaign_v5
from #campaign_v2 a
left join #campaign_v4 b
on a.Primary_Brand_Key=b.Primary_Brand_Key
and a.Type=b.Type_Spends_Short
and a.Market=b.Market
and a.Month=b.Month and a.Year=b.Year
--where a.Primary_Brand_Key like  '%Surf Excel|Centaurus'
   --and a.Month='Dec' and a.Year='2021'
   --and b.Market='India'
  
   order by Market, Type

/*
select * from #campaign_v5 
where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
 order by Market

*/
IF OBJECT_ID('tempDB..#campaign_v6') IS NOT NULL
BEGIN
DROP TABLE #campaign_v6
END

select a.*, b.TV_Penetration
into #campaign_v6
 from 
#campaign_v5 a
left join
DW.BKP_UL_MEDIA_IN_SOG b (NOLOCK)
on 
a.Primary_Brand_Key = b.Primary_Brand_Key
and a.Market=b.Market
and a.Brand_TG=b.TG
and a.Global_Campaign_Name=b.Campaign
 order by a.Market

 -- Reach part begins

 /*
select * from #campaign_v6 
where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
 order by Market

*/

  IF OBJECT_ID('tempDB..#campaign_v7') IS NOT NULL
BEGIN
DROP TABLE #campaign_v7
END
    
select Category,Segment,Primary_Brand_Key,Month, Year, Market, Campaign, TG, LSM, Type,
sum(case when (Medium in ('TV')   )  then Value  else 0 end) as TV_Reach,
sum(case when (Medium in ('Print')  ) then Value  else 0 end) as Print_Reach,
sum(case when (Medium in ('Radio')   ) then Value  else 0 end) as Radio_Reach,
sum(case when (Medium in ('Cinema')   ) then Value   else 0 end) as Cinema_Reach,
sum(case when (Medium in ('OOH')   ) then Value   else 0 end) as OOH_Reach,
sum(case when (Medium in ('YT')   ) then Value   else 0 end) as YouTube_Reach,
sum(case when (Medium in ('OTT')  ) then Value   else 0 end) as OTT_Reach,
sum(case when (Medium in ('FB')   ) then Value   else 0 end) as FB_Reach,
sum(case when (Medium in ('Mobile')  ) then Value  else 0 end) as Mobile_Reach

into #campaign_v7
from DW.BKP_UL_MEDIA_IN_CAMPAIGN_REACH (NOLOCK)
group by Category,Segment,Primary_Brand_Key,Month, Year, Market, Campaign, TG, LSM, Type
order by Primary_Brand_Key, Market

 /*
select * from #campaign_v7 
where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
 order by Market

*/

IF OBJECT_ID('tempDB..#campaign_v8') IS NOT NULL
BEGIN
DROP TABLE #campaign_v8
END

select *, 
CASE WHEN Type = 'Post_Reach' THEN 'Post'
WHEN Type = 'Pre_Reach' THEN 'Pre' END as Type_Reach_Short 
into #campaign_v8
from #campaign_v7

/*
select * from #campaign_v8 
where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
 order by Market

*/


IF OBJECT_ID('tempDB..#campaign_v9') IS NOT NULL
BEGIN
DROP TABLE #campaign_v9
END

select distinct a.*,
b.TV_Reach,b.Print_Reach, b.Radio_Reach, b.Cinema_Reach, b.OOH_Reach, b.YouTube_Reach, b.OTT_Reach,
b.FB_Reach, b.Mobile_Reach
into #campaign_v9
from #campaign_v6 a
left join #campaign_v8 b
on a.Primary_Brand_Key=b.Primary_Brand_Key
and a.Type=b.Type_Reach_Short
and a.Market=b.Market
and a.Month=b.Month and a.Year=b.Year
--and a.Brand_TG=b.TG
--where a.Primary_Brand_Key like  '%Surf Excel|Centaurus'
   --and a.Month='Dec' and a.Year='2021'
   --and b.Market='India'
  
   order by a.Market, a.Type


   
/*
select * from #campaign_v9 
where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
 order by Market, Type

*/

-- Calc of IRS TV Reach & All Media Reach


IF OBJECT_ID('tempDB..#campaign_v10') IS NOT NULL
BEGIN
DROP TABLE #campaign_v10
END

select *,
 ((TV_Reach * CAST(REPLACE(TV_Penetration,'%','') as FLOAT))/100) as IRS_TV_Reach,
 ((1-(1-(((TV_Reach * CAST(REPLACE(TV_Penetration,'%','') as FLOAT))/100))/100)*(1-(Print_Reach/100))*(1-(Radio_Reach/100))*
(1-(Cinema_Reach/100))*(1-(Mobile_Reach/100))*(1-(Youtube_Reach/100))*(1-(OTT_Reach/100))*(1-(FB_Reach/100))
*(1-(OOH_Reach/100)))) as All_Media_Reach_IRS
into #campaign_v10 
from #campaign_v9 


/*
select * from #campaign_v10 
where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
 order by Market, Type

*/

--Reach Media In Mn Calc


IF OBJECT_ID('tempDB..#campaign_v11') IS NOT NULL
BEGIN
DROP TABLE #campaign_v11
END


select *,
IRS_HHs*All_Media_Reach_IRS as IRS_HHs_All_Media_Reach_In_Mn,
SOG_HHs*All_Media_Reach_IRS as SOG_HHs_All_Media_Reach_In_Mn
into #campaign_v11
 from
#campaign_v10 

/*
select * from #campaign_v11 
where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
   --and Type='Post'
 order by Market, Type

*/

-- For addition of new column SOG Media Reach perc

IF OBJECT_ID('tempDB..#sog_media_perc') IS NOT NULL
BEGIN
DROP TABLE #sog_media_perc
END


select *,
SOG_HHs_All_Media_Reach_In_Mn/NULLIF(SOG_HHs,0) as All_Media_Reach_SOG

--SOG_HHs*All_Media_Reach as SOG_HHs_All_Media_Reach_In_Mn
into #sog_media_perc
 from
#campaign_v11

/*
select * from #sog_media_perc 
where Primary_Brand_Key like  '%Beauty & Personal Care|Hair Care|Hair Care (excl Hair Oil)|Wash & Care|Shampoo|Clinic Plus|Clinic Plus Shampoo|Isotope'
   and Month='Dec' and Year='2021'
 order by Market, Type

*/

-- India Calc

   IF OBJECT_ID('tempDB..#campaign_ind_hhs_media_reach_calc') IS NOT NULL
BEGIN
DROP TABLE #campaign_ind_hhs_media_reach_calc
END

  select 
   Primary_Brand_Key, 
   Month, Year, Brand_TG, 'India' as Market, 
    Type,  Global_Campaign_Name,	
   
  sum(IRS_HHs_All_Media_Reach_In_Mn) as IRS_HHs_All_Media_Reach_In_Mn,
  sum(SOG_HHs_All_Media_Reach_In_Mn) as SOG_HHs_All_Media_Reach_In_Mn
 into #campaign_ind_hhs_media_reach_calc
   from #sog_media_perc
 where  Market NOT IN('Bangalore','Chennai','Hyderabad','Kolkata','Mumbai','India')

   group by   
    Primary_Brand_Key, 
   Month, Year, Brand_TG, Type,  Global_Campaign_Name
    order by Market, Type
	

update #sog_media_perc
set IRS_HHs_All_Media_Reach_In_Mn=b.IRS_HHs_All_Media_Reach_In_Mn,
	SOG_HHs_All_Media_Reach_In_Mn=b.SOG_HHs_All_Media_Reach_In_Mn
from #sog_media_perc a
inner join #campaign_ind_hhs_media_reach_calc b
on a.Primary_Brand_Key = b.Primary_Brand_Key
and a.Market=b.Market
and a.Month=b.Month and a.Year=b.year
and a.Brand_TG=b.Brand_TG
and a.Global_Campaign_Name=b.Global_Campaign_Name
and a.Type=b.Type
and a.Market='India'

/*
select * from #sog_media_perc 
where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
 order by Market, Type

*/

--India AllMediaReach calc

   IF OBJECT_ID('tempDB..#campaign_ind_all_media_reach_calc') IS NOT NULL
BEGIN
DROP TABLE #campaign_ind_all_media_reach_calc
END

select  
   Primary_Brand_Key, 
   Month, Year, Brand_TG, 'India' as Market, 
    Type,  Global_Campaign_Name,IRS_HHs_All_Media_Reach_In_Mn,IRS_HHs,
		All_Media_Reach_IRS=IRS_HHs_All_Media_Reach_In_Mn/NULLIF((IRS_HHs),0)

		into #campaign_ind_all_media_reach_calc
from #sog_media_perc
  where  Market='India'

    group by   
    Primary_Brand_Key, 
   Month, Year, Brand_TG, Type,  Global_Campaign_Name,IRS_HHs_All_Media_Reach_In_Mn,IRS_HHs
    order by Market, Type

	/*
select * from #campaign_ind_all_media_reach_calc
where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
 order by Market, Type

*/


update #sog_media_perc
set All_Media_Reach_IRS=b.All_Media_Reach_IRS

from #sog_media_perc a
inner join #campaign_ind_all_media_reach_calc b
on a.Primary_Brand_Key = b.Primary_Brand_Key
and a.Market=b.Market
and a.Month=b.Month and a.Year=b.year
and a.Brand_TG=b.Brand_TG
and a.Global_Campaign_Name=b.Global_Campaign_Name
and a.Type=b.Type
and a.Market='India'



--sog India calc

 IF OBJECT_ID('tempDB..#campaign_ind_hhs_all_media_reach_perc_sog') IS NOT NULL
BEGIN
DROP TABLE #campaign_ind_hhs_all_media_reach_perc_sog
END

  select 
   Primary_Brand_Key, 
   Month, Year, Brand_TG, 'India' as Market, 
    Type,  Global_Campaign_Name,	
	(sum(SOG_HHs_All_Media_Reach_In_Mn)/NULLIF(sum(SOG_HHs),0)) as All_Media_Reach_SOG 
   
  --sum(IRS_HHs_All_Media_Reach_In_Mn) as IRS_HHs_All_Media_Reach_In_Mn,
  --sum(SOG_HHs_All_Media_Reach_In_Mn) as SOG_HHs_All_Media_Reach_In_Mn
 into #campaign_ind_hhs_all_media_reach_perc_sog
   from #sog_media_perc
 where  Market NOT IN('Bangalore','Chennai','Hyderabad','Kolkata','Mumbai','India')

   group by   
    Primary_Brand_Key, 
   Month, Year, Brand_TG, Type,  Global_Campaign_Name
    order by Market, Type
	

update #sog_media_perc
set All_Media_Reach_SOG =b.All_Media_Reach_SOG 
from #sog_media_perc a
inner join #campaign_ind_hhs_all_media_reach_perc_sog b
on a.Primary_Brand_Key = b.Primary_Brand_Key
and a.Market=b.Market
and a.Month=b.Month and a.Year=b.year
and a.Brand_TG=b.Brand_TG
and a.Global_Campaign_Name=b.Global_Campaign_Name
and a.Type=b.Type
and a.Market='India'



/*
select * from #sog_media_perc
where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
 order by Market, Type

*/

IF OBJECT_ID('tempDB..#campaign_v12') IS NOT NULL
BEGIN
DROP TABLE #campaign_v12
END

select *, 
(Total_Spends*100000)/NULLIF((IRS_HHs_All_Media_Reach_In_Mn*1000000),0) as IRS_HHS_CPR,
(Total_Spends*100000)/NULLIF((SOG_HHs_All_Media_Reach_In_Mn*1000000),0) as SOG_HHS_CPR

into #campaign_v12
from #sog_media_perc


/*
select * from #campaign_v12 
where Primary_Brand_Key like  '%Surf Excel|Centaurus'
   and Month='Dec' and Year='2021'
 order by Market, Type

*/


--Digital market logic

IF OBJECT_ID('tempDB..#data_with_digital_market') IS NOT NULL
BEGIN
DROP TABLE #data_with_digital_market
END

select *
--distinct Primary_Brand_Key, Month, Year,Type,Brand_TG,Global_Campaign_Name
into #data_with_digital_market
from #campaign_v12
where Market  in ('Digital Market Cluster')
  order by Primary_Brand_Key

  --India market data for digital primary brands

IF OBJECT_ID('tempDB..#data_with_digital_market_India') IS NOT NULL
BEGIN
DROP TABLE #data_with_digital_market_India
END

select distinct a.Primary_Brand_Key,a.Market, a.Month, a.Year,a.Type,a.Brand_TG,a.Global_Campaign_Name,
a.All_Media_Reach_IRS, a.IRS_HHs, a.IRS_HHs_All_Media_Reach_In_Mn
into #data_with_digital_market_India
from #campaign_v12 a
inner join #data_with_digital_market b
on a.Primary_Brand_Key=b.Primary_Brand_Key and a.Year=b.Year and a.Month=b.Month
  and a.Brand_TG=b.Brand_TG
and a.Global_Campaign_Name=b.Global_Campaign_Name
and a.Type=b.Type
where a.Market in ('India')
order by a.Primary_Brand_Key, a.Market, a.Type, a.Month, a.Year


IF OBJECT_ID('tempDB..#data_with_digital_market_India_with_reach_more_than_0') IS NOT NULL
BEGIN
DROP TABLE #data_with_digital_market_India_with_reach_more_than_0
END

select *
into  #data_with_digital_market_India_with_reach_more_than_0
from #data_with_digital_market a
where YouTube_Reach>0
or FB_Reach>0
or OTT_Reach>0
--order by a.Primary_Brand_Key, a.Market, a.Type

/*
select *
from #data_with_digital_market_India_with_reach_more_than_0 a
order by a.Primary_Brand_Key, a.Market, a.Type
*/

IF OBJECT_ID('tempDB..#data_with_digital_market_India_with_reach_more_than_0_Ind') IS NOT NULL
BEGIN
DROP TABLE #data_with_digital_market_India_with_reach_more_than_0_Ind
END


select distinct a.Primary_Brand_Key,a.Market, a.Month, a.Year,a.Type,a.Brand_TG,a.Global_Campaign_Name,
a.All_Media_Reach_IRS, a.IRS_HHs, a.IRS_HHs_All_Media_Reach_In_Mn
into  #data_with_digital_market_India_with_reach_more_than_0_Ind
from #campaign_v12 a
inner join #data_with_digital_market_India_with_reach_more_than_0 b
on a.Primary_Brand_Key=b.Primary_Brand_Key and a.Year=b.Year and a.Month=b.Month
  and a.Brand_TG=b.Brand_TG
and a.Global_Campaign_Name=b.Global_Campaign_Name
and a.Type=b.Type
where a.Market in ('India')
order by a.Primary_Brand_Key, a.Market, a.Type, a.Month, a.Year


update  #campaign_v12
  set   All_Media_Reach_IRS=(1-(1-(b.Value_All_Media_Reach))*(1-(c.Value_Youtube_Reach/100))
  *(1-(d.Value_OTT_Reach/100))*(1-(e.Value_Facebook_Reach/100)))
  from #campaign_v12 a
  inner join (select Primary_Brand_Key,Market, Month, Year,Brand_TG,Global_Campaign_Name,Type,
   All_Media_Reach_IRS as Value_All_Media_Reach from #data_with_digital_market_India_with_reach_more_than_0_Ind
  where  Market='India'
  ) b
  on a.Primary_Brand_Key=b.Primary_Brand_Key and a.Year=b.Year and a.Month=b.Month and a.Brand_TG=b.Brand_TG
and a.Global_Campaign_Name=b.Global_Campaign_Name
and a.Type=b.Type and a.Market=b.Market

   inner join (select Primary_Brand_Key,Market, Month, Year,Brand_TG,Global_Campaign_Name,Type, 
   YouTube_Reach as Value_Youtube_Reach from #data_with_digital_market_India_with_reach_more_than_0
 -- where  Market='Digital Market Cluster'
  ) c
  on a.Primary_Brand_Key=c.Primary_Brand_Key and a.Year=c.Year and a.Month=c.Month and a.Brand_TG=b.Brand_TG
and a.Global_Campaign_Name=b.Global_Campaign_Name
and a.Type=b.Type --and a.Market=c.Market

   inner join (select Primary_Brand_Key,Market, Month, Year,Brand_TG,Global_Campaign_Name,Type, 
   OTT_Reach as Value_OTT_Reach from #data_with_digital_market_India_with_reach_more_than_0
  --where  Market='Digital Market Cluster'
  ) d
  on a.Primary_Brand_Key=d.Primary_Brand_Key and a.Year=d.Year and a.Month=d.Month and a.Brand_TG=b.Brand_TG
and a.Global_Campaign_Name=b.Global_Campaign_Name
and a.Type=b.Type --and a.Market=d.Market

   inner join (select Primary_Brand_Key,Market, Month, Year,Brand_TG,Global_Campaign_Name,Type,
    FB_Reach as Value_Facebook_Reach from #data_with_digital_market_India_with_reach_more_than_0
  --where  Market='Digital Market Cluster'
  ) e
  on a.Primary_Brand_Key=e.Primary_Brand_Key and a.Year=e.Year and a.Month=e.Month and a.Brand_TG=b.Brand_TG
and a.Global_Campaign_Name=b.Global_Campaign_Name
and a.Type=b.Type --and a.Market=e.Market

  where  a.Market='India'
  
   --and Market NOT IN('Bangalore','Chennai','Hyderabad','Kolkata','Mumbai','India')
 --order by a.Market, Type
  
 update #campaign_v12
 set IRS_HHs_All_Media_Reach_In_Mn=a.All_Media_Reach_IRS*a.IRS_HHs
from #campaign_v12 a
inner join  #data_with_digital_market_India_with_reach_more_than_0_Ind b
on a.Primary_Brand_Key=b.Primary_Brand_Key and a.Year=b.Year and a.Month=b.Month and a.Brand_TG=b.Brand_TG
and a.Global_Campaign_Name=b.Global_Campaign_Name
and a.Type=b.Type and a.Market=b.Market
where a.Market='India'


/*
select * from #campaign_v12
where Primary_Brand_Key='Beauty & Personal Care|Hair Care|Hair Care (excl Hair Oil)|Wash & Care|Shampoo|Dove|Dove Shampoo|Daenerys (Dove)'
and Month='Dec' and Year='2021'
and Type='Pre'
order by Market, Type

select distinct TV_Reach from #campaign_v12

*/


-- New columns add

IF OBJECT_ID('tempDB..#campaign_v13') IS NOT NULL
BEGIN
DROP TABLE #campaign_v13
END

select *,
(IRS_TV_Reach/100)*IRS_HHs as 'TV Reach in MN_IRS HHs',
(IRS_TV_Reach/100)*SOG_HHs as 'TV Reach in MN_SOG HHs',

(Print_Reach/100)*IRS_HHs as 'Print Reach in MN_IRS HHs',
(Print_Reach/100)*SOG_HHs as 'Print Reach in MN_SOG HHs',

(Radio_Reach/100)*IRS_HHs as 'Radio Reach in MN_IRS HHs',
(Radio_Reach/100)*SOG_HHs as 'Radio Reach in MN_SOG HHs',

(Cinema_Reach/100)*IRS_HHs as 'Cinema Reach in MN_IRS HHs',
(Cinema_Reach/100)*SOG_HHs as 'Cinema Reach in MN_SOG HHs',

(OOH_Reach/100)*IRS_HHs as 'OOH Reach in MN_IRS HHs',
(OOH_Reach/100)*SOG_HHs as 'OOH Reach in MN_SOG HHs',

(Youtube_Reach/100)*IRS_HHs as 'YouTube Reach in MN_IRS HHs',
(YouTube_Reach/100)*SOG_HHs as 'YouTube Reach in MN_SOG HHs',

(OTT_Reach/100)*IRS_HHs as 'OTT Reach in MN_IRS HHs',
(OTT_Reach/100)*SOG_HHs as 'OTT Reach in MN_SOG HHs',

(FB_Reach/100)*IRS_HHs as 'FB Reach in MN_IRS HHs',
(FB_Reach/100)*SOG_HHs as 'FB Reach in MN_SOG HHs',

(Mobile_Reach/100)*IRS_HHs as 'Mobile Reach in MN_IRS HHs',
(Mobile_Reach/100)*SOG_HHs as 'Mobile Reach in MN_SOG HHs',

(1-(1-(YouTube_Reach/100))*(1-(OTT_Reach/100))*(1-(FB_Reach/100))) as 'Digital Reach %',

((1-(1-(YouTube_Reach/100))*(1-(OTT_Reach/100))*(1-(FB_Reach/100)))*IRS_HHs) as 'Digital Reach in MN_IRS HHs',

((1-(1-(YouTube_Reach/100))*(1-(OTT_Reach/100))*(1-(FB_Reach/100)))*SOG_HHs) as 'Digital Reach in MN_SOG HHs',

(1-(1-(Print_Reach/100))*(1-(Radio_Reach/100))*(1-(Cinema_Reach/100))*(1-(OOH_Reach/100)) 
	*(1-(Mobile_Reach/100))) as 'NTV Reach %',
	
((1-(1-(Print_Reach/100))*(1-(Radio_Reach/100))*(1-(Cinema_Reach/100))*(1-(OOH_Reach/100)) 
	*(1-(Mobile_Reach/100)))*IRS_HHs) as 'NTV Reach in MN_IRS HHs',

((1-(1-(Print_Reach/100))*(1-(Radio_Reach/100))*(1-(Cinema_Reach/100))*(1-(OOH_Reach/100)) 
	*(1-(Mobile_Reach/100)))*SOG_HHs) as 'NTV Reach in MN_SOG HHs'

into #campaign_v13

from #campaign_v12


--Digital, NTV REach in Mn IRS, SOG India calc

 IF OBJECT_ID('tempDB..#campaign_ind_digital_reach_in_mn_irs_sog_calc') IS NOT NULL
BEGIN
DROP TABLE #campaign_ind_digital_reach_in_mn_irs_sog_calc
END

  select 
   Primary_Brand_Key, 
   Month, Year, Brand_TG, 'India' as Market, 
    Type,  Global_Campaign_Name,	
	(sum([Digital Reach in MN_IRS HHs])) as 'Digital Reach in MN_IRS HHs',
	(sum([Digital Reach in MN_SOG HHs])) as 'Digital Reach in MN_SOG HHs',
	(sum([NTV Reach in MN_IRS HHs])) as 'NTV Reach in MN_IRS HHs',
	(sum([NTV Reach in MN_SOG HHs])) as 'NTV Reach in MN_SOG HHs'
   
 into #campaign_ind_digital_reach_in_mn_irs_sog_calc
   from #campaign_v13
 where  Market NOT IN('Bangalore','Chennai','Hyderabad','Kolkata','Mumbai','India')

   group by   
    Primary_Brand_Key, 
   Month, Year, Brand_TG, Type,  Global_Campaign_Name
    order by Market, Type
	

update #campaign_v13
set [Digital Reach in MN_IRS HHs] =b.[Digital Reach in MN_IRS HHs], 
[Digital Reach in MN_SOG HHs] =b.[Digital Reach in MN_SOG HHs],
[NTV Reach in MN_IRS HHs] =b.[NTV Reach in MN_IRS HHs],
[NTV Reach in MN_SOG HHs] =b.[NTV Reach in MN_SOG HHs]
from #campaign_v13 a
inner join #campaign_ind_digital_reach_in_mn_irs_sog_calc b
on a.Primary_Brand_Key = b.Primary_Brand_Key
and a.Market=b.Market
and a.Month=b.Month and a.Year=b.year
and a.Brand_TG=b.Brand_TG
and a.Global_Campaign_Name=b.Global_Campaign_Name
and a.Type=b.Type
and a.Market='India'


--Digital, NTV Reach % IRS, SOG India calc

 IF OBJECT_ID('tempDB..#campaign_ind_digital_reach_perc_irs_sog_calc') IS NOT NULL
BEGIN
DROP TABLE #campaign_ind_digital_reach_perc_irs_sog_calc
END

  select 
   Primary_Brand_Key, 
   Month, Year, Brand_TG, 'India' as Market, 
    Type,  Global_Campaign_Name,	
	[Digital Reach in MN_IRS HHs]/NULLIF(IRS_HHs,0) as 'Digital Reach %',
	[NTV Reach in MN_IRS HHs]/NULLIF(IRS_HHs,0) as 'NTV Reach %'
   
 into #campaign_ind_digital_reach_perc_irs_sog_calc
   from #campaign_v13
 where  Market ='India'

   group by   
    Primary_Brand_Key, 
   Month, Year, Brand_TG, Type,  Global_Campaign_Name, [Digital Reach in MN_IRS HHs], [NTV Reach in MN_IRS HHs],
   IRS_HHs
    order by Market, Type
	

update #campaign_v13
set [Digital Reach %] =b.[Digital Reach %], 
[NTV Reach %] =b.[NTV Reach %]

from #campaign_v13 a
inner join #campaign_ind_digital_reach_perc_irs_sog_calc b
on a.Primary_Brand_Key = b.Primary_Brand_Key
and a.Market=b.Market
and a.Month=b.Month and a.Year=b.year
and a.Brand_TG=b.Brand_TG
and a.Global_Campaign_Name=b.Global_Campaign_Name
and a.Type=b.Type
and a.Market='India'


/*
select * from #campaign_v13
where Primary_Brand_Key='Beauty & Personal Care|Hair Care|Hair Care (excl Hair Oil)|Wash & Care|Shampoo|Clinic Plus|Clinic Plus Shampoo|Isotope'
and Month='Dec' and Year='2021'
and Type='Pre'
order by Market, Type


select * from #campaign_v13
where Primary_Brand_Key='Beauty & Personal Care|Colour Cosmetics|Colour Cosmetics|Colour Cosmetics|Colour Cosmetics|Lakme|Lakme Absolute|Avicii'
and Month='Apr' and Year='2021'
and Type='Pre'
order by Market, Type

*/


update #campaign_v13
set All_Media_Reach_IRS=All_Media_Reach_IRS*100

 update #campaign_v13
 set All_Media_Reach_SOG=All_Media_Reach_SOG*100

  update #campaign_v13
 set [Digital Reach %]=[Digital Reach %]*100

  update #campaign_v13
 set [NTV Reach %]=[NTV Reach %]*100

/*
select *,Youtube_Reach/100 from #campaign_v13 
 where Primary_Brand_Key like  '%Beauty & Personal Care|Colour Cosmetics|Colour Cosmetics|Colour Cosmetics|Colour Cosmetics|Lakme|Lakme Absolute|Avicii%'
   and Month='Apr' and Year='2021'
   --and Flag_Type='All_Media_Reach_IRS'
   and Market like '%India%'
   and Type='Pre'
   --and Market NOT IN('Bangalore','Chennai','Hyderabad','Kolkata','Mumbai','India')
 order by Market, Type

*/


 IF OBJECT_ID('DW.[campaign_output_temp]') IS NOT NULL
BEGIN
DROP TABLE DW.[campaign_output_temp]
END

SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]  
	  , NULL as [Reach_Freq]  
	  ,'IRS_HHs' as Flag_Type
      ,[IRS_HHs] as Value
      
	  INTO  DW.campaign_output_temp

  FROM #campaign_v13 

  --select * from DW.campaign_output_temp

alter table DW.campaign_output_temp
alter column Value varchar(255)

alter table DW.campaign_output_temp
alter column Flag_type varchar(255)

alter table DW.campaign_output_temp
alter column Reach_Freq varchar(255)

IF OBJECT_ID('DW.campaign_output_temp') IS NOT NULL 
TRUNCATE TABLE DW.campaign_output_temp

INSERT INTO DW.campaign_output_temp
([Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]
	  , [Reach_Freq]      
	  ,Flag_Type
      ,Value)

	  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]  
	  , NULL as [Reach_Freq]  
	  ,'SOG_Level' as Flag_Type
      ,TRY_CAST([SOG_Level] AS NVARCHAR) as Value
      
	    FROM #campaign_v13
			     	  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition],
	   NULL as [Reach_Freq]      
	  ,'IRS_HHs in Mn' as Flag_Type
      ,TRY_CAST([IRS_HHs] AS NVARCHAR) as Value
      
	  FROM #campaign_v13


  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition] 
	  , NULL as [Reach_Freq]     
	  ,'Source_Of_Growth' as Flag_Type
      ,TRY_CAST([Source_Of_Growth] AS NVARCHAR)  as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]
	  , NULL as [Reach_Freq]      
	  ,'SOG_HHs in Mn' as Flag_Type
      ,TRY_CAST([SOG_HHs] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'TV_Spends' as Flag_Type
      ,TRY_CAST([TV_Spends] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'Print_Spends' as Flag_Type
      ,TRY_CAST([Print_Spends] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'Radio_Spends' as Flag_Type
      ,TRY_CAST([Radio_Spends] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'Cinema_Spends' as Flag_Type
      ,TRY_CAST([Cinema_Spends] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition] 
	  , NULL as [Reach_Freq]     
	  ,'OOH_Spends' as Flag_Type
      ,TRY_CAST([OOH_Spends] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'YouTube_Spends' as Flag_Type
      ,TRY_CAST([YouTube_Spends] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'OTT_Spends' as Flag_Type
      ,TRY_CAST([OTT_Spends] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'FB_Spends' as Flag_Type
      ,TRY_CAST([FB_Spends] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'Mobile_Spends' as Flag_Type
      ,TRY_CAST([Mobile_Spends] AS NVARCHAR) as Value
  
  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'Digital_Spends' as Flag_Type
      ,TRY_CAST([Digital_Spends] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'NTV_Spends' as Flag_Type
      ,TRY_CAST([NTV_Spends] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'Total_Spends' as Flag_Type
      ,TRY_CAST([Total_Spends] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]  
	  , NULL as [Reach_Freq]    
	  ,'TV_Penetration %' as Flag_Type
      ,try_cast([TV_Penetration]  AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'TV_Reach %' as Flag_Type
      ,TRY_CAST([TV_Reach]  AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'TV Reach in MN_IRS HHs' as Flag_Type
      ,TRY_CAST([TV Reach in MN_IRS HHs]  AS NVARCHAR) as Value
      

  FROM #campaign_v13 

   UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'TV Reach in MN_SOG HHs' as Flag_Type
      ,TRY_CAST([TV Reach in MN_SOG HHs]  AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]  
	  , NULL as [Reach_Freq]    
	  ,'Print_Reach %' as Flag_Type
      ,TRY_CAST([Print_Reach]  AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]  
	  , NULL as [Reach_Freq]    
	  ,'Print Reach in MN_IRS HHs' as Flag_Type
      ,TRY_CAST([Print Reach in MN_IRS HHs]  AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]  
	  , NULL as [Reach_Freq]    
	  ,'Print Reach in MN_SOG HHs' as Flag_Type
      ,TRY_CAST([Print Reach in MN_SOG HHs]  AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition] 
	  , NULL as [Reach_Freq]     
	  ,'Radio_Reach %' as Flag_Type
      ,TRY_CAST([Radio_Reach] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition] 
	  , NULL as [Reach_Freq]     
	  ,'Radio Reach in MN_IRS HHs' as Flag_Type
      ,TRY_CAST([Radio Reach in MN_IRS HHs] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  
  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition] 
	  , NULL as [Reach_Freq]     
	  ,'Radio Reach in MN_SOG HHs' as Flag_Type
      ,TRY_CAST([Radio Reach in MN_SOG HHs] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'Cinema_Reach %' as Flag_Type
      ,TRY_CAST([Cinema_Reach] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'Cinema Reach in MN_IRS HHs' as Flag_Type
      ,TRY_CAST([Cinema Reach in MN_IRS HHs] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'Cinema Reach in MN_SOG HHs' as Flag_Type
      ,TRY_CAST([Cinema Reach in MN_SOG HHs] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'OOH_Reach %' as Flag_Type
      ,TRY_CAST([OOH_Reach] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'OOH Reach in MN_IRS HHs' as Flag_Type
      ,TRY_CAST([OOH Reach in MN_IRS HHs] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'OOH Reach in MN_SOG HHs' as Flag_Type
      ,TRY_CAST([OOH Reach in MN_SOG HHs] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'YouTube_Reach %' as Flag_Type
      ,TRY_CAST([YouTube_Reach] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'YouTube Reach in MN_IRS HHs' as Flag_Type
      ,TRY_CAST([YouTube Reach in MN_IRS HHs] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'YouTube Reach in MN_SOG HHs' as Flag_Type
      ,TRY_CAST([YouTube Reach in MN_SOG HHs] AS NVARCHAR) as Value
      

  FROM #campaign_v13 


  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'OTT_Reach %' as Flag_Type
      ,TRY_CAST([OTT_Reach] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'OTT Reach in MN_IRS HHs' as Flag_Type
      ,TRY_CAST([OTT Reach in MN_IRS HHs] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'OTT Reach in MN_SOG HHs' as Flag_Type
      ,TRY_CAST([OTT Reach in MN_SOG HHs] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition] 
	  , NULL as [Reach_Freq]     
	  ,'FB_Reach %' as Flag_Type
      ,TRY_CAST([FB_Reach] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition] 
	  , NULL as [Reach_Freq]     
	  ,'FB Reach in MN_IRS HHs' as Flag_Type
      ,TRY_CAST([FB Reach in MN_IRS HHs] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition] 
	  , NULL as [Reach_Freq]     
	  ,'FB Reach in MN_SOG HHs' as Flag_Type
      ,TRY_CAST([FB Reach in MN_SOG HHs] AS NVARCHAR) as Value
      

  FROM #campaign_v13 


  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'Mobile_Reach %' as Flag_Type
      ,TRY_CAST([Mobile_Reach] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'Mobile Reach in MN_IRS HHs' as Flag_Type
      ,TRY_CAST([Mobile Reach in MN_IRS HHs] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'Mobile Reach in MN_SOG HHs' as Flag_Type
      ,TRY_CAST([Mobile Reach in MN_SOG HHs] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]  
	  , NULL as [Reach_Freq]    
	  ,'IRS_TV_Reach %' as Flag_Type
      ,TRY_CAST([IRS_TV_Reach] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'All_Media_Reach_IRS %' as Flag_Type
      ,TRY_CAST([All_Media_Reach_IRS] AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'All_Media_Reach_SOG %' as Flag_Type
      ,TRY_CAST([All_Media_Reach_SOG] AS NVARCHAR) as Value
      

  FROM #campaign_v13

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]    
	  , NULL as [Reach_Freq]  
	  ,'IRS_HHs_All_Media_Reach_In_Mn' as Flag_Type
      ,TRY_CAST([IRS_HHs_All_Media_Reach_In_Mn] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]  
	  , NULL as [Reach_Freq]    
	  ,'SOG_HHs_All_Media_Reach_In_Mn' as Flag_Type
      ,TRY_CAST([SOG_HHs_All_Media_Reach_In_Mn] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition] 
	  , NULL as [Reach_Freq]     
	  ,'IRS_HHS_CPR' as Flag_Type
      ,TRY_CAST([IRS_HHS_CPR] AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'SOG_HHS_CPR' as Flag_Type
      ,TRY_CAST([SOG_HHS_CPR]  AS NVARCHAR) as Value
      

  FROM #campaign_v13 

  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'Digital Reach %' as Flag_Type
      ,TRY_CAST([Digital Reach %]  AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  
  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'Digital Reach in MN_IRS HHs' as Flag_Type
      ,TRY_CAST([Digital Reach in MN_IRS HHs]  AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'Digital Reach in MN_SOG HHs' as Flag_Type
      ,TRY_CAST([Digital Reach in MN_SOG HHs]  AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'NTV Reach %' as Flag_Type
      ,TRY_CAST([NTV Reach %]  AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'NTV Reach in MN_IRS HHs' as Flag_Type
      ,TRY_CAST([NTV Reach in MN_IRS HHs]  AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  
  UNION 
  
  SELECT [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
	  , NULL as [Reach_Freq]   
	  ,'NTV Reach in MN_SOG HHs' as Flag_Type
      ,TRY_CAST([NTV Reach in MN_SOG HHs]  AS NVARCHAR) as Value
      

  FROM #campaign_v13 
  
  --Fetching Reach_Freq values

  IF OBJECT_ID('tempDB..#reach_freq_value') IS NOT NULL
BEGIN
DROP TABLE #reach_freq_value
END


    select distinct Medium, Reach_Freq
	into #reach_freq_value
  from [DB_PBRT].[DW].[UL_MEDIA_IN_CAMPAIGN_REACH]

 -- select * from #reach_freq_value


	update DW.campaign_output_temp
	set Reach_Freq=(select Reach_Freq from #reach_freq_value where Medium='TV')
	where Flag_Type ='TV_Reach %'

	update DW.campaign_output_temp
	set Reach_Freq=(select Reach_Freq from #reach_freq_value where Medium='Mobile')
	where Flag_Type ='Mobile_Reach %'

	update DW.campaign_output_temp
	set Reach_Freq=(select Reach_Freq from #reach_freq_value where Medium='YT')
	where Flag_Type ='YouTube_Reach %'

	update DW.campaign_output_temp
	set Reach_Freq=(select Reach_Freq from #reach_freq_value where Medium='Print')
	where Flag_Type ='Print_Reach %'

	update DW.campaign_output_temp
	set Reach_Freq=(select Reach_Freq from #reach_freq_value where Medium='OTT')
	where Flag_Type ='OTT_Reach %'

	update DW.campaign_output_temp
	set Reach_Freq=(select Reach_Freq from #reach_freq_value where Medium='Cinema')
	where Flag_Type ='Cinema_Reach %'

	update DW.campaign_output_temp
	set Reach_Freq=(select Reach_Freq from #reach_freq_value where Medium='FB')
	where Flag_Type ='FB_Reach %'

	update DW.campaign_output_temp
	set Reach_Freq=(select Reach_Freq from #reach_freq_value where Medium='OOH')
	where Flag_Type ='OOH_Reach %'

	update DW.campaign_output_temp
	set Reach_Freq=(select Reach_Freq from #reach_freq_value where Medium='Radio')
	where Flag_Type ='Radio_Reach %'

	
  IF OBJECT_ID('DW.UL_MEDIA_IN_CAMPAIGN_OUTPUT') IS NOT NULL
BEGIN
DROP TABLE DW.UL_MEDIA_IN_CAMPAIGN_OUTPUT
END

 select 
 [Big_C]
      ,[Small_C]      ,[Sub_Category]      ,[Segment]      ,[Sub_Segment]      ,[Primary_Brand]      ,[Brand_Name]
      ,[Primary_Brand_Key]      ,[Global_Campaign_Name]      ,[Type]
      ,[Month]      ,[Year]      ,[Brand_TG]      ,[Market_Type]      ,[Market]      ,[Base_Definition]   
  	  , Flag_Type
      , IsNUll([Value], '') as Value
	  , IsNUll([Reach_Freq], '')  as Reach_Freq

 into DW.UL_MEDIA_IN_CAMPAIGN_OUTPUT
  from
 DW.campaign_output_temp

 /*
 select * from  #campaign_v13 
  where Primary_Brand_Key like  'Beauty & Personal Care|Hair Care|Hair Care (excl Hair Oil)|Wash & Care|Shampoo|Clinic Plus|Clinic Plus Shampoo|Isotope'
   and Month='Dec' and Year='2021'
   and Market='India'
 order by Market, Type

 */


