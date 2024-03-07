clearvars
clear merge_tables
global n 
n = [];
% combine nfcs
drr_method = 'schmid';
pad_adjustment = 'cadj';
weather = false;
addpath('.\functions\')

% load and merge tables
table_1 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_doe.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method, pad_adjustment, weather);
table_2 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_I85.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method, pad_adjustment, weather);
table_3 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_jdsmc.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method, pad_adjustment, weather);
table_4 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_canada.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method, pad_adjustment, weather);
nfc_tbl_aug = merge_tables(merge_tables(merge_tables(table_1,table_2),table_3),table_4);

%% a couple of outliers
nfc_tbl_aug(nfc_tbl_aug.ID_plat==160,:)=[];
nfc_tbl_aug(nfc_tbl_aug.ID_ref==160,:)=[];

%% absolute results
mdl = plotAbsPdiff(nfc_tbl_aug);

mdl = fitlm([nfc_tbl_aug.delPAD,nfc_tbl_aug.delPaero,nfc_tbl_aug.G,nfc_tbl_aug.delP_fan],nfc_tbl_aug.delP_true,'CategoricalVars','x3','RobustOpts','cauchy')

%% relative results
figure(2)
clf
hold on
mdl = fitlm(nfc_tbl_aug.NPC_inf,nfc_tbl_aug.NPC_true,'RobustOpts','on');
mdl.plotSlice


%% mixed effects attempt (you need multiple membership modeling though)
% this is really hard to visualize and encode...
% C = unique([nfc_tbl_aug.G,nfc_tbl_aug.N_plat;nfc_tbl_aug.G,nfc_tbl_aug.N_ref],'rows')
% [~,nfc_tbl_aug.q_plat]=ismember([nfc_tbl_aug.G,nfc_tbl_aug.N_plat],C,'rows');
% [~,nfc_tbl_aug.q_ref]=ismember([nfc_tbl_aug.G,nfc_tbl_aug.N_ref],C,'rows');
% % dumb dummies
% mdl = fitlm([nfc_tbl_aug.delPAD,nfc_tbl_aug.delPaero,nfc_tbl_aug.q_ref,nfc_tbl_aug.q_plat],nfc_tbl_aug.delP_true,'CategoricalVars',{'x3','x4'})
% % what is the output?
% fitlme(nfc_tbl_aug,'delP_true~delPaero+delPAD+(1|q_plat)+(1|q_ref)')


function merged_table = merge_tables(table_1,table_2)
   global n
   if isempty(n)
      n = 1;
      table_1.set = n*ones(height(table_1),1);
   end
   n = n+1;
   table_2.set = n*ones(height(table_2),1);
   table_2.G = table_2.G+max(table_1.G);
   commonvars = intersect(table_1.Properties.VariableNames,table_2.Properties.VariableNames,'stable');
   merged_table = [table_1(:,commonvars);table_2(:,commonvars)];
end