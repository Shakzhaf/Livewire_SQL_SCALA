SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('DW.proc_UL_MEDIA_IN_PBRT_SPENDS_OUTPUT') IS NOT NULL
DROP PROCEDURE DW.proc_UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
GO

CREATE PROC DW.proc_UL_MEDIA_IN_PBRT_SPENDS_OUTPUT AS

update DW.UL_MEDIA_IN_PBRT_SPENDS
set Market='India'
where market is NULL

IF OBJECT_ID('tempDB..#spend_v1') IS NOT NULL
BEGIN
DROP TABLE #spend_v1
END

select distinct A.Primary_Brand_Key, A.Year, A.Month, A.Category, Medium ,A.Market,b.Sub_Category,
 b.Segment as Segment, b.Sub_Segment as Sub_Segment, b.Big_C, b.Small_C,
b.Primary_Brand as Primary_Brand_Name,
case IB_TYPE when 'CWBS' then 'FATMAN'  end as IB_Type,
concat(Month,' ',Year) as Period_Type,
CASE WHEN A.Market='AP / Telangana' THEN 'Cluster'
 WHEN A.Market='Assam / North East / Sikkim' THEN 'Cluster' 
 WHEN A.Market='Bihar/Jharkhand' THEN 'Cluster'
 WHEN A.Market='Digital Market Cluster' THEN 'Club Market'
 WHEN A.Market='Guj / D&D / DNH' THEN 'Cluster'
 WHEN A.Market='Karnataka' THEN 'Cluster'
 WHEN A.Market='Kerala' THEN 'Cluster'
 WHEN A.Market='Mah / Goa' THEN 'Cluster'
 WHEN A.Market='MP/Chhattisgarh' THEN 'Cluster'
 WHEN A.Market='Odisha' THEN 'Cluster'
 WHEN A.Market='Pun / Har / Cha / HP / J&K' THEN 'Cluster'
 WHEN A.Market='Rajasthan' THEN 'Cluster' 
 WHEN A.Market='TN/Pondicherry' THEN 'Cluster'
 WHEN A.Market='UP/Uttarakhand' THEN 'Cluster' 
 WHEN A.Market='West Bengal' THEN 'Cluster'
 WHEN A.Market='Delhi' THEN 'Cluster'
 WHEN A.Market='Bangalore' THEN 'Metro'
 WHEN A.Market='Chennai' THEN 'Metro' 
 WHEN A.Market='Hyderabad' THEN 'Metro'
 WHEN A.Market='Kolkata' THEN 'Metro'
 WHEN A.Market='Mumbai' THEN 'Metro'
 WHEN A.Market='India' THEN 'India' END as Geography_Type,
A.LSM as Target_Group
into #spend_v1 
from DW.UL_MEDIA_IN_PBRT_SPENDS (NOLOCK) a 
left join
DW.UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER b (NOLOCK)
on --a.Category = b.Small_C and 
a.Primary_Brand_Key = b.PBRT_KEY
group by A.Primary_Brand_Key, A.Year, A.Month, A.Category, Medium ,A.Market,b.Sub_Category, b.Segment , b.Sub_Segment, b.Big_C, b.Small_C,b.Primary_Brand,
IB_TYPE, LSM
--select count(*) from #spend_v1
--where Market ='Digital Market Cluster'

--Where Market as India not present
IF OBJECT_ID('tempDB..#spend_v8') IS NOT NULL
BEGIN
DROP TABLE #spend_v8
END

select distinct A.Primary_Brand_Key, A.Year, A.Month, A.Category, Medium ,'India' as Market,b.Sub_Category,
 b.Segment as Segment, b.Sub_Segment as Sub_Segment, b.Big_C, b.Small_C,
b.Primary_Brand as Primary_Brand_Name,
case IB_TYPE when 'CWBS' then 'FATMAN'  end as IB_Type,
concat(Month,' ',Year) as Period_Type,
'Geo' as Geography_Type,
A.LSM as Target_Group
into #spend_v8 
from DW.UL_MEDIA_IN_PBRT_SPENDS (NOLOCK) a 
inner join
DW.UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER b (NOLOCK)
on --a.Category = b.Small_C and 
a.Primary_Brand_Key = b.PBRT_KEY
where a.Market !='India'
group by A.Primary_Brand_Key, A.Year, A.Month, A.Category, Medium ,b.Sub_Category, b.Segment ,
 b.Sub_Segment, b.Big_C, b.Small_C,b.Primary_Brand,
IB_TYPE, LSM

/*
select * from #spend_v8
where Primary_Brand_Key like '%3 roses%'
and Month='May' and Year='2019'
order by Market
*/

/*
select * from #spend_v1
where Primary_Brand_Key like '3 roses'
and Month='May' and Year='2019'
order by Market
*/
--Pulling spend summary as expected in the spend output excel file

--IF OBJECT_ID('#spend_v2') IS NOT NULL 
--DROP TABLE #spend_v2; 

IF OBJECT_ID('tempDB..#spend_v2') IS NOT NULL
BEGIN
DROP TABLE #spend_v2
END

select distinct Primary_Brand_Key,year, month,   Market, IB_TYPE,
sum(case when (Medium in ('TV')   )  then Amount_Spent_INR when IB_TYPE ='CWBS' then 0 else 0 end) as TV_Spends,
sum(case when (Medium in ('Print')  ) then Amount_Spent_INR  when IB_TYPE ='CWBS' then 0 else 0 end) as Print_Spends,
sum(case when (Medium in ('Radio')   ) then Amount_Spent_INR  when IB_TYPE ='CWBS' then 0 else 0 end) as Radio_Spends,
sum(case when (Medium in ('Cinema')   ) then Amount_Spent_INR  when IB_TYPE ='CWBS' then 0 else 0 end) as Cinema_Spends,
sum(case when (Medium in ('Mobile')  ) then Amount_Spent_INR  when IB_TYPE ='CWBS' then 0 else 0 end) as Mobile_Spends,
sum(case when (Medium in ('YT')   ) then Amount_Spent_INR when IB_TYPE ='CWBS' then 0  else 0 end) as YouTube_Spends,
------------------
sum(case when (Medium in ('STATIC RURAL')   ) then Amount_Spent_INR when IB_TYPE ='CWBS' then 0  else 0 end) as Static_Rural_Spends,
------------------
sum(case when (Medium in ('OTT')  ) then Amount_Spent_INR  when IB_TYPE ='CWBS' then 0 else 0 end) as OTT_Spends,
sum(case when (Medium in ('FB')   ) then Amount_Spent_INR when IB_TYPE ='CWBS' then 0  else 0 end) as Facebook_Spends,
sum(case when (Medium in ('OOH')   ) then Amount_Spent_INR when IB_TYPE ='CWBS' then 0  else 0 end) as OOH_Spends,
sum(case when (Medium in ('Others')   ) then Amount_Spent_INR when IB_TYPE ='CWBS' then 0  else 0 end) as Others_Spends,
sum(case when (Medium in ('YT', 'OTT', 'FB')  ) then Amount_Spent_INR else 0 end) as Digital_Spends,
sum(Amount_Spent_INR) as Total_Spends,
----Below New code is added by Dilip on 29-09-2022-----
sum(case when (Medium in('Print','Radio','Cinema','Mobile','OOH') ) then Amount_Spent_INR else 0 end) as NTV_Spends,
---Old code----
--(sum(Amount_Spent_INR)-ISNULL(sum(case when (Medium in ('TV')) then Amount_Spent_INR end),0)) as NTV_Spends,

cast(NULL as decimal(15,7)) as Fatman_Spends
into #spend_v2 
from DW.UL_MEDIA_IN_PBRT_SPENDS (NOLOCK)
group by year, month,   Primary_Brand_Key, Market, IB_TYPE



IF OBJECT_ID('tempDB..#spend_total') IS NOT NULL
BEGIN
DROP TABLE #spend_total
END

select distinct Primary_Brand_Key,year, month,   Market, IB_TYPE,
Total_Spends=sum(TV_spends)+sum(Print_Spends)+sum(Radio_Spends)+sum(Cinema_Spends)+sum(Mobile_Spends)
		 +sum(Youtube_Spends)+sum(OTT_Spends)+sum(Facebook_Spends)+sum(OOH_Spends)+sum(Others_Spends)
		 into #spend_total
		 from #spend_v2
		 group by Primary_Brand_Key,year, month,   Market, IB_TYPE

update #spend_v2
set Total_Spends=b.Total_Spends
from #spend_v2 a
inner join #spend_total b
on a.Primary_Brand_Key=b.Primary_Brand_Key and a.Month=b.Month and a.Year=b.Year and a.IB_TYPE=b.IB_TYPE

/*
select * from #spend_v2
where Primary_Brand_Key like '%3 roses%'
and Month='May' and Year='2020'
and Market='India'
order by Market
*/

update #spend_v2
set Fatman_Spends=TV_Spends
where IB_TYPE='CWBS'
   
IF OBJECT_ID('tempDB..#spend_v5') IS NOT NULL
BEGIN
DROP TABLE #spend_v5
END

select distinct Primary_Brand_Key,year, month, category,   Market, IB_TYPE,
sum(case when (Medium in ('TV')  and IB_TYPE !='CWBS' )  then Amount_Spent_INR when (Medium in ('TV') and Market is NULL  and IB_TYPE ='CWBS'   ) then 0 else 0 end) as TV_Spends,
--sum(case when (Medium in ('TV') and IB_TYPE!='CWBS')  then Amount_Spent_INR when (Medium in ('TV') and Market is Null)  then Amount_Spent_INR  when IB_TYPE ='CWBS' then 0 else 0 end) as TV_Spends,
--sum(case when (Medium in ('TV') and IB_TYPE!='CWBS')  then Amount_Spent_INR when Market is Null and IB_TYPE!='CWBS' then Amount_Spent_INR  when IB_TYPE ='CWBS' then 0 else 0 end) as TV_Spends,
--sum(case when (Medium in ('TV') )  then Amount_Spent_INR when IB_TYPE ='CWBS' then 0 else 0 end) as TV_Spends,
sum(case when (Medium in ('Print') and Market is NULL or Market is not NULL and IB_TYPE !='CWBS'   ) then Amount_Spent_INR  else 0  end) as Print_Spends,
sum(case when (Medium in ('Radio') and Market is NULL or Market is not NULL and IB_TYPE !='CWBS'   ) then Amount_Spent_INR  else 0 end) as Radio_Spends,
sum(case when (Medium in ('Cinema') and Market is NULL or Market is not NULL and IB_TYPE !='CWBS'  ) then Amount_Spent_INR  else 0 end) as Cinema_Spends,
sum(case when (Medium in ('Mobile')  and Market is NULL or Market is not NULL and IB_TYPE !='CWBS'   ) then Amount_Spent_INR  else 0 end) as Mobile_Spends,
sum(case when (Medium in ('YT') and Market is NULL or Market is not NULL and IB_TYPE !='CWBS'   ) then Amount_Spent_INR  else 0 end) as YouTube_Spends,
--------------------------
sum(case when (Medium in ('Static Rural') and Market is NULL or Market is not NULL and IB_TYPE !='CWBS'   ) then Amount_Spent_INR  else 0 end) as Static_Rural_Spends,
--------------------------
sum(case when (Medium in ('OTT')and Market is NULL or Market is not NULL and IB_TYPE !='CWBS'  ) then Amount_Spent_INR  else 0 end) as OTT_Spends,
sum(case when (Medium in ('FB') and Market is NULL or Market is not NULL and IB_TYPE !='CWBS'   ) then Amount_Spent_INR  else 0 end) as Facebook_Spends,
sum(case when (Medium in ('OOH')  and Market is NULL or Market is not NULL and IB_TYPE !='CWBS'   ) then Amount_Spent_INR  else 0 end) as OOH_Spends,
sum(case when (Medium in ('Others') and Market is NULL or Market is not NULL and IB_TYPE !='CWBS'   ) then Amount_Spent_INR  else 0 end) as Others_Spends,
sum(case when (Medium in ('YT', 'OTT', 'FB') and IB_TYPE !='CWBS' ) then Amount_Spent_INR else 0 end) as Digital_Spends,
sum(Amount_Spent_INR) as Total_Spends,
----Below New code is added by Dilip on 29-09-2022-----
sum(case when (Medium in('Print','Radio','Cinema','Mobile','OOH') ) then Amount_Spent_INR else 0 end) as NTV_Spends,
---Old code----
--(sum(Amount_Spent_INR)-sum(case when (Medium in ('TV')) then Amount_Spent_INR end)) as NTV_Spends,
cast(NULL as decimal(15,7)) as Fatman_Spends
into #spend_v5 
from DW.UL_MEDIA_IN_PBRT_SPENDS
where Market is NULL
group by year, month, category,  Primary_Brand_Key, Market, IB_TYPE



--select * from #spend_v5
--where Market ='Digital Market Cluster'
--order by Primary_Brand_Key, Market


--IF OBJECT_ID('#spend_v3') IS NOT NULL 
--DROP TABLE #spend_v3; 

IF OBJECT_ID('tempDB..#spend_v3') IS NOT NULL
BEGIN
DROP TABLE #spend_v3
END

select Primary_Brand_Key,
		Year,Month,
		IB_Type,
		'India' as Market,sum(TV_spends) as TV_spends, sum(Print_Spends)as Print_Spends,
		 sum(Radio_Spends) as Radio_Spends, sum(Cinema_Spends) as Cinema_Spends, sum(Mobile_Spends) as Mobile_Spends, 
		 sum(Youtube_Spends) Youtube_Spends, 
         ------------------------------
         sum(Static_Rural_Spends) Static_Rural_Spends, 
         ------------------------------
		 sum(OTT_Spends) OTT_Spends,
		  sum(Facebook_Spends) as Facebook_Spends, sum(OOH_Spends) as OOH_Spends,  sum(Others_Spends) as Others_Spends, 
		 sum(Digital_Spends) as Digital_Spends,
		 
		 (sum(TV_spends)+sum(Print_Spends)+sum(Radio_Spends)+sum(Cinema_Spends)+sum(Mobile_Spends)
		 +sum(Youtube_Spends)+sum(OTT_Spends)+sum(Facebook_Spends)+sum(OOH_Spends)+sum(Others_Spends)) as Total_Spends,
		 ---New code added by Dilip on 29-9-2022---
		  (sum(Print_Spends)+sum(Radio_Spends)+sum(Cinema_Spends)+sum(Mobile_Spends)+sum(OOH_Spends)) as NTV_Spends,
		 -------Old code--
		 --(sum(TV_spends)+sum(Print_Spends)+sum(Radio_Spends)+sum(Cinema_Spends)+sum(Mobile_Spends)
		 --+sum(Youtube_Spends)+sum(OTT_Spends)+sum(Facebook_Spends)
		 --+sum(OOH_Spends)+sum(Others_Spends))-sum(TV_spends) as NTV_Spends,

		 sum(Fatman_Spends) as Fatman_Spends
		 into #spend_v3
		 from #spend_v2 
		 where-- IB_TYPE is NULL
		  Market NOT IN('Bangalore','Chennai','Hyderabad','Kolkata','Mumbai')
		 group by Primary_Brand_Key, Year, Month, IB_TYPE
		 
		 /*
		 select Primary_Brand_Key,
		Year,Month,
		IB_Type,
		'India' as Market,sum(TV_spends) as TV_spends, sum(Print_Spends)as Print_Spends,
		 sum(Radio_Spends) as Radio_Spends, sum(Cinema_Spends) as Cinema_Spends, sum(Mobile_Spends) as Mobile_Spends, 
		 sum(Youtube_Spends) Youtube_Spends, 
		 sum(OTT_Spends) OTT_Spends,
		  sum(Facebook_Spends) as Facebook_Spends, sum(OOH_Spends) as OOH_Spends,  sum(Others_Spends) as Others_Spends, 
		 sum(Digital_Spends) as Digital_Spends,
		 
		 (sum(TV_spends)+sum(Print_Spends)+sum(Radio_Spends)+sum(Cinema_Spends)+sum(Mobile_Spends)
		 +sum(Youtube_Spends)+sum(OTT_Spends)+sum(Facebook_Spends)+sum(OOH_Spends)+sum(Others_Spends)) as Total_Spends,

		 (sum(TV_spends)+sum(Print_Spends)+sum(Radio_Spends)+sum(Cinema_Spends)+sum(Mobile_Spends)
		 +sum(Youtube_Spends)+sum(OTT_Spends)+sum(Facebook_Spends)
		 +sum(OOH_Spends)+sum(Others_Spends))-sum(TV_spends) as NTV_Spends,

		 sum(Fatman_Spends) as Fatman_Spends
		 --into #spend_v3
		 from #spend_v2 
		 where-- IB_TYPE is NULL
		  Market NOT IN('Bangalore','Chennai','Hyderabad','Kolkata','Mumbai')
		  and Market!='India'
		  and Primary_Brand_Key like '%boost%'
		and Month='Sep' and Year='2021'
		 group by Primary_Brand_Key, Year, Month, IB_TYPE
		 order by Primary_Brand_Key
		 */
		 /*
		 select * from #spend_v3
		 where Primary_Brand_Key like '%Boost%'
	  and Year=2021 and Month='Sep'

	  /*
select * from #spend_v3
where Primary_Brand_Key like 'Food & Refreshment|Nutrition|MFD|Total-Boost|Kids|Boost||'
and Month='Sep' and Year='2021'
order by Market
*/

	  select * from DW.UL_MEDIA_IN_PBRT_SPENDS
	  where Primary_Brand_Key like 'Beauty & Personal Care|Skin Care|Face Care|Face Cleansing|Face Cleansing|Pond''s Face Wash||'
	  and Year=2021 and Month='Jan'
	  and Medium='TV'
	  */

		
IF OBJECT_ID('tempDB..#spend_v4') IS NOT NULL
BEGIN
DROP TABLE #spend_v4
END

select distinct A.Primary_Brand_Key as Primary_Brand_Key , A.Year, A.Month, A.Category, IsNull(A.Market, '') as Market, 
IsNull(A.Sub_Category, '')as Sub_Category, 
IsNull(A.Segment, '') as Segment, 
IsNull(A.Sub_Segment, '') as Sub_Segment, IsNull(A.Big_C, '') as Big_C, IsNull(A.Small_C, '') as Small_C, 
a.Primary_Brand_Name as Primary_Brand,
IsNull(A.IB_Type, '') as IB_Type, A.Period_Type, IsNull(A.Geography_Type, '')as Geography_Type,  
IsNull(A.Target_Group, '') as Target_Group, 
--d.ACD as ACD,
--COALESCE(sum(c.Norm30sec_GrpxAverage_Length)/NULLIF(sum(c.Norm30sec_Grp),0),0) as ACD,
--from DW.UL_MEDIA_IN_PBRT_HULACD_MASTER
B.TV_Spends,
 B.Print_Spends,
  B.Radio_Spends,
	    B.Cinema_Spends,
	  B.Mobile_Spends,
	  B.Youtube_Spends,
      B.Static_Rural_Spends,
	   B.OTT_Spends,
	    B.Facebook_Spends,
 B.OOH_Spends,
	   B.Others_Spends,
	    B.Digital_Spends,
		Total_Spends,
		b.NTV_Spends,
		b.Fatman_Spends
		into  #spend_v4
		from #spend_v1 (NOLOCK) a 
		inner join #spend_v2 (NOLOCK) b 
		on a.Primary_Brand_Key=b.Primary_Brand_Key
		and a.Market=b.Market
		and a.Year=b.Year
		and a.Month=b.Month
		and a.Market!='India'
		--and a.IB_Type=b.IB_TYPE
		
		--left join DW.UL_MEDIA_IN_PBRT_HULACD_MASTER (NOLOCK) c	
		--on a.Primary_Brand_Key=c.Primary_Brand_Key
		/*
		select top 10 * from DW.UL_MEDIA_IN_PBRT_ACD_OUTPUT
		*/
		--and a.Market=c.Market
		--and a.Year=c.year
		--and a.Month=c.Month
		--left join DW.UL_MEDIA_IN_PBRT_ACD_OUTPUT (NOLOCK) d
			--on a.Primary_Brand_Key=d.Primary_Brand_Key
			
		
		group by A.Primary_Brand_Key, A.Year, A.Month, A.Category, A.Market, Sub_Category, A.Segment , Sub_Segment, Big_C, Small_C,Primary_Brand_Name,
		A.IB_Type, Period_Type, Geography_Type, Target_Group,
		TV_spends, Print_Spends, Radio_Spends, Cinema_Spends, Mobile_Spends, Youtube_Spends, Static_Rural_Spends, OTT_Spends,  Facebook_Spends, OOH_Spends,  Others_Spends, 
		 Digital_Spends, Total_Spends,NTV_Spends,Fatman_Spends--, d.ACD

		 --select * from #spend_v4
				
				/*
		 select * from #spend_v4
		  select * from #spend_v4
		 where Primary_Brand_Key like '%Boost%'
and Month='Sep' and Year='2021'
and Market='India'
order by Primary_Brand_Key, Month, Year,Market
*/
				 		  
		UNION 
		 
		-- IF OBJECT_ID('#spend_v4') IS NOT NULL 
--DROP TABLE #spend_v4; 

		 select distinct A.Primary_Brand_Key as Primary_Brand_Key , A.Year, A.Month, A.Category, b.Market, IsNull(A.Sub_Category, '')as Sub_Category, 
IsNull(A.Segment, '') as Segment, 
IsNull(A.Sub_Segment, '') as Sub_Segment, IsNull(A.Big_C, '') as Big_C, IsNull(A.Small_C, '') as Small_C,A.Primary_Brand_Name as Primary_Brand,
IsNull(b.IB_Type, '') as IB_Type, A.Period_Type, IsNull(A.Geography_Type, '')as Geography_Type,  IsNull(A.Target_Group, '') as Target_Group, 
--NULL as ACD,
B.TV_Spends,
 B.Print_Spends,
  B.Radio_Spends,
	    B.Cinema_Spends,
	  B.Mobile_Spends,
	  B.Youtube_Spends,
      B.Static_Rural_Spends,
	   B.OTT_Spends,
	    B.Facebook_Spends,
      B.OOH_Spends,
	   B.Others_Spends,
	    B.Digital_Spends,
		Total_Spends,
		b.NTV_Spends,
		b.Fatman_Spends
		--into  #spend_v4
		from #spend_v1 a
		inner join #spend_v5 b
		on a.Primary_Brand_Key=b.Primary_Brand_Key
		and b.Market=a.Market
		and a.Year=b.Year
		and a.Month=b.Month
		--and a.IB_Type=b.IB_TYPE
		
		
		--left join DW.UL_MEDIA_IN_PBRT_HULACD_MASTER c
		--on a.Primary_Brand_Key=c.Primary_Brand_Key
		--and a.Market=c.Market
		--and a.Year=c.year
		--and a.Month=c.Month 
		
		where b.Market is NULL
		and a.Geography_Type is NULL
		
		group by A.Primary_Brand_Key,b.Market, A.Year, A.Month, A.Category,  Sub_Category, A.Segment , Sub_Segment, Big_C, Small_C,Primary_Brand_Name,
		b.IB_Type, Period_Type, Geography_Type, Target_Group,
		TV_spends, Print_Spends, Radio_Spends, Cinema_Spends, Mobile_Spends, Youtube_Spends, Static_Rural_Spends, OTT_Spends,  Facebook_Spends, OOH_Spends,  Others_Spends, 
		 Digital_Spends, Total_Spends,NTV_Spends,Fatman_Spends--, ACD

		 UNION

		 select distinct b.Primary_Brand_Key as Primary_Brand_Key , b.Year, b.Month, c.Category, b.Market, IsNull(A.Sub_Category, '')as Sub_Category, 
IsNull(A.Segment, '') as Segment, 
IsNull(A.Sub_Segment, '') as Sub_Segment, IsNull(A.Big_C, '') as Big_C, IsNull(A.Small_C, '') as Small_C,a.Primary_Brand as Primary_Brand,
IsNull(b.IB_Type, '') as IB_Type, concat(b.Month,' ',b.Year) as Period_Type,
CASE WHEN B.Market='AP / Telangana' THEN 'Cluster'
 WHEN B.Market='Assam / North East / Sikkim' THEN 'Cluster' 
 WHEN B.Market='Bihar/Jharkhand' THEN 'Cluster'
 WHEN B.Market='Digital Market Cluster' THEN 'Club Market'
 WHEN B.Market='Guj / D&D / DNH' THEN 'Cluster'
 WHEN B.Market='Karnataka' THEN 'Cluster'
 WHEN B.Market='Kerala' THEN 'Cluster'
 WHEN B.Market='Mah / Goa' THEN 'Cluster'
 WHEN B.Market='MP/Chhattisgarh' THEN 'Cluster'
 WHEN B.Market='Odisha' THEN 'Cluster'
 WHEN B.Market='Pun / Har / Cha / HP / J&K' THEN 'Cluster'
 WHEN B.Market='Rajasthan' THEN 'Cluster' 
 WHEN B.Market='TN/Pondicherry' THEN 'Cluster'
 WHEN B.Market='UP/Uttarakhand' THEN 'Cluster' 
 WHEN B.Market='West Bengal' THEN 'Cluster'
 WHEN B.Market='Delhi' THEN 'Cluster'
 WHEN B.Market='Bangalore' THEN 'Metro'
 WHEN B.Market='Chennai' THEN 'Metro' 
 WHEN B.Market='Hyderabad' THEN 'Metro'
 WHEN B.Market='Kolkata' THEN 'Metro'
 WHEN B.Market='Mumbai' THEN 'Metro'
 WHEN B.Market='India' THEN 'India' END as Geography_Type,  
 IsNull(c.LSM, '') as Target_Group, 
--NULL as ACD,
B.TV_Spends,
 B.Print_Spends,
  B.Radio_Spends,
	    B.Cinema_Spends,
	  B.Mobile_Spends,
	  B.Youtube_Spends,
      B.Static_Rural_Spends,
	   B.OTT_Spends,
	    B.Facebook_Spends,
      B.OOH_Spends,
	   B.Others_Spends,
	    B.Digital_Spends,
		b.Total_Spends,
		b.NTV_Spends,
		b.Fatman_Spends
		--into  #spend_v4
		from #spend_v3 b
		inner join DW.UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER a
		on a.PBRT_KEY=b.Primary_Brand_Key
		inner join DW.UL_MEDIA_IN_PBRT_SPENDS c
		on b.Primary_Brand_Key=c.Primary_Brand_Key
		--and b.Market=a.Market
		--and a.Year=b.Year
		--and a.Month=b.Month
		--and a.IB_Type=b.IB_TYPE
		
		-- where b.Primary_Brand_Key like '%Boost%'
		--and b.Month='Sep' and b.Year='2021'
		
		
		group by b.Primary_Brand_Key,b.Market, b.Year, b.Month, c.Category,  Sub_Category, A.Segment , Sub_Segment, Big_C, Small_C,a.Primary_Brand,
		b.IB_Type, --Period_Type, Geography_Type, 
		c.LSM,
		TV_spends, Print_Spends, Radio_Spends, Cinema_Spends, Mobile_Spends, Youtube_Spends, Static_Rural_Spends, OTT_Spends,  Facebook_Spends, OOH_Spends,  Others_Spends, 
		 Digital_Spends, Total_Spends,NTV_Spends,Fatman_Spends

		
		 --select * from #spend_v4
		  --where Primary_Brand ='CornettoIce Cream'
		 --order by Primary_Brand, Market
		 
		 --select count(*) from #spend_v4 
		 
		 /*
		 select * from #spend_v4
		  select * from #spend_v4
		 where Primary_Brand_Key like '%Boost%'
and Month='Sep' and Year='2021'
and Market='India'
order by Primary_Brand_Key, Month, Year,Market

	  */
		   
		     /*
select * from #spend_v4
where Primary_Brand_Key like 'Food & Refreshment|Nutrition|MFD|Total-Boost|Kids|Boost||'
and Month='Sep' and Year='2021'
order by Market
*/

		 IF OBJECT_ID('tempDB..#Spend_Output') IS NOT NULL
BEGIN
DROP TABLE #Spend_Output
END

		SELECT [Primary_Brand_Key],
	   [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,[IB_Type]
      ,[Period_Type]
      ,[Geography_Type]
      ,[Target_Group]
	  --,[ACD] as ACD
      ,'TV_Spends' as Spends_Type
      ,[TV_Spends] as Value

	  into #Spend_Output
	  
  FROM #spend_v4

  --select * from #Spend_Output
    
  UNION 

  SELECT [Primary_Brand_Key],
	   [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,[IB_Type]
      ,[Period_Type]
      ,[Geography_Type]
      ,[Target_Group]
	  --,[ACD] as ACD
      ,'Print_Spends' as Spends_Type
      ,[Print_Spends] as Value
  FROM #spend_v4
  
  UNION

  SELECT [Primary_Brand_Key],
	   [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,[IB_Type]
      ,[Period_Type]
      ,[Geography_Type]
      ,[Target_Group]
	  --,[ACD] as ACD,
	  ,'Radio_Spends' as Spends_Type
      ,[Radio_Spends] as Value
  FROM #spend_v4

  
  UNION

  SELECT [Primary_Brand_Key],
	   [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,[IB_Type]
      ,[Period_Type]
      ,[Geography_Type]
      ,[Target_Group]
	  --,[ACD] as ACD,
	  ,'Cinema_Spends' as Spends_Type
      ,[Cinema_Spends] as Value
  FROM #spend_v4
   
  UNION

  SELECT [Primary_Brand_Key],
	   [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,[IB_Type]
      ,[Period_Type]
      ,[Geography_Type]
      ,[Target_Group]
	  --,[ACD] as ACD,
	  ,'Mobile_Spends' as Spends_Type
      ,[Mobile_Spends] as Value
  FROM #spend_v4
     
  UNION

  SELECT [Primary_Brand_Key],
	   [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,[IB_Type]
      ,[Period_Type]
      ,[Geography_Type]
      ,[Target_Group]
	  --,[ACD] as ACD,
	  ,'Youtube_Spends' as Spends_Type
      ,[Youtube_Spends] as Value
  FROM #spend_v4
     
  UNION

  SELECT [Primary_Brand_Key],
	   [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,[IB_Type]
      ,[Period_Type]
      ,[Geography_Type]
      ,[Target_Group]
	  --,[ACD] as ACD,
	  ,'OTT_Spends' as Spends_Type
      ,[OTT_Spends] as Value
  FROM #spend_v4
     
  UNION

  SELECT [Primary_Brand_Key],
	   [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,[IB_Type]
      ,[Period_Type]
      ,[Geography_Type]
      ,[Target_Group]
	  --,[ACD] as ACD,
	  ,'Facebook_Spends' as Spends_Type
      ,[Facebook_Spends] as Value
  FROM #spend_v4
     
  UNION

  SELECT [Primary_Brand_Key],
	   [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,[IB_Type]
      ,[Period_Type]
      ,[Geography_Type]
      ,[Target_Group]
	 -- ,[ACD] as ACD,
	  ,'OOH_Spends' as Spends_Type
      ,[OOH_Spends] as Value
  FROM #spend_v4

  UNION

  SELECT [Primary_Brand_Key],
	   [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,[IB_Type]
      ,[Period_Type]
      ,[Geography_Type]
      ,[Target_Group]
	  --,[ACD] as ACD,
	  ,'Others_Spends' as Spends_Type
      ,[Others_Spends] as Spend
  FROM #spend_v4
  
  UNION

  SELECT [Primary_Brand_Key],
	   [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,[IB_Type]
      ,[Period_Type]
      ,[Geography_Type]
      ,[Target_Group]
	  --,[ACD] as ACD,
	  ,'Digital_Spends' as Spends_Type
      ,[Digital_Spends] as Value
  FROM #spend_v4

  UNION

  SELECT [Primary_Brand_Key],
	   [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,[IB_Type]
      ,[Period_Type]
      ,[Geography_Type]
      ,[Target_Group]
	  --,[ACD] as ACD,
	  ,'Total_Spends' as Spends_Type
      ,[Total_Spends] as Value
  FROM #spend_v4

    UNION

  SELECT [Primary_Brand_Key],
	   [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,[IB_Type]
      ,[Period_Type]
      ,[Geography_Type]
      ,[Target_Group]
	  --,[ACD] as ACD,
	  ,'NTV_Spends' as Spends_Type
      ,[NTV_Spends] as Value
  FROM #spend_v4

  UNION

  SELECT [Primary_Brand_Key],
	   [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,[IB_Type]
      ,[Period_Type]
      ,[Geography_Type]
      ,[Target_Group]
	  --,[ACD] as ACD,
	  ,'Fatman_Spends' as Spends_Type
      ,[Fatman_Spends] as Value
  FROM #spend_v4

  UNION

  SELECT [Primary_Brand_Key],
	   [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,[IB_Type]
      ,[Period_Type]
      ,[Geography_Type]
      ,[Target_Group]
	  --,[ACD] as ACD,
	  ,'STATIC RURAL_Spends' as Spends_Type
      ,[Static_Rural_Spends] as Value
  FROM #spend_v4

  /*
  select * 
  
  from DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
  where Primary_Brand='Elle 18Colour Cosmetics'
  order by Primary_Brand, Market */
  
  /*
  select * from #Spend_Output
		 where Primary_Brand_Key like '%Boost%'
and Month='Sep' and Year='2021'
and Market='India'
order by Primary_Brand_Key, Month, Year,Market
  */
  /*
  alter table DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
alter column Value nvarchar(255)

alter table DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
alter column ACD nvarchar(255)
*/
  
  IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT') IS NOT NULL 
TRUNCATE TABLE DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT 

insert into DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
([Primary_Brand_Key],
		[Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,IB_Type
      ,[Period_Type]
      ,Geography_Type
      ,[Target_Group]
	  --,[ACD] 
      ,[Spends_Type]
      ,[Value])

	  --select * from DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT

  SELECT [Primary_Brand_Key],
  [Primary_Brand]
      ,[Year]
      ,[Month]
      ,[Category]
      ,[Market]
      ,[Sub_Category]
      ,[Segment]
      ,[Sub_Segment]
      ,[Big_C]
      ,[Small_C]
      ,IsNULL(case IB_TYPE when 'CWBS' then 'FATMAN'  end,'') as IB_Type
      ,[Period_Type]

      ,CASE WHEN Market='AP / Telangana' THEN 'Cluster'
 WHEN Market='Assam / North East / Sikkim' THEN 'Cluster' 
 WHEN Market='Bihar/Jharkhand' THEN 'Cluster'
 WHEN Market='Digital Market Cluster' THEN 'Club Market'
 WHEN Market='Guj / D&D / DNH' THEN 'Cluster'
 WHEN Market='Karnataka' THEN 'Cluster'
 WHEN Market='Kerala' THEN 'Cluster'
 WHEN Market='Mah / Goa' THEN 'Cluster'
 WHEN Market='MP/Chhattisgarh' THEN 'Cluster'
 WHEN Market='Odisha' THEN 'Cluster'
 WHEN Market='Pun / Har / Cha / HP / J&K' THEN 'Cluster'
 WHEN Market='Rajasthan' THEN 'Cluster' 
 WHEN Market='TN/Pondicherry' THEN 'Cluster'
 WHEN Market='UP/Uttarakhand' THEN 'Cluster' 
 WHEN Market='West Bengal' THEN 'Cluster'
 WHEN Market='Delhi' THEN 'Cluster'
 WHEN Market='Bangalore' THEN 'Metro'
 WHEN Market='Chennai' THEN 'Metro' 
 WHEN Market='Hyderabad' THEN 'Metro'
 WHEN Market='Kolkata' THEN 'Metro'
 WHEN Market='Mumbai' THEN 'Metro'
 WHEN Market='India' THEN 'India' END as Geography_Type

      ,[Target_Group]
	  --,[ACD] 
      ,[Spends_Type]
      ,TRY_CAST([Value] as NVARCHAR) as Value

	   --into DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT

  FROM #Spend_Output


--select * from #Spend_Output where IB_Type is not null

  /*
  select * from DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
  where Market ='India'
  and Year=2021 and Month='Sep'
  and Primary_Brand like '%Beauty & Personal Care|Skin Care|Face Care|Face Cleansing|Face Cleansing|Pond%'
  */
--   update b
--   set b.ACD = TRY_CAST(ISNULL(a.ACD,'') as NVARCHAR)
--   from DW.UL_MEDIA_IN_PBRT_ACD_OUTPUT a
--   inner join DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT b
--   on a.Primary_Brand_Key=b.Primary_Brand_Key
--   and a.Market=b.Market
--   and a.Month=b.Month
--   and a.Year=b.Year
--   where b.Market is NOT NULL
-- 		and b.Geography_Type is NOT NULL


		update  DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
		set Value=NULL
		where IB_Type='FATMAN'
		and Spends_Type='TV_Spends'

	delete  from DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
	where Spends_Type NOT in ('Fatman_Spends')
	and IB_Type='Fatman'
	
	delete  from DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
	where Spends_Type = 'Fatman_Spends'
	and Value is NULL

-- 	update  DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
-- 	Set ACD = ISNull(ACD,0)

--   update  DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
-- 	Set ACD = ISNull(0,'')

	--set ACD=Try_CAST(ISNull(ACD,'') as VARCHAR)

	update  DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
	set Value=ISNull(Value,'')


	
IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand') IS NOT NULL
BEGIN
DROP TABLE DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand
END

select 
a.primary_brand_key as primary_brand_key,
b.month as month,
c.year as year,
d.market as market
-- ,
-- e.medium as medium
--distinct (primary_brand_key,LSM,Market )
into DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand
from (select distinct primary_brand_key from DW.UL_MEDIA_IN_PBRT_SPENDS)a
inner join (select distinct month from DW.UL_MEDIA_IN_PBRT_SPENDS) b
on 1 = 1
inner join (select distinct year from DW.UL_MEDIA_IN_PBRT_SPENDS) c
on 1 = 1
inner join (select distinct market from DW.UL_MEDIA_IN_PBRT_SPENDS) d
on 1 = 1
-- inner join (select distinct Medium from DW.UL_MEDIA_IN_PBRT_SPENDS) e
-- on 1 = 1


IF OBJECT_ID('DW.ALL_Spends_Type') IS NOT NULL
BEGIN
DROP TABLE DW.ALL_Spends_Type
END

SELECT 
[Primary_Brand_Key]
,[Year]
,[Month]
,[Market]
,'TV_Spends' as Spends_Type

into DW.ALL_Spends_Type

FROM DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand


UNION 

SELECT 
[Primary_Brand_Key]
,[Year]
,[Month]
,[Market]
,'Print_Spends' as Spends_Type
FROM DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand

UNION

SELECT 
[Primary_Brand_Key]
,[Year]
,[Month]
,[Market]
,'Radio_Spends' as Spends_Type
FROM DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand


UNION

SELECT 
[Primary_Brand_Key]
,[Year]
,[Month]
,[Market]
,'Cinema_Spends' as Spends_Type
FROM DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand

UNION

SELECT 
[Primary_Brand_Key]
,[Year]
,[Month]
,[Market]
,'Mobile_Spends' as Spends_Type
FROM DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand

UNION

SELECT 
[Primary_Brand_Key]
,[Year]
,[Month]
,[Market]
,'Youtube_Spends' as Spends_Type
FROM DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand

UNION

SELECT 
[Primary_Brand_Key]
,[Year]
,[Month]
,[Market]
,'OTT_Spends' as Spends_Type
FROM DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand

UNION

SELECT 
[Primary_Brand_Key]
,[Year]
,[Month]
,[Market]
,'Facebook_Spends' as Spends_Type
FROM DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand

UNION

SELECT 
[Primary_Brand_Key]
,[Year]
,[Month]
,[Market]
,'OOH_Spends' as Spends_Type
FROM DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand

UNION

SELECT 
[Primary_Brand_Key]
,[Year]
,[Month]
,[Market]
,'Others_Spends' as Spends_Type
FROM DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand

UNION

SELECT 
[Primary_Brand_Key]
,[Year]
,[Month]
,[Market]
,'Digital_Spends' as Spends_Type
FROM DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand

UNION

SELECT 
[Primary_Brand_Key]
,[Year]
,[Month]
,[Market]
,'Total_Spends' as Spends_Type
FROM DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand

UNION

SELECT 
[Primary_Brand_Key]
,[Year]
,[Month]
,[Market]
,'NTV_Spends' as Spends_Type
FROM DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand

UNION

SELECT 
[Primary_Brand_Key]
,[Year]
,[Month]
,[Market]
,'Fatman_Spends' as Spends_Type
FROM DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand

UNION

SELECT 
[Primary_Brand_Key]
,[Year]
,[Month]
,[Market]
,'STATIC RURAL_Spends' as Spends_Type
FROM DW.UL_MEDIA_IN_PBRT_Spends_month_year_brand



IF OBJECT_ID('DW.Extra_Spends_Markets') IS NOT NULL
BEGIN
DROP TABLE DW.Extra_Spends_Markets
END

select primary_brand_key, month, year, market, Spends_Type 
into DW.Extra_Spends_Markets
from DW.ALL_Spends_Type
except 
select primary_brand_key, month, year, market, Spends_Type 
from DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
------------------------------------------------------------


IF OBJECT_ID('DW.Extra_Spends_Markets1') IS NOT NULL
BEGIN
DROP TABLE DW.Extra_Spends_Markets1
END


select 
a.primary_brand_key as primary_brand_key,
b.Primary_Brand as Primary_Brand,
a.year as year,
a.month as month,
c.Category as Category,
a.market as market,
b.Sub_Category,
b.Segment as Segment,
b.Sub_Segment as Sub_Segment, 
b.Big_C as Big_C, 
b.Small_C as Small_C,
null as IB_Type,
concat(a.Month,' ',a.Year) as Period_Type,
CASE WHEN A.Market='AP / Telangana' THEN 'Cluster'
 WHEN A.Market='Assam / North East / Sikkim' THEN 'Cluster' 
 WHEN A.Market='Bihar/Jharkhand' THEN 'Cluster'
 WHEN A.Market='Digital Market Cluster' THEN 'Club Market'
 WHEN A.Market='Guj / D&D / DNH' THEN 'Cluster'
 WHEN A.Market='Karnataka' THEN 'Cluster'
 WHEN A.Market='Kerala' THEN 'Cluster'
 WHEN A.Market='Mah / Goa' THEN 'Cluster'
 WHEN A.Market='MP/Chhattisgarh' THEN 'Cluster'
 WHEN A.Market='Odisha' THEN 'Cluster'
 WHEN A.Market='Pun / Har / Cha / HP / J&K' THEN 'Cluster'
 WHEN A.Market='Rajasthan' THEN 'Cluster' 
 WHEN A.Market='TN/Pondicherry' THEN 'Cluster'
 WHEN A.Market='UP/Uttarakhand' THEN 'Cluster' 
 WHEN A.Market='West Bengal' THEN 'Cluster'
 WHEN A.Market='Delhi' THEN 'Cluster'
 WHEN A.Market='Bangalore' THEN 'Metro'
 WHEN A.Market='Chennai' THEN 'Metro' 
 WHEN A.Market='Hyderabad' THEN 'Metro'
 WHEN A.Market='Kolkata' THEN 'Metro'
 WHEN A.Market='Mumbai' THEN 'Metro'
 WHEN A.Market='India' THEN 'India' END as Geography_Type,
 '' as Target_Group,
 0  as ACD,
 '' as LSM,
a.Spends_Type,
 0 as value
into DW. Extra_Spends_Markets1
from DW.Extra_Spends_Markets a 
left join DW.UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER b (NOLOCK)
on a.Primary_Brand_Key = b.PBRT_KEY
left join (select distinct primary_brand_key, Category, Segment from DW.UL_MEDIA_IN_PBRT_SPENDS) c 
on a.Primary_Brand_Key = c.primary_brand_key




INSERT INTO DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
select
Primary_Brand_Key, Primary_Brand, Year ,Month, Category, Market, Sub_Category,	
Segment, Sub_Segment,Big_C, Small_C, IB_Type, Period_Type, Geography_Type, Target_Group, ACD,
Spends_Type, Value from DW. Extra_Spends_Markets1


  update b
  set b.ACD = TRY_CAST(ISNULL(a.ACD,0) as NVARCHAR)
  from DW.UL_MEDIA_IN_PBRT_ACD_OUTPUT a
  inner join DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT b
  on a.Primary_Brand_Key=b.Primary_Brand_Key
  and a.Market=b.Market
  and a.Month=b.Month
  and a.Year=b.Year
  where b.Market is NOT NULL
		and b.Geography_Type is NOT NULL

	update  DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
	Set ACD = ISNull(ACD,0)

--   update  DW.UL_MEDIA_IN_PBRT_SPENDS_OUTPUT
-- 	Set ACD = ISNull('',0)

