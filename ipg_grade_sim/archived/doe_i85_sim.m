tbl=load_ipg_platoon_data('../../IPG_data/platoon_I85/*.dat')
tbl.set_velocity(:)=104.598;
tbl.ego_m(:) = 17000;
tbl.other_m(tbl.other_m==0)=17000;
tbl.drag_reduction_ratio(:)=1;

%% segmentation
%elevation at 2540 is 35.42 to -139.25 = -174.67
%-138.69 to 6.73 = 145.42
tbl.westbound = tbl.x>2540&tbl.x<37136;
tbl.eastbound = tbl.x>39400&tbl.x<74816;

tbl = tbl(tbl.eastbound|tbl.westbound,:);

%% get groupstats
stats =grpstats(tbl,{'westbound','ID'},{'mean'},'DataVars',{'engine_power','fuel_rate','v','mass_eff','ego_m','engine_rpm','drag_reduction_ratio'});
stats.mean_P_AD = grpstats(tbl.P_AD,{tbl.westbound,tbl.ID},'mean');
stats.mean_E_AD = grpstats(tbl.P_AD./tbl.mass_eff,{tbl.westbound,tbl.ID},'mean').*3.6;
stats.mean_P_AD_true = grpstats(tbl.PwrL_Brake,{tbl.westbound,tbl.ID},'mean');
stats.mean_E_AD_true = grpstats(tbl.PwrL_Brake./tbl.mass_eff,{tbl.westbound,tbl.ID},'mean').*3.6;
stats.mean_P_rr_true = grpstats(tbl.PwrL_Tire,{tbl.westbound,tbl.ID},'mean');
stats.mean_P_aero_true = grpstats(tbl.PwrL_Aero,{tbl.westbound,tbl.ID},'mean');
stats.mean_P_grvt_true = grpstats(tbl.PwrD_Grvt,{tbl.westbound,tbl.ID},'mean');
stats.var_v = grpstats(tbl.v,{tbl.westbound,tbl.ID},'var');
stats.mean_set_v=grpstats(tbl.set_velocity,{tbl.westbound,tbl.ID},'mean');

%% NPC
stats.NPC(1:3)=stats.mean_engine_power(1:3)/stats.mean_engine_power(2)
stats.NPC(4:6)=stats.mean_engine_power(4:6)/stats.mean_engine_power(5)

stats.NPC_hat=0.7254*stats.mean_P_AD_true./sqrt(stats.mean_mass_eff)./stats.mean_v.^2;
stats.NPC-stats.NPC_hat
