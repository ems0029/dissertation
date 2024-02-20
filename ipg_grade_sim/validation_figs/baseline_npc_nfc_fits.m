stats =readtable('..\processed\stats_wDrr.csv');
addpath('..\functions\')
clearvars [fig1 fig2]
close all
Xy_C = stats(stats.truck=="C",{'mean_v','mean_ego_m','mean_engine_power'});
Xy_L = stats(stats.truck=="L",{'mean_v','mean_ego_m','mean_engine_power'});
Xy_C_fuel = stats(stats.truck=="C",{'mean_v','mean_ego_m','mean_fuel_rate','mean_engine_rpm'});
Xy_L_fuel = stats(stats.truck=="L",{'mean_v','mean_ego_m','mean_fuel_rate','mean_engine_rpm'});

[nn_C,rmse_C] = nn_power(Xy_C);
[nn_L,rmse_L] = nn_power(Xy_L);

fig1 = figure(1);clf;hold on
v = Xy_C.mean_v;
m_s = Xy_C.mean_ego_m;
power = Xy_C.mean_engine_power;
xlin = linspace(min(v), max(v), 47);
ylin = linspace(min(m_s), max(m_s), 11);
[X,Y] = meshgrid(xlin, ylin);
Z = reshape(nn_C.predict([X(:),Y(:)]),size(X));
pts = scatter3(v,m_s/1000,power/1000,'k.');
fit = surface(X,Y/1000,Z/1000,'FaceAlpha',0.5,'EdgeColor','none')
xlabel('Velocity [m/s]');ylabel('Truck Mass [mt]');zlabel('Mean Power Demand [kW]')
view(3)
legend([pts,fit],{'Brakeless Reference Results','Neural Network Fit'},'Location','best')
exportgraphics(fig1,'baseline_npc_fit.png','Resolution',300)

fig2=figure(2);clf;hold on
Z = griddata(v,m_s,power-nn_C.predict([v,m_s]),X,Y,'v4');
contourf(X,Y/1000,Z/1000,'ShowText','on',"LabelFormat","%0.1f kW",'LabelSpacing',600,'TextStep',0.2,'EdgeColor','none')
title('Power Demand Regression Error Contour')
xlabel('Velocity [m/s]');ylabel('Truck Mass [mt]');
cbar=colorbar(gca);
cbar.Title.String='Error [kW]';
exportgraphics(fig2,'npc_fit_errorContour.png','Resolution',300)


fig3 = figure(3);clf;hold on;
v = stats.mean_v;
m = stats.mean_ego_m;
xlin = linspace(min(v), max(v), 100);
ylin = linspace(min(m), max(m), 100);
[X,Y_true] = meshgrid(xlin, ylin);
Z_C = reshape(nn_C.predict([X(:),Y_true(:)]),size(X));
Z_L = reshape(nn_L.predict([X(:),Y_true(:)]),size(X));pts =scatter3(v,m/1000,stats.mean_engine_power/1000,'k.')
csur=  surface(X,Y_true/1000,Z_C/1000,'EdgeColor','none','FaceAlpha',0.75)
% surface(X,Y_true,Z_L/1000,'EdgeColor','none','FaceAlpha',0.75)
xlabel('Mean Speed [m/s]');ylabel('Vehicle Mass [mt]');zlabel('Mean Power Consumption [kW]')
legend([pts,csur],{'Individual Simulations','Brakeless Reference Surface'})
