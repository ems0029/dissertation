load('..\lookups\tbl_canada_2_15_2024.mat','tbl')


%% Normalized Fuel Consumption
nfc_tbl = grpstats(tbl,{'truck','numTrucks','spacing','ID'},"mean",'DataVars',{'fuel_rate','engine_power','P_AD_cadj','P_AD','P_AD_rls','P_aero','drag_reduction_ratio','drag_reduction_ratio_husseinpwr','drag_reduction_ratio_husseinrp','v','fan_power_est'})
nfc_tbl.trip_time = grpstats(tbl,{'truck','numTrucks','spacing','ID'},"range",'DataVars',{'time'}).range_time

