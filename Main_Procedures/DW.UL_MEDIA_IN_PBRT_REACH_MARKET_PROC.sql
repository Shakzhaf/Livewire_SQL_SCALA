SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_REACH_MARKET_PROC') IS NOT NULL
DROP PROCEDURE DW.UL_MEDIA_IN_PBRT_REACH_MARKET_PROC
GO

CREATE PROC DW.UL_MEDIA_IN_PBRT_REACH_MARKET_PROC AS



IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_TG_MAPPING') IS NOT NULL
BEGIN
DROP TABLE DW.UL_MEDIA_IN_PBRT_TG_MAPPING
END

select distinct Primary_Brand_Key as Primary_Key,
CASE
    WHEN Primary_Brand_Key in ('Beauty & Personal Care|Skin Care|Face Care|||Glow & Handsome||',
	'Beauty & Personal Care|Deodrants|Deodrants|Deodrants|Deodrants|Rexona||',
	'Beauty & Personal Care|Deodrants|Deodrants|Deodrants|Deodrants|Axe||') THEN 'Male'
	ELSE 'Female'
END AS TG
into DW.UL_MEDIA_IN_PBRT_TG_MAPPING
from DW.UL_MEDIA_IN_PBRT_REACH



IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_REACH_MARKET') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_REACH_MARKET
END  

select a.Primary_Brand_key,a.year, a.month, a.Category, a.Segment, isnull(c.Market,a.Market) as Market, a.LSM, isnull(c.IRS_HHs,0) as HHs, isnull(c.IRS_TV_Pen,0) as TV_pen,
b.TG,
sum(case when Medium in ('TV') then Reach else 0 end) as BARC_Reach,  
sum(case when Medium in ('Print') then Reach else 0 end) as Print_Reach,  
sum(case when Medium in ('Radio') then Reach else 0 end) as Radio_Reach,  
sum(case when Medium in ('Cinema') then Reach else 0 end) as Cinema_Reach,  
sum(case when Medium in ('Mobile') then Reach else 0 end) as Mobile_Reach,  
sum(case when Medium in ('YT') then Reach else 0 end) as YouTube_Reach,  
sum(case when Medium in ('OTT') then Reach else 0 end) as OTT_Reach,  
sum(case when Medium in ('FB') then Reach else 0 end) as Facebook_Reach,  
sum(case when Medium in ('OOH') then Reach else 0 end) as OOH_Reach,     
sum(case when Medium in ('STATIC RURAL') then Reach else 0 end)  as STATIC_RURAL,
(1-((1- sum(case when Medium in ('YT') then Reach else 0 end))
*(1- sum(case when Medium in ('OTT') then Reach else 0 end))
*(1- sum(case when Medium in ('FB') then Reach else 0 end))
)) as Digital_Reach_,
(1-
(1- sum(case when Medium in ('YT') then Reach else 0 end))*
(1- sum(case when Medium in ('OTT') then Reach else 0 end))*
(1- sum(case when Medium in ('FB') then Reach else 0 end))) *
isnull((case when a.market = 'Digital Market Cluster' then d.IRS_HHs else c.IRS_HHs end),0) 
as Digital_Reach_In_Mn,
1-((1- sum(case when Medium in ('Print') then Reach else 0 end))
*(1- sum(case when Medium in ('Radio') then Reach else 0 end))
*(1- sum(case when Medium in ('Cinema') then Reach else 0 end))
*(1- sum(case when Medium in ('Mobile') then Reach else 0 end))
*(1- sum(case when Medium in ('OOH') then Reach else 0 end))
) as NTV_Reach_,
(1-((1- sum(case when Medium in ('Print') then Reach else 0 end))
*(1- sum(case when Medium in ('Radio') then Reach else 0 end))
*(1- sum(case when Medium in ('Cinema') then Reach else 0 end))
*(1- sum(case when Medium in ('Mobile') then Reach else 0 end))
*(1- sum(case when Medium in ('OOH') then Reach else 0 end))
)) * isnull(c.IRS_HHs,0) as NTV_Reach_In_Mn,
--sum(case when Medium in ('Cinema', 'Mobile', 'Radio', 'Print', 'OOH') then Reach else 0 end) as NTV_Reach_,
(sum(case when Medium in ('Print') then Reach else 0 end) * isnull(c.IRS_HHs,0))  as Print_Reach_In_Mn,
(sum(case when Medium in ('Radio') then Reach else 0 end) * isnull(c.IRS_HHs,0))  as Radio_Reach_In_Mn,  
(sum(case when Medium in ('Cinema') then Reach else 0 end) * isnull(c.IRS_HHs,0))  as Cinema_Reach_In_Mn,  
(sum(case when Medium in ('Mobile') then Reach else 0 end) * isnull(c.IRS_HHs,0))  as Mobile_Reach_In_Mn,  
(sum(case when Medium in ('YT') then Reach else 0 end) * isnull(case when a.market = 'Digital Market Cluster' then d.IRS_HHs else c.IRS_HHs end,0))  as YouTube_Reach_In_Mn,  
(sum(case when Medium in ('OTT') then Reach else 0 end) * isnull(case when a.market = 'Digital Market Cluster' then d.IRS_HHs else c.IRS_HHs end,0))  as OTT_Reach_In_Mn, 
(sum(case when Medium in ('FB') then Reach else 0 end) * isnull(case when a.market = 'Digital Market Cluster' then d.IRS_HHs else c.IRS_HHs end,0))  as Facebook_Reach_In_Mn,  
(sum(case when Medium in ('OOH') then Reach else 0 end) * isnull(c.IRS_HHs,0))  as OOH_Reach_In_Mn,     
(sum(case when Medium in ('STATIC RURAL') then Reach else 0 end) * isnull(c.IRS_HHs,0))  as STATIC_RURAL_In_Mn,
(((sum(case when Medium in ('TV') then Reach else 0 end) * isnull(c.IRS_TV_Pen,0)) / 10000) * isnull(c.IRS_HHs,0)) as IRS_Reach_In_Mn,
(((sum(case when Medium in ('TV') then Reach else 0 end) * isnull(c.IRS_TV_Pen,0)) / 10000)) as IRS_Reach,
1-(
(1- (sum(case when Medium in ('TV') then Reach else 0 end) * isnull(c.IRS_TV_Pen,0)/10000))
*(1- sum(case when Medium in ('Print') then Reach else 0 end))
*(1- sum(case when Medium in ('Radio') then Reach else 0 end))
*(1- sum(case when Medium in ('Cinema') then Reach else 0 end))
*(1- sum(case when Medium in ('Mobile') then Reach else 0 end))
*(1- sum(case when Medium in ('YT') then Reach else 0 end))
*(1- sum(case when Medium in ('OTT') then Reach else 0 end))
*(1- sum(case when Medium in ('FB') then Reach else 0 end))
*(1- sum(case when Medium in ('OOH') then Reach else 0 end))
*(1-(sum(case when Medium in ('STATIC RURAL') then Reach else 0 end))
)) as All_Media_Reach,
(1-(1- (((sum(case when Medium in ('TV') then Reach else 0 end) * isnull(c.IRS_TV_Pen,0)) / 10000)))*
(1- sum(case when Medium in ('Print') then Reach else 0 end))*
(1- sum(case when Medium in ('Radio') then Reach else 0 end))*
(1- sum(case when Medium in ('Cinema') then Reach else 0 end))*
(1- sum(case when Medium in ('Mobile') then Reach else 0 end))*
(1- sum(case when Medium in ('YT') then Reach else 0 end))*
(1- sum(case when Medium in ('OTT') then Reach else 0 end))*
(1- sum(case when Medium in ('FB') then Reach else 0 end))*
(1- sum(case when Medium in ('OOH') then Reach else 0 end))*
(1-sum(case when Medium in ('STATIC RURAL') then Reach else 0 end))) * 
isnull(case when a.market = 'Digital Market Cluster' then d.IRS_HHs else c.IRS_HHs end,0) as All_Media_Reach_In_Mn
into DW.UL_MEDIA_IN_PBRT_REACH_MARKET
from (select category, segment, primary_brand_key,month, year,market, TG, LSM, sum(Reach) as Reach, Medium from DW.UL_MEDIA_IN_PBRT_REACH
group by category, segment, primary_brand_key,month, year,market, TG, LSM, Medium) a
inner join DW.UL_MEDIA_IN_PBRT_TG_MAPPING b
on b.Primary_Key = a.Primary_brand_key
left join DW.UL_MEDIA_IN_PBRT_IRS_HHS_MASTER c
on a.LSM = c.LSM and a.Market = c.Market and b.TG=c.TG
left join (select TG,LSM,IRS_TV_PEN ,IRS_HHs  from DW.UL_MEDIA_IN_PBRT_IRS_HHS_MASTER where market  = 'INDIA' group by TG, LSM, IRS_TV_PEN ,IRS_HHs) d
on  a.LSM = d.LSM and b.TG=d.TG
--where  a.year= 2022 and a.month = 'Dec' and a.LSM = 'INDIA 1' and
--a.primary_brand_key = 'Home Care|Laundry|Laundry (Det Bars + Washing Powder/Liquid)|Detergent Bars|Detergent Bars|Rin||'
group by a.Primary_Brand_key,a.year, a.month, a.Category, a.Segment, a.Market, a.LSM, c.LSM , c.TG, c.Market,a.TG,
c.IRS_HHs, c.IRS_TV_Pen, d.IRS_HHs, d.IRS_TV_Pen,b.TG
--drop table DW.TEST_TABLE
--------------------------------



insert into Dw.UL_MEDIA_IN_PBRT_IRS_HHS_MASTER values 
('Female','INDIA 1','Digital Market Cluster', 0.00000 ,0.00)

insert into Dw.UL_MEDIA_IN_PBRT_IRS_HHS_MASTER values 
('Female','INDIA 2','Digital Market Cluster', 0.00000 ,0.00)

insert into Dw.UL_MEDIA_IN_PBRT_IRS_HHS_MASTER values 
('Female','INDIA 3','Digital Market Cluster', 0.00000 ,0.00)

insert into Dw.UL_MEDIA_IN_PBRT_IRS_HHS_MASTER values 
('Male','INDIA 1','Digital Market Cluster', 0.00000 ,0.00)

insert into Dw.UL_MEDIA_IN_PBRT_IRS_HHS_MASTER values 
('Male','INDIA 2','Digital Market Cluster', 0.00000 ,0.00)

insert into Dw.UL_MEDIA_IN_PBRT_IRS_HHS_MASTER values 
('Male','INDIA 3','Digital Market Cluster', 0.00000 ,0.00)



IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_REACH_month_year_brand') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_REACH_month_year_brand
END  

select 
a.Primary_Key as primary_brand_key,
a.TG,
b.LSM,
b.Market,
b.IRS_TV_Pen,
b.IRS_HHs,
c.[month],
d.[year]
--distinct (primary_brand_key,LSM,Market )
into DW.UL_MEDIA_IN_PBRT_REACH_month_year_brand
from (select * from DW.UL_MEDIA_IN_PBRT_TG_MAPPING)a
inner join (select *  from  DW.UL_MEDIA_IN_PBRT_IRS_HHS_MASTER)b
on a.TG = b.TG
inner join (select distinct month from DW.UL_MEDIA_IN_PBRT_REACH) c
on 1 = 1
inner join (select distinct year from DW.UL_MEDIA_IN_PBRT_REACH) d
on 1 = 1
--left JOIN (select * from DW.UL_MEDIA_IN_PBRT_REACH) e




IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_REACH_ALL_COMBINATION') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_REACH_ALL_COMBINATION
END  

select  distinct
a.primary_brand_key,
a.TG,
a.LSM,
coalesce(a.Market,b.Market)  as Market,
a.IRS_TV_Pen,
a.IRS_HHs,
a.[month],
a.[year]
into DW.UL_MEDIA_IN_PBRT_REACH_ALL_COMBINATION
--drop table  DW.UL_MEDIA_IN_PBRT_REACH_ALL_COMBINATION
from DW.UL_MEDIA_IN_PBRT_REACH_month_year_brand a
left JOIN (select * from DW.UL_MEDIA_IN_PBRT_REACH) b
on 
a.primary_brand_key = b.primary_brand_key and a.Market  = b.Market and a.LSM  = b.LSM  
and a.month = b.month and a.year = b.year





IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_REACH_EXTRA_MARKET') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_REACH_EXTRA_MARKET
END  

select a.primary_brand_key,a.year,a.month, 
c.Category as Category, c.Segment as Segment, 
a.Market, a.LSM, 
b.IRS_HHs, b.IRS_TV_Pen, b.TG, 0.000000 as BARC_Reach, 0.000000 as Print_Reach, 0.000000 as Radio_Reach, 0.000000 as Cinema_Reach, 
0.000000 as Mobile_Reach, 0.000000 as YouTube_Reach, 0.000000 as OTT_Reach, 0.000000 as Facebook_Reach, 0.000000 as OOH_Reach, 0.000000 as STATIC_RURAL, 
0.000000 as Digital_Reach_, 0.000000 as Digital_Reach_In_Mn, 0.000000 as NTV_Reach_, 0.000000 as NTV_Reach_In_Mn, 0.000000 as Print_Reach_In_Mn, 
0.000000 as Radio_Reach_In_Mn, 0.000000 as Cinema_Reach_In_Mn, 0.000000 as Mobile_Reach_In_Mn, 0.000000 as YouTube_Reach_In_Mn, 
0.000000 as OTT_Reach_In_Mn, 0.000000 as Facebook_Reach_In_Mn, 0.000000 as OOH_Reach_In_Mn, 0.000000 as STATIC_RURAL_In_Mn, 0.000000 as IRS_Reach_In_Mn, 
0.000000 as IRS_Reach, 0.000000 as All_Media_Reach, 0.000000 as All_Media_Reach_In_Mn  
into DW.UL_MEDIA_IN_PBRT_REACH_EXTRA_MARKET
from (select primary_brand_key,Market,month,year, lsm from DW.UL_MEDIA_IN_PBRT_REACH_ALL_COMBINATION where Market != 'India' group by  primary_brand_key,Market,month,year,lsm
EXCEPT
select primary_brand_key,Market,month,year,lsm from DW.UL_MEDIA_IN_PBRT_REACH_MARKET group by primary_brand_key,Market,month,year,lsm) a
inner join DW.UL_MEDIA_IN_PBRT_REACH_ALL_COMBINATION b
on a.primary_brand_key = b.primary_brand_key and a.Market = b.Market and a.lsm=b.lsm and a.month = b.month and a.year = b.year
inner join
(select distinct Primary_Brand_Key,Category, Segment from DW.UL_MEDIA_IN_PBRT_REACH) c
on 
-- a.Category = b.Small_C and 
a.Primary_Brand_Key = c.Primary_Brand_Key 

insert into DW.UL_MEDIA_IN_PBRT_REACH_MARKET select * from DW.UL_MEDIA_IN_PBRT_REACH_EXTRA_MARKET

delete from Dw.UL_MEDIA_IN_PBRT_IRS_HHS_MASTER where Market  = 'Digital Market Cluster'
--------------------------------------




IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_REACH_INDIA') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_REACH_INDIA
END  


select a.Primary_Brand_key,a.year, a.month, a.Category, a.Segment, 'India' as Market, a.LSM, IRS_HHs, IRS_TV_Pen,
(sum(a.IRS_Reach_In_Mn)/IRS_HHs) as IRS_Reach,
((case when b.Facebook_Reach_In_Mn <> 0 then b.Facebook_Reach_In_Mn else sum(a.Facebook_Reach_In_Mn) end)/IRS_HHs) as Facebook_Reach,
((case when b.YouTube_Reach_In_Mn <> 0 then b.YouTube_Reach_In_Mn else sum(a.YouTube_Reach_In_Mn) end)/IRS_HHs) as YouTube_Reach,
(sum(a.Radio_Reach_In_Mn)/IRS_HHs) as Radio_Reach,
(sum(a.Cinema_Reach_In_Mn)/IRS_HHs) as Cinema_Reach,
(sum(a.Mobile_Reach_In_Mn)/IRS_HHs) as Mobile_Reach,
(sum(a.OOH_Reach_In_Mn)/IRS_HHs) as OOH_Reach,
sum(a.STATIC_RURAL_In_Mn)/IRS_HHs as STATIC_RURAL,
((case when b.OTT_Reach_In_Mn <> 0 then b.OTT_Reach_In_Mn else sum(a.OTT_Reach_In_Mn) end)/IRS_HHs) as OTT_Reach,
(sum(a.Print_Reach_In_Mn)/IRS_HHs) as Print_Reach,
(sum(a.NTV_Reach_In_Mn)/IRS_HHs) as NTV_Reach_,
case when b.Facebook_Reach_In_Mn <> 0 then b.Facebook_Reach_In_Mn else sum(a.Facebook_Reach_In_Mn) end Facebook_Reach_In_Mn,
case when b.YouTube_Reach_In_Mn <> 0 then b.YouTube_Reach_In_Mn else sum(a.YouTube_Reach_In_Mn) end YouTube_Reach_In_Mn,
case when b.OTT_Reach_In_Mn <> 0 then b.OTT_Reach_In_Mn else sum(a.OTT_Reach_In_Mn) end OTT_Reach_In_Mn,
((sum(a.IRS_Reach_In_Mn)/IRS_HHs) / IRS_TV_Pen)*10000 as Barc_Reach,
(1- ((1 -sum(a.All_Media_Reach_In_Mn)/IRS_HHs)* (1 - b.Facebook_Reach) * (1 - b.Youtube_Reach) * (1 - b.OTT_Reach))) as All_Media_Reach,
(1- ((1 -sum(a.Digital_Reach_In_Mn)/IRS_HHs)* (1 - b.Facebook_Reach) * (1 - b.Youtube_Reach) * (1 - b.OTT_Reach))) as Digital_Reach_,
(1- ((1 -sum(a.All_Media_Reach_In_Mn)/IRS_HHs)* (1 - b.Facebook_Reach) * (1 - b.Youtube_Reach) * (1 - b.OTT_Reach))) * IRS_HHs as All_Media_Reach_In_Mn,
(1- ((1 -sum(a.Digital_Reach_In_Mn)/IRS_HHs)* (1 - b.Facebook_Reach) * (1 - b.Youtube_Reach) * (1 - b.OTT_Reach))) * IRS_HHs as Digital_Reach_In_Mn,
--1-((1-(a.Digital_Reach_In_Mn/IRS_HHs))*(1-)*(1-S11)*(1-T11))
sum(a.IRS_Reach_In_Mn) as IRS_Reach_In_Mn, sum(a.Print_Reach_In_Mn) as Print_Reach_In_Mn,
sum(a.Radio_Reach_In_Mn) as Radio_Reach_In_Mn, sum(a.Cinema_Reach_In_Mn) as Cinema_Reach_In_Mn,
sum(a.Mobile_Reach_In_Mn) as Mobile_Reach_In_Mn, sum(a.OOH_Reach_In_Mn) as OOH_Reach_In_Mn, sum(a.STATIC_RURAL_In_Mn) as STATIC_RURAL_In_Mn,
sum(a.NTV_Reach_In_Mn) as NTV_Reach_In_Mn
--sum(a.Digital_Reach_In_Mn) as Digital_Reach_In_Mn,

into DW.UL_MEDIA_IN_PBRT_REACH_INDIA
from (select * from DW.UL_MEDIA_IN_PBRT_REACH_MARKET a
where market not in ('Bangalore','Chennai','Hyderabad','Kolkata','Mumbai','India', 'Digital Market Cluster'))a
left join (select * from DW.UL_MEDIA_IN_PBRT_REACH_MARKET where market = 'Digital Market Cluster')b
on a.Primary_Brand_key = b.Primary_Brand_key and a.year = b.year and a.month = b.month
and isnull(a.Category,'NA')= isnull(b.Category,'NA') and isnull(a.Segment,'NA')= isnull(b.Segment,'NA')
and isnull(a.LSM,'NA')= isnull(b.LSM,'NA')
left join (select * from DW.UL_MEDIA_IN_PBRT_IRS_HHS_MASTER where market = 'India') c
on a.LSM = c.LSM and a.TG=c.TG
--where a.year= 2022 and a.month = 'Jan' and
--a.primary_brand_key = 'Beauty & Personal Care|Hair Care|Hair Care (excl Hair Oil)|Wash & Care|Hair Conditioners|Dove||'
--and a.LSM = 'INDIA 3'
group by a.Primary_Brand_key,a .year, a.month, a.Category, a.Segment, a.LSM, b.Facebook_Reach_In_Mn, b.OTT_Reach_In_Mn, b.YouTube_Reach_In_Mn,
IRS_HHs, IRS_TV_Pen, b.Facebook_Reach, b.YouTube_Reach, b.OTT_Reach
-----------------------------------------




IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_REACH_ALL_LSM') IS NOT NULL
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_REACH_ALL_LSM
END  
select a.Primary_Brand_key,a .year, a.month, a.Category, a.Segment, a.Market,a.TG, 'All LSM' as LSM, 0 as IRS_TV_Pen, isnull(b.IRS_HHs,0) as IRS_HHs, 0 as BARC_Reach,
(isnull(sum(IRS_Reach_In_Mn) /b.IRS_HHs,0)) as IRs_Reach,
case when a.Market = 'Digital Market Cluster'  then (isnull(sum(Facebook_Reach_In_Mn) /c.IRS_HHs,0)) 
else (isnull(sum(Facebook_Reach_In_Mn) /b.IRS_HHs,0)) end as Facebook_Reach,
case when a.Market = 'Digital Market Cluster'  then (isnull(sum(YouTube_Reach_In_Mn) /c.IRS_HHs,0)) 
else (isnull(sum(YouTube_Reach_In_Mn) /b.IRS_HHs,0)) end as YouTube_Reach,
case when a.Market = 'Digital Market Cluster'  then (isnull(sum(OTT_Reach_In_Mn) /c.IRS_HHs,0)) 
else (isnull(sum(OTT_Reach_In_Mn) /b.IRS_HHs,0)) end as OTT_Reach,
case when a.Market = 'Digital Market Cluster'  then (isnull(sum(All_Media_Reach_In_Mn) /c.IRS_HHs,0)) 
else (isnull(sum(All_Media_Reach_In_Mn) /b.IRS_HHs,0)) end as All_Media_Reach,
case when a.Market = 'Digital Market Cluster'  then (isnull(sum(Digital_Reach_In_Mn) /c.IRS_HHs,0)) 
else (isnull(sum(Digital_Reach_In_Mn) /b.IRS_HHs,0)) end as Digital_Reach_,
case when a.Market = 'Digital Market Cluster'  then (isnull(sum(Print_Reach_In_Mn) /c.IRS_HHs,0)) 
else (isnull(sum(Print_Reach_In_Mn) /b.IRS_HHs,0)) end as Print_Reach,
case when a.Market = 'Digital Market Cluster'  then (isnull(sum(Cinema_Reach_In_Mn) /c.IRS_HHs,0)) 
else (isnull(sum(Cinema_Reach_In_Mn) /b.IRS_HHs,0)) end as Cinema_Reach,
case when a.Market = 'Digital Market Cluster'  then (isnull(sum(STATIC_RURAL_In_Mn) /c.IRS_HHs,0)) 
else (isnull(sum(STATIC_RURAL_In_Mn) /b.IRS_HHs,0)) end as STATIC_RURAL,
case when a.Market = 'Digital Market Cluster'  then (isnull(sum(NTV_Reach_In_Mn) /c.IRS_HHs,0)) 
else (isnull(sum(NTV_Reach_In_Mn) /b.IRS_HHs,0)) end as NTV_Reach_,
case when a.Market = 'Digital Market Cluster'  then (isnull(sum(OOH_Reach_In_Mn) /c.IRS_HHs,0)) 
else (isnull(sum(OOH_Reach_In_Mn) /b.IRS_HHs,0)) end as OOH_Reach,
case when a.Market = 'Digital Market Cluster'  then (isnull(sum(Mobile_Reach_In_Mn) /c.IRS_HHs,0)) 
else (isnull(sum(Mobile_Reach_In_Mn) /b.IRS_HHs,0)) end as Mobile_Reach,
case when a.Market = 'Digital Market Cluster'  then (isnull(sum(Radio_Reach_In_Mn) /c.IRS_HHs,0)) 
else (isnull(sum(Radio_Reach_In_Mn) /b.IRS_HHs,0)) end as Radio_Reach,

isnull(sum(IRS_Reach_In_Mn),0) as IRS_Reach_In_Mn, 
isnull(sum(Facebook_Reach_In_Mn),0) as Facebook_Reach_In_Mn, 
isnull(sum(YouTube_Reach_In_Mn),0) as YouTube_Reach_In_Mn,
isnull(sum(OTT_Reach_In_Mn),0) as OTT_Reach_In_Mn, 
isnull(sum(All_Media_Reach_In_Mn),0) as All_Media_Reach_In_Mn, 
isnull(sum(Digital_Reach_In_Mn),0) as Digital_Reach_In_Mn,
isnull(sum(Print_Reach_In_Mn),0) as Print_Reach_In_Mn, 
isnull(sum(Cinema_Reach_In_Mn),0) as Cinema_Reach_In_Mn, 
isnull(sum(STATIC_RURAL_In_Mn),0) as STATIC_RURAL_In_Mn, 
isnull(sum(NTV_Reach_In_Mn),0) as NTV_Reach_In_Mn, 
isnull(sum(OOH_Reach_In_Mn),0) as OOH_Reach_In_Mn,
isnull(sum(Mobile_Reach_In_Mn),0) as Mobile_Reach_In_Mn, 
isnull(sum(Radio_Reach_In_Mn),0) as Radio_Reach_In_Mn
into DW.UL_MEDIA_IN_PBRT_REACH_ALL_LSM
from DW.UL_MEDIA_IN_PBRT_REACH_MARKET a
left join (select TG, Market, sum(IRS_HHs) as IRS_HHs from DW.UL_MEDIA_IN_PBRT_IRS_HHS_MASTER 
group by TG, market) b on a.TG = b.TG and a.market = b.market
left join (select TG,sum(IRS_HHs) as IRS_HHs from DW.UL_MEDIA_IN_PBRT_IRS_HHS_MASTER where market  not in ('Bangalore','Chennai','Hyderabad','Kolkata','Mumbai','India', 'Digital Market Cluster')
group by TG) c
on a.TG=c.TG
 --where  a.year= 2022 and a.month = 'Jan' and
 --a.primary_brand_key = 'Beauty & Personal Care|Skin Care|Face Care|||Lakme Skin||'  
 --and a.Market = 'Digital Market Cluster'
group by a.Primary_Brand_key,a.year, a.month, a.Category, a.Segment, a.Market, b.IRS_HHs, a.TG, c.IRS_HHs
--------------------------------------------------




IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_REACH_ALL_INDIA') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_REACH_ALL_INDIA
END  
select a.Primary_Brand_key,a .year, a.month, a.Category, a.Segment, 'India' as Market, a.LSM, c.IRS_HHs, 0 as IRS_TV_Pen, c.TG,
(sum(a.IRS_Reach_In_Mn)/c.IRS_HHs) as IRS_Reach,
((case when b.Facebook_Reach_In_Mn <> 0 then b.Facebook_Reach_In_Mn else sum(a.Facebook_Reach_In_Mn) end)/c.IRS_HHs) as Facebook_Reach,
((case when b.YouTube_Reach_In_Mn <> 0 then b.YouTube_Reach_In_Mn else sum(a.YouTube_Reach_In_Mn) end)/c.IRS_HHs) as YouTube_Reach,
sum(a.Radio_Reach_In_Mn)/c.IRS_HHs as Radio_Reach,
sum(a.Cinema_Reach_In_Mn)/c.IRS_HHs as Cinema_Reach,
(sum(a.Mobile_Reach_In_Mn)/c.IRS_HHs) as Mobile_Reach,
(sum(a.OOH_Reach_In_Mn)/c.IRS_HHs) as OOH_Reach,
sum(a.STATIC_RURAL_In_Mn)/c.IRS_HHs as STATIC_RURAL,
((case when b.OTT_Reach_In_Mn <> 0 then b.OTT_Reach_In_Mn else sum(a.OTT_Reach_In_Mn) end)/c.IRS_HHs) as OTT_Reach,
(sum(a.Print_Reach_In_Mn)/c.IRS_HHs) as Print_Reach,
(sum(a.NTV_Reach_In_Mn)/c.IRS_HHs) as NTV_Reach_,
case when b.Facebook_Reach_In_Mn <> 0 then b.Facebook_Reach_In_Mn else sum(a.Facebook_Reach_In_Mn) end Facebook_Reach_In_Mn,
case when b.YouTube_Reach_In_Mn <> 0 then b.YouTube_Reach_In_Mn else sum(a.YouTube_Reach_In_Mn) end YouTube_Reach_In_Mn,
case when b.OTT_Reach_In_Mn <> 0 then b.OTT_Reach_In_Mn else sum(a.OTT_Reach_In_Mn) end OTT_Reach_In_Mn,
0 as Barc_Reach,
(d.All_Media_Reach_In_Mn/c.IRS_HHs) as All_Media_Reach, 
(d.Digital_Reach_In_Mn/c.IRS_HHs) as Digital_Reach_,
d.All_Media_Reach_In_Mn as All_Media_Reach_In_Mn, 
d.Digital_Reach_In_Mn as Digital_Reach_In_Mn,
--1-((1-(a.Digital_Reach_In_Mn/IRS_HHs))*(1-)*(1-S11)*(1-T11))
sum(a.IRS_Reach_In_Mn) as IRS_Reach_In_Mn, sum(a.Print_Reach_In_Mn)  as Print_Reach_In_Mn, 
sum(a.Radio_Reach_In_Mn) as Radio_Reach_In_Mn, sum(a.Cinema_Reach_In_Mn) as Cinema_Reach_In_Mn, 
sum(a.Mobile_Reach_In_Mn) as Mobile_Reach_In_Mn, sum(a.OOH_Reach_In_Mn) as OOH_Reach_In_Mn, sum(a.STATIC_RURAL_In_Mn) as STATIC_RURAL_In_Mn,
sum(a.NTV_Reach_In_Mn) as NTV_Reach_In_Mn
--sum(a.Digital_Reach_In_Mn) as Digital_Reach_In_Mn, 
--sum(a.All_Media_Reach_In_Mn) as All_Media_Reach_In_Mn

into DW.UL_MEDIA_IN_PBRT_REACH_ALL_INDIA
from (select * from DW.UL_MEDIA_IN_PBRT_REACH_ALL_LSM  a
where market not in ('Bangalore','Chennai','Hyderabad','Kolkata','Mumbai','India', 'Digital Market Cluster'))a
inner join (select * from DW.UL_MEDIA_IN_PBRT_REACH_ALL_LSM where market = 'Digital Market Cluster')b
on a.Primary_Brand_key = b.Primary_Brand_key and a.year = b.year and a.month = b.month 
and isnull(a.Category,'NA')= isnull(b.Category,'NA') and isnull(a.Segment,'NA')= isnull(b.Segment,'NA') 
left join (select TG,sum(IRS_HHs) as IRS_HHs from DW.UL_MEDIA_IN_PBRT_IRS_HHS_MASTER where market  not in ('Bangalore','Chennai','Hyderabad','Kolkata','Mumbai','India', 'Digital Market Cluster')
group by TG) c
on a.TG=c.TG
left join (select Primary_Brand_key, year, month, Category, Segment, Market, sum(ALL_Media_Reach_In_Mn) as ALL_Media_Reach_In_Mn, sum(Digital_Reach_In_Mn) as Digital_Reach_In_Mn from DW.UL_MEDIA_IN_PBRT_REACH_INDIA 
group by Primary_Brand_key,year, month, Category, Segment, Market) as d 
on a.Primary_Brand_key = d.Primary_Brand_key and a.year = d.year and a.month = d.month 
-- where  a.year= 2022 and a.month = 'Dec' and
-- a.primary_brand_key = 'Home Care|Laundry|Laundry (Det Bars + Washing Powder/Liquid)|Detergent Bars|Detergent Bars|Rin||' 

group by a.Primary_Brand_key,a .year, a.month, a.Category, a.Segment, a.LSM, b.Facebook_Reach_In_Mn, b.OTT_Reach_In_Mn, b.YouTube_Reach_In_Mn,
c.IRS_HHs, b.Facebook_Reach, b.YouTube_Reach, b.OTT_Reach, d.ALL_Media_Reach_In_Mn, d.Digital_Reach_In_Mn, c.TG





IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_REACH_UNION_TABLE') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_REACH_UNION_TABLE
END  

select * into DW.UL_MEDIA_IN_PBRT_REACH_UNION_TABLE from (
SELECT Primary_Brand_key, year, month, Category, Market, Segment, LSM ,
cast([IRS_HHs] as decimal(38, 9)) as [IRS_HHs],
cast([IRS_TV_Pen] as decimal(38,9)) as [IRS_TV_Pen],
cast([IRS_Reach] as decimal(38,9)) as [IRS_Reach],
cast([Facebook_Reach] as decimal(38, 9)) as [Facebook_Reach],
cast([YouTube_Reach] as decimal(38,9)) as [YouTube_Reach],
cast([Radio_Reach] as decimal(38, 9)) as [Radio_Reach],
cast([Cinema_Reach] as decimal(38,9)) as [Cinema_Reach],
cast([Mobile_Reach] as decimal(38, 9)) as [Mobile_Reach],
cast([OOH_Reach] as decimal(38,9)) as [OOH_Reach],
cast([STATIC_RURAL] as decimal(38, 9)) as [STATIC_RURAL],
cast([OTT_Reach] as decimal(38,9)) as [OTT_Reach],
cast([Print_Reach] as decimal(38, 9)) as [Print_Reach],
cast([NTV_Reach_] as decimal(38,9)) as [NTV_Reach_],
cast([Facebook_Reach_In_Mn] as decimal(38, 9)) as [Facebook_Reach_In_Mn],
cast([YouTube_Reach_In_Mn] as decimal(38,9)) as [YouTube_Reach_In_Mn],
cast([OTT_Reach_In_Mn] as decimal(38, 9)) as [OTT_Reach_In_Mn],
cast([Barc_Reach] as decimal(38,9)) as [Barc_Reach],
cast([All_Media_Reach] as decimal(38, 9)) as [All_Media_Reach],
cast([Digital_Reach_] as decimal(38,9)) as [Digital_Reach_],
cast([All_Media_Reach_In_Mn] as decimal(38, 9)) as [All_Media_Reach_In_Mn],
cast([Digital_Reach_In_Mn] as decimal(38,9)) as [Digital_Reach_In_Mn],
cast([IRS_Reach_In_Mn] as decimal(38, 9)) as [IRS_Reach_In_Mn],
cast([Print_Reach_In_Mn] as decimal(38,9)) as [Print_Reach_In_Mn],
cast([Cinema_Reach_In_Mn] as decimal(38, 9)) as [Cinema_Reach_In_Mn],
cast([Mobile_Reach_In_Mn] as decimal(38,9)) as [Mobile_Reach_In_Mn],
cast([OOH_Reach_In_Mn] as decimal(38, 9)) as [OOH_Reach_In_Mn],
cast([STATIC_RURAL_In_Mn] as decimal(38, 9)) as [STATIC_RURAL_In_Mn],
cast([NTV_Reach_In_Mn] as decimal(38,9)) as [NTV_Reach_In_Mn],
cast([Radio_Reach_In_Mn] as decimal(38,9)) as [Radio_Reach_In_Mn]
from DW.UL_MEDIA_IN_PBRT_REACH_INDIA


union

SELECT Primary_Brand_key, year, month, Category, Market, Segment, LSM ,
cast([HHs] as decimal(38, 9)) as [IRS_HHs],
cast([TV_Pen] as decimal(38,9)) as [IRS_TV_Pen],
cast([IRS_Reach] as decimal(38,9)) as [IRS_Reach],
cast([Facebook_Reach] as decimal(38, 9)) as [Facebook_Reach],
cast([YouTube_Reach] as decimal(38,9)) as [YouTube_Reach],
cast([Radio_Reach] as decimal(38, 9)) as [Radio_Reach],
cast([Cinema_Reach] as decimal(38,9)) as [Cinema_Reach],
cast([Mobile_Reach] as decimal(38, 9)) as [Mobile_Reach],
cast([OOH_Reach] as decimal(38,9)) as [OOH_Reach],
cast([STATIC_RURAL] as decimal(38, 9)) as [STATIC_RURAL],
cast([OTT_Reach] as decimal(38,9)) as [OTT_Reach],
cast([Print_Reach] as decimal(38, 9)) as [Print_Reach],
cast([NTV_Reach_] as decimal(38,9)) as [NTV_Reach_],
cast([Facebook_Reach_In_Mn] as decimal(38, 9)) as [Facebook_Reach_In_Mn],
cast([YouTube_Reach_In_Mn] as decimal(38,9)) as [YouTube_Reach_In_Mn],
cast([OTT_Reach_In_Mn] as decimal(38, 9)) as [OTT_Reach_In_Mn],
cast([Barc_Reach] as decimal(38,9)) as [Barc_Reach],
cast([All_Media_Reach] as decimal(38, 9)) as [All_Media_Reach],
cast([Digital_Reach_] as decimal(38,9)) as [Digital_Reach_],
cast([All_Media_Reach_In_Mn] as decimal(38, 9)) as [All_Media_Reach_In_Mn],
cast([Digital_Reach_In_Mn] as decimal(38,9)) as [Digital_Reach_In_Mn],
cast([IRS_Reach_In_Mn] as decimal(38, 9)) as [IRS_Reach_In_Mn],
cast([Print_Reach_In_Mn] as decimal(38,9)) as [Print_Reach_In_Mn],
cast([Cinema_Reach_In_Mn] as decimal(38, 9)) as [Cinema_Reach_In_Mn],
cast([Mobile_Reach_In_Mn] as decimal(38,9)) as [Mobile_Reach_In_Mn],
cast([OOH_Reach_In_Mn] as decimal(38, 9)) as [OOH_Reach_In_Mn],
cast([STATIC_RURAL_In_Mn] as decimal(38, 9)) as [STATIC_RURAL_In_Mn],
cast([NTV_Reach_In_Mn] as decimal(38,9)) as [NTV_Reach_In_Mn],
cast([Radio_Reach_In_Mn] as decimal(38,9)) as [Radio_Reach_In_Mn]
from DW.UL_MEDIA_IN_PBRT_REACH_MARKET
union 

SELECT Primary_Brand_key, year, month, Category, Market, Segment, LSM ,
cast([IRS_HHs] as decimal(38, 9)) as [IRS_HHs],
cast([IRS_TV_Pen] as decimal(38,9)) as [IRS_TV_Pen],
cast([IRS_Reach] as decimal(38,9)) as [IRS_Reach],
cast([Facebook_Reach] as decimal(38, 9)) as [Facebook_Reach],
cast([YouTube_Reach] as decimal(38,9)) as [YouTube_Reach],
cast([Radio_Reach] as decimal(38, 9)) as [Radio_Reach],
cast([Cinema_Reach] as decimal(38,9)) as [Cinema_Reach],
cast([Mobile_Reach] as decimal(38, 9)) as [Mobile_Reach],
cast([OOH_Reach] as decimal(38,9)) as [OOH_Reach],
cast([STATIC_RURAL] as decimal(38, 9)) as [STATIC_RURAL],
cast([OTT_Reach] as decimal(38,9)) as [OTT_Reach],
cast([Print_Reach] as decimal(38, 9)) as [Print_Reach],
cast([NTV_Reach_] as decimal(38,9)) as [NTV_Reach_],
cast([Facebook_Reach_In_Mn] as decimal(38, 9)) as [Facebook_Reach_In_Mn],
cast([YouTube_Reach_In_Mn] as decimal(38,9)) as [YouTube_Reach_In_Mn],
cast([OTT_Reach_In_Mn] as decimal(38, 9)) as [OTT_Reach_In_Mn],
cast([Barc_Reach] as decimal(38,9)) as [Barc_Reach],
cast([All_Media_Reach] as decimal(38, 9)) as [All_Media_Reach],
cast([Digital_Reach_] as decimal(38,9)) as [Digital_Reach_],
cast([All_Media_Reach_In_Mn] as decimal(38, 9)) as [All_Media_Reach_In_Mn],
cast([Digital_Reach_In_Mn] as decimal(38,9)) as [Digital_Reach_In_Mn],
cast([IRS_Reach_In_Mn] as decimal(38, 9)) as [IRS_Reach_In_Mn],
cast([Print_Reach_In_Mn] as decimal(38,9)) as [Print_Reach_In_Mn],
cast([Cinema_Reach_In_Mn] as decimal(38, 9)) as [Cinema_Reach_In_Mn],
cast([Mobile_Reach_In_Mn] as decimal(38,9)) as [Mobile_Reach_In_Mn],
cast([OOH_Reach_In_Mn] as decimal(38, 9)) as [OOH_Reach_In_Mn],
cast([STATIC_RURAL_In_Mn] as decimal(38, 9)) as [STATIC_RURAL_In_Mn],
cast([NTV_Reach_In_Mn] as decimal(38,9)) as [NTV_Reach_In_Mn],
cast([Radio_Reach_In_Mn] as decimal(38,9)) as [Radio_Reach_In_Mn]
from DW.UL_MEDIA_IN_PBRT_REACH_ALL_INDIA
union

SELECT Primary_Brand_key, year, month, Category, Market, Segment, LSM ,
cast([IRS_HHs] as decimal(38, 9)) as [IRS_HHs],
cast([IRS_TV_Pen] as decimal(38,9)) as [IRS_TV_Pen],
cast([IRS_Reach] as decimal(38,9)) as [IRS_Reach],
cast([Facebook_Reach] as decimal(38, 9)) as [Facebook_Reach],
cast([YouTube_Reach] as decimal(38,9)) as [YouTube_Reach],
cast([Radio_Reach] as decimal(38, 9)) as [Radio_Reach],
cast([Cinema_Reach] as decimal(38,9)) as [Cinema_Reach],
cast([Mobile_Reach] as decimal(38, 9)) as [Mobile_Reach],
cast([OOH_Reach] as decimal(38,9)) as [OOH_Reach],
cast([STATIC_RURAL] as decimal(38, 9)) as [STATIC_RURAL],
cast([OTT_Reach] as decimal(38,9)) as [OTT_Reach],
cast([Print_Reach] as decimal(38, 9)) as [Print_Reach],
cast([NTV_Reach_] as decimal(38,9)) as [NTV_Reach_],
cast([Facebook_Reach_In_Mn] as decimal(38, 9)) as [Facebook_Reach_In_Mn],
cast([YouTube_Reach_In_Mn] as decimal(38,9)) as [YouTube_Reach_In_Mn],
cast([OTT_Reach_In_Mn] as decimal(38, 9)) as [OTT_Reach_In_Mn],
cast([Barc_Reach] as decimal(38,9)) as [Barc_Reach],
cast([All_Media_Reach] as decimal(38, 9)) as [All_Media_Reach],
cast([Digital_Reach_] as decimal(38,9)) as [Digital_Reach_],
cast([All_Media_Reach_In_Mn] as decimal(38, 9)) as [All_Media_Reach_In_Mn],
cast([Digital_Reach_In_Mn] as decimal(38,9)) as [Digital_Reach_In_Mn],
cast([IRS_Reach_In_Mn] as decimal(38, 9)) as [IRS_Reach_In_Mn],
cast([Print_Reach_In_Mn] as decimal(38,9)) as [Print_Reach_In_Mn],
cast([Cinema_Reach_In_Mn] as decimal(38, 9)) as [Cinema_Reach_In_Mn],
cast([Mobile_Reach_In_Mn] as decimal(38,9)) as [Mobile_Reach_In_Mn],
cast([OOH_Reach_In_Mn] as decimal(38, 9)) as [OOH_Reach_In_Mn],
cast([STATIC_RURAL_In_Mn] as decimal(38, 9)) as [STATIC_RURAL_In_Mn],
cast([NTV_Reach_In_Mn] as decimal(38,9)) as [NTV_Reach_In_Mn],
cast([Radio_Reach_In_Mn] as decimal(38,9)) as [Radio_Reach_In_Mn]
from DW.UL_MEDIA_IN_PBRT_REACH_ALL_LSM
) abc




IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_REACH_UNPIVOT_TABLE') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_REACH_UNPIVOT_TABLE
END  


select * into DW.UL_MEDIA_IN_PBRT_REACH_UNPIVOT_TABLE
from (
SELECT Primary_Brand_key, year, month, Category, Market, Segment, LSM , Reach_Type, Value1 FROM (
SELECT Primary_Brand_key, year, month, Category, Market, Segment, LSM ,
cast([IRS_HHs] as decimal(38, 9)) as [IRS_HHs],
cast([IRS_TV_Pen] as decimal(38,9)) as [IRS_TV_Pen],
cast([IRS_Reach]*100 as decimal(38,9)) as [IRS_Reach],
cast([Facebook_Reach]*100 as decimal(38, 9)) as [Facebook_Reach],
cast([YouTube_Reach]*100 as decimal(38,9)) as [YouTube_Reach],
cast([Radio_Reach]*100 as decimal(38, 9)) as [Radio_Reach],
cast([Cinema_Reach]*100 as decimal(38,9)) as [Cinema_Reach],
cast([Mobile_Reach]*100 as decimal(38, 9)) as [Mobile_Reach],
cast([OOH_Reach]*100 as decimal(38,9)) as [OOH_Reach],
cast([STATIC_RURAL]*100 as decimal(38, 9)) as [STATIC_RURAL],
cast([OTT_Reach]*100 as decimal(38,9)) as [OTT_Reach],
cast([Print_Reach]*100 as decimal(38, 9)) as [Print_Reach],
cast([NTV_Reach_]*100 as decimal(38,9)) as [NTV_Reach_],
cast([Facebook_Reach_In_Mn] as decimal(38, 9)) as [Facebook_Reach_In_Mn],
cast([YouTube_Reach_In_Mn] as decimal(38,9)) as [YouTube_Reach_In_Mn],
cast([OTT_Reach_In_Mn] as decimal(38, 9)) as [OTT_Reach_In_Mn],
cast([Barc_Reach] as decimal(38,9)) as [Barc_Reach],
cast([All_Media_Reach]*100 as decimal(38, 9))  as [All_Media_Reach],
cast([Digital_Reach_]*100 as decimal(38,9)) as [Digital_Reach_],
cast([All_Media_Reach_In_Mn] as decimal(38, 9)) as [All_Media_Reach_In_Mn],
cast([Digital_Reach_In_Mn] as decimal(38,9)) as [Digital_Reach_In_Mn],
cast([IRS_Reach_In_Mn] as decimal(38, 9)) as [IRS_Reach_In_Mn],
cast([Print_Reach_In_Mn] as decimal(38,9)) as [Print_Reach_In_Mn],
cast([Cinema_Reach_In_Mn] as decimal(38, 9)) as [Cinema_Reach_In_Mn],
cast([Mobile_Reach_In_Mn] as decimal(38,9)) as [Mobile_Reach_In_Mn],
cast([OOH_Reach_In_Mn] as decimal(38, 9)) as [OOH_Reach_In_Mn],
cast([STATIC_RURAL_In_Mn] as decimal(38, 9)) as [STATIC_RURAL_In_Mn],
cast([NTV_Reach_In_Mn] as decimal(38,9)) as [NTV_Reach_In_Mn],
cast([Radio_Reach_In_Mn] as decimal(38,9)) as [Radio_Reach_In_Mn]
from DW.UL_MEDIA_IN_PBRT_REACH_UNION_TABLE
)P
UNPIVOT
(
 Value1 for Reach_Type IN (IRS_HHs,IRS_TV_Pen,IRS_Reach,Facebook_Reach,YouTube_Reach,Radio_Reach,Cinema_Reach,Mobile_Reach,OOH_Reach,STATIC_RURAL,OTT_Reach,Print_Reach,NTV_Reach_,Facebook_Reach_In_Mn,YouTube_Reach_In_Mn,OTT_Reach_In_Mn,Barc_Reach,All_Media_Reach,Digital_Reach_,All_Media_Reach_In_Mn,Digital_Reach_In_Mn,IRS_Reach_In_Mn,
Print_Reach_In_Mn,Radio_Reach_In_Mn,Cinema_Reach_In_Mn,Mobile_Reach_In_Mn,OOH_Reach_In_Mn,STATIC_RURAL_In_Mn,NTV_Reach_In_Mn)
) unpvt ) a



IF OBJECT_ID('DW.reach_freq_value') IS NOT NULL
BEGIN
DROP TABLE DW.reach_freq_value
END

select distinct Medium, Reach_Freq
into DW.reach_freq_value
from DW.UL_MEDIA_IN_PBRT_REACH


IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_REACH_FINAL_OP') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_REACH_FINAL_OP
END  
select a.primary_brand_key,	b.primary_brand, a.month, a.year, a.category, a.Market, b.Big_c, b.Small_C, b.Sub_Category,  
 b.Segment,b.Sub_Segment,concat(a.Month,' ',a.Year) "Period_Type",
 CASE WHEN Market='AP / Telangana' THEN 'Cluster'
 WHEN Market='Assam / North East / Sikkim' THEN 'Cluster' 
 WHEN Market='Bihar/Jharkhand' THEN 'Cluster'
 WHEN Market='Digital Market Cluster' THEN 'Club Market'
 WHEN Market='Guj / D&D / DNH' THEN 'Cluster'
 WHEN Market='Karnataka' THEN 'Cluster'
 WHEN Market='Kerala' THEN 'Cluster'
 WHEN Market='Mah / Goa' THEN 'Cluster'
 WHEN Market='MP/Chhattisgarh' THEN  'Cluster'
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
 WHEN Market='India' THEN 'India' END as Geography_Type, 
 a.LSM as Target_Group, 
 case when a.Reach_Type = 'IRS_HHs' then 'HHs'
	when a.Reach_Type = 'IRS_TV_Pen' then 'TV_Pen'
	when a.Reach_Type = 'STATIC_RURAL_In_Mn' then 'STATIC_RURAL_Mn'
	else a.Reach_Type end as Reach_Type,

 a.Value1 as value,
 CASE
		When Reach_Type ='BARC_Reach' then (select IsNULL(Reach_Freq,'') from DW.reach_freq_value where Medium='TV')
		WHEN Reach_Type ='Mobile_Reach' then (select IsNULL(Reach_Freq,'') from DW.reach_freq_value where Medium='Mobile')
		WHEN Reach_Type ='YouTube_Reach' then (select IsNULL(Reach_Freq,'') from DW.reach_freq_value where Medium='YT')
		WHEN Reach_Type ='Print_Reach' then (select IsNULL(Reach_Freq,'') from DW.reach_freq_value where Medium='Print')
		WHEN Reach_Type ='Cinema_Reach' then (select IsNULL(Reach_Freq,'') from DW.reach_freq_value where Medium='Cinema')
		WHEN Reach_Type ='OTT_Reach' then (select IsNULL(Reach_Freq,'') from DW.reach_freq_value where Medium='OTT')
		WHEN Reach_Type ='Facebook_Reach' then (select IsNULL(Reach_Freq,'') from DW.reach_freq_value where Medium='FB')
		WHEN Reach_Type ='OOH_Reach' then (select IsNULL(Reach_Freq,'') from DW.reach_freq_value where Medium='OOH')
		WHEN Reach_Type ='Radio_Reach' then (select IsNULL(Reach_Freq,'') from DW.reach_freq_value where Medium='Radio')
	ELSE '' END as Reach_Freq
	

-- , Reach_Freq

into DW.UL_MEDIA_IN_PBRT_REACH_FINAL_OP
from DW.UL_MEDIA_IN_PBRT_REACH_UNPIVOT_TABLE a
left join
dw.UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER b
on 
-- a.Category = b.Small_C and 
a.Primary_Brand_Key = b.PBRT_KEY 
--where value1 <> 0 

