clearvars
load('..\lookups\tbl_jdsmc_2_24_2024.mat','tbl')

%% make table
nfc_tbl = grpstats(tbl,{'truck','numTrucks','lead_ctrl','follow_ctrl','westbound','ID'},"mean",'DataVars',{'refID','fuel_rate','engine_power','P_AD_cadj','P_AD','P_AD_rls','P_aero','drag_reduction_ratio','drag_reduction_ratio_husseinpwr','drag_reduction_ratio_husseinrp','v','fan_power_est','mass_eff'})
nfc_tbl.trip_time = grpstats(tbl,{'truck','numTrucks','lead_ctrl','follow_ctrl','westbound','ID'},"range",'DataVars',{'time'}).range_time

