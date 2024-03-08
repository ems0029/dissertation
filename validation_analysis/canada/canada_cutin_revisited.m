nfc_tbl_aug = load("../lookups/nfc_tbl_aug_canada.mat",'nfc_tbl_aug').nfc_tbl_aug
nfc_tbl_aug = nfc_tbl_aug(nfc_tbl_aug.N_plat==41 | nfc_tbl_aug.N_ref==41,:)
nfc_tbl_aug = nfc_tbl_aug(any(nfc_tbl_aug.N_plat==[38,39,40],2)| any(nfc_tbl_aug.N_ref==[38,39,40],2),:)
[~,~,ci2,~]=ttest(nfc_tbl_aug.NPC_inf)
[~,~,ci,~]=ttest(nfc_tbl_aug.NPC_true)

bar([mean(nfc_tbl_aug.NPC_true),mean(nfc_tbl_aug.NPC_inf)])
hold on;errorbar([1 2],[mean(nfc_tbl_aug.NPC_true),mean(nfc_tbl_aug.NPC_inf)],[ci(2) ci2(2)]-[mean(nfc_tbl_aug.NPC_true),mean(nfc_tbl_aug.NPC_inf)],'.')
nfc_tbl_aug.mean_engine_power_T_plat/1000

%% platoon
nfc_tbl_aug.mean_fuel_rate_T_plat./(nfc_tbl_aug.mean_fuel_rate_T_plat+kappa()*nfc_tbl_aug.mean_P_aero_T_plat.*(1-nfc_tbl_aug.mean_drag_reduction_ratio_plat))
nfc_tbl_aug.mean_engine_power_T_plat./(nfc_tbl_aug.mean_engine_power_T_plat+nfc_tbl_aug.mean_P_aero_T_plat.*(1-nfc_tbl_aug.mean_drag_reduction_ratio_plat))
%% cutin
nfc_tbl_aug.mean_fuel_rate_T_ref./(nfc_tbl_aug.mean_fuel_rate_T_ref+kappa()*(nfc_tbl_aug.mean_P_aero_T_ref.*(1-nfc_tbl_aug.mean_drag_reduction_ratio_ref)-nfc_tbl_aug.mean_P_AD_T_ref))
nfc_tbl_aug.mean_engine_power_T_ref./(nfc_tbl_aug.mean_engine_power_T_ref+nfc_tbl_aug.mean_P_aero_T_ref.*(1-nfc_tbl_aug.mean_drag_reduction_ratio_ref)-nfc_tbl_aug.mean_P_AD_T_ref)
%% difference
process_nfc_tbl(nfc_tbl_aug,'schmid','rls',false).NFC_inf
process_nfc_tbl(nfc_tbl_aug,'schmid','rls',false).NFC_true
process_nfc_tbl(nfc_tbl_aug,'schmid','none',false).NPC_inf
process_nfc_tbl(nfc_tbl_aug,'schmid','none',false).NPC_true

%% all comparisons
drr = {'schmid','husseinrp','husseinpwr'}
pad = {'none' ,'cadj' ,'rls'}
weather = {true,false}
mu =nan(3,3,2)
bnd = nan(3,3,2)
for q = 1:3
    for qq = 1:3
        for qqq =1:2
            npc =(process_nfc_tbl(nfc_tbl_aug,drr{q},pad{qq},weather{qqq}).NPC_inf);
            mu(q,qq,qqq) = mean(npc);
            [~,~,ci]=ttest(npc);
            bnd(q,qq,qqq) = ci(2)-mu(q,qq,qqq);
        end
    end
end
appLayout(mu, bnd);

nfc_tbl_aug.mean_engine_power_T_plat/1000
nfc_tbl_aug.mean_engine_power_T_ref/1000
nfc_tbl_aug.mean_fuel_rate_T_plat
nfc_tbl_aug.mean_fuel_rate_T_ref
nfc_tbl_aug.mean_drag_reduction_ratio_ref
nfc_tbl_aug.mean_drag_reduction_ratio_plat
nfc_tbl_aug.mean_drag_reduction_ratio_husseinrp_plat
nfc_tbl_aug.mean_drag_reduction_ratio_husseinrp_ref
nfc_tbl_aug.mean_drag_reduction_ratio_husseinpwr_ref
nfc_tbl_aug.mean_drag_reduction_ratio_husseinrp_plat
nfc_tbl_aug.mean_drag_reduction_ratio_husseinrp_ref
nfc_tbl_aug.mean_drag_reduction_ratio_husseinpwr_plat
nfc_tbl_aug.mean_drag_reduction_ratio_husseinpwr_ref
nfc_tbl_aug.mean_P_aero_wind_T_plat/1000
nfc_tbl_aug.mean_P_aero_T_plat/1000
nfc_tbl_aug.mean_P_aero_T_ref/1000
nfc_tbl_aug.mean_P_AD_T_ref/1000
nfc_tbl_aug.mean_P_AD_T_plat/1000
nfc_tbl_aug.mean_P_AD_cadj_T_plat/1000
nfc_tbl_aug.mean_P_AD_cadj_T_ref/1000
nfc_tbl_aug.mean_P_AD_rls_T_ref/1000

function appLayout(mu, bnd)
colororder("sail")
yline(0.881)
hold on
yline(0.925)
patch([-0.5 21 21 -0.5],[0.881 0.881 0.925 0.925],'k','facealpha',0.2,'edgecolor','none')
bar([1:18],mu(:),'grouped')
errorbar([1:18],mu(:),bnd(:))
xlim([-0.2000   19.2000])

% build the table
rname = {'DRR';'P_AD';'P_aero'};
r1 = reshape(repmat({'sch','h.rp','h.pw'},1,6),[],1);
r2 = reshape(repmat({'none','cofst','rls'},3,2),[],1);
r3 = reshape(repmat({'true','false'},9,1),[],1);
c = [r1,r2,r3]'
T = cell2table(table2cell(table(r1,r2,r3))','RowNames',rname);
f = uifigure('Position', [100 100 730 420]);
a = uiaxes(f, 'Position', [10 120 718 280]);
hold(a,'on')
colororder("sail")
ylabel(a,'NPC_{inferred}')
bars=bar(a,[1:18],mu(:),'grouped')
ebars=errorbar(a,[1:18],mu(:),bnd(:))
truth=patch(a,[-0.5 21 21 -0.5],[0.881 0.881 0.925 0.925],'k','facealpha',0.2,'edgecolor','k','linestyle','--')
xlim(a,[0.2000   18.7])
ylim(a,[0.8,0.95])
xticks(a,[1:18])
legend(a,[bars,ebars,truth],'Mean NPC_{inferred}','95% Bounds','Published True Value')
tobj = uitable(f,'Data',T{:,:},'ColumnName',[1:18],...
    'RowName',T.Properties.RowNames,'Position', [10 10 715 99],'ColumnWidth','fit');
end