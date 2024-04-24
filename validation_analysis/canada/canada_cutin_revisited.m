clearvars
addpath('..\functions\')
nfc_tbl_aug = load("../lookups/nfc_tbl_aug_canada.mat",'nfc_tbl_aug').nfc_tbl_aug
nfc_tbl_aug = nfc_tbl_aug(nfc_tbl_aug.N_plat==41 | nfc_tbl_aug.N_ref==41,:)
nfc_tbl_aug = nfc_tbl_aug(any(nfc_tbl_aug.N_plat==[38,39,40],2)| any(nfc_tbl_aug.N_ref==[38,39,40],2),:)

% [~,~,ci2,~]=ttest(nfc_tbl_aug.NPC_inf)
% [~,~,ci,~]=ttest(nfc_tbl_aug.NPC_true)
% 
% bar([mean(nfc_tbl_aug.NPC_true),mean(nfc_tbl_aug.NPC_inf)])
% hold on;errorbar([1 2],[mean(nfc_tbl_aug.NPC_true),mean(nfc_tbl_aug.NPC_inf)],[ci(2) ci2(2)]-[mean(nfc_tbl_aug.NPC_true),mean(nfc_tbl_aug.NPC_inf)],'.')
% nfc_tbl_aug.mean_engine_power_T_plat/1000

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

nfc_tbl_aug_ci = nfc_tbl_aug;


%% all comparisons
drr = {'schmid','husseinrp','husseinpwr'}
pad = {'none' ,'cadj' ,'rls'}
weather = {true,false}
mu =nan(3,3,2)
bnd = nan(3,3,2)
for q = 1:3
    for qq = 1:3
        for qqq =1:2
            npc =1./(process_nfc_tbl(nfc_tbl_aug,drr{q},pad{qq},weather{qqq},0.322).NPC_inf);
            npc1 =1./(process_nfc_tbl(nfc_tbl_aug,drr{q},pad{qq},weather{qqq},0.322,'plat').NPC_inf);
            npc2 =(process_nfc_tbl(nfc_tbl_aug,drr{q},pad{qq},weather{qqq},0.322,'ref').NPC_inf);
            mu(q,qq,qqq) = mean(npc);
            [~,~,ci]=ttest(npc);
            bnd(q,qq,qqq) = ci(2)-mu(q,qq,qqq);
            
            mu1(q,qq,qqq) = mean(npc1);
            [~,~,ci]=ttest(npc1);
            bnd1(q,qq,qqq) = ci(2)-mu1(q,qq,qqq);
            
            mu2(q,qq,qqq) = mean(npc2);
            [~,~,ci]=ttest(npc2);
            bnd2(q,qq,qqq) = ci(2)-mu2(q,qq,qqq);
        end
    end
end
figure(1);clf
tiledlayout(2,1,'TileSpacing','compact','Padding','compact')
nexttile
appLayout(mu1, bnd1, [0.881 0.905],true);
title('Platoon, 23m IVD')
set(gca(),'fontsize',10)
nexttile
appLayout(mu2, bnd2, [0.972 1.008],true);
title('Platoon w/ Cut-ins, 23m IVD')
set(gca(),'fontsize',10)
% nexttile
% appLayout(1-mu, bnd, 1-[0.881 0.925],true);
% title('Effect of Cut-ins')
% set(gca(),'fontsize',10)
xlabel("Calculation Method No.")
% ylabel('\DeltaNPC_{inferred}')
% legend('Mean \DeltaNPC_{inferred}','Published True Value','Estimated Confidence Interval')

% nfc_tbl_aug.mean_engine_power_T_plat/1000
% nfc_tbl_aug.mean_engine_power_T_ref/1000
% nfc_tbl_aug.mean_fuel_rate_T_plat
% nfc_tbl_aug.mean_fuel_rate_T_ref
% nfc_tbl_aug.mean_drag_reduction_ratio_ref
% nfc_tbl_aug.mean_drag_reduction_ratio_plat
% nfc_tbl_aug.mean_drag_reduction_ratio_husseinrp_plat
% nfc_tbl_aug.mean_drag_reduction_ratio_husseinrp_ref
% nfc_tbl_aug.mean_drag_reduction_ratio_husseinpwr_ref
% nfc_tbl_aug.mean_drag_reduction_ratio_husseinrp_plat
% nfc_tbl_aug.mean_drag_reduction_ratio_husseinrp_ref
% nfc_tbl_aug.mean_drag_reduction_ratio_husseinpwr_plat
% nfc_tbl_aug.mean_drag_reduction_ratio_husseinpwr_ref
% nfc_tbl_aug.mean_P_aero_wind_T_plat/1000
% nfc_tbl_aug.mean_P_aero_T_plat/1000
% nfc_tbl_aug.mean_P_aero_T_ref/1000
% nfc_tbl_aug.mean_P_AD_T_ref/1000
% nfc_tbl_aug.mean_P_AD_T_plat/1000
% nfc_tbl_aug.mean_P_AD_cadj_T_plat/1000
% nfc_tbl_aug.mean_P_AD_cadj_T_ref/1000
% nfc_tbl_aug.mean_P_AD_rls_T_ref/1000
% nfc_tbl_aug.mean_P_AD_T_ref/1000

function appLayout(mu, bnd, act_bnd,leg)
% colororder("sail")
% patch([-0.5 21 21 -0.5],[0.881 0.881 0.925 0.925],'k','facealpha',0.2,'edgecolor','none')
% bar([1:18],mu(:),'grouped')
% errorbar([1:18],mu(:),bnd(:))
% xlim([-0.2000   19.2000])
a = gca();
hold(a,'on')
colororder("gem")
ylabel(a,'NPC_{inferred}')
bars=bar(a,[1:18],mu(:),'grouped','LineWidth',1.25)
% ebars=errorbar(a,[1:18],mu(:),bnd(:),'LineWidth',1.25)
true_mean=yline(mean(act_bnd),'LineWidth',1.25)
truth=patch(a,[-0.5 21 21 -0.5],[act_bnd(1) act_bnd(1) act_bnd(2) act_bnd(2)],'k','facealpha',0.2,'edgecolor','k','linestyle','--')
xlim(a,[0.2000   18.7])
ylim(a,[act_bnd(1)-0.05 act_bnd(2)+0.05])
xticks(a,[1:18])
if leg
    legend(a,[bars,true_mean,truth],'Mean NPC_{inferred}','Published True Value','Published Confidence Interval','Location','eastoutside')
end
end