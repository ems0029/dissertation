stats = readtable("processed\stats_wDrr.csv");
stats.brakes = stats.mean_P_AD_true/1000;
stats.brakes_simplified = stats.mean_P_AD_true./sqrt(stats.mean_mass_eff)./stats.mean_v.^2
stats.brakes_est = stats.mean_P_AD/1000;
stats.brakes_simplified_est = stats.mean_P_AD./sqrt(stats.mean_mass_eff)./stats.mean_v.^2
stats.drf = 1-round(stats.mean_drag_reduction_ratio,2);
stats.npcr = stats.mean_NPC-1;

hold on
scatter3(stats.brakes,stats.drr,stats.npcr,'filled','CData',stats.mean_v)
%% full
lm_true = stepwiselm(stats(:,{'brakes','drf','npcr','mean_v','mean_mass_eff'}),...
    'npcr~brakes*drf*mean_v^2*mean_mass_eff-1')
lm_true =lm_true.removeTerms('brakes:drf:mean_v^2:mean_mass_eff+drf+1+mean_v^2:mean_mass_eff+mean_v:mean_mass_eff+mean_v^2+mean_mass_eff')
lm_true.plot
lm_true.plotDiagnostics
lm_true.plotSlice

lm_est = stepwiselm(stats(:,{'brakes_est','drf','npcr','mean_v','mean_mass_eff'}),...
    'npcr~brakes_est*drf*mean_v^2*mean_mass_eff-1')
lm_est =lm_est.removeTerms('brakes_est:drf:mean_v^2:mean_mass_eff+drf+1+mean_v^2:mean_mass_eff+mean_v:mean_mass_eff+mean_v^2+mean_mass_eff')
lm_est.plotSlice

% visualize versus drf and braking
pb = linspace(0,50,100)';
drf = linspace(0,0.5,100)';
[X,Y] = meshgrid(pb, drf);
m = ones(size(X)); % unladen, kg
v = ones(size(X)); % unladen, kg
npcr_hat_45 = reshape(lm_true.predict([X(:),Y(:),20.1168*v(:),16500*m(:)]),size(X));
npcr_hat_45l = reshape(lm_true.predict([X(:),Y(:),20.1168*v(:),29400*m(:)]),size(X));
npcr_hat_65 = reshape(lm_true.predict([X(:),Y(:),29*v(:),16500*m(:)]),size(X));
npcr_hat_65l = reshape(lm_true.predict([X(:),Y(:),29*v(:),29400*m(:)]),size(X));

figure(1);clf;hold on
s45 =surf(X,Y,npcr_hat_45,'EdgeColor','none','FaceColor','r')
s45l =surf(X,Y,npcr_hat_45l,'EdgeColor','none','FaceColor','b')
s65 =surf(X,Y,npcr_hat_65,'EdgeColor','none','FaceColor','g')
s65l =surf(X,Y,npcr_hat_65l,'EdgeColor','none','FaceColor','m')
set([s45,s45l],'FaceAlpha',0.2)
set([s65,s65l],'FaceAlpha',0.5)
grid on
legend([s45,s45l,s65,s65l],{'45 mph, unladen','45 mph, laden','65 mph, unladen','65 mph, laden'})
%% simplified

lm2_true= fitlm([stats.brakes_simplified,stats.drf],stats.npcr,"interactions",'RobustOpts','on')
lm2_true.plotDiagnostics
lm2_true.plotSlice

lm2_est = fitlm([stats.brakes_simplified_est,stats.drr],stats.npcr,"interactions",'RobustOpts','on')
lm2_est.plotDiagnostics
lm2_est.plotSlice

%% PRR
stats.P_R = stats.mean_P_aero_true./(stats.mean_P_aero_true+stats.mean_P_rr_true);
stats_1 = stats(ismember(stats.mean_drag_reduction_ratio,1.0),:);
lm_P_R = stepwiselm(stats_1(:,{'mean_v','mean_ego_m','P_R'}),'P_R~mean_v^2+mean_ego_m^2')
stats.drag_fraction = lm_P_R.predict([stats.mean_v,stats.mean_ego_m]);
stats.PRR = (stats.mean_drag_reduction_ratio-1).*stats.drag_fraction+1
stats.PIR = stats.mean_P_AD_true./stats.mean_P_aero_true.*stats.mean_drag_reduction_ratio.*stats.drag_fraction+1

scatter3(stats.PIR,stats.PRR,stats.npc)

fitlm([stats.brakes_simplified,1-stats.PRR],stats.npcr,'y~x1*x2-1')

