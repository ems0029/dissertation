clearvars
load('..\lookups\tbl_jdsmc_2_24_2024.mat','tbl')

%% make table
nfc_tbl = grpstats(tbl,{'truck','numTrucks','lead_ctrl','follow_ctrl','westbound','ID'},"mean",'DataVars',{'runID','refID','fuel_rate','engine_power','P_AD_cadj','P_AD','P_AD_rls','P_aero','drag_reduction_ratio','drag_reduction_ratio_husseinpwr','drag_reduction_ratio_husseinrp','v','fan_power_est','mass_eff','wind_v','wind_yaw_veh','amb_density'})
nfc_tbl.trip_time = grpstats(tbl,{'truck','numTrucks','lead_ctrl','follow_ctrl','westbound','ID'},"range",'DataVars',{'time'}).range_time

%% put into standard format

%need the group, in-group ID, test, control (fuel and power), braking (*3),
%aero (*3)
C = nfc_tbl(nfc_tbl.truck=="RF",:);
T =nfc_tbl(nfc_tbl.truck~="RF",:);
nfc_tbl = innerjoin(T,C,"LeftKeys",{'mean_refID','westbound'},"RightKeys",{'mean_runID','westbound'},"RightVariables",{'mean_engine_power','mean_fan_power_est','mean_fuel_rate','mean_mass_eff','mean_P_AD','mean_P_AD_cadj','mean_P_AD_rls','mean_P_aero','mean_v','trip_time'});

