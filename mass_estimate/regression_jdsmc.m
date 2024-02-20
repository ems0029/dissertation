clearvars
close all
load('jdsmc_table_11_19_23.mat')

str=["RF","T13","T14"];
robust_opt = 'ols';
for q=1:3

    switch str(q)
        case "RF"
            param_path = "..\validation_analysis\lookups\truck_params\A2_JDSMC.mat";
            title_str = "Control";
        case "T13"
            param_path = "..\validation_analysis\lookups\truck_params\T13_JDSMC.mat";
            title_str = "Leader";
        case "T14"
            param_path = "..\validation_analysis\lookups\truck_params\T14_JDSMC.mat";
            title_str = "Follower";
        otherwise
            error("truck not found")
    end
    load(param_path)
    
    RF = tbl_wfeat(tbl_wfeat.truck==str(q),:);
    RF = RF(:,6:end);
    RF = RF(~RF.decel_on,:);
    RF.UTC_time = [];
    RF.eastbound = [];
    RF.westbound = [] ;
    RF.range_estimate_drtk = [];
    RF.leading = []    ;
    RF.decel_on= []    ;
    RF.coasting_on= []  ;
    RF.fan_on = [];
%     RF = RF(RF.engine_pct_torque<2,:)
    % RF = RF(RF.decel_on==false,:)

    RF=fillmissing(RF,'nearest');
    RF=rmoutliers(RF);
    X = RF.a_estimate*1.04+9.8*(sind(RF.grade_estimate));
    y = 1.34*RF.engine_power./RF.v- RF.v.^2*truck.c_d*truck.front_area*1.177*0.5;

    ax(q) = subplot(1,3,q);
    mdl=fitlm(X,y,'RobustOpts',robust_opt);
    hold on
    mdl.plot
    legend('',sprintf('\\textbf{ %.0f} $ \\pm $ \\textbf{%.0f kg}',mdl.Coefficients.Estimate(2),1.96*mdl.Coefficients.SE(2)),'','Interpreter','latex','Location','northoutside')
    set(gcf,'position',[0 0 900 400])
    set(gca,'FontSize',14)
%     scatter(X,y,'filled',MarkerFaceAlpha=0.5)
%     refline(flip(mdl.Coefficients.Estimate))
    xlabel('x')
    title(title_str)
    fprintf('----- Truck %s ------\n Using %s robust regression\n',str(q),upper(robust_opt))
    fprintf('Model R-squared: %0.4f\n',mdl.Rsquared.Ordinary)
    fprintf('Estimated Mass: %.0f +- %.0f kg\n',mdl.Coefficients.Estimate(2),1.96*mdl.Coefficients.SE(2))
    fprintf('Estimated Crr: %.4f +- %.4f,\n C_dA = %.2f\n',...
        mdl.Coefficients.Estimate(1)/mdl.Coefficients.Estimate(2)/9.8,...
        1.96*sqrt(var_grouped(mdl)),truck.c_d*truck.front_area)

    r(q) = mdl.Rsquared.Ordinary;
    
end
linkaxes(ax)
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