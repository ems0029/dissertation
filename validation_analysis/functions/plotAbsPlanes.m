function mdl = plotAbsPlanes(nfc_tbl_aug,fuel)
figure(1)
set(gcf(),'Position',[445,351,825,420])
% set(gcf(),'Renderer','painters','RendererMode','manual')
clf
try
    c =colororder("dye");
    colormap('abyss')
catch
    disp('MATLAB 2023b+ required for desired color palette')
end
if exist('fuel','var')
    eta = 0.306;
    x = kappa(eta)*nfc_tbl_aug.delPAD;
    y = kappa(eta)*nfc_tbl_aug.delPaero;
    xlin = linspace(min(x),max(x),15);
    ylin = linspace(min(y),max(y),15);
    [X,Y] = meshgrid(xlin,ylin);
    z = nfc_tbl_aug.delF_true;
    xlstr="\kappa\DeltaP_{AD} [L/hr]";
    ylstr="\kappa\DeltaP_{aero} [L/hr]";
    zlstr="\DeltaF_{true} [L/hr]";
else
    x = nfc_tbl_aug.delPAD/1000;
    y = nfc_tbl_aug.delPaero/1000;
    xlin = linspace(min(x),max(x),15);
    ylin = linspace(min(y),max(y),15);
    [X,Y] = meshgrid(xlin,ylin);
    z = nfc_tbl_aug.delP_true/1000;
    xlstr="\DeltaP_{AD} [kW]";
    ylstr="\DeltaP_{aero} [kW]";
    zlstr="\DeltaP_{true} [kW]";
end
tiledlayout(2,2,'Padding','loose','TileSpacing','tight')
mdl = fitlm([x,y,nfc_tbl_aug.set],z,'y~x1+x2+x3*x1+x3*x2-x3','CategoricalVars','x3','RobustOpts','ols');
% nexttile([2 2])
for q = 1:4
    ax(q) =nexttile;
    hold on
    grid on
    mask = nfc_tbl_aug.set==q;
    scat(q) = scatter3(gca(),x(mask),y(mask),z(mask),20,'filled','MarkerFaceAlpha',1,'MarkerFaceColor',c(q,:));
    Z = reshape(mdl.predict([X(:),Y(:),q*ones(numel(X),1)]),size(X));
    fitted(q) = surf(gca(),X,Y,Z,'EdgeColor','none','FaceAlpha',0.5,'FaceColor',c(q,:));
    one2one = surf(X,Y,X+Y,'EdgeColor','k','FaceColor','none','EdgeAlpha',0.5,'LineWidth',1.25);
    xlabel(xlstr)
    ylabel(ylstr)
    zlabel(zlstr)
end
 % aH = cell2mat(ancestor(v,'axes'));
 linkprop(ax,'CameraPosition');
 ax(1).CameraPosition =[ -443.4679 -187.9284  136.7243];
% xlin = linspace(min(x),max(x),15);
% ylin = linspace(min(y),max(y),15);
% [X,Y] = meshgrid(xlin,ylin);
% one2one = surf(X,Y,X+Y,'EdgeColor','k','FaceColor','none','EdgeAlpha',0.5,'LineWidth',1.25);
% legend([fitted,one2one], ...
%     {sprintf('\\bfDOE Test-Track \\rm(\\itn=%u\\rm)',sum(nfc_tbl_aug.set==1)),...
%     sprintf('\\bfNRC Test-Track \\rm(\\itn=%u\\rm)',sum(nfc_tbl_aug.set==2)), ...
%     sprintf('\\bfI-85 On-Road \\rm(\\itn=%u\\rm)',sum(nfc_tbl_aug.set==3)), ...
%     sprintf('\\bfHwy-280 On-Road \\rm(\\itn=%u\\rm)',sum(nfc_tbl_aug.set==4)), ...
%     sprintf('\n\n\\bfFitted Response (OLS):\\rm\n\\DeltaP_{true}\\sim%.2f+%.2f\\DeltaP_{AD}+%.2f\\DeltaP_{aero}\n R^2=%.3f',mdl.Coefficients.Estimate,  mdl.Rsquared.Ordinary), ...
%     sprintf('\n\\bf1:1 Plane\n\\rm\\DeltaP_{true}\\sim\\DeltaP_{AD}+\\DeltaP_{aero}')},"Location","eastoutside")

set(gca(),"FontSize",10)
end