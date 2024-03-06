% combine nfcs
drr_method = 'schmid';
pad_adjustment = 'cadj';
weather = false;
addpath('.\functions\')

% load and merge tables
table_1 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_jdsmc.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method, pad_adjustment, weather);
table_2 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_I85.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method, pad_adjustment, weather);
table_3 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_canada.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method, pad_adjustment, weather);
% table_4 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_doe.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method, pad_adjustment, weather);
nfc_tbl_aug = merge_tables(merge_tables(table_1,table_2),table_3);

scatter3(nfc_tbl_aug.delPAD,nfc_tbl_aug.delPaero,nfc_tbl_aug.delP_true)
fitlm([nfc_tbl_aug.delPAD,nfc_tbl_aug.delPaero,nfc_tbl_aug.G,nfc_tbl_aug.delP_fan],nfc_tbl_aug.delP_true,'CategoricalVars','x3')

function merged_table = merge_tables(table_1,table_2)
   %shift groups
   table_2.G = table_2.G+max(table_1.G);
   commonvars = intersect(table_1.Properties.VariableNames,table_2.Properties.VariableNames,'stable');
   merged_table = [table_1(:,commonvars);table_2(:,commonvars)];
end