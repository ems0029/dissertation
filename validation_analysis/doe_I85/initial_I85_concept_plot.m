nfc_tbl = grpstats(tbl_trim,{'truck','spacing','westbound'},"mean",'DataVars',{'fuel_rate','engine_power','P_AD_cadj','P_AD','P_AD_rls','P_aero','drag_reduction_ratio','v'})

tbl_trim.NFC(tbl_trim.truck=="A1"&tbl_trim.westbound==0)= ...
    tbl_trim.fuel_rate(tbl_trim.truck=="A1"&tbl_trim.westbound==0)./nfc_tbl{"A1_NA_0","mean_fuel_rate"};
tbl_trim.NFC(tbl_trim.truck=="A2"&tbl_trim.westbound==0)= ...
    tbl_trim.fuel_rate(tbl_trim.truck=="A2"&tbl_trim.westbound==0)./nfc_tbl{"A2_NA_0","mean_fuel_rate"};
tbl_trim.NFC(tbl_trim.truck=="A1"&tbl_trim.westbound==1)= ...
    tbl_trim.fuel_rate(tbl_trim.truck=="A1"&tbl_trim.westbound==1)./nfc_tbl{"A1_NA_1","mean_fuel_rate"};
tbl_trim.NFC(tbl_trim.truck=="A2"&tbl_trim.westbound==1)= ...
    tbl_trim.fuel_rate(tbl_trim.truck=="A2"&tbl_trim.westbound==1)./nfc_tbl{"A2_NA_1","mean_fuel_rate"};
tbl_trim.NPC(tbl_trim.truck=="A1"&tbl_trim.westbound==0)= ...
    tbl_trim.fuel_rate(tbl_trim.truck=="A1"&tbl_trim.westbound==0)./nfc_tbl{"A1_NA_0","mean_engine_power"};
tbl_trim.NPC(tbl_trim.truck=="A2"&tbl_trim.westbound==0)= ...
    tbl_trim.fuel_rate(tbl_trim.truck=="A2"&tbl_trim.westbound==0)./nfc_tbl{"A2_NA_0","mean_engine_power"};
tbl_trim.NPC(tbl_trim.truck=="A1"&tbl_trim.westbound==1)= ...
    tbl_trim.fuel_rate(tbl_trim.truck=="A1"&tbl_trim.westbound==1)./nfc_tbl{"A1_NA_1","mean_engine_power"};
tbl_trim.NPC(tbl_trim.truck=="A2"&tbl_trim.westbound==1)= ...
    tbl_trim.fuel_rate(tbl_trim.truck=="A2"&tbl_trim.westbound==1)./nfc_tbl{"A2_NA_1","mean_engine_power"};


%% groupstats
stats =grpstats(tbl_trim,{'runID','truck','spacing','westbound'},'mean','DataVars',{'engine_power','fuel_rate','P_aero','P_AD','P_AD_rls','P_AD_cadj','gear_number','v','wind_v_veh','mass_eff','fan_on','fan_power_est','drag_reduction_ratio','NFC'});
stats.trip_time = grpstats(tbl_trim,{'runID','truck','spacing','westbound'},'range','DataVars',{'time'}).range_time;
stats.net_elevation = grpstats(tbl_trim,{'runID','truck','spacing','westbound'},@(x) x(end)-x(1),'DataVars',{'alt_google'}).Fun1_alt_google;
stats.mean_P_grvt = stats.net_elevation.*stats.mean_mass_eff*9.8./stats.trip_time;
stats.mean_P_aero = 0.5*0.679*8.0779*1.225*(stats.mean_wind_v_veh).^2.*stats.mean_v;

%% drag fraction estimate
kappa = 3600/0.366/36e6; %3600 s/hr,fuel conversion efficiency,LHV in J/L
stats.NPC_inferred_nobrake = stats.mean_engine_power./(stats.mean_engine_power-0*stats.mean_P_AD+stats.mean_P_aero.*(1-stats.mean_drag_reduction_ratio));
stats.NPC_inferred = stats.mean_engine_power./(stats.mean_engine_power-stats.mean_P_AD_cadj+stats.mean_P_aero.*(1-stats.mean_drag_reduction_ratio));
stats.NFC_inferred = stats.mean_fuel_rate./(stats.mean_fuel_rate+kappa*(-stats.mean_P_AD_cadj+stats.mean_P_aero.*(1-stats.mean_drag_reduction_ratio)));
fitlm(stats.NFC_inferred,stats.mean_NFC,'y~x1')



colormap jet
hold off
scatter(stats.NPC_inferred,stats.mean_NFC,'CData',findgroups(stats.westbound))
hold on
scatter(stats.NFC_inferred,stats.mean_NFC)
axis equal
refline(1)

X =tls([1+0*stats.NFC_inferred,stats.NFC_inferred-1],stats.mean_NFC-1)