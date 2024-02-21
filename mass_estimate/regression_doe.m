clearvars
close all
addpath ..\validation_analysis\functions\
addpath(genpath('..\validation_analysis\lookups'))

% load('canada_table_12_4_23.mat')
load('..\validation_analysis\lookups\tbl_doeTestTrack_2_14_2024.mat','subtbl')
title_str = "A1";
param_path = "A1_doe.mat";
load(param_path)

subtbl =tbl(tbl.truck==title_str&tbl.numTrucks=="Baseline",:);

robust_opt = 'ols';

kappa = 3600/0.45/36e6; %3600 s/hr,fuel conversion efficiency,LHV in J/L

subtbl = subtbl;
subtbl = subtbl(abs(subtbl.fuel_rate)>8,:);
subtbl = subtbl(~isoutlier(gradient(subtbl.a_estimate)),:);
subtbl.range_estimate_drtk = [];
subtbl.leading = [];
subtbl.decel_on= []    ;
subtbl.coasting_on= []  ;
subtbl.fan_on = [];
subtbl.brakes_on= [];
subtbl.brake_by_driver= [];
subtbl.gear_number= [];


%     RF = RF(RF.engine_pct_torque<2,:)
% RF = RF(RF.decel_on==false,:)

subtbl=fillmissing(subtbl,'nearest');
%     tbl=rmoutliers(tbl);
y = subtbl.a_estimate*1.04+9.8*(sind(subtbl.grade_estimate_lookup));
X = 1/kappa*subtbl.fuel_rate./subtbl.v- subtbl.v.^2*truck.c_d.*subtbl.drag_reduction_ratio.*truck.front_area*1.177*0.5;

clf
mdl=fitlm(X,y,'y~x1','RobustOpts',robust_opt);
m = 1/mdl.Coefficients.Estimate(2)
b = -mdl.Coefficients.Estimate(1)/mdl.Coefficients.Estimate(2)

hold on
mdl.plot
legend('',sprintf('\\textbf{ %.0f} $ \\pm $ \\textbf{%.0f kg}',m,1.96*mdl.Coefficients.SE(2)*m^2),'','Interpreter','latex','Location','northoutside')
set(gcf,'position',[0 0 900 400])
set(gca,'FontSize',14)
%     scatter(X,y,'filled',MarkerFaceAlpha=0.5)
%     refline(flip(mdl.Coefficients.Estimate))
xlabel('x')
title(title_str)
fprintf('----- Truck %s ------\n Using %s robust regression\n',title_str,upper(robust_opt))
fprintf('Model R-squared: %0.4f\n',mdl.Rsquared.Ordinary)
fprintf('Estimated Mass: %.0f +- %.0f kg\n',m,1.96*mdl.Coefficients.SE(2)*m^2)
fprintf('Estimated Crr: %.4f +- %.4f,\n C_dA = %.2f\n',...
    b/m/9.8,...
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