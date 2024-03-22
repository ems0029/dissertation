i=1;
L=[];
U=[];
Lt=[];
Ut=[];
p=[];
for q=0.001:0.01:0.3
    try
    p(i)=q
    [L(i),U(i)]=twoSidedMaybe(rocmetrics(y_true_train,[1-y_hat_score_train_lr],[0]).Metrics, ...
    rocmetrics(y_true_train,[y_hat_score_train_lr],[1]).Metrics, ...
    q)
    [Lt(i),Ut(i)]=twoSidedMaybe(rocmetrics(y_true_test,[1-y_hat_score_test_lr],[0]).Metrics, ...
    rocmetrics(y_true_test,[y_hat_score_test_lr],[1]).Metrics, ...
    q)
    i=i+1
    end
end
Ut(Ut<.50)=.5
Lt(Lt>0.5)=.5
clf
hold on
colormap gray
xtickformat('percentage')
ytickformat('percentage')
mb = patch((1-[p,flip(p)])*100,[L,flip(U)]*100,validatecolor("#b5b5b5"),'FaceAlpha',0.5,'EdgeColor','none');%.*validatecolor("#D5D5D5")'
yes = patch((1-[p,flip(p)])*100,[U,ones(size(U))]*100,validatecolor("#168ef0"),'FaceAlpha',0.5,'EdgeColor','none');
no = patch((1-[p,flip(p)])*100,[L,zeros(size(L))]*100,validatecolor("#ff4c42"),'FaceAlpha',0.5,'EdgeColor','none');
% f = griddedInterpolant(logreg.predict([1.5:-0.01:0.5]'),[1.5:-0.01:0.5],'linear','nearest');
% P = 0:0.01:1;
% clevel = 70:1:100;
% [X,Y]=meshgrid(clevel,P);
% Z = reshape(f(Y(:)),size(X));
% [~,ctr]=contour(X,Y*100,Z,[0.9,0.95:0.025:1.05,1.1],'ShowText','on','LabelSpacing',500,'EdgeColor','k','EdgeAlpha',0.5);
% legend([yes,mb,no,ctr],{'Platoon','Maybe','Do Not Platoon','NFC_{inferred}'},'AutoUpdate','off')
set(gca(),'XDir','reverse','TickDir','none')
xlabel('Confidence Level')
ylabel('Estimated Probability')
xlim([71 99.9])

% plot((1-[p])*100,[L;(U)]'*100,'-k');
% grid on


yyaxis right
% tvec = unique([flip(0.55+logspace(log10(0.05),log10(0.55),7)*-1),0.45+logspace(log10(0.05),log10(0.55),7)])
tvec = flip([0.9,0.95:0.025:1.05,1.1])
yticks(logreg.predict(tvec'))
ylim([0, 1])
yline(logreg.predict(tvec'),'--').set('Alpha',0.5)
yticklabels(sprintf('%.3f\n',tvec))
set(gca(),'YColor','k')
ylabel('NFC_{inferred}')
a=annotation('textbox',[0.53,0.73,0.2,0.2],'String','Platoon','BackgroundColor',validatecolor("#168ef0"))
b=annotation('textbox',[0.23,0.48,0.2,0.2],'String','Maybe','BackgroundColor',validatecolor("#b5b5b5"))
c=annotation('textbox',[0.53,0.23,0.2,0.2],'String','Do Not Platoon','BackgroundColor',validatecolor("#ff4c42"))
set([a,b,c],'FaceAlpha',0.5,'HorizontalAlignment','center','fitboxtotext',true,'edgecolor','none','VerticalAlignment','baseline')

%% sigmoid plot

clf
figure;plot([0.5:0.01:1.5],logreg.predict([0.5:0.01:1.5]'))

meshgrid([0.5:0.01:1.5],)
f(U),f(L)
