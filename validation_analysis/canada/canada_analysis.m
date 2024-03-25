clearvars
tbl = load('..\lookups\tbl_canada_3_5_2024.mat','tbl_all').tbl_all;

tbl.engine_power_C = 22.371*pi/30*tbl.engine_pct_tq_NRC_subtbl.*tbl.engine_speed_NRC_subtbl;
tbl.fuel_rate_C = tbl.engine_fuel_rate_NRC_subtbl;

%% Normalized Fuel Consumption
nfc_tbl = grpstats(tbl,{'truck','numTrucks','spacing','ID'},"mean",'DataVars', ...
    {'engine_power','fuel_rate','P_AD_cadj','P_AD','P_AD_rls','P_aero', ...
    'P_aero_wind','drag_reduction_ratio','drag_reduction_ratio_husseinpwr', ...
    'drag_reduction_ratio_husseinrp','v','fan_power_est','mass_eff','wind_v', ...
    'wind_v_veh','wind_yaw_veh','amb_density','engine_power_C','fuel_rate_C'});
nfc_tbl.trip_time = grpstats(tbl,{'truck','numTrucks','spacing','ID'},"range", ...
    'DataVars',{'time'}).range_time;
nfc_tbl.bsln = any(lower(nfc_tbl.numTrucks)=={'rf'},2);

%% T/C format
% while the table already contain T and C information, doing this the same
% way as for the other datasets

C = nfc_tbl;
C.mean_engine_power = C.mean_engine_power_C;
C.mean_fuel_rate = C.mean_fuel_rate_C;
T = nfc_tbl;
nfc_tbl = innerjoin(T,C,"LeftKeys",{'ID'},"RightKeys",{'ID'},"RightVariables", ...
    {'mean_engine_power','mean_fan_power_est','mean_fuel_rate','mean_mass_eff','mean_P_AD','mean_P_AD_cadj','mean_P_AD_rls','mean_P_aero','mean_P_aero_wind','mean_v','trip_time'});

nfc_tbl.G =findgroups(nfc_tbl.truck);
nfc_tbl.N =findgroups(nfc_tbl.G,nfc_tbl.ID);
nfc_tbl = movevars(nfc_tbl,{'G','N'},"Before","truck");

%% augmented nfc table
nfc_tbl_aug = cell(max(nfc_tbl.G),1);
for q = 1:max(nfc_tbl.G)
    combos = nchoosek(nfc_tbl.N(nfc_tbl.G==q),2);
    tblArr = cell(length(combos),1);
    for qq = 1:length(combos)
        plat = nfc_tbl(nfc_tbl.N==combos(qq,1),:);
        ref = nfc_tbl(nfc_tbl.N==combos(qq,2),:);
        tblArr{qq} = join(plat,ref,"Keys","G");
    end
    nfc_tbl_aug{q} = vertcat(tblArr{:});
end

nfc_tbl_aug = vertcat(nfc_tbl_aug{:});
nfc_tbl_aug = movevars(nfc_tbl_aug,"N_ref","After","N_plat");
%% add NPC/NFC
nfc_tbl_aug = process_nfc_tbl(nfc_tbl_aug,'husseinrp','cadj',true);

scatter(nfc_tbl_aug.NPC_inf,nfc_tbl_aug.NPC_true,'filled')
fitlm([nfc_tbl_aug.NPC_inf-1,nfc_tbl_aug.G],nfc_tbl_aug.NPC_true-1,'CategoricalVars','x2')
hold on
scatter(nfc_tbl_aug.NFC_inf,nfc_tbl_aug.NFC_true,'filled')
fitlm([nfc_tbl_aug.NFC_inf-1,nfc_tbl_aug.G],nfc_tbl_aug.NFC_true-1,'CategoricalVars','x2')
xlabel('Inferred Change [ratio]')
ylabel('Actual Change [ratio]')
legend('Power Basis','Fuel Basis')
