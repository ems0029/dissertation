% incredibly inefficient code 
clearvars;close all
drr_method = {'schmid','husseinrp','husseinpwr'};
pad_adjustment = {'none','rls','cadj'};
weather = {false,true};
eta = 0.322;
robust = 'on';
fSet = @(tbl) ones(height(tbl),1);

addpath('.\functions\')

for q=1:3
    for qq = 1:3
        for qqq = 1:2
            table_1 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_doe.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method{q}, pad_adjustment{qq}, weather{qqq},eta);
            table_2 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_canada.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method{q}, pad_adjustment{qq}, weather{qqq},eta);
            table_3 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_I85.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method{q}, pad_adjustment{qq}, weather{qqq},eta);
            table_4 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_jdsmc.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method{q}, pad_adjustment{qq}, weather{qqq},eta);
            table_1.set = (1*fSet(table_1));
            table_2.set = (2*fSet(table_2));
            table_3.set = (3*fSet(table_3));
            table_4.set = (4*fSet(table_4));
            nfc_tbl_aug = merge_tables(merge_tables(merge_tables(table_1,table_2),table_3),table_4);
            
            %% a couple of outliers
            nfc_tbl_aug(nfc_tbl_aug.ID_plat==160,:)=[];
            nfc_tbl_aug(nfc_tbl_aug.ID_ref==160,:)=[];
            classifier
            accurtest{qqq,qq,q} =sum(y_true_test==(y_hat_score_test_lr>0.5))./length(y_true_test);
            accurtrain{qqq,qq,q} =sum(y_true_train==(y_hat_score_train_lr>0.5))./length(y_true_train);
        end
    end
end
mean(cell2mat(accurtrain),"all")
mean(cell2mat(accurtest),'all')
max(cell2mat(accurtrain),[],"all")
max(cell2mat(accurtest),[],'all')