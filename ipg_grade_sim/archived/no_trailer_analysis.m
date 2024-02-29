%% load both the baseline table and the full table
% return %takes a minute to run this!
clearvars
tic
load("processed\tbl_platoon_working.mat")
tbl_LF = tbl;
toc
load("processed\tbl_baseline_working.mat")
tbl_C = tbl;
toc

%% harmonize the tables
tbl_C.other_m = -1*ones(height(tbl_C),1);

if ~isempty(setdiff(tbl_LF.Properties.VariableNames,tbl_C.Properties.VariableNames))
    error('there is a difference in table columns')
end

%% join the tables
tbl = [tbl_LF;tbl_C];

%% regenerate IDs

tbl.ID = findgroups(tbl.truck,tbl.ego_m,tbl.other_m,tbl.set_velocity);

%remove a weirdo run (double ran)
tbl = tbl(tbl.ID~=1265,:);
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
stats =grpstats(tbl_trim,{'truck','ID'},{'mean'},'DataVars',{'engine_power','fuel_rate','v','mass_eff','ego_m','engine_rpm','drag_reduction_ratio'});
stats.mean_ego_m = stats.mean_ego_m +15000;
stats.mean_P_AD = grpstats(tbl_trim.P_AD,{tbl_trim.truck,tbl_trim.ID},'mean');
stats.mean_E_AD = grpstats(tbl_trim.P_AD./tbl_trim.mass_eff,{tbl_trim.truck,tbl_trim.ID},'mean').*3.6;
stats.mean_E_AD_true = grpstats(tbl_trim.PwrL_Brake./tbl_trim.mass_eff,{tbl_trim.truck,tbl_trim.ID},'mean').*3.6;
stats.mean_P_AD_true = grpstats(tbl_trim.PwrL_Brake,{tbl_trim.truck,tbl_trim.ID},'mean');


%% baseline power/fuel regression


% lm_power.plotResiduals('fitted')
% [Xy,C,S] = normalize(stats(stats.truck=="C",{'mean_v','mean_ego_m','mean_engine_power'}));
Xy = stats(stats.truck=="C",{'mean_v','mean_ego_m','mean_engine_power'});
Xy_fuel = stats(stats.truck=="C",{'mean_v','mean_ego_m','mean_fuel_rate','mean_engine_rpm'});

nn_C = fitrnet(Xy,'mean_engine_power','Standardize',true,'Activations','relu','Lambda',7.67,'LayerSizes',[299 8]);
rmse = sqrt(mean(((Xy.mean_engine_power-nn_C.predict(Xy))).^2));

lm_power =fitlm(stats(stats.truck=="C",:),'mean_engine_power~mean_v^3+mean_ego_m:mean_v','PredictorVars',{'mean_v','mean_ego_m'})
lm_fuel =fitlm(Xy_fuel,'mean_fuel_rate~mean_v^3+mean_ego_m:mean_v+mean_engine_rpm','PredictorVars',{'mean_v','mean_ego_m','mean_engine_rpm'})

% tree_fuel = fitrensemble(Xy_fuel,"mean_fuel_rate","Method","LSBoost");
% sqrt(tree_fuel.loss(Xy_fuel))

figure(1);clf;hold on
scatter3(Xy.mean_v,Xy.mean_ego_m,Xy.mean_engine_power)
scatter3(Xy.mean_v,Xy.mean_ego_m,nn_C.predict(Xy))
scatter3(Xy.mean_v,Xy.mean_ego_m,lm_power.predict(Xy))
%check overfit?
v = stats.mean_v;
m = stats.mean_ego_m;
xlin = linspace(min(v), max(v), 100);
ylin = linspace(min(m), max(m), 100);
[X,Y] = meshgrid(xlin, ylin);
Z = reshape(nn_C.predict([X(:),Y(:)]),size(X));

figure(1);clf;hold on;
scatter3(v,m,stats.mean_engine_power/1000,'k.')
surface(X,Y,Z/1000,'EdgeColor','none','FaceAlpha',0.75)
xlabel('Mean Speed [m/s]');ylabel('Vehicle Mass [kg]');zlabel('Mean Power Consumption [kW]')
%% Normalized power consumption
stats.mean_NPC = stats.mean_engine_power./nn_C.predict([stats.mean_v,stats.mean_ego_m]);
stats.mean_NFC = stats.mean_fuel_rate./lm_fuel.predict([stats.mean_v,stats.mean_ego_m,stats.mean_engine_rpm]);
figure(1);clf;hold on
scatter(stats.mean_NPC,stats.mean_NFC,'filled','markerfacealpha',0.3,'markeredgealpha',0.1,'MarkerEdgeColor','k')
ref = refline(1).set('Color','r');
xlabel('Normalized Power Consumption');ylabel('Normalized Fuel Consumption')

%% Figures
figure(1);clf;hold on
ax = gca();
view(ax,3)
X = stats.mean_mass_eff;
Y = stats.mean_P_AD_true./sqrt(stats.mean_mass_eff)./stats.mean_v.^2;
Y = stats.mean_P_AD./sqrt(stats.mean_mass_eff)./stats.mean_v.^2;
% Y = stats.mean_P_AD_true;
% Y = stats.mean_E_AD_true;
Z = stats.mean_NPC;
colors  = stats.mean_v;
scatter3(gca,X,Y,Z,'CData',colors,'MarkerFaceColor','flat')
zlabel("Normalized Power Consumption")
xlabel('Effective Mass [kg]');
ylabel('Mean Braking Power per (sqrt(mass) v^2 hr) [kg^{0.5}/hr]')
% ylabel('Mean Braking Power [W]')
% ylabel('E_AD [kJ/kghr]')
cbar=colorbar(gca)
cbar.Title.String='Speed';

lm =stepwiselm(stats,"linear","PredictorVars",{'mean_v','mean_ego_m','mean_E_AD_true'},"ResponseVar","mean_NPC")
lm =fitlm(stats,"linear","PredictorVars",{'mean_v','mean_ego_m','mean_E_AD'},"ResponseVar","mean_NPC")


writetable(stats,'processed/stats.csv')
