clearvars
clear merge_tables
global n 
n = [];
% combine nfcs
drr_method = 'schmid';
pad_adjustment = 'none';
weather = true;
eta = 0.306;
addpath('.\functions\')

% load and merge tables
table_1 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_doe.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method, pad_adjustment, weather,eta);
table_2 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_canada.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method, pad_adjustment, weather,eta);
table_3 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_I85.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method, pad_adjustment, weather,eta);
table_4 = process_nfc_tbl(load("./lookups/nfc_tbl_aug_jdsmc.mat",'nfc_tbl_aug').nfc_tbl_aug, drr_method, pad_adjustment, weather,eta);

nfc_tbl_aug = merge_tables(merge_tables(merge_tables(table_1,table_2),table_3),table_4);

%% a couple of outliers
nfc_tbl_aug(nfc_tbl_aug.ID_plat==160,:)=[];
nfc_tbl_aug(nfc_tbl_aug.ID_ref==160,:)=[];

%% absolute results
mdl = plotAbsPdiff(nfc_tbl_aug)
mdl = plotAbsFdiff(nfc_tbl_aug,.332)

mdl = fitlm([nfc_tbl_aug.delPAD,nfc_tbl_aug.delPaero,nfc_tbl_aug.G,nfc_tbl_aug.delP_fan],nfc_tbl_aug.delP_true,'y~x1+x2+x3*x1+x3*x2+x4','CategoricalVars','x3','RobustOpts','ols')



%% relative results
figure(2)
clf
% tiledlayout(1,2,'TileSpacing','tight','Padding','tight')
% nexttile
hold on
mdl = fitlm([nfc_tbl_aug.NPC_inf],nfc_tbl_aug.NPC_true,'y~x1','RobustOpts','off');
mdl.plot
xlabel('NPC_{inferred}','Interpreter','tex')
ylabel('NPC_{true}','Interpreter','tex')
title('')
legend('AutoUpdate','off',Location='southeast')
annotation('textbox',[0.15 0.7 0.2 0.2],'EdgeColor','none','FontSize',12,'String',sprintf('\\bfNPC_{true} = %.3f + %.3f NPC_{inferred}\n\\rmR^2 = %.3f',mdl.Coefficients.Estimate,mdl.Rsquared.Ordinary),'Fitboxtotext',true)
ax2 = gca()
set(gca(),'FontSize',12)
figure(3)
clf
% nexttile
hold on
mdl = fitlm([nfc_tbl_aug.NFC_inf],nfc_tbl_aug.NFC_true,'y~x1','RobustOpts','off');
mdl.plot
xlabel('NFC_{inferred}','Interpreter','tex')
ylabel('NFC_{true}','Interpreter','tex')
title('')
legend('AutoUpdate','off',Location='southeast')
% annotation('textbox',[0.58 0.82 0.2 0.2],'String',sprintf('\\bfNFC_{true} \\sim %.3f + %.3f NFC_{inferred}\n\\rmR^2 = %.3f',mdl.Coefficients.Estimate,mdl.Rsquared.Ordinary),'Fitboxtotext',true)
annotation('textbox',[0.15 0.7 0.2 0.2],'EdgeColor','none','FontSize',12,'String',sprintf('\\bfNFC_{true} \\sim %.3f + %.3f NFC_{inferred}\n\\rmR^2 = %.3f',mdl.Coefficients.Estimate,mdl.Rsquared.Ordinary),'Fitboxtotext',true)
ax3 = gca()
linkaxes([ax2,ax3])
set(ax3,'FontSize',12)
exportgraphics(figure(3),'C:\Users\ems0029\Box\Advanced Powertrain Group\Platooning\Evan Stegner Dissertation\New Graphics\NFC_vs_NFC_inferred_experimental_rep_res.png','Resolution',300)
exportgraphics(figure(2),'C:\Users\ems0029\Box\Advanced Powertrain Group\Platooning\Evan Stegner Dissertation\New Graphics\NPC_vs_NPC_inferred_experimental_rep_res.png','Resolution',300)
exportgraphics(figure(2),'C:\Users\ems0029\Box\Advanced Powertrain Group\Platooning\Evan Stegner Dissertation\New Graphics\NFC_and_NPC_experimental_rep_res.png','Resolution',300)
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