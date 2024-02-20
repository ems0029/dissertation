clearvars
close all
addpath ..\validation_analysis\functions\
addpath ..\validation_analysis\lookups\truck_params\

% load('canada_table_12_4_23.mat')
path="F:\ACM_2019_data\4T_100\A2_4T_100_1_2019-10-24-08-23-35.mat";
path="F:\ACM_2019_data\4T_100\A2_4T_100_2_2019-10-24-10-33-42.mat";
path="F:\ACM_2019_data\4T_50\A2_4T_50_2_2019-10-24-14-18-56.mat";
path="F:\ACM_2021_data\A2\5_15\A2_CutIn_2_2021-05-15-11-28-32.mat";
param_path = "A2_doe.mat";
tbl = flat_auburn_data(path);
tbl.leading = false(height(tbl),1);
tbl = add_features(tbl,param_path,[1400:30000]);
robust_opt = 'andrews';
title_str = "A2";
load(param_path)

tbl = tbl;
tbl = tbl(:,6:end);
tbl = tbl(~tbl.decel_on,:);
tbl.range_estimate_drtk = [];
tbl.leading = [];
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
X = smoothdata(tbl.a_estimate)*1.04+9.8*(sind(tbl.grade_estimate));
y = 1.34*tbl.engine_power./tbl.v- tbl.v.^2*truck.c_d.*tbl.drag_reduction_ratio.*truck.front_area*1.177*0.5;

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