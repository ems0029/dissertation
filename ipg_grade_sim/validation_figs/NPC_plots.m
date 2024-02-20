stats = readtable("..\processed\stats_wDrr.csv");
%% first figure
figure(1);clf;colormap("turbo")
X1 = stats.mean_v;
Y1 = stats.mean_ego_m;
Y_true = stats.mean_P_AD_true/1000;
% Y = stats.mean_P_AD./sqrt(stats.mean_mass_eff)./stats.mean_v.^2
Z = stats.mean_engine_power/1000;
scatter3(gca,X1,Y1/1000,stats.mean_NPC,'CData',stats.PRR,'MarkerFaceColor','flat','MarkerFaceAlpha',1,'MarkerEdgeColor','none','SizeData',10)
zlabel("Normalized Power Consumption")
xlabel('Mean Speed [m/s]')
ylabel('Vehicle Mass [mt]')
view(3)
set(gca,'XDir','reverse');
cbar=colorbar(gca);
cbar.Title.String = 'PRR';
cbar.Location ='northoutside'
grid on
fig1 = gcf;
exportgraphics(fig1,'NPC_mass_speed.png','Resolution',300)

scatter3(gca,X1,Y1/1000,stats.mean_NPC,'CData',stats.PIF,'MarkerFaceColor','flat','MarkerFaceAlpha',1,'MarkerEdgeColor','none','SizeData',10)
zlabel("Normalized Power Consumption")
xlabel('Mean Speed [m/s]')
ylabel('Vehicle Mass [mt]')
view(3)
set(gca,'XDir','reverse');
cbar=colorbar(gca);
cbar.Title.String = 'PIF';
cbar.Location ='northoutside'
grid on
fig1 = gcf;
exportgraphics(fig1,'NPC_mass_speed_2.png','Resolution',300)

%% second figure
stats.NPC_inferred = stats.mean_engine_power./...
    (stats.mean_engine_power...
    -stats.mean_P_AD_true+...
    stats.mean_P_aero_true.*(1./stats.mean_drag_reduction_ratio-1))
clf
colororder({'blue'})
plot([0.6,1.4],[0.6,1.4],'Color','r','LineWidth',1.25)
hold on
scatter(stats.NPC_inferred,stats.mean_NPC,'filled','SizeData',5,'MarkerFaceAlpha',0.2,'MarkerEdgeAlpha',0.2)
grid on
xlabel('NPC_{inferred}')
ylabel('NPC')
xlim([0.6 1.4])
ylim([0.6 1.4])
fig2=gcf;
exportgraphics(fig2,'NPC_vs_NPC_inferred.png','Resolution',300)
scatter3(gca,X,Y_true,stats.mean_NPC,'CData',X1,'SizeData',Y1/500,'MarkerFaceColor','flat')
xlabel('Power Reduction Ratio')
ylabel('Mean Braking Power [kW]')
zlabel("Normalized Power Consumption")
set(gca,'XDir','reverse');
cbar=colorbar(gca);
cbar.Title.String = 'Speed [m/s]';
grid on
fig2 = gcf;
exportgraphics(fig2,'NPC_PRR_Braking.png','Resolution',300)

%% third figure
Y_new = stats.mean_P_AD_true./stats.mean_v.^1.9624./(stats.mean_mass_eff.^0.3891);
scatter3(gca,X,Y_new,stats.mean_NPC,'CData',X1,'MarkerFaceColor','flat')
lmP = fitlm([X,Y_new],stats.mean_NPC,'y~x1+x2-1')
xlin = linspace(min(X), max(X), 100);
ylin = linspace(min(Y_new), max(Y_new), 100);
[X_,Y_] = meshgrid(xlin, ylin);
Z_ = reshape(lmP.predict([X_(:),Y_(:)]),size(X_));
hold on
rplane=surf(X_,Y_,Z_,'EdgeColor','none','FaceAlpha',0.3);
xlabel('Power Reduction Ratio [-]')
ylabel('P_{AD}/(m_{eff}^{0.3891}v^1.9624) ')
zlabel("Normalized Power Consumption [-]")
set(gca,'XDir','reverse');
cbar=colorbar(gca);
cbar.Title.String = 'Speed [m/s]';
clim([20,35])
legend(rplane,sprintf('Linear fit:\nNPC ~ PRR+P_{AD}/m^{\alpha}v^\beta-1\nRMSE =%.1f%% of NPC',lmP.RMSE*100),'Location','best')
grid on
fig3 = gcf;
exportgraphics(fig3,'NPC_PRR_BrakingAdjusted.png','Resolution',300)


Y_new = stats.mean_P_AD_true./stats.mean_v.^2./sqrt(stats.mean_mass_eff);
% Y_new = stats.mean_P_AD_true./stats.mean_v.^1.9624./stats.mean_mass_eff.^0.3891;
% Y_new = stats.mean_P_AD_true./stats.mean_v.^2./stats.mean_mass_eff.^0.4;
scatter3(gca,X,Y_new,stats.mean_NPC,'CData',X1,'MarkerFaceColor','flat')
% lmP = fitlm([[X;repmat([0.9;0.8;0.7;0.6],517,1)],...
%     [Y_new;repmat([0;0;0;0],517,1)]],...
%     [stats.mean_NPC;repmat([0.9;0.8;0.7;0.6],517,1)],'y~x1+x2')
lmP = fitlm([X,...
    Y_new],...
    stats.mean_NPC,'y~x1+x2-1')
xlin = linspace(min(X), max(X), 100);
ylin = linspace(min(Y_new), max(Y_new), 100);
[X_,Y_] = meshgrid(xlin, ylin);
Z_ = reshape(lmP.predict([X_(:),Y_(:)]),size(X_));
hold on
rplane=surf(X_,Y_,Z_,'EdgeColor','none','FaceAlpha',0.3);
xlabel('Power Reduction Ratio [-]')
ylabel('P_{AD}/(m_{eff}^{0.5}v^2) [kg^{0.5}/s]')
zlabel("Normalized Power Consumption [-]")
set(gca,'XDir','reverse');
cbar=colorbar(gca);
cbar.Title.String = 'Speed [m/s]';
clim([20,35])
legend(rplane,sprintf('Linear fit:\nNPC ~ PRR+P_{AD}/m^{0.5}v^2-1\nRMSE =%.1f%% of NPC',lmP.RMSE*100),'Location','best')
grid on
fig3 = gcf;
exportgraphics(fig3,'NPC_PRR_BrakingAdjusted.png','Resolution',300)



