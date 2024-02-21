% grab and plot plane
data =cell2mat(get(gca().Children,{'XData','YData'})')';
mdl = fitlm(data(:,1),data(:,2));
xv = [-6:0.1:8];
yv = [-15:0.1:10];
[X,Y]=meshgrid(xv,yv);
colormap gray
surf(X,Y,reshape(mdl.predict([X(:),Y(:)]),size(X)),'FaceAlpha',0.5,'EdgeColor','none')
grid on
rng('default')
[train_idx,val_idx,test_idx]=dividerand(length(data),0.7,0,0.30);

logreg=fitglm(data(train_idx,1),data(train_idx,2)<0,'Distribution','binomial')
svm = fitcsvm(data(train_idx,1),data(train_idx,2)<0,"Standardize",true)
rfst = fitctree(data(train_idx,1),data(train_idx,2)<0,"OptimizeHyperparameters","auto")
figure
confusionchart(confusionmat(data(test_idx,2)<0,logreg.predict(data(test_idx,1))>0.8),{'Do Not Platoon','Platoon'},'Normalization','row-normalized','RowSummary','absolute')
figure
confusionchart(data(test_idx,2)<0,svm.predict(data(test_idx,1)),'Normalization','row-normalized','RowSummary','absolute')
figure
confusionchart(data(test_idx,2)<0,rfst.predict(data(test_idx,1)),'Normalization','row-normalized','RowSummary','absolute')

% pure regression for a yes-no-maybe
mdl = fitlm(data(train_idx,1),data(train_idx,2))
[y_hat,bnds] =mdl.predict(data(test_idx,1),'Prediction','curve','Alpha',0.05)
yes = bnds(:,2)<0
no = bnds(:,1)>0
maybe = ~yes&~no
plot(yes)
hold on
plot(no)
plot(maybe)
hold off
confusionchart(data(test_idx,2)<0,yes,'Normalization','row-normalized')

