function createfigure(xdata1, ydata1, zdata1)
%CREATEFIGURE(xdata1, ydata1, zdata1, X1, Z1, CData1)
%  XDATA1:  surface xdata
%  YDATA1:  surface ydata
%  ZDATA1:  surface zdata
%  X1:  vector of scatter3 x data
%  Z1:  vector of scatter3 z data
%  CDATA1:  scatter3 cdata

%  Auto-generated by MATLAB on 24-Jan-2024 19:40:49

% Create figure
figure1 = figure('OuterPosition',[672 538 576 513]);

% Create axes
axes1 = axes;
hold(axes1,'on');

% Create surf
surf(xdata1,ydata1,zdata1,'FaceAlpha',0.25,'EdgeColor','none');

% Create contour
[c1,h1] = contour3(xdata1,ydata1,zdata1,'FaceAlpha',0.5,'ZLocation','zmin');
clabel(c1,h1);

% Create scatter3
scatter3(0,0,0.9,'CData',[0 0 0],'MarkerFaceColor',[0 0 0]);

% Create zlabel
zlabel('NPC');

% Create ylabel
ylabel('\bf\gamma=P_{grvt}/(P_{ref}) [%]','Rotation',-15);

% Create xlabel
xlabel('\bf{\beta}=P_{AD}/(P_{ref}) [%]','Rotation',30);

view(axes1,[-53.40000033783 38.6134966160853]);
grid(axes1,'on');
axis(axes1,'tight');
hold(axes1,'off');
% Create textarrow
annotation(figure1,'textarrow',[0.351785714285714 0.373214285714285],...
    [0.35952380952381 0.471428571428572],...
    'String',{'Consumes 90% power','when P_{grvt}=P_{AD}=0'});

% Create textarrow
annotation(figure1,'textarrow',[0.692857142857134 0.694642857142857],...
    [0.341857142857148 0.271428571428571],...
    'String',{'Asymptotically','approaches -\infty'},...
    'HorizontalAlignment','left');

