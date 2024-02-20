% grab and plot plane
data =cell2mat(get(gca().Children,{'XData','YData','ZData'})')';
mdl = fitlm(data(:,1:2),data(:,3));
xv = [-2:0.1:10];
yv = [-5:0.1:2];
[X,Y]=meshgrid(xv,yv);
colormap gray
surf(X,Y,reshape(mdl.predict([X(:),Y(:)]),size(X)),'FaceAlpha',0.5,'EdgeColor','none')
grid on