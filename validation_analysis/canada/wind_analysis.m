% wind analysis
load('..\lookups\tbl_canada_2_15_2024.mat','tbl')

nfc_tbl = grpstats(tbl,{'truck','numTrucks','spacing','ID'},"mean",'DataVars',{'fuel_rate','engine_power','P_AD_cadj','P_AD','P_AD_rls','P_aero','drag_reduction_ratio','drag_reduction_ratio_husseinpwr','drag_reduction_ratio_husseinrp','v'})
nfc_tbl.trip_time = grpstats(tbl,{'truck','numTrucks','spacing','ID'},"range",'DataVars',{'time'}).range_time

%% wind plot
e_dir = abs(abs(smoothdata(tbl.windDir_WS_NRC,'movmean',6000)-tbl.wind_dir_abs)-2*mod(abs(smoothdata(tbl.windDir_WS_NRC,'movmean',6000)-tbl.wind_dir_abs),180));
plot(e_dir)
rms(e_dir)
median(e_dir)

ID = findgroups(tbl.truck,tbl.numTrucks,tbl.otherId,tbl.spacing,tbl.runIter);
z0 = [0.01:0.01:2]
for q = 1:length(z0) 
    e_wind_v(q) = rmse(tbl.windSpeed_WS_NRC,body_axis_wind(tbl,z0(q)).wind_v);
end

plot(z0,e_wind_v)
xlabel('z_0 [m]')
ylabel('RMSE [m/s]')
grid on
ylim([0 2.5])

clf
plot(tbl.windSpeed_WS_NRC)
hold on
plot(body_axis_wind(tbl,0.2).wind_v,'LineWidth',2)


