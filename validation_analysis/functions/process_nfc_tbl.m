function nfc_tbl_aug = process_nfc_tbl(nfc_tbl_aug,drr_model,P_AD_adjustment,use_wind,eta)
narginchk(3,5)
if ~exist('use_wind','var')
    use_wind=false;
end
if ~exist('eta','var')
    eta=0.366;
end
% take in an augmented nfc table and add the normalized fuel consumption to
% it
%% remove baseline compares
nfc_tbl_aug(nfc_tbl_aug.bsln_plat&nfc_tbl_aug.bsln_ref,:)=[];

rng('default')
flip = (-0.5+(rand(height(nfc_tbl_aug),1)>=0.5))*2;
nfc_tbl_aug.flip = flip;

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

if use_wind
    P_aero_plat = nfc_tbl_aug.mean_P_aero_wind_T_plat;
    P_aero_ref = nfc_tbl_aug.mean_P_aero_wind_T_ref;
else
    P_aero_plat = nfc_tbl_aug.mean_P_aero_T_plat;
    P_aero_ref = nfc_tbl_aug.mean_P_aero_T_ref;
end


nfc_tbl_aug.NPC_true = ... 
    (( P_plat.T ./ P_plat.C )./... %TC plat
    ( P_ref.T ./ P_ref.C )).^flip; %TC ref
nfc_tbl_aug.delP_true = ... 
    (( P_plat.T ./ P_plat.C )-... %TC plat
    ( P_ref.T ./ P_ref.C )).*mean([P_plat.C,P_ref.C],2).*flip; %TC ref

nfc_tbl_aug.NPC_inf = ...
    (P_plat.T./ ...
    (P_plat.T - (P_AD_plat + P_aero_plat.*DRR_plat)+(P_AD_ref+P_aero_ref.*DRR_ref))).^flip;
nfc_tbl_aug.delP_inf = ...
    ((P_AD_plat + P_aero_plat.*DRR_plat)-(P_AD_ref+P_aero_ref.*DRR_ref)).*flip;
nfc_tbl_aug.delPAD = ...
    ((P_AD_plat)-(P_AD_ref)).*flip;
nfc_tbl_aug.delP_fan = ...
    1000*(nfc_tbl_aug.mean_fan_power_est_T_plat-nfc_tbl_aug.mean_fan_power_est_T_ref).*flip;
nfc_tbl_aug.delPaero = ...
    ((P_aero_plat.*DRR_plat)-(P_aero_ref.*DRR_ref)).*flip;

%% fuel
nfc_tbl_aug.NFC_true = ...
    (( F_plat.T ./ F_plat.C ) ./...
    ( F_ref.T ./  F_ref.C )).^flip;
nfc_tbl_aug.delF_true = ...
    (( F_plat.T ./ F_plat.C )-...
    ( F_ref.T ./  F_ref.C )).*mean([F_plat.C,F_ref.C],2).*flip;

nfc_tbl_aug.NFC_inf = ...
    (F_plat.T ./ ...
    ( F_plat.T +...
    kappa(eta)*((P_AD_ref+P_aero_ref.*DRR_ref) - (P_AD_plat + P_aero_plat.*DRR_plat)) )).^flip;

nfc_tbl_aug.delF_inf = ...
    kappa(eta)*(-(P_AD_ref+P_aero_ref.*DRR_ref) + (P_AD_plat + P_aero_plat.*DRR_plat)).*flip;
nfc_tbl_aug.delFAD = ...
    kappa(eta)*((P_AD_plat)-(P_AD_ref)).*flip;
nfc_tbl_aug.delF_fan = ...
    kappa(eta)*1000*(nfc_tbl_aug.mean_fan_power_est_T_plat-nfc_tbl_aug.mean_fan_power_est_T_ref).*flip;
nfc_tbl_aug.delFaero = ...
    kappa(eta)*((P_aero_plat.*DRR_plat)-(P_aero_ref.*DRR_ref)).*flip;
end