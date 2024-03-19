clearvars;close all
drr_method = {'schmid','husseinrp','husseinpwr'};
pad_adjustment = {'none','rls','cadj'};
weather = {false};
eta = 0.322;
robust = 'on';
fSet = @(tbl) ones(height(tbl),1);

addpath('.\functions\')

for q=1:3
    for qq = 1:3
        for qqq = 1

            % load and merge tables
            table_1 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_doe.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method{q}, pad_adjustment{qq}, weather{qqq},eta);
            table_2 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_canada.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method{q}, pad_adjustment{qq}, weather{qqq},eta);
            table_3 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_I85.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method{q}, pad_adjustment{qq}, weather{qqq},eta);
            table_4 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_jdsmc.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method{q}, pad_adjustment{qq}, weather{qqq},eta);
            table_1.set = categorical(1*fSet(table_1));
            table_2.set = categorical(2*fSet(table_2));
            table_3.set = categorical(3*fSet(table_3));
            table_4.set = categorical(4*fSet(table_4));
            nfc_tbl_aug = merge_tables(merge_tables(merge_tables(table_1,table_2),table_3),table_4);
            
        %% a couple of outliers
        nfc_tbl_aug(nfc_tbl_aug.ID_plat==160,:)=[];
        nfc_tbl_aug(nfc_tbl_aug.ID_ref==160,:)=[];

        mdl_Pdiff_{q,qq,qqq} = fitlm(nfc_tbl_aug,'delP_true~delPAD+delPaero',RobustOpts=robust);
        mdl_Fdiff_{q,qq,qqq} = fitlm(nfc_tbl_aug,'delF_true~delFAD+delFaero',RobustOpts=robust);
        mdl_Pdiff{q,qq,qqq} = fitlm(nfc_tbl_aug,'delP_true~delP_inf',RobustOpts=robust);
        mdl_Fdiff{q,qq,qqq} = fitlm(nfc_tbl_aug,'delF_true~delF_inf',RobustOpts=robust);
        mdl_NPC{q,qq,qqq} = fitlm(nfc_tbl_aug,'NPC_true~NPC_inf',RobustOpts=robust);
        mdl_NFC{q,qq,qqq} = fitlm(nfc_tbl_aug,'NFC_true~NFC_inf',RobustOpts=robust);
        % NPC_tls{q,qq,qqq} = tls([nfc_tbl_aug.NPC_inf-1],nfc_tbl_aug.NPC_true-1);
        end
    end
end

%% various coefficients
Rq_P_=cellfun(@(x) x.Rsquared.Ordinary,mdl_Pdiff_)
Rq_F_=cellfun(@(x) x.Rsquared.Ordinary,mdl_Fdiff_)
Rq_P=cellfun(@(x) x.Rsquared.Ordinary,mdl_Pdiff)
Rq_F=cellfun(@(x) x.Rsquared.Ordinary,mdl_Fdiff)
Rq_NPC=cellfun(@(x) x.Rsquared.Ordinary,mdl_NPC)
Rq_NFC=cellfun(@(x) x.Rsquared.Ordinary,mdl_NFC)

betaPAD_diff=cellfun(@(x) x.Coefficients.Estimate(end-1),mdl_Pdiff_,'UniformOutput',true)
betaFAD_diff=cellfun(@(x) x.Coefficients.Estimate(end-1),mdl_Fdiff_,'UniformOutput',true)
SE_PAD_diff=cellfun(@(x) x.Coefficients.SE(end-1),mdl_Pdiff_,'UniformOutput',true)
SE_FAD_diff=cellfun(@(x) x.Coefficients.SE(end-1),mdl_Fdiff_,'UniformOutput',true)

betaPaero_diff=cellfun(@(x) x.Coefficients.Estimate(end),mdl_Pdiff_,'UniformOutput',true)
betaFaero_diff=cellfun(@(x) x.Coefficients.Estimate(end),mdl_Fdiff_,'UniformOutput',true)
SE_Paero_diff=cellfun(@(x) x.Coefficients.SE(end),mdl_Pdiff_,'UniformOutput',true)
SE_Faero_diff=cellfun(@(x) x.Coefficients.SE(end),mdl_Fdiff_,'UniformOutput',true)

round(reshape([[betaPAD_diff;SE_PAD_diff*1.96],[betaFAD_diff;SE_FAD_diff*1.96]],3,[])*100,1)
round(reshape([[betaPaero_diff;1.96*SE_Paero_diff],[betaFaero_diff;1.96*SE_Faero_diff]],3,[])*100,1)

betaP_diff=cellfun(@(x) x.Coefficients.Estimate(end),mdl_Pdiff,'UniformOutput',true)
betaF_diff=cellfun(@(x) x.Coefficients.Estimate(end),mdl_Fdiff,'UniformOutput',true)
SE_P_diff=cellfun(@(x) x.Coefficients.SE(end),mdl_Pdiff,'UniformOutput',true)
SE_F_diff=cellfun(@(x) x.Coefficients.SE(end),mdl_Fdiff,'UniformOutput',true)
betaNPC=cellfun(@(x) x.Coefficients.Estimate(end),mdl_NPC,'UniformOutput',true)
betaNFC=cellfun(@(x) x.Coefficients.Estimate(end),mdl_NFC,'UniformOutput',true)
SE_NPC=cellfun(@(x) x.Coefficients.SE(end),mdl_NPC,'UniformOutput',true)
SE_NFC=cellfun(@(x) x.Coefficients.SE(end),mdl_NFC,'UniformOutput',true)
beta0NPC=cellfun(@(x) x.Coefficients.Estimate(1),mdl_NPC,'UniformOutput',true)
beta0NFC=cellfun(@(x) x.Coefficients.Estimate(1),mdl_NFC,'UniformOutput',true)
SE0_NPC=cellfun(@(x) x.Coefficients.pValue(1),mdl_NPC,'UniformOutput',true)
SE0_NFC=cellfun(@(x) x.Coefficients.pValue(1),mdl_NFC,'UniformOutput',true)

round(reshape([[betaP_diff;SE_P_diff*1.96],[betaF_diff;SE_F_diff*1.96]],3,[])*100,1)
round(reshape([[betaNPC;SE_NPC*1.96],[betaNFC;SE_NFC*1.96]],3,[])*100,1)

fSum = @(x) [[x;mean(x,1)],[mean(x,2);mean(mean(x,1))]];
fSum(Rq_P)
fSum(betaNFC)

% NONE does better than cadj
mean(Rq_NPC,1)
mean(Rq_NFC,1)
% schmid is best for this dataset
mean(Rq_NPC,2)
mean(Rq_NFC,2)
% better without weather
mean(mean(Rq_NFC,1))

figure(1);clf;hold on;set(gcf(),'Position',[100 100 800 400])
tiledlayout(1,2,'TileSpacing','tight','Padding','tight')
nexttile
xlabel('\DeltaP_{inferred} [kW]');ylabel("\DeltaP_{true} [kW]")
xlim([-20 20]);ylim([-20 20])
cellfun(@(x) refline(x.Coefficients.Estimate(end),x.Coefficients.Estimate(1)/1000).set('color','r'),mdl_Pdiff,'UniformOutput',false)
refline(1).set('color','k','Linewidth',3,'LineStyle','--')
grid on
nexttile
xlabel('\DeltaF_{inferred} [L/hr]');ylabel("\DeltaF_{true} [L/hr]")
linkaxes(gcf().Children.Children)
cellfun(@(x) refline(x.Coefficients.Estimate(end),x.Coefficients.Estimate(1)).set('color','b'),mdl_Fdiff,'UniformOutput',false)
refline(1).set('color','k','Linewidth',3,'LineStyle','--')
grid on

%% relative slopes

figure(2);clf;hold on;set(gcf(),'Position',[100 100 800 400])
tiledlayout(1,2,'TileSpacing','tight','Padding','tight')
nexttile
xlabel('NPC_{inferred}');ylabel("NPC_{true}")
xlim([0.5,1.5]);ylim([0.5,1.5])
cellfun(@(x) refline(x.Coefficients.Estimate(end),x.Coefficients.Estimate(1)).set('color','r'),mdl_NPC,'UniformOutput',false)
refline(1).set('color','k','Linewidth',3,'LineStyle','--')
grid on
nexttile
xlabel('NFC_{inferred}');ylabel("NFC_{true}")
linkaxes(gcf().Children.Children)
cellfun(@(x) refline(x.Coefficients.Estimate(end),x.Coefficients.Estimate(1)).set('color','b'),mdl_NFC,'UniformOutput',false)
refline(1).set('color','k','Linewidth',3,'LineStyle','--')
xlim([0.5,1.5]);ylim([0.5,1.5])
grid on

function merged_table = merge_tables(table_1,table_2)
table_2.G = table_2.G+max(table_1.G);
commonvars = intersect(table_1.Properties.VariableNames,table_2.Properties.VariableNames,'stable');
merged_table = [table_1(:,commonvars);table_2(:,commonvars)];
end
