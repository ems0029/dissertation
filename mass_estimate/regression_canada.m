clearvars
close all
addpath ..\validation_analysis\functions\
addpath ..\validation_analysis\lookups\truck_params\

% load('canada_table_12_4_23.mat')
path='F:\PatrickSmith\Canada_Fuel_Test\OT\A2\OT-CI-S75-1_2019-06-27-17-18-20.mat';
param_path = "..\validation_analysis\lookups\truck_params\A2_canada.mat";
tbl = flat_auburn_data(path);
tbl.numTrucks = repmat("AL",height(tbl),1);
tbl.truck = repmat("A2",height(tbl),1);

tbl = add_features(tbl,param_path,[1400:30000]);
robust_opt = 'ols';
title_str = "A2";
load(param_path)
kappa = 3600/0.43/36e6; %3600 s/hr,fuel conversion efficiency,LHV in J/L

tbl = tbl;
tbl = tbl(:,6:end);
tbl = tbl(tbl.P_AD==0,:);
tbl.range_estimate_drtk = [];
tbl.decel_on= []    ;
tbl.coasting_on= []  ;
tbl.fan_on = [];
tbl.brakes_on= [];
tbl.brake_by_driver= [];
tbl.gear_number= [];

%     RF = RF(RF.engine_pct_torque<2,:)
% RF = RF(RF.decel_on==false,:)

    tbl=fillmissing(tbl,'nearest');
%     tbl=rmoutliers(tbl);
X = (tbl.a_estimate)*1.04+9.8*(sind(tbl.grade_estimate));
y = 1/kappa*tbl.fuel_rate./tbl.v- tbl.v.^2*truck.c_d.*tbl.drag_reduction_ratio.*truck.front_area*1.225*0.5;

mdl=fitlm(X,y,'y~x1','RobustOpts',robust_opt);
hold on
mdl.plot
legend('',sprintf('\\textbf{ %.0f} $ \\pm $ \\textbf{%.0f kg}',mdl.Coefficients.Estimate(2),1.96*mdl.Coefficients.SE(2)),'','Interpreter','latex','Location','northoutside')
set(gcf,'position',[0 0 900 400])
set(gca,'FontSize',14)
%     scatter(X,y,'filled',MarkerFaceAlpha=0.5)
%     refline(flip(mdl.Coefficients.Estimate))
xlabel('x')
title(title_str)
fprintf('----- Truck %s ------\n Using %s robust regression\n',title_str,upper(robust_opt))
fprintf('Model R-squared: %0.4f\n',mdl.Rsquared.Ordinary)
fprintf('Estimated Mass: %.0f +- %.0f kg\n',mdl.Coefficients.Estimate(2),1.96*mdl.Coefficients.SE(2))
fprintf('Estimated Crr: %.4f +- %.4f,\n C_dA = %.2f\n',...
    mdl.Coefficients.Estimate(1)/mdl.Coefficients.Estimate(2)/9.8,...
    1.96*sqrt(var_grouped(mdl)),truck.c_d*truck.front_area)

r = mdl.Rsquared.Ordinary;
disp(mean(r))

function V_R_over_S = var_grouped(mdl)

mu_R = mdl.Coefficients.Estimate(1);
mu_S = mdl.Coefficients.Estimate(2);
covRS = mdl.CoefficientCovariance(1,2);
V_R = mdl.CoefficientCovariance(1,1);
V_S = mdl.CoefficientCovariance(2,2);

V_R_over_S = mu_R^2/mu_S^2*(V_R/mu_R^2 ...
    -2*(covRS/mu_R/mu_S) ...
    +V_S/mu_S^2);

end