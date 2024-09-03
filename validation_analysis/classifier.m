% Classifier
close all
%% simplest scheme
cmat = @(tbl) confusionchart(confusionmat(tbl.NFC_true>1,tbl.NFC_inf>1), ...
    {'platoon','do not platoon'}, ...
    'ColumnSummary','total-normalized', ...
    'XLabel','Predicted Class of NFC','YLabel','True Class of NFC');
cmat(nfc_tbl_aug(any(nfc_tbl_aug.set==[2],2),:))
clf
tiledlayout(1,4)
nexttile
cmat(nfc_tbl_aug(nfc_tbl_aug.truck_plat=="A1"&any(nfc_tbl_aug.set==[1,3,4],2),:))
title("A1")
nexttile
cmat(nfc_tbl_aug(nfc_tbl_aug.truck_plat=="A2"&any(nfc_tbl_aug.set==[1,3,4],2),:))
title("A2")
nexttile
cmat(nfc_tbl_aug(nfc_tbl_aug.truck_plat=="T13"&any(nfc_tbl_aug.set==[1,3,4],2),:))
title("T13")
nexttile
cmat(nfc_tbl_aug(nfc_tbl_aug.truck_plat=="T14"&any(nfc_tbl_aug.set==[1,3,4],2),:))
title("T14")
nfc_tbl_aug.y = nfc_tbl_aug.NFC_true<1;
nfc_tbl_aug.X = [nfc_tbl_aug.NPC_inf];
%% Split into test and train
train = nfc_tbl_aug(any(nfc_tbl_aug.set==[1],2),:);
% [train.X,C,S] = normalize(train.X);
test  = nfc_tbl_aug(any(nfc_tbl_aug.set==[3,4],2),:);
% test.X = normalize(test.X,'center',C,'scale',S);
logreg=fitglm(train.X,train.y,'Distribution','binomial');
% [~,ci]=fitlm([train.delPaero,train.delPAD],train.delP_true,'RobustOpts','on').predict('prediction','observation');
% forest=fitctree([train.NFC_inf],train.NFC_true<1,"OptimizeHyperparameters","auto");

%% a class of 1 means fuel saved, a class of 0 means fuel lost

%% training peformance
y_true_train = train.y;
y_hat_score_train_lr= logreg.predict;
% [~,y_hat_score_train_f]=forest.predict(train.NFC_inf);
% y_hat_score_train_f=y_hat_score_train_f(:,2);
%% test performance
y_true_test = test.y;
y_hat_score_test_lr = logreg.predict(test.X);
% [~,y_hat_score_test_f]=forest.predict(test.NFC_inf);
% y_hat_score_test_f=y_hat_score_test_f(:,2);

%% ROC
close all
rocmetrics(y_true_train,[y_hat_score_train_lr],[1]).plot
hold on
rocmetrics(y_true_test,[y_hat_score_test_lr],[1]).plot
% rocmetrics(y_true_train,[y_hat_score_train_f],[1]).plot
% rocmetrics(y_true_test,[y_hat_score_test_f],[1]).plot


trainMetrics = rocmetrics(y_true_train,[1-y_hat_score_train_lr,y_hat_score_train_lr],[0,1]).Metrics;
testMetrics  = rocmetrics(y_true_test, [1-y_hat_score_test_lr,y_hat_score_test_lr],[0,1]).Metrics;
i=1;

[l_bound,u_bound]=twoSidedMaybe(rocmetrics(y_true_train,[1-y_hat_score_train_lr],[0]).Metrics, ...
    rocmetrics(y_true_train,[y_hat_score_train_lr],[1]).Metrics, ...
    0.1);
figure(2);clf
tiledlayout(1,2,'TileSpacing','tight',Padding='compact',TileIndexing='rowmajor')
nexttile
confusionchart(confusionmat(double(y_true_train), ...
    (y_hat_score_train_lr>l_bound)+(y_hat_score_train_lr>l_bound&y_hat_score_train_lr<u_bound)), ...
    {'do not platoon','platoon','maybe'},'RowSummary','off','ColumnSummary','total-normalized')
title('TRAIN')
nexttile
confusionchart(confusionmat(double(y_true_test), ...
    (y_hat_score_test_lr>l_bound)+(y_hat_score_test_lr>l_bound&y_hat_score_test_lr<u_bound)) ...
    ,{'do not platoon','platoon','maybe'},'RowSummary','off','ColumnSummary','total-normalized')
title('TEST')

figure(3)
clf;tiledlayout(1,2,'TileSpacing','tight',Padding='compact',TileIndexing='rowmajor')
nexttile
confusionchart(confusionmat((y_true_train), ...
    (y_hat_score_train_lr>0.5)) ...
    ,{'do not platoon','platoon'},'RowSummary','off','ColumnSummary','total-normalized')
title('TRAIN')
nexttile
confusionchart(confusionmat((y_true_test), ...
    (y_hat_score_test_lr>0.5)) ...
    ,{'do not platoon','platoon'},'RowSummary','off','ColumnSummary','total-normalized')
title('TEST')

f_train=@(p) -sum(y_true_train==(y_hat_score_train_lr>p))./length(y_true_train);
f_test=@(p)  -sum(y_true_test==(y_hat_score_test_lr>p))./length(y_true_test);
best=fminsearch(f_train,0.5)
-f_train(best)
best=fminsearch(f_test,0.5)
-f_test(best)
