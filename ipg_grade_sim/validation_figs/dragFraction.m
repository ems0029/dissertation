%% Power Reduction ratio
stats =readtable('..\processed\stats_wDrr.csv');
addpath('..\functions\')
clearvars [fig1 fig2]

stats.P_R = stats.mean_P_aero_true./(stats.mean_P_aero_true+stats.mean_P_rr_true);

stats_1 = stats(ismember(stats.mean_drag_reduction_ratio,1.0),:);
v = stats_1.mean_v;
m = stats_1.mean_ego_m;
xlin = linspace(min(v),max(v),100);
ylin = linspace(min(m),max(m),100);
[X,Y] = meshgrid(xlin,ylin);
lm_P_R = stepwiselm(stats_1(:,{'mean_v','mean_ego_m','P_R'}),'P_R~mean_v^2+mean_ego_m^2')
P_R_hat = reshape(lm_P_R.predict([X(:),Y(:)]),size(X))
fig1 = figure(1);clf
contourf(X,Y/1000,P_R_hat*100,'ShowText','on','LabelFormat','%2.0f %%','LabelSpacing',5000)
xlabel('Velocity [m/s]');ylabel('Truck Mass [mt]');
exportgraphics(fig1,'dragFraction.png','Resolution',300)