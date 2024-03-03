%% load both the baseline table and the full table
% return %takes a minute to run this!
clearvars
tic
load("processed\tbl_platoon_working.mat")
tbl_L = tbl(tbl.truck=="L",:);
toc
load("processed\tbl_platoon_wDrr_working.mat")
tbl_F = tbl;
load("processed\tbl_baseline_working.mat")
tbl_C = tbl;
toc

addpath functions\

%% harmonize the tables
tbl_C.other_m = -1*ones(height(tbl_C),1);

if ~isempty(setdiff(tbl_F.Properties.VariableNames,tbl_C.Properties.VariableNames))
    error('there is a difference in table columns')
end

%% join the tables
tbl = [tbl_L;tbl_F;tbl_C];

%% regenerate IDs

tbl.ID = findgroups(tbl.truck,tbl.ego_m,tbl.other_m,tbl.set_velocity,tbl.drag_reduction_ratio);

%remove a weirdo run (double ran) F setv 84 egom 10000 otherm 14000 drr1
% tbl = tbl(tbl.ID~=1265,:);
%% trim the tables

start_pad = 1000;
track_length = 3702;
tbl_trim = tbl(tbl.x>=start_pad&tbl.x<=start_pad+track_length,:);

%% outlier removal

dv = grpstats(tbl_trim.v,tbl_trim.ID,@(x) (x(1)-x(end))/mean(x));
id = grpstats(tbl_trim.ID,tbl_trim.ID,'mode');
validID = id(~isoutlier(dv,'median'));
dv = dv(~isoutlier(dv,'median'));
tbl_trim = tbl_trim(ismember(tbl_trim.ID,validID),:);

%% get groupstats
stats =grpstats(tbl_trim,{'truck','ID'},{'mean'},'DataVars',{'engine_power','fuel_rate','v','PT_engine_be','mass_eff','ego_m','engine_rpm','drag_reduction_ratio'});
stats.mean_ego_m = stats.mean_ego_m +15000;
stats.mean_P_AD = grpstats(tbl_trim.P_AD,{tbl_trim.truck,tbl_trim.ID},'mean');
stats.mean_E_AD = grpstats(tbl_trim.P_AD./tbl_trim.mass_eff,{tbl_trim.truck,tbl_trim.ID},'mean').*3.6;
stats.mean_P_AD_true = grpstats(tbl_trim.PwrL_Brake,{tbl_trim.truck,tbl_trim.ID},'mean');
stats.mean_E_AD_true = grpstats(tbl_trim.PwrL_Brake./tbl_trim.mass_eff,{tbl_trim.truck,tbl_trim.ID},'mean').*3.6;
stats.mean_P_rr_true = grpstats(tbl_trim.PwrL_Tire,{tbl_trim.truck,tbl_trim.ID},'mean');
stats.mean_P_aero_true = grpstats(tbl_trim.PwrL_Aero,{tbl_trim.truck,tbl_trim.ID},'mean');
stats.mean_P_grvt_true = grpstats(tbl_trim.PwrD_Grvt,{tbl_trim.truck,tbl_trim.ID},'mean');
stats.var_v = grpstats(tbl_trim.v,{tbl_trim.truck,tbl_trim.ID},'var');
stats.sq_plus_var_v = stats.mean_v.^2+stats.var_v;
stats.mean_set_v=grpstats(tbl_trim.set_velocity,{tbl_trim.truck,tbl_trim.ID},'mean');
%% PRR
stats.P_R = stats.mean_P_aero_true./(stats.mean_P_aero_true+stats.mean_P_rr_true);
stats_1 = stats(ismember(stats.mean_drag_reduction_ratio,1.0),:);
lm_P_R = stepwiselm(stats_1(:,{'mean_v','mean_ego_m','P_R'}),'P_R~mean_v^2+mean_ego_m^2')
stats.drag_fraction = lm_P_R.predict([stats.mean_v,stats.mean_ego_m]);
stats.PRR = (stats.mean_drag_reduction_ratio-1).*stats.drag_fraction+1
stats.PIF = stats.mean_P_AD_true./stats.mean_P_aero_true.*stats.mean_drag_reduction_ratio.*stats.drag_fraction

% fitlm([stats.PIF+stats.PRR],stats.mean_NPC).plot


%% baseline power/fuel regression

% lm_power.plotResiduals('fitted')
% [Xy,C,S] = normalize(stats(stats.truck=="C",{'mean_v','mean_ego_m','mean_engine_power'}));
Xy_C = stats(stats.truck=="C",{'mean_v','mean_ego_m','mean_engine_power'});
Xy_L = stats(stats.truck=="L",{'mean_v','mean_ego_m','mean_engine_power'});
Xy_C_fuel = stats(stats.truck=="C",{'mean_v','mean_ego_m','mean_fuel_rate','mean_engine_rpm'});
Xy_L_fuel = stats(stats.truck=="L",{'mean_v','mean_ego_m','mean_fuel_rate','mean_engine_rpm'});

[nn_C,rmse_C] = nn_power(Xy_C);
[nn_L,rmse_L] = nn_power(Xy_L);

lm_power =fitlm(stats(stats.truck=="L",:),'mean_engine_power~mean_v^3+mean_ego_m:mean_v','PredictorVars',{'mean_v','mean_ego_m'})
lm_fuel =fitlm(Xy_C_fuel,'mean_fuel_rate~mean_v^3+mean_ego_m:mean_v+mean_engine_rpm','PredictorVars',{'mean_v','mean_ego_m','mean_engine_rpm'})

% tree_fuel = fitrensemble(Xy_fuel,"mean_fuel_rate","Method","LSBoost");
% sqrt(tree_fuel.loss(Xy_fuel))

figure(1);clf;hold on
scatter3(Xy_L.mean_v,Xy_L.mean_ego_m,Xy_L.mean_engine_power)
scatter3(Xy_L.mean_v,Xy_L.mean_ego_m,nn_L.predict(Xy_L))
scatter3(Xy_L.mean_v,Xy_L.mean_ego_m,lm_power.predict(Xy_L))
%check overfit?
v = stats.mean_v;
m = stats.mean_ego_m;
xlin = linspace(min(v), max(v), 100);
ylin = linspace(min(m), max(m), 100);
[X,Y_true] = meshgrid(xlin, ylin);
Z_C = reshape(nn_C.predict([X(:),Y_true(:)]),size(X));
% Z_L = reshape(nn_L.predict([X(:),Y_true(:)]),size(X));

figure(1);clf;hold on;
pts =scatter3(v,m/1000,stats.mean_engine_power/1000,'k.')
csur=  surface(X,Y_true/1000,Z_C/1000,'EdgeColor','none','FaceAlpha',0.75)
% surface(X,Y_true,Z_L/1000,'EdgeColor','none','FaceAlpha',0.75)
xlabel('Mean Speed [m/s]');ylabel('Vehicle Mass [mt]');zlabel('Mean Power Consumption [kW]')
legend([pts,csur],{'Individual Simulations','Brakeless Reference Surface'})

%% Normalized power consumption
stats.mean_NPC = stats.mean_engine_power./nn_C.predict([stats.mean_v,stats.mean_ego_m]);
stats.mean_NFC = stats.mean_fuel_rate./lm_fuel.predict([stats.mean_v,stats.mean_ego_m,stats.mean_engine_rpm]);
figure(1);clf;hold on
scatter(stats.mean_NPC,stats.mean_NFC,'filled','markerfacealpha',0.3,'markeredgealpha',0.1,'MarkerEdgeColor','k')
ref = refline(1).set('Color','r');
xlabel('Normalized Power Consumption');ylabel('Normalized Fuel Consumption')
legend('Data','1:1','Location','northwest')
% writetable(stats,'processed/stats_wDrr.csv')

%% Figures (official ones in the NPC_plots script)

% NPC
subplot(2,2,2);figure(1);clf;hold on;colormap default
% subplot(2,2,1);
colors = 1-stats.mean_drag_reduction_ratio;
Y_true = stats.PIF;
% Y = stats.mean_P_AD./sqrt(stats.mean_mass_eff)./stats.mean_v.^2
Z = stats.mean_NPC;
X = stats.PRR;
sizeD = stats.mean_ego_m;
scatter3(gca,X,Y_true,Z,'CData',colors,'SizeData',sizeD/500,'MarkerFaceColor','flat')
zlabel("Normalized Power Consumption")
xlabel('Mean Speed [m/s]');
ylabel('Mean Braking Power [kW]')
view(3)
cbar=colorbar(gca);
cbar.Title.String='DRR';
cbar.Direction='reverse';
cbar.TickLabels=num2cell([1.0:-0.05:0.5]);

scatter3(gca,X,Y,Z,'CData',colors,'MarkerFaceColor','flat')
zlabel("Normalized Power Consumption")
xlabel('Effective Mass [kg]');
ylabel('Mean Braking Power per (sqrt(mass) v^2 hr) [kg^{0.5}/hr]')

cbar=colorbar(gca);
cbar.Title.String='Speed';
subplot(2,1,2)
lm_true =fitlm(Y_true,Z);
lm_true.plot

subplot(2,1,2)
hold on
lm =fitlm([X,Y_true],Z,'y~x1+x2-1')
scatter(Y,Z,'.')

% NFC
figure(1);clf;hold on
subplot(2,2,1);
X = stats.mean_mass_eff;
Y_true = stats.mean_P_AD_true./sqrt(stats.mean_mass_eff)./stats.mean_v.^2*3.6;
Y = stats.mean_P_AD./sqrt(stats.mean_mass_eff)./stats.mean_v.^2*3.6
Z_L = stats.mean_NPC;
colors  = stats.mean_v;
scatter3(gca,X,Y_true,Z_L,'CData',colors,'MarkerFaceColor','flat')
zlabel("Normalized Power Consumption")
xlabel('Effective Mass [kg]');
ylabel('Mean Braking Power per (sqrt(mass) v^2 hr) [kg^{0.5}/hr]')
subplot(2,2,2);
scatter3(gca,X,Y,Z_L,'CData',colors,'MarkerFaceColor','flat')
zlabel("Normalized Power Consumption")
xlabel('Effective Mass [kg]');
ylabel('Mean Braking Power per (sqrt(mass) v^2 hr) [kg^{0.5}/hr]')

cbar=colorbar(gca)
cbar.Title.String='Speed';
subplot(2,1,2)
lm_true =fitlm(Y_true,Z_L)
lm_true.plot

subplot(2,1,2)
hold on
lm =fitlm(Y,Z_L)
lm.plot
scatter(Y,Z_L,'.')

lm =stepwiselm(stats,"linear","PredictorVars",{'mean_v','mean_ego_m','mean_E_AD_true'},"ResponseVar","mean_NPC")

