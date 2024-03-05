% combine nfcs
drr_method = 'schmid';
pad_adjustment = 'cadj';
weather = false;
addpath('.\functions\')

% TODO function form to add a table to another, this is sloppy

load("./lookups/nfc_tbl_aug_canada.mat",'nfc_tbl_aug')
out = process_nfc_tbl(nfc_tbl_aug,drr_method,pad_adjustment,weather)
out.dataset = 1*ones(height(out),1);
load("./lookups/nfc_tbl_aug_jdsmc.mat",'nfc_tbl_aug')
nfc_tbl_aug.G = nfc_tbl_aug.G+max(out.G)
nfc_tbl_aug = process_nfc_tbl(nfc_tbl_aug,drr_method,pad_adjustment,weather)
nfc_tbl_aug.dataset = 1*ones(height(nfc_tbl_aug),1);
out = out(:,intersect(nfc_tbl_aug.Properties.VariableNames,out.Properties.VariableNames,'stable'))

nfc_tbl_aug = nfc_tbl_aug(:,intersect(nfc_tbl_aug.Properties.VariableNames,out.Properties.VariableNames,'stable'))

nfc_tbl_aug = [out;nfc_tbl_aug]

scatter3(nfc_tbl_aug.delPAD,nfc_tbl_aug.delPaero,nfc_tbl_aug.delP_true)
fitlm([nfc_tbl_aug.delPAD,nfc_tbl_aug.delPaero,nfc_tbl_aug.G,nfc_tbl_aug.delP_fan],nfc_tbl_aug.delP_true,'CategoricalVars','x3')

func