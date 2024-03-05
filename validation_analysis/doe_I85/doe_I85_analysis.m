load('..\lookups\tbl_I85_3_4_2024.mat','tbl')

tbl_trim = tbl(tbl.east>-30000&tbl.east<-1000,:);

%regeneration? invalidating
tbl_trim(tbl_trim.runID==1,:)=[];

tbl_trim.P_aero = 0.5*0.55*10.*1.225.*(tbl_trim.v).^2.*tbl_trim.v;
tbl_trim.P_aero_wind = 0.5*0.55*10.*tbl_trim.amb_density.*(tbl_trim.wind_v_veh).^2.*tbl_trim.v;

%% Make Table
nfc_tbl = grpstats(tbl_trim,{'truck','spacing','westbound','ID'},"mean",'DataVars',{'engine_power','fuel_rate','P_AD_cadj','P_AD','P_AD_rls','P_aero','P_aero_wind','drag_reduction_ratio','drag_reduction_ratio_husseinpwr','drag_reduction_ratio_husseinrp','v','fan_power_est','mass_eff','wind_v','wind_v_veh','wind_yaw_veh','amb_density'});
nfc_tbl.trip_time = grpstats(tbl_trim,{'truck','spacing','westbound','ID'},"range",'DataVars',{'time'}).range_time;

%% put into standard format

% need the group, in-group ID, test, control (fuel and power), braking (*3),
% aero (*3) 

% C is just a dummy table here, since there was no control truck
C = nfc_tbl;
C{:,{'mean_fuel_rate','mean_engine_power'}}=ones(height(C),2);
T = nfc_tbl;
nfc_tbl = innerjoin(T,C,"LeftKeys",{'ID','westbound'},"RightKeys",{'ID','westbound'},"RightVariables",{'mean_engine_power','mean_fan_power_est','mean_fuel_rate','mean_mass_eff','mean_P_AD','mean_P_AD_cadj','mean_P_AD_rls','mean_P_aero','mean_P_aero_wind','mean_v','trip_time'});

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
nfc_tbl_aug = movevars(nfc_tbl_aug,"N_ref","After","N_plat");
%% add NPC/NFC
nfc_tbl_aug = process_nfc_tbl(nfc_tbl_aug,'husseinrp','none',false);

scatter(nfc_tbl_aug.NPC_inf,nfc_tbl_aug.NPC_true,'filled')
fitlm([nfc_tbl_aug.NPC_inf-1,nfc_tbl_aug.G],nfc_tbl_aug.NPC_true-1,'CategoricalVars','x2')
hold on
scatter(nfc_tbl_aug.NFC_inf,nfc_tbl_aug.NFC_true,'filled')
fitlm([nfc_tbl_aug.NFC_inf-1,nfc_tbl_aug.G],nfc_tbl_aug.NFC_true-1,'CategoricalVars','x2')
xlabel('Inferred Change [ratio]')
ylabel('Actual Change [ratio]')
legend('Power Basis','Fuel Basis')
axis equal
