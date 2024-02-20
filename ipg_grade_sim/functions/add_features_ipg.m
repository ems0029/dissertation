function tbl = add_features_ipg(tbl)
% add_features
% Adaptation of F:\other_scripts_2021\SAE_2023_utils\feature_engineering\splitApplyAccel_experimental.m
% this script appends estimated acceleration, modeled acceleration,
% and deceleration, including the Deceleration power/energy loss to each unique run ID

narginchk(1,2)

addpath F:\other_scripts_2021\SAE_2023_utils\feature_engineering\

%% noisy wheelspeed
rng('default')
tbl.v_noise = tbl.v+randn(height(tbl),1).*0.02;

%% acceleration estimate per Chen, 2007

% tbl.a_estimate = fKalmanFiltSpeed(tbl.time,tbl.v,3.0,0);
tbl.a_estimate = fKalmanFiltSpeed(tbl.time,tbl.v_noise,56.0,0);
% the above will create some nans


%% modeled acceleration, requires parameter files and and the aero-drag model

tbl = model_acceleration_with_aero_ipg(tbl);
% model_checks_ipg(tbl)

tbl.a_residual = tbl.a_estimate - tbl.a_modeled_w_drr;

tbl = active_deceleration_predictive_ipg(tbl,0,true);
% catch ME
%     disp(ME)
% end
end
