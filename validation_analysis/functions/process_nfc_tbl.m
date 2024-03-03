function nfc_tbl_aug = process_nfc_tbl(nfc_tbl_aug,drr_model,P_AD_adjustment)
% take in an augmented nfc table and add the normalized fuel consumption to
% it
%% power
P_plat.T = nfc_tbl_aug.mean_engine_power_T_plat;
P_plat.C = nfc_tbl_aug.mean_engine_power_C_plat;
P_ref.T = nfc_tbl_aug.mean_engine_power_T_ref;
P_ref.C = nfc_tbl_aug.mean_engine_power_C_ref;
F_plat.T = nfc_tbl_aug.mean_fuel_rate_T_plat;
F_plat.C = nfc_tbl_aug.mean_fuel_rate_C_plat;
F_ref.T = nfc_tbl_aug.mean_fuel_rate_T_ref;
F_ref.C = nfc_tbl_aug.mean_fuel_rate_C_ref;
switch lower(P_AD_adjustment)
    case 'rls'
        P_AD_plat = nfc_tbl_aug.mean_P_AD_rls_T_plat;
        P_AD_ref = nfc_tbl_aug.mean_P_AD_rls_T_ref;
        fprintf('RLS braking adjustments applied\n')
    case 'cadj'
        P_AD_plat = nfc_tbl_aug.mean_P_AD_cadj_T_plat;
        P_AD_ref = nfc_tbl_aug.mean_P_AD_cadj_T_ref;
        fprintf('Constant offset braking adjustments applied\n')
    otherwise
        P_AD_plat = nfc_tbl_aug.mean_P_AD_T_plat;
        P_AD_ref = nfc_tbl_aug.mean_P_AD_T_ref;
        fprintf('No braking adjustments applied\n')
end

switch lower(drr_model)
    case 'husseinpwr'
        DRR_plat = nfc_tbl_aug.mean_drag_reduction_ratio_husseinpwr_plat;
        DRR_ref = nfc_tbl_aug.mean_drag_reduction_ratio_husseinpwr_ref;
        fprintf('Using the Hussein Power Law DRR model\n')
    case 'husseinrp'
        DRR_plat = nfc_tbl_aug.mean_drag_reduction_ratio_husseinrp_plat;
        DRR_ref = nfc_tbl_aug.mean_drag_reduction_ratio_husseinrp_ref;
        fprintf('Using the Hussein Rational Polynomial DRR model\n')
    otherwise
        DRR_plat = nfc_tbl_aug.mean_drag_reduction_ratio_plat;
        DRR_ref = nfc_tbl_aug.mean_drag_reduction_ratio_ref;
        fprintf('Using the Schmid DRR model\n')
end
P_aero_plat = nfc_tbl_aug.mean_P_aero_T_plat;
P_aero_ref = nfc_tbl_aug.mean_P_aero_T_ref;


nfc_tbl_aug.NPC_true = ... 
    ( P_plat.T ./ P_plat.C )./... %TC plat
    ( P_ref.T ./ P_ref.C ); %TC ref

nfc_tbl_aug.NPC_inf = ...
    P_plat.T./ ...
    (P_plat.T - (P_AD_plat + P_aero_plat.*DRR_plat)+(P_AD_ref+P_aero_ref.*DRR_ref));
%% fuel
nfc_tbl_aug.NFC_true = ...
    ( F_plat.T ./ F_plat.C ) ./...
    ( F_ref.T ./  F_ref.C );

nfc_tbl_aug.NFC_inf = ...
    F_plat.T ./ ...
    ( F_plat.T +...
    kappa()*((P_AD_ref+P_aero_ref.*DRR_ref) - (P_AD_plat + P_aero_plat.*DRR_plat)) );

end