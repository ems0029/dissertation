drr_method = {'schmid','husseinrp','husseinpwr'};
pad_adjustment = {'none','rls','cadj'};
weather = {true,false};
eta = 0.306;

addpath('.\functions\')

for q=1:3
    for qq = 1:3
        for qqq = 1:2

            % load and merge tables
            table_1 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_doe.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method{q}, pad_adjustment{qq}, weather{qqq},eta);
            table_2 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_canada.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method{q}, pad_adjustment{qq}, weather{qqq},eta);
            table_3 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_I85.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method{q}, pad_adjustment{qq}, weather{qqq},eta);
            table_4 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_jdsmc.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method{q}, pad_adjustment{qq}, weather{qqq},eta);

            nfc_tbl_aug = merge_tables(merge_tables(merge_tables(table_1,table_2),table_3),table_4);

            %% a couple of outliers
            nfc_tbl_aug(nfc_tbl_aug.ID_plat==160,:)=[];
            nfc_tbl_aug(nfc_tbl_aug.ID_ref==160,:)=[];

            mdl_Pdiff{q,qq,qqq} = fitlm(nfc_tbl_aug,'delP_true~delPAD+delPaero+G',CategoricalVars='G',RobustOpts='off');
            mdl_Fdiff{q,qq,qqq} = fitlm(nfc_tbl_aug,'delF_true~delFAD+delFaero+G',CategoricalVars='G',RobustOpts='off');
            mdl_NPC{q,qq,qqq} = fitlm(nfc_tbl_aug,'NPC_true~NPC_inf+G',CategoricalVars='G',RobustOpts='off');
            mdl_NFC{q,qq,qqq} = fitlm(nfc_tbl_aug,'NFC_true~NFC_inf+G',CategoricalVars='G',RobustOpts='off');

        end
    end
end

%% absolute 
Rq_P=cellfun(@(x) x.Rsquared.Ordinary,mdl_Pdiff)
Rq_F=cellfun(@(x) x.Rsquared.Ordinary,mdl_Fdiff)
betaPAD=cellfun(@(x) x.Coefficients.Estimate(2),mdl_Pdiff,'UniformOutput',true)
betaFAD=cellfun(@(x) x.Coefficients.Estimate(2),mdl_Fdiff,'UniformOutput',true)
betaPaero=cellfun(@(x) x.Coefficients.Estimate(3),mdl_Pdiff,'UniformOutput',true)
betaFaero=cellfun(@(x) x.Coefficients.Estimate(3),mdl_Fdiff,'UniformOutput',true)

% none does better than cadj
mean(Rq_P,1)
mean(Rq_F,1)
% schmid is best for this dataset
mean(Rq_P,2)
mean(Rq_F,2)
% better without weather
mean(mean(Rq_P,1))


function merged_table = merge_tables(table_1,table_2)
table_2.G = table_2.G+max(table_1.G);
commonvars = intersect(table_1.Properties.VariableNames,table_2.Properties.VariableNames,'stable');
merged_table = [table_1(:,commonvars);table_2(:,commonvars)];
end
