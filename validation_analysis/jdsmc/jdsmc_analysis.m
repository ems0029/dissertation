clearvars
load('..\lookups\tbl_jdsmc_2_24_2024.mat','tbl')

%% make table
nfc_tbl = grpstats(tbl,{'truck','numTrucks','lead_ctrl','follow_ctrl','westbound','ID'},"mean",'DataVars',{'runID','refID','fuel_rate','fuel_rate','P_AD_cadj','P_AD','P_AD_rls','P_aero','drag_reduction_ratio','drag_reduction_ratio_husseinpwr','drag_reduction_ratio_husseinrp','v','fan_power_est','mass_eff','wind_v','wind_yaw_veh','amb_density'})
nfc_tbl.trip_time = grpstats(tbl,{'truck','numTrucks','lead_ctrl','follow_ctrl','westbound','ID'},"range",'DataVars',{'time'}).range_time

%% put into standard format

%need the group, in-group ID, test, control (fuel and power), braking (*3),
%aero (*3)
C = nfc_tbl(nfc_tbl.truck=="RF",:);
T =nfc_tbl(nfc_tbl.truck~="RF",:);
nfc_tbl = innerjoin(T,C,"LeftKeys",{'mean_refID','westbound'},"RightKeys",{'mean_runID','westbound'},"RightVariables",{'mean_engine_power','mean_fan_power_est','mean_fuel_rate','mean_mass_eff','mean_P_AD','mean_P_AD_cadj','mean_P_AD_rls','mean_P_aero','mean_v','trip_time'});

nfc_tbl.G =findgroups(nfc_tbl.truck,nfc_tbl.westbound);
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
nfc_tbl_aug =movevars(nfc_tbl_aug,"N_ref","After","N_plat");
% TODO make this calculation mistake-proof! swappable elements (hussein,
% cadj, rls) in a function form
nfc_tbl_aug.NPC_true = (nfc_tbl_aug.mean_engine_power_T_plat./nfc_tbl_aug.mean_engine_power_C_plat)./(nfc_tbl_aug.mean_engine_power_T_ref./nfc_tbl_aug.mean_engine_power_C_ref)
nfc_tbl_aug.NPC_inf = nfc_tbl_aug.mean_engine_power_T_plat./(nfc_tbl_aug.mean_engine_power_T_plat-(nfc_tbl_aug.mean_P_AD_cadj_T_plat+nfc_tbl_aug.mean_P_aero_T_plat.*nfc_tbl_aug.mean_drag_reduction_ratio_plat)+(nfc_tbl_aug.mean_P_AD_cadj_T_ref+nfc_tbl_aug.mean_P_aero_T_ref.*nfc_tbl_aug.mean_drag_reduction_ratio_ref))
nfc_tbl_aug.NFC_true = (nfc_tbl_aug.mean_fuel_rate_T_plat./nfc_tbl_aug.mean_fuel_rate_C_plat)./(nfc_tbl_aug.mean_fuel_rate_T_ref./nfc_tbl_aug.mean_fuel_rate_C_ref)
nfc_tbl_aug.NFC_inf = nfc_tbl_aug.mean_fuel_rate_T_plat./...
    (nfc_tbl_aug.mean_fuel_rate_T_plat-...
    kappa()*( (nfc_tbl_aug.mean_P_AD_cadj_T_plat+ ...
    nfc_tbl_aug.mean_P_aero_T_plat.*nfc_tbl_aug.mean_drag_reduction_ratio_plat)- ...
    (nfc_tbl_aug.mean_P_AD_cadj_T_ref+ ...
    nfc_tbl_aug.mean_P_aero_T_ref.*nfc_tbl_aug.mean_drag_reduction_ratio_ref)))

scatter(nfc_tbl_aug.NPC_inf,nfc_tbl_aug.NPC_true,'filled')
fitlm([nfc_tbl_aug.NPC_inf-1,nfc_tbl_aug.G],nfc_tbl_aug.NPC_true-1,'CategoricalVars','x2')
hold on
scatter(nfc_tbl_aug.NFC_inf,nfc_tbl_aug.NFC_true,'filled')
fitlm([nfc_tbl_aug.NFC_inf-1,nfc_tbl_aug.G],nfc_tbl_aug.NFC_true-1,'CategoricalVars','x2')
xlabel('Inferred Change [ratio]')
ylabel('Actual Change [ratio]')
legend('Power Basis','Fuel Basis')
