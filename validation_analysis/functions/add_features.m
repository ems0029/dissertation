function subtbl = add_features(subtbl,param_path,trim)    
% add_features
% Adaptation of F:\other_scripts_2021\SAE_2023_utils\feature_engineering\splitApplyAccel_experimental.m
% this script appends estimated acceleration, modeled acceleration, 
% and deceleration, including the Deceleration power/energy loss to each unique run ID

narginchk(2,3)

addpath F:\other_scripts_2021\SAE_2023_utils\feature_engineering\

%% trim the table
%TODO make an input index
if ~exist('trim','var')
disp('using whole dataset')
else
    subtbl = subtbl(trim,:); 
end

%% vehicle offset
if sum(isnan('drtk_v2v_dist'))~=height(subtbl)
    v2v_rpv_offset = nanmedian(subtbl.drtk_v2v_dist-subtbl.range_estimate);
    subtbl.range_estimate_drtk = subtbl.drtk_v2v_dist-v2v_rpv_offset;         
end




%% fan power
subtbl = getFanOnConsumption(subtbl);

%% acceleration estimate per Chen, 2007

% tbl.a_estimate = fKalmanFiltSpeed(tbl.time,tbl.v,3.0,0);
subtbl.a_estimate = get_fir_accel(subtbl);

% the above will create some nans

%% DRR ratio per Schmid
[plen,ppos]=platoonLenPos(subtbl);
fprintf(['\n************************' ...
    '\n%s-%s classed as position %u of %u' ...
    '\n************************\n'],subtbl.truck(1),subtbl.numTrucks(1),ppos,plen)
subtbl.drag_reduction_ratio = aero_benefit_schmid(subtbl,plen,ppos);
subtbl.drag_reduction_ratio_husseinpwr = aero_benefit_hussein(subtbl,plen,ppos,'power');
subtbl.drag_reduction_ratio_husseinrp = aero_benefit_hussein(subtbl,plen,ppos,'rp');


%% modeled acceleration, requires parameter files and and the aero-drag model

subtbl.decel_on=subtbl.brake_by_driver |...
    subtbl.brakes_on |...
    subtbl.desired_ctrl_brake_rate<0 |...
    subtbl.retarder_pct_torque~=0;

subtbl = model_acceleration_with_aero(subtbl, param_path);
subtbl.a_rls = RLS(subtbl,0.995);
subtbl.a_cadj = constant_adjust(subtbl);
subtbl.a_residual = subtbl.a_modeled_w_drr-subtbl.a_estimate;
subtbl.a_residual_rls = subtbl.a_rls-subtbl.a_estimate;
subtbl.a_residual_cadj = subtbl.a_cadj-subtbl.a_estimate;

subtbl = active_deceleration_predictive(subtbl,2,false);

end
