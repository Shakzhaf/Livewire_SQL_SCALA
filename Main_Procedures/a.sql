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
nullif(sum(case when a.Medium in ('YT') and c.Medium is null then a.Value else 0 end)/100,0) as YouTube_Reach,  
nullif(sum(case when a.Medium in ('OTT') and c.Medium is null then a.Value else 0 end)/100,0) as OTT_Reach,  
nullif(sum(case when a.Medium in ('FB') and c.Medium is null then a.Value else 0 end)/100,0) as FB_Reach,  
nullif(sum(case when a.Medium in ('OOH') then a.Value else 0 end)/100,0) as OOH_Reach,

isnull(b.TV_Penetration,0)/100 * sum(case when a.Medium in ('TV') then a.Value else 0 end) as IRS_TV_Reach,
isnull(b.TV_Penetration,0)/100 * sum(case when a.Medium in ('TV') then a.Value else 0 end) * isnull(b.IRS_HHs,0)/100 as TV_Reach_in_MN_IRS_HHs,
isnull(b.TV_Penetration,0)/100 * sum(case when a.Medium in ('TV') then a.Value else 0 end) * isnull(b.SOG_HHs,0)/100 as TV_Reach_in_MN_SOG_HHs,
isnull(b.TV_Penetration,0)/100 * sum(case when b.SOG_HHs = 0 then 0 when a.Medium in ('TV') then a.Value else 0 end) as SOG_TV_Reach,

-- isnull(b.TV_Penetration,0)/100 * sum(case when a.Medi