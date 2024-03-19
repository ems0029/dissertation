% Classifier

%% Split into test and train
train = nfc_tbl_aug(any(nfc_tbl_aug.set==[1],2),:);
test  = nfc_tbl_aug(any(nfc_tbl_aug.set==[2,3,4],2),:);
logreg=fitglm([train.NFC_inf],train.NFC_true<1,'Distribution','binomial');

%% a class of 1 means fuel saved, a class of 0 means fuel lost

%% training peformance
y_true_train = train.NFC_true<1;
y_hat_score_train = logreg.predict;


%% test performance
y_true_test = test.NFC_true<1;
y_hat_score_test = logreg.predict([test.NFC_inf]);


%% ROC
close all
rocmetrics(y_true_train,[y_hat_score_train],[1]).plot
hold on
rocmetrics(y_true_train,[1-y_hat_score_train],[0]).plot


trainMetrics = rocmetrics(y_true_train,[1-y_hat_score_train,y_hat_score_train],[0,1]).Metrics
testMetrics  = rocmetrics(y_true_test, [1-y_hat_score_test,y_hat_score_test],[0,1]).Metrics

[l_bound,u_bound]=twoSidedMaybe(rocmetrics(y_true_train,[1-y_hat_score_train],[0]).Metrics, ...
    rocmetrics(y_true_train,[y_hat_score_train],[1]).Metrics, ...
    0.1)
figure(2);clf
tiledlayout(1,2,'TileSpacing','tight',Padding='compact',TileIndexing='rowmajor')
nexttile
confusionchart(confusionmat(double(y_true_train), ...
    (y_hat_score_train>l_bound)+(y_hat_score_train>l_bound&y_hat_score_train<u_bound)), ...
    {'do not platoon','platoon','maybe'},'RowSummary','off','ColumnSummary','total-normalized')
title('TRAIN')
nexttile
confusionchart(confusionmat(double(y_true_test), ...
    (y_hat_score_test>l_bound)+(y_hat_score_test>l_bound&y_hat_score_test<u_bound)) ...
    ,{'do not platoon','platoon','maybe'},'RowSummary','off','ColumnSummary','total-normalized')
title('TEST')


function [l_bound, u_bound] = twoSidedMaybe(zeroclass,oneclass,alpha)
    l_bound = 1-(zeroclass.Threshold(find(zeroclass.FalsePositiveRate<alpha,1,"last")));
    u_bound = (oneclass.Threshold(find(oneclass.FalsePositiveRate<alpha,1,"last")));
end
