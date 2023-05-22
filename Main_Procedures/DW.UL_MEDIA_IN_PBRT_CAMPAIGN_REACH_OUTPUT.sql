IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_CAMPAIGN_DIGITAL_MARKET') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_CAMPAIGN_DIGITAL_MARKET
END 

select *, '' as SOG_Level, 
0.00 as TV_Peneration,
0.00 as IRS_HHs,
0 as Source_of_Growth,
0.00 as SOG_HHs
into DW.UL_MEDIA_IN_PBRT_CAMPAIGN_DIGITAL_MARKET
from (select distinct primary_brand_key, Campaign, TG, Market, LSM from DW.UL_MEDIA_IN_CAMPAIGN_REACH where market  = 'Digital Market Cluster') a


--Cluster
IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET
END  

select a.Primary_Brand_key,a.year, a.month, a.Category, a.Segment, a.Market as Market, a.TG, a.[Type],
isnull(b.TV_Penetration,0) as TV_Penetration, isnull(b.IRS_HHs,0) as IRS_HHs, isnull(b.SOG_HHs,0) as SOG_HHs,
nullif(sum(case when a.Medium in ('TV') then a.Value else 0 end)/100,0) as TV_Reach,  
nullif(sum(case when a.Medium in ('Print') then a.Value else 0 end)/100,0) as Print_Reach,  
nullif(sum(case when a.Medium in ('Radio') then a.Value else 0 end)/100,0) as Radio_Reach,  
nullif(sum(case when a.Medium in ('Cinema') then a.Value else 0 end)/100,0) as Cinema_Reach,  
nullif(sum(case when a.Medium in ('Mobile') then a.Value else 0 end)/100,0) as Mobile_Reach,  
nullif(sum(case when a.Medium in ('YT') and c.Medium is null then a.Value when c.Medium in ('YT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100,0) as YouTube_Reach,  
nullif(sum(case when a.Medium in ('OTT') and c.Medium is null then a.Value when c.Medium in ('OTT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100,0) as OTT_Reach,  
nullif(sum(case when a.Medium in ('FB') and c.Medium is null then a.Value when c.Medium in ('FB') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100,0) as FB_Reach,  
nullif(sum(case when a.Medium in ('OOH') then a.Value else 0 end)/100,0) as OOH_Reach,

isnull(b.TV_Penetration,0)/100 * sum(case when a.Medium in ('TV') then a.Value else 0 end) as IRS_TV_Reach,
isnull(b.TV_Penetration,0)/100 * sum(case when a.Medium in ('TV') then a.Value else 0 end) * isnull(b.IRS_HHs,0)/100 as TV_Reach_in_MN_IRS_HHs,
isnull(b.TV_Penetration,0)/100 * sum(case when a.Medium in ('TV') then a.Value else 0 end) * isnull(b.SOG_HHs,0)/100 as TV_Reach_in_MN_SOG_HHs,
isnull(b.TV_Penetration,0)/100 * sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('TV') then a.Value else 0 end) as SOG_TV_Reach,

-- isnull(b.TV_Penetration,0)/100 * sum(case when a.Medium in ('Print') then a.Value else 0 end) as "IRS_Print_Reach %",
sum(case when a.Medium in ('Print') then a.Value else 0 end) * isnull(b.IRS_HHs,0)/100 as Print_Reach_in_MN_IRS_HHs,
sum(case when a.Medium in ('Print') then a.Value else 0 end) * isnull(b.SOG_HHs,0)/100 as Print_Reach_in_MN_SOG_HHs,
sum(case when b.SOG_HHs = 0 then 0 
    when a.Medium in ('Print') then a.Value else 0 end) as SOG_Print_Reach,

-- isnull(b.TV_Penetration,0)/100 * sum(case when a.Medium in ('Radio') then a.Value else 0 end) as "IRS_Radio_Reach %",
sum(case when a.Medium in ('Radio') then a.Value else 0 end) * isnull(b.IRS_HHs,0)/100 as Radio_Reach_in_MN_IRS_HHs,
sum(case when a.Medium in ('Radio') then a.Value else 0 end) * isnull(b.SOG_HHs,0)/100 as Radio_Reach_in_MN_SOG_HHs,
sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('Radio') then a.Value else 0 end) as SOG_Radio_Reach,

-- isnull(b.TV_Penetration,0)/100 * sum(case when a.Medium in ('Cinema') then a.Value else 0 end) as "IRS_Cinema_Reach %",
sum(case when a.Medium in ('Cinema') then a.Value else 0 end) * isnull(b.IRS_HHs,0)/100 as Cinema_Reach_in_MN_IRS_HHs,
sum(case when a.Medium in ('Cinema') then a.Value else 0 end) * isnull(b.SOG_HHs,0)/100 as Cinema_Reach_in_MN_SOG_HHs,
sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('Cinema') then a.Value else 0 end) as SOG_Cinema_Reach,

-- isnull(b.TV_Penetration,0)/100 * sum(case when a.Medium in ('Mobile') then a.Value else 0 end) as "IRS_Mobile_Reach %",
sum(case when a.Medium in ('Mobile') then a.Value else 0 end) * isnull(b.IRS_HHs,0)/100 as Mobile_Reach_in_MN_IRS_HHs,
sum(case when a.Medium in ('Mobile') then a.Value else 0 end) * isnull(b.SOG_HHs,0)/100 as Mobile_Reach_in_MN_SOG_HHs,
sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('Mobile') then a.Value else 0 end) as SOG_Mobile_Reach,

-- isnull(b.TV_Penetration,0)/100 * sum(case when a.Medium in ('YT') then a.Value else 0 end) as "IRS_YouTube_Reach %",
nullif(sum(case when a.Medium in ('YT') and c.Medium is null then a.Value when c.Medium in ('YT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100,0) * isnull(b.IRS_HHs,0)/100 as YouTube_Reach_in_MN_IRS_HHs,
nullif(sum(case when a.Medium in ('YT') and c.Medium is null then a.Value when c.Medium in ('YT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100,0) * isnull(b.SOG_HHs,0)/100 as YouTube_Reach_in_MN_SOG_HHs,
sum(case when b.SOG_HHs = 0 and a.Market! = 'Digital Market Cluster' then 0 when a.Medium in ('YT') and c.Medium is null then a.Value when c.Medium in ('YT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end) as SOG_YouTube_Reach,

-- isnull(b.TV_Penetration,0)/100 * sum(case when a.Medium in ('OTT') then a.Value else 0 end) as "IRS_OTT_Reach %",
sum(case when a.Medium in ('OTT') and c.Medium is null then a.Value when c.Medium in ('OTT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end) * isnull(b.IRS_HHs,0)/100 as OTT_Reach_in_MN_IRS_HHs,
sum(case when a.Medium in ('OTT') and c.Medium is null then a.Value when c.Medium in ('OTT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end) * isnull(b.SOG_HHs,0)/100 as OTT_Reach_in_MN_SOG_HHs,
sum(case when b.SOG_HHs = 0 and a.Market! = 'Digital Market Cluster' then 0 when a.Medium in ('OTT') and c.Medium is null then a.Value when c.Medium in ('OTT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end) as SOG_OTT_Reach,

-- isnull(b.TV_Penetration,0)/100 * sum(case when a.Medium in ('FB') then a.Value else 0 end) as "IRS_FB_Reach %",
sum(case when a.Medium in ('FB') and c.Medium is null then a.Value when c.Medium in ('FB') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end) * isnull(b.IRS_HHs,0)/100 as FB_Reach_in_MN_IRS_HHs,
sum(case when a.Medium in ('FB') and c.Medium is null then a.Value when c.Medium in ('FB') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end) * isnull(b.SOG_HHs,0)/100 as FB_Reach_in_MN_SOG_HHs,
sum(case when b.SOG_HHs = 0 and a.Market! = 'Digital Market Cluster' then 0 when a.Medium in ('FB') and c.Medium is null then a.Value when c.Medium in ('FB') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end) as SOG_FB_Reach,

-- isnull(b.TV_Penetration,0)/100 * sum(case when a.Medium in ('OOH') then a.Value else 0 end) as "IRS_OOH_Reach %",
sum(case when a.Medium in ('OOH') then a.Value else 0 end) * isnull(b.IRS_HHs,0)/100 as OOH_Reach_in_MN_IRS_HHs,
sum(case when a.Medium in ('OOH') then a.Value else 0 end) * isnull(b.SOG_HHs,0)/100 as OOH_Reach_in_MN_SOG_HHs,
sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('OOH') then a.Value else 0 end) as SOG_OOH_Reach,

1-(
(1- (sum(case when a.Medium in ('TV') then a.Value else 0 end) * isnull(b.TV_Penetration,0)/100))
*(1- sum(case when a.Medium in ('Print') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Radio') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Cinema') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Mobile') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('YT') and c.Medium is null then a.Value when c.Medium in ('YT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('OTT') and c.Medium is null then a.Value when c.Medium in ('OTT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('FB') and c.Medium is null then a.Value when c.Medium in ('FB') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('OOH') then a.Value else 0 end)/100)
) as All_Media_Reach,

(1-(
(1- (sum(case when a.Medium in ('TV') then a.Value else 0 end) * isnull(b.TV_Penetration,0)/100))
*(1- sum(case when a.Medium in ('Print') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Radio') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Cinema') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Mobile') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('YT') and c.Medium is null then a.Value when c.Medium in ('YT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('OTT') and c.Medium is null then a.Value when c.Medium in ('OTT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('FB') and c.Medium is null then a.Value when c.Medium in ('FB') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('OOH') then a.Value else 0 end)/100)
)) * isnull(b.IRS_HHs,0) as All_Media_Reach_in_IRS_HHs_in_Mn,

(1-(
(1- (sum(case when a.Medium in ('TV') then a.Value else 0 end) * isnull(b.TV_Penetration,0)/100))
*(1- sum(case when a.Medium in ('Print') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Radio') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Cinema') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Mobile') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('YT') and c.Medium is null then a.Value when c.Medium in ('YT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('OTT') and c.Medium is null then a.Value when c.Medium in ('OTT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('FB') and c.Medium is null then a.Value when c.Medium in ('FB') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('OOH') then a.Value else 0 end)/100)
)) * isnull(b.SOG_HHs,0) as All_Media_Reach_in_SOG_HHs_in_Mn,

1-(
(1- (sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('TV') then a.Value else 0 end) * isnull(b.TV_Penetration,0)/100))
*(1- sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('Print') then a.Value else 0 end)/100)
*(1- sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('Radio') then a.Value else 0 end)/100)
*(1- sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('Cinema') then a.Value else 0 end)/100)
*(1- sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('Mobile') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('YT') and c.Medium is null then a.Value when c.Medium in ('YT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('OTT') and c.Medium is null then a.Value when c.Medium in ('OTT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('FB') and c.Medium is null then a.Value when c.Medium in ('FB') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)
*(1- sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('OOH') then a.Value else 0 end)/100)
) as All_Media_Reach_SOG,

-- (1-((1- sum(case when a.Medium in ('YT') then a.Value else 0 end)/100)
-- *(1- sum(case when a.Medium in ('OTT') then a.Value else 0 end)/100)
-- *(1- sum(case when a.Medium in ('FB') then a.Value else 0 end)/100)
-- )) as Digital_Reach_

1-(1-sum(case when a.Medium in ('YT') and c.Medium is null then a.Value when c.Medium in ('YT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)*
(1-sum(case when a.Medium in ('OTT') and c.Medium is null then a.Value when c.Medium in ('OTT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)*
(1-sum(case when a.Medium in ('FB') and c.Medium is null then a.Value when c.Medium in ('FB') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)
as Digital_Reach_, 

(1-(1-sum(case when a.Medium in ('YT') and c.Medium is null then a.Value when c.Medium in ('YT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)*
(1-sum(case when a.Medium in ('OTT') and c.Medium is null then a.Value when c.Medium in ('OTT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)*
(1-sum(case when a.Medium in ('FB') and c.Medium is null then a.Value when c.Medium in ('FB') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)) * isnull(b.IRS_HHs,0)
as Digital_Reach_IRS_HHS, 

(1-(1-sum(case when a.Medium in ('YT') and c.Medium is null then a.Value when c.Medium in ('YT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)*
(1-sum(case when a.Medium in ('OTT') and c.Medium is null then a.Value when c.Medium in ('OTT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)*
(1-sum(case when a.Medium in ('FB') and c.Medium is null then a.Value when c.Medium in ('FB') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)) * isnull(b.SOG_HHs,0)
as Digital_Reach_SOG_HHS, 

(1-(1-sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('YT') and c.Medium is null then a.Value when c.Medium in ('YT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)*
(1-sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('OTT') and c.Medium is null then a.Value when c.Medium in ('OTT') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100)*
(1-sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('FB') and c.Medium is null then a.Value when c.Medium in ('FB') and a.Market= c.Market and c.Medium is not null then c.Value else 0 end)/100))
as Digital_Reach_SOG,

(1-((1- sum(case when a.Medium in ('Print') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Radio') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Cinema') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Mobile') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('OOH') then a.Value else 0 end)/100)))
as NTV_Reach_,

(1-((1- sum(case when a.Medium in ('Print') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Radio') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Cinema') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Mobile') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('OOH') then a.Value else 0 end)/100))) * isnull(b.IRS_HHs,0)
as NTV_Reach_IRS_HHS,

(1-((1- sum(case when a.Medium in ('Print') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Radio') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Cinema') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('Mobile') then a.Value else 0 end)/100)
*(1- sum(case when a.Medium in ('OOH') then a.Value else 0 end)/100))) * isnull(b.SOG_HHs,0)
as NTV_Reach_SOG_HHs,

(1-((1- sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('Print') then a.Value else 0 end)/100)
*(1- sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('Radio') then a.Value else 0 end)/100)
*(1- sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('Cinema') then a.Value else 0 end)/100)
*(1- sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('Mobile') then a.Value else 0 end)/100)
*(1- sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('OOH') then a.Value else 0 end)/100)))
as NTV_Reach_SOG

into DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET
from (select category, segment, primary_brand_key,month, year,market, TG, LSM, Type, sum(Value) as Value, Medium from DW.UL_MEDIA_IN_CAMPAIGN_REACH
group by category, segment, primary_brand_key,month, year,market, TG, LSM, Medium, Type) a
inner join (select * from DW.UL_MEDIA_IN_SOG union select * from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_DIGITAL_MARKET) b
on a.Market = b.Market and b.TG=a.TG and b.Primary_Brand_key=a.Primary_Brand_key

left join (select category, segment, primary_brand_key,month, year,market, TG, LSM, Type, sum(Value) as Value, Medium from DW.UL_MEDIA_IN_CAMPAIGN_REACH
where market = 'Digital Market Cluster'
group by category, segment, primary_brand_key,month, year,market, TG, LSM, Medium, Type) c
on c.Primary_Brand_key=a.Primary_Brand_key and a.month = c.month and a.year = c.year and a.type = c.type and a.TG = c.TG and a.Medium = c.Medium

group by a.Primary_Brand_key,a.year, a.month, a.Category, a.Segment, a.Market, a.TG, a.Type,
b.TV_Penetration, b.IRS_HHs, b.SOG_HHs



--Digital Market KPI Calculation
IF OBJECT_ID('DW.EXTRA_KPI') IS NOT NULL  
BEGIN  
DROP TABLE DW.EXTRA_KPI
END 

select 
a.Primary_Brand_key,a.year, a.month, a.Category, a.Segment,  a.TG, a.Type, 'Digital Market Cluster' as Market,
sum(a.IRS_HHs)*YouTube_Reach as YouTube_Reach_in_MN_IRS_HHs,
sum(a.SOG_HHs)*YouTube_Reach as YouTube_Reach_in_MN_SOG_HHs,
sum(a.IRS_HHs)*OTT_Reach as OTT_Reach_in_MN_IRS_HHs,
sum(a.SOG_HHs)*OTT_Reach as OTT_Reach_in_MN_SOG_HHs,
sum(a.IRS_HHs)*FB_Reach as FB_Reach_in_MN_IRS_HHs,
sum(a.SOG_HHs)*FB_Reach as FB_Reach_in_MN_SOG_HHs,
sum(a.IRS_HHs)*All_Media_Reach as All_Media_Reach_in_IRS_HHs_in_Mn,
sum(a.SOG_HHs)*All_Media_Reach as All_Media_Reach_in_SOG_HHs_in_Mn,
sum(a.IRS_HHs)*Digital_Reach_ as Digital_Reach_IRS_HHS,
sum(a.SOG_HHs)*Digital_Reach_ as Digital_Reach_SOG_HHS,
sum(a.IRS_HHs)*NTV_Reach_ as NTV_Reach_IRS_HHS,
sum(a.SOG_HHs)*NTV_Reach_ as NTV_Reach_SOG_HHs,
1 as Flag
into DW.EXTRA_KPI
from 
(select Primary_Brand_key,year, month, Category, Segment,  TG, Type,sum(isnull(IRS_HHs,0)) as IRS_HHs,
sum(isnull(SOG_HHs,0)) as SOG_HHs,
sum(isnull(TV_Penetration,0)) as TV_Penetration from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET where market != 'Digital Market Cluster'
group by Primary_Brand_key,year, month, Category, Segment,  TG, Type) a

left join (
    select Primary_Brand_key,year, month, Category, Segment,  TG, Type,
    sum(isnull(IRS_HHs,0)) as IRS_HHs,
sum(isnull(SOG_HHs,0)) as SOG_HHs, sum(isnull(TV_Penetration,0)) as TV_Penetrationm, sum(YouTube_Reach) as YouTube_Reach,
sum(OTT_Reach) as OTT_Reach, sum(FB_Reach) as FB_Reach, sum(All_Media_Reach) as All_Media_Reach,
sum(Digital_Reach_) as Digital_Reach_,sum(NTV_Reach_) as NTV_Reach_
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET where market = 'Digital Market Cluster'
group by Primary_Brand_key,year, month, Category, Segment,  TG, Type
) b
on a.Primary_Brand_key = b.Primary_Brand_key  and a.year = b.year and a.month = b.month and a.TG = b.TG and a.type = b.type

group by a.Primary_Brand_key,a.year, a.month, a.Category, a.Segment,  a.TG, a.Type, b.Youtube_Reach, b.OTT_Reach, b.FB_Reach, 
b.All_Media_Reach, b.Digital_Reach_, b.NTV_Reach_
-------------------------------
update DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET
set YouTube_Reach_in_MN_IRS_HHs = b.YouTube_Reach_in_MN_IRS_HHs
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET a 
inner join DW.EXTRA_KPI b on  a.Primary_Brand_key = b.Primary_Brand_key  and a.year = b.year and a.month = b.month and a.TG = b.TG and a.type = b.type and a.Market = b.Market
where a.market = 'Digital Market Cluster'

update DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET
set YouTube_Reach_in_MN_SOG_HHs = b.YouTube_Reach_in_MN_SOG_HHs
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET a 
inner join DW.EXTRA_KPI b on  a.Primary_Brand_key = b.Primary_Brand_key  and a.year = b.year and a.month = b.month and a.TG = b.TG and a.type = b.type and a.Market = b.Market
where a.market = 'Digital Market Cluster'

update DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET
set OTT_Reach_in_MN_IRS_HHs = b.OTT_Reach_in_MN_IRS_HHs
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET a 
inner join DW.EXTRA_KPI b on  a.Primary_Brand_key = b.Primary_Brand_key  and a.year = b.year and a.month = b.month and a.TG = b.TG and a.type = b.type and a.Market = b.Market
where a.market = 'Digital Market Cluster'

update DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET
set OTT_Reach_in_MN_SOG_HHs = b.OTT_Reach_in_MN_SOG_HHs
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET a 
inner join DW.EXTRA_KPI b on  a.Primary_Brand_key = b.Primary_Brand_key  and a.year = b.year and a.month = b.month and a.TG = b.TG and a.type = b.type and a.Market = b.Market
where a.market = 'Digital Market Cluster'

update DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET
set FB_Reach_in_MN_IRS_HHs = b.FB_Reach_in_MN_IRS_HHs
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET a 
inner join DW.EXTRA_KPI b on  a.Primary_Brand_key = b.Primary_Brand_key  and a.year = b.year and a.month = b.month and a.TG = b.TG and a.type = b.type and a.Market = b.Market
where a.market = 'Digital Market Cluster'

update DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET
set FB_Reach_in_MN_SOG_HHs = b.FB_Reach_in_MN_SOG_HHs
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET a 
inner join DW.EXTRA_KPI b on  a.Primary_Brand_key = b.Primary_Brand_key  and a.year = b.year and a.month = b.month and a.TG = b.TG and a.type = b.type and a.Market = b.Market
where a.market = 'Digital Market Cluster'

update DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET
set All_Media_Reach_in_IRS_HHs_in_Mn = b.All_Media_Reach_in_IRS_HHs_in_Mn
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET a 
inner join DW.EXTRA_KPI b on  a.Primary_Brand_key = b.Primary_Brand_key  and a.year = b.year and a.month = b.month and a.TG = b.TG and a.type = b.type and a.Market = b.Market
where a.market = 'Digital Market Cluster'

update DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET
set All_Media_Reach_in_SOG_HHs_in_Mn = b.All_Media_Reach_in_SOG_HHs_in_Mn
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET a 
inner join DW.EXTRA_KPI b on  a.Primary_Brand_key = b.Primary_Brand_key  and a.year = b.year and a.month = b.month and a.TG = b.TG and a.type = b.type and a.Market = b.Market
where a.market = 'Digital Market Cluster'

update DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET
set Digital_Reach_IRS_HHS = b.Digital_Reach_IRS_HHS
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET a 
inner join DW.EXTRA_KPI b on  a.Primary_Brand_key = b.Primary_Brand_key  and a.year = b.year and a.month = b.month and a.TG = b.TG and a.type = b.type and a.Market = b.Market
where a.market = 'Digital Market Cluster'

update DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET
set Digital_Reach_SOG_HHS = b.Digital_Reach_SOG_HHS
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET a 
inner join DW.EXTRA_KPI b on  a.Primary_Brand_key = b.Primary_Brand_key  and a.year = b.year and a.month = b.month and a.TG = b.TG and a.type = b.type and a.Market = b.Market
where a.market = 'Digital Market Cluster'

update DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET
set NTV_Reach_IRS_HHS = b.NTV_Reach_IRS_HHS
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET a 
inner join DW.EXTRA_KPI b on  a.Primary_Brand_key = b.Primary_Brand_key  and a.year = b.year and a.month = b.month and a.TG = b.TG and a.type = b.type and a.Market = b.Market
where a.market = 'Digital Market Cluster'

update DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET
set NTV_Reach_SOG_HHs = b.NTV_Reach_SOG_HHs
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET a 
inner join DW.EXTRA_KPI b on  a.Primary_Brand_key = b.Primary_Brand_key  and a.year = b.year and a.month = b.month and a.TG = b.TG and a.type = b.type and a.Market = b.Market
where a.market = 'Digital Market Cluster'


---ALL Extra Markets
IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_CAMPAIGN_month_year_brand') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_CAMPAIGN_month_year_brand
END  

select 
a.primary_brand_key as primary_brand_key,
d.[year],
c.month,
a.Category, 
a.Segment,
e.Market as Market,
a.TG as TG,
g.type,
0 as TV_Penetration,
0 as IRS_HHs,
0 as SOG_HHs,
0 as TV_Reach, 
0 as Print_Reach, 
0 as Radio_Reach, 
0 as Cinema_Reach, 
0 as Mobile_Reach, 
0 as YouTube_Reach, 
0 as OTT_Reach, 
0 as FB_Reach, 
0 as OOH_Reach, 
0 as IRS_TV_Reach, 
0 as TV_Reach_in_MN_IRS_HHs, 
0 as TV_Reach_in_MN_SOG_HHs, 
0 as SOG_TV_Reach, 
0 as Print_Reach_in_MN_IRS_HHs, 
0 as Print_Reach_in_MN_SOG_HHs, 
0 as SOG_Print_Reach, 
0 as Radio_Reach_in_MN_IRS_HHs, 
0 as Radio_Reach_in_MN_SOG_HHs, 
0 as SOG_Radio_Reach, 
0 as Cinema_Reach_in_MN_IRS_HHs, 
0 as Cinema_Reach_in_MN_SOG_HHs, 
0 as SOG_Cinema_Reach, 
0 as Mobile_Reach_in_MN_IRS_HHs, 
0 as Mobile_Reach_in_MN_SOG_HHs, 
0 as SOG_Mobile_Reach, 
0 as YouTube_Reach_in_MN_IRS_HHs, 
0 as YouTube_Reach_in_MN_SOG_HHs, 
0 as SOG_YouTube_Reach, 
0 as OTT_Reach_in_MN_IRS_HHs, 
0 as OTT_Reach_in_MN_SOG_HHs, 
0 as SOG_OTT_Reach, 
0 as FB_Reach_in_MN_IRS_HHs, 
0 as FB_Reach_in_MN_SOG_HHs, 
0 as SOG_FB_Reach, 
0 as OOH_Reach_in_MN_IRS_HHs, 
0 as OOH_Reach_in_MN_SOG_HHs, 
0 as SOG_OOH_Reach, 
0 as All_Media_Reach, 
0 as All_Media_Reach_in_IRS_HHs_in_Mn, 
0 as All_Media_Reach_in_SOG_HHs_in_Mn, 
0 as All_Media_Reach_SOG, 
0 as Digital_Reach_, 
0 as Digital_Reach_IRS_HHS, 
0 as Digital_Reach_SOG_HHS, 
0 as Digital_Reach_SOG, 
0 as NTV_Reach_, 
0 as NTV_Reach_IRS_HHS, 
0 as NTV_Reach_SOG_HHs, 
0 as NTV_Reach_SOG
into DW.UL_MEDIA_IN_PBRT_CAMPAIGN_month_year_brand
from (select distinct primary_brand_key, TG, Category, Segment from DW.UL_MEDIA_IN_CAMPAIGN_REACH) a
inner join (select distinct month from DW.UL_MEDIA_IN_PBRT_REACH) c
on 1 = 1
inner join (select distinct year from DW.UL_MEDIA_IN_PBRT_REACH) d
on 1 = 1
inner join (select distinct market from DW.UL_MEDIA_IN_CAMPAIGN_REACH) e
on 1 = 1
left join DW.UL_MEDIA_IN_SOG f
on e.Market = f.Market and a.TG=f.TG and a.Primary_Brand_key=f.Primary_Brand_key
inner join (select distinct type from DW.UL_MEDIA_IN_CAMPAIGN_REACH) g
on 1 = 1

IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_EXTRA_MARKETS') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_EXTRA_MARKETS
END 


select *,
0 as TV_Penetration,
0 as IRS_HHs,
0 as SOG_HHs,
0 as TV_Reach, 
0 as Print_Reach, 
0 as Radio_Reach, 
0 as Cinema_Reach, 
0 as Mobile_Reach, 
0 as YouTube_Reach, 
0 as OTT_Reach, 
0 as FB_Reach, 
0 as OOH_Reach, 
0 as IRS_TV_Reach, 
0 as TV_Reach_in_MN_IRS_HHs, 
0 as TV_Reach_in_MN_SOG_HHs, 
0 as SOG_TV_Reach, 
0 as Print_Reach_in_MN_IRS_HHs, 
0 as Print_Reach_in_MN_SOG_HHs, 
0 as SOG_Print_Reach, 
0 as Radio_Reach_in_MN_IRS_HHs, 
0 as Radio_Reach_in_MN_SOG_HHs, 
0 as SOG_Radio_Reach, 
0 as Cinema_Reach_in_MN_IRS_HHs, 
0 as Cinema_Reach_in_MN_SOG_HHs, 
0 as SOG_Cinema_Reach, 
0 as Mobile_Reach_in_MN_IRS_HHs, 
0 as Mobile_Reach_in_MN_SOG_HHs, 
0 as SOG_Mobile_Reach, 
0 as YouTube_Reach_in_MN_IRS_HHs, 
0 as YouTube_Reach_in_MN_SOG_HHs, 
0 as SOG_YouTube_Reach, 
0 as OTT_Reach_in_MN_IRS_HHs, 
0 as OTT_Reach_in_MN_SOG_HHs, 
0 as SOG_OTT_Reach, 
0 as FB_Reach_in_MN_IRS_HHs, 
0 as FB_Reach_in_MN_SOG_HHs, 
0 as SOG_FB_Reach, 
0 as OOH_Reach_in_MN_IRS_HHs, 
0 as OOH_Reach_in_MN_SOG_HHs, 
0 as SOG_OOH_Reach, 
0 as All_Media_Reach, 
0 as All_Media_Reach_in_IRS_HHs_in_Mn, 
0 as All_Media_Reach_in_SOG_HHs_in_Mn, 
0 as All_Media_Reach_SOG, 
0 as Digital_Reach_, 
0 as Digital_Reach_IRS_HHS, 
0 as Digital_Reach_SOG_HHS, 
0 as Digital_Reach_SOG, 
0 as NTV_Reach_, 
0 as NTV_Reach_IRS_HHS, 
0 as NTV_Reach_SOG_HHs, 
0 as NTV_Reach_SOG into DW.UL_MEDIA_IN_PBRT_EXTRA_MARKETS from 
(
select primary_brand_key, year, month, Category, Segment, Market, TG, type from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_month_year_brand
except
select primary_brand_key, year, month, Category, Segment, Market, TG, type from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET) a


insert into DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET select * from DW.UL_MEDIA_IN_PBRT_EXTRA_MARKETS




-- INDIA CALCULATIONS
IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_CAMPAIGN_INDIA') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_CAMPAIGN_INDIA
END  


select a.Primary_Brand_key,a.year, a.month, a.Category, a.Segment, 'India' as Market, a.TG as TG, a.[Type],
sum(isnull(a.IRS_HHs,0)) as IRS_HHs,
sum(isnull(a.SOG_HHs,0)) as SOG_HHs,
0 as TV_Penetration,
0 as TV_Reach, 

sum(a.TV_Reach_in_MN_IRS_HHs)*100/nullif(sum(a.IRS_HHs),0) as IRS_TV_Reach,
sum(a.TV_Reach_in_MN_IRS_HHs) as TV_Reach_in_MN_IRS_HHs,
sum(a.TV_Reach_in_MN_SOG_HHs) as TV_Reach_in_MN_SOG_HHs,
sum(a.TV_Reach_in_MN_SOG_HHs)*100/nullif(sum(a.SOG_HHs),0) as SOG_TV_Reach,

sum(a.Print_Reach_in_MN_IRS_HHs)*100/nullif(sum(a.IRS_HHs),0) as Print_Reach,
sum(a.Print_Reach_in_MN_IRS_HHs) as Print_Reach_in_MN_IRS_HHs,
sum(a.Print_Reach_in_MN_SOG_HHs) as Print_Reach_in_MN_SOG_HHs,
sum(a.Print_Reach_in_MN_SOG_HHs)*100/nullif(sum(a.SOG_HHs),0) as SOG_Print_Reach,

sum(a.Radio_Reach_in_MN_IRS_HHs)*100/nullif(sum(a.IRS_HHs),0) as Radio_Reach,
sum(a.Radio_Reach_in_MN_IRS_HHs) as Radio_Reach_in_MN_IRS_HHs,
sum(a.Radio_Reach_in_MN_SOG_HHs) as Radio_Reach_in_MN_SOG_HHs,
sum(a.Radio_Reach_in_MN_SOG_HHs)*100/nullif(sum(a.SOG_HHs),0) as SOG_Radio_Reach,

sum(a.Cinema_Reach_in_MN_IRS_HHs)*100/nullif(sum(a.IRS_HHs),0)  as Cinema_Reach,
sum(a.Cinema_Reach_in_MN_IRS_HHs)as Cinema_Reach_in_MN_IRS_HHs,
sum(a.Cinema_Reach_in_MN_SOG_HHs) as Cinema_Reach_in_MN_SOG_HHs,
sum(a.Cinema_Reach_in_MN_SOG_HHs)*100/nullif(sum(a.SOG_HHs),0) as SOG_Cinema_Reach,

sum(a.Mobile_Reach_in_MN_IRS_HHs)*100/nullif(sum(a.IRS_HHs),0) as Mobile_Reach,
sum(a.Mobile_Reach_in_MN_IRS_HHs) as Mobile_Reach_in_MN_IRS_HHs,
sum(a.Mobile_Reach_in_MN_SOG_HHs) as Mobile_Reach_in_MN_SOG_HHs,
sum(a.Mobile_Reach_in_MN_SOG_HHs)*100/nullif(sum(a.SOG_HHs),0) as SOG_Mobile_Reach,

case when b.YouTube_Reach <> 0 then b.YouTube_Reach else sum(a.YouTube_Reach_in_MN_IRS_HHs)*100/nullif(sum(a.IRS_HHs),0) end as YouTube_Reach,
case when b.YouTube_Reach <> 0 then b.YouTube_Reach*sum(isnull(a.IRS_HHs,0)) else sum(a.YouTube_Reach_in_MN_IRS_HHs) end as YouTube_Reach_in_MN_IRS_HHs,
case when b.YouTube_Reach <> 0 then b.YouTube_Reach*sum(isnull(a.SOG_HHs,0)) else sum(a.YouTube_Reach_in_MN_SOG_HHs) end as YouTube_Reach_in_MN_SOG_HHs,
case when b.YouTube_Reach <> 0 then b.YouTube_Reach else sum(a.YouTube_Reach_in_MN_SOG_HHs)*100/nullif(sum(a.SOG_HHs),0) end as SOG_YouTube_Reach,

case when b.OTT_Reach <> 0 then b.OTT_Reach else sum(a.OTT_Reach_in_MN_IRS_HHs)*100/nullif(sum(a.IRS_HHs),0) end as OTT_Reach,
case when b.OTT_Reach <> 0 then b.OTT_Reach*sum(isnull(a.IRS_HHs,0)) else sum(a.OTT_Reach_in_MN_IRS_HHs) end as OTT_Reach_in_MN_IRS_HHs,
case when b.OTT_Reach <> 0 then b.OTT_Reach*sum(isnull(a.SOG_HHs,0)) else sum(a.OTT_Reach_in_MN_SOG_HHs) end as OTT_Reach_in_MN_SOG_HHs,
case when b.OTT_Reach <> 0 then b.OTT_Reach else sum(a.OTT_Reach_in_MN_SOG_HHs)*100/nullif(sum(a.SOG_HHs),0) end as SOG_OTT_Reach,

case when b.FB_Reach <> 0 then b.FB_Reach else sum(a.FB_Reach_in_MN_IRS_HHs)*100/nullif(sum(a.IRS_HHs),0) end as FB_Reach,
case when b.FB_Reach <> 0 then b.FB_Reach else sum(a.FB_Reach_in_MN_IRS_HHs) end as FB_Reach_in_MN_IRS_HHs,
case when b.FB_Reach <> 0 then b.FB_Reach else sum(a.FB_Reach_in_MN_SOG_HHs) end as FB_Reach_in_MN_SOG_HHs,
case when b.FB_Reach <> 0 then b.FB_Reach else sum(a.FB_Reach_in_MN_SOG_HHs)*100/nullif(sum(a.SOG_HHs),0) end as SOG_FB_Reach,

sum(a.OOH_Reach_in_MN_IRS_HHs)*100/nullif(sum(a.IRS_HHs),0) as OOH_Reach,
sum(a.OOH_Reach_in_MN_IRS_HHs) as OOH_Reach_in_MN_IRS_HHs,
sum(a.OOH_Reach_in_MN_SOG_HHs) as OOH_Reach_in_MN_SOG_HHs,
sum(a.OOH_Reach_in_MN_SOG_HHs)*100/nullif(sum(a.SOG_HHs),0) as SOG_OOH_Reach,

1-((1-sum(a.All_Media_Reach_in_IRS_HHs_in_Mn)/nullif(sum(a.IRS_HHs),0))*(1-isnull(b.YouTube_Reach,0))*(1-isnull(b.OTT_Reach,0))*(1-isnull(b.FB_Reach,0))) as All_Media_Reach,
(1-((1-sum(a.All_Media_Reach_in_IRS_HHs_in_Mn)/nullif(sum(a.IRS_HHs),0))*(1-isnull(b.YouTube_Reach,0))*(1-isnull(b.OTT_Reach,0))*(1-isnull(b.FB_Reach,0)))) * nullif(sum(a.IRS_HHs),0) as All_Media_Reach_in_IRS_HHs_in_Mn,
(1-((1-sum(a.All_Media_Reach_in_SOG_HHs_in_Mn)/nullif(sum(a.SOG_HHs),0))*(1-isnull(b.YouTube_Reach,0))*(1-isnull(b.OTT_Reach,0))*(1-isnull(b.FB_Reach,0)))) * nullif(sum(a.SOG_HHs),0) as All_Media_Reach_in_SOG_HHs_in_Mn,
(1-((1-sum(a.All_Media_Reach_in_SOG_HHs_in_Mn)/nullif(sum(a.SOG_HHs),0))*(1-isnull(b.YouTube_Reach,0))*(1-isnull(b.OTT_Reach,0))*(1-isnull(b.FB_Reach,0)))) as All_Media_Reach_SOG,

1-((1-sum(a.Digital_Reach_IRS_HHS)/nullif(sum(a.IRS_HHs),0))*(1-isnull(b.YouTube_Reach,0))*(1-isnull(b.OTT_Reach,0))*(1-isnull(b.FB_Reach,0))) as Digital_Reach_,
(1-((1-sum(a.Digital_Reach_IRS_HHS)/nullif(sum(a.IRS_HHs),0))*(1-isnull(b.YouTube_Reach,0))*(1-isnull(b.OTT_Reach,0))*(1-isnull(b.FB_Reach,0)))) * nullif(sum(a.IRS_HHs),0) as Digital_Reach_IRS_HHS,
(1-((1-sum(a.Digital_Reach_SOG_HHS)/nullif(sum(a.SOG_HHs),0))*(1-isnull(b.YouTube_Reach,0))*(1-isnull(b.OTT_Reach,0))*(1-isnull(b.FB_Reach,0)))) * nullif(sum(a.SOG_HHs),0) as Digital_Reach_SOG_HHS,
(1-((1-sum(a.Digital_Reach_SOG_HHS)/nullif(sum(a.SOG_HHs),0))*(1-isnull(b.YouTube_Reach,0))*(1-isnull(b.OTT_Reach,0))*(1-isnull(b.FB_Reach,0)))) as Digital_Reach_SOG,

sum(a.NTV_Reach_IRS_HHS)*100/nullif(sum(a.IRS_HHs),0) as NTV_Reach_,
sum(a.NTV_Reach_IRS_HHS) as NTV_Reach_IRS_HHS,
sum(a.NTV_Reach_SOG_HHs) as NTV_Reach_SOG_HHs,
sum(a.NTV_Reach_SOG_HHs)*100/nullif(sum(a.SOG_HHs),0) as NTV_Reach_SOG


into DW.UL_MEDIA_IN_PBRT_CAMPAIGN_INDIA
from 
(select * from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET where market != 'Digital Market Cluster') a
left join 
(select * from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET where market = 'Digital Market Cluster') b
on a.Primary_Brand_key = b.Primary_Brand_key  and a.year = b.year and a.month = b.month and a.TG = b.TG and a.type = b.type

group by a.Primary_Brand_key,a.year, a.month, a.Category, a.Segment,  a.TG, a.Type, b.YouTube_Reach, b.OTT_Reach,b.FB_Reach


IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_CAMPAIGN_REACH_UNPIVOT_TABLE') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_CAMPAIGN_REACH_UNPIVOT_TABLE
END  


select * into DW.UL_MEDIA_IN_PBRT_CAMPAIGN_REACH_UNPIVOT_TABLE
from (
SELECT Primary_Brand_key,year, month, Category, Segment, Market as Market, TG, Type, Flag_Type, Value1 FROM (
SELECT Primary_Brand_key,year, month, Category, Segment, Market as Market, TG, Type,
TV_Penetration, 
IRS_HHs, 
SOG_HHs,
TV_Reach,  
Print_Reach,  
Radio_Reach,  
Cinema_Reach,  
Mobile_Reach,  
YouTube_Reach,  
OTT_Reach,  
FB_Reach,  
OOH_Reach,
IRS_TV_Reach,
TV_Reach_in_MN_IRS_HHs,
TV_Reach_in_MN_SOG_HHs,
SOG_TV_Reach,
Print_Reach_in_MN_IRS_HHs,
Print_Reach_in_MN_SOG_HHs,
SOG_Print_Reach,
Radio_Reach_in_MN_IRS_HHs,
Radio_Reach_in_MN_SOG_HHs,
SOG_Radio_Reach,
Cinema_Reach_in_MN_IRS_HHs,
Cinema_Reach_in_MN_SOG_HHs,
SOG_Cinema_Reach,
Mobile_Reach_in_MN_IRS_HHs,
Mobile_Reach_in_MN_SOG_HHs,
SOG_Mobile_Reach,
YouTube_Reach_in_MN_IRS_HHs,
YouTube_Reach_in_MN_SOG_HHs,
SOG_YouTube_Reach,
OTT_Reach_in_MN_IRS_HHs,
OTT_Reach_in_MN_SOG_HHs,
SOG_OTT_Reach,
FB_Reach_in_MN_IRS_HHs,
FB_Reach_in_MN_SOG_HHs,
SOG_FB_Reach,
OOH_Reach_in_MN_IRS_HHs,
OOH_Reach_in_MN_SOG_HHs,
SOG_OOH_Reach,
All_Media_Reach,
All_Media_Reach_in_IRS_HHs_in_Mn,
All_Media_Reach_in_SOG_HHs_in_Mn,
All_Media_Reach_SOG,
Digital_Reach_, 
Digital_Reach_IRS_HHS, 
Digital_Reach_SOG_HHS, 
Digital_Reach_SOG,
NTV_Reach_,
NTV_Reach_IRS_HHS,
NTV_Reach_SOG_HHs,
NTV_Reach_SOG
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_MARKET

union

SELECT Primary_Brand_key,year, month, Category, Segment, Market as Market, TG, Type,
TV_Penetration, 
IRS_HHs, 
SOG_HHs,
TV_Reach,  
Print_Reach,  
Radio_Reach,  
Cinema_Reach,  
Mobile_Reach,  
YouTube_Reach,  
OTT_Reach,  
FB_Reach,  
OOH_Reach,
IRS_TV_Reach,
TV_Reach_in_MN_IRS_HHs,
TV_Reach_in_MN_SOG_HHs,
SOG_TV_Reach,
Print_Reach_in_MN_IRS_HHs,
Print_Reach_in_MN_SOG_HHs,
SOG_Print_Reach,
Radio_Reach_in_MN_IRS_HHs,
Radio_Reach_in_MN_SOG_HHs,
SOG_Radio_Reach,
Cinema_Reach_in_MN_IRS_HHs,
Cinema_Reach_in_MN_SOG_HHs,
SOG_Cinema_Reach,
Mobile_Reach_in_MN_IRS_HHs,
Mobile_Reach_in_MN_SOG_HHs,
SOG_Mobile_Reach,
YouTube_Reach_in_MN_IRS_HHs,
YouTube_Reach_in_MN_SOG_HHs,
SOG_YouTube_Reach,
OTT_Reach_in_MN_IRS_HHs,
OTT_Reach_in_MN_SOG_HHs,
SOG_OTT_Reach,
FB_Reach_in_MN_IRS_HHs,
FB_Reach_in_MN_SOG_HHs,
SOG_FB_Reach,
OOH_Reach_in_MN_IRS_HHs,
OOH_Reach_in_MN_SOG_HHs,
SOG_OOH_Reach,
All_Media_Reach,
All_Media_Reach_in_IRS_HHs_in_Mn,
All_Media_Reach_in_SOG_HHs_in_Mn,
All_Media_Reach_SOG,
Digital_Reach_,
Digital_Reach_IRS_HHS, 
Digital_Reach_SOG_HHS, 
Digital_Reach_SOG,
NTV_Reach_,
NTV_Reach_IRS_HHS,
NTV_Reach_SOG_HHs,
NTV_Reach_SOG
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_INDIA
)P
UNPIVOT
(
Value1 for Flag_Type IN (TV_Penetration, IRS_HHs, SOG_HHs,TV_Reach, Print_Reach, Radio_Reach, Cinema_Reach, Mobile_Reach, YouTube_Reach,  
OTT_Reach, FB_Reach, OOH_Reach, IRS_TV_Reach,TV_Reach_in_MN_IRS_HHs, TV_Reach_in_MN_SOG_HHs, SOG_TV_Reach, Print_Reach_in_MN_IRS_HHs,
Print_Reach_in_MN_SOG_HHs, SOG_Print_Reach, Radio_Reach_in_MN_IRS_HHs, Radio_Reach_in_MN_SOG_HHs, SOG_Radio_Reach, Cinema_Reach_in_MN_IRS_HHs,
Cinema_Reach_in_MN_SOG_HHs, SOG_Cinema_Reach, Mobile_Reach_in_MN_IRS_HHs, Mobile_Reach_in_MN_SOG_HHs, SOG_Mobile_Reach,
YouTube_Reach_in_MN_IRS_HHs, YouTube_Reach_in_MN_SOG_HHs, SOG_YouTube_Reach, OTT_Reach_in_MN_IRS_HHs, OTT_Reach_in_MN_SOG_HHs,
SOG_OTT_Reach, FB_Reach_in_MN_IRS_HHs, FB_Reach_in_MN_SOG_HHs, SOG_FB_Reach, OOH_Reach_in_MN_IRS_HHs, OOH_Reach_in_MN_SOG_HHs, SOG_OOH_Reach,
All_Media_Reach, All_Media_Reach_in_IRS_HHs_in_Mn, All_Media_Reach_in_SOG_HHs_in_Mn, All_Media_Reach_SOG, Digital_Reach_,
Digital_Reach_IRS_HHS,  Digital_Reach_SOG_HHS,  Digital_Reach_SOG, NTV_Reach_, NTV_Reach_IRS_HHS, NTV_Reach_SOG_HHs,NTV_Reach_SOG)
) unpvt ) a



IF OBJECT_ID('DW.UL_MEDIA_IN_PBRT_CAMPAIGN_REACH_OUTPUT') IS NOT NULL  
BEGIN  
DROP TABLE DW.UL_MEDIA_IN_PBRT_CAMPAIGN_REACH_OUTPUT
END  

select b.Big_C,b.Small_C,b.Sub_Category,b.Segment,b.Sub_Segment,b.Primary_Brand,b.Brand,
a.Primary_Brand_Key,b.Global_Campaign_Name,

CASE WHEN a.Type like 'Post_Reach' THEN 'Post'
WHEN a.Type like 'Pre_Reach' then 'Pre' END AS Type,
-- a.Type,
a.Month,a.Year,
a.TG as Brand_TG,
CASE WHEN a.TG like '%U' THEN 'Urban'
WHEN a.TG like '% R' then 'Rural'
WHEN a.TG like '%U+R' then 'Urban + Rural' END AS Market_Type,	-- How to do it
a.Market,	
SUBSTRING(a.TG,CHARINDEX('LSM',a.TG)-1,LEN(a.TG)) as Base_Definition,
Flag_Type,
ISNULL(Value1, 0 ) as value
into DW.UL_MEDIA_IN_PBRT_CAMPAIGN_REACH_OUTPUT
from DW.UL_MEDIA_IN_PBRT_CAMPAIGN_REACH_UNPIVOT_TABLE a 
left join DW.UL_MEDIA_IN_PBRT_BRAND_HIERARCHY_MASTER b 
on a.Primary_Brand_key= b.PBRT_KEY


