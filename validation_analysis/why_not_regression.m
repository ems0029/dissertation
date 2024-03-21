mdl = fitlm(nfc_tbl_aug,'NFC_true~NFC_inf','CategoricalVars','truck_plat','RobustOpts','on')
[~,ci]=mdl.predict('prediction','observation','alpha',0.2)
yes = all(ci<1,2)
no = all(ci>1,2)
maybe = any(ci<1,2)&not(yes)&not(no)

confusionchart(confusionmat(double(nfc_tbl_aug.NFC_true<1),-1+no+2*yes+3*maybe),{'do not platoon','platoon','maybe'},'ColumnSummary','total-normalized')