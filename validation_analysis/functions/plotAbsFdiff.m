function mdl = plotAbsPdiff(nfc_tbl_aug,eta)
figure(1)
set(gcf(),'Position',[445,351,825,420])
set(gcf(),'Renderer','painters','RendererMode','manual')
clf
try
    colororder("dye")
    colormap('abyss')
catch
    disp('MATLAB 2023b+ required for desired color palette')
end
if ~exist('eta','var')
    eta = 0.366;
    disp('********* Assuming eta=36.6% *********')
end

% tiledlayout(2,3)
x = 3600*kappa(eta)*nfc_tbl_aug.delPAD/1000;xlin = linspace(min(x),max(x),15);
y = 3600*kappa(eta)*nfc_tbl_aug.delPaero/1000;ylin = linspace(min(y),max(y),15);
z = 3600*nfc_tbl_aug.delF_true/1000;
% nexttile([2 2])
for q = 1:4
   mask = nfc_tbl_aug.set==q;
   scat(q) = scatter3(gca(),x(mask),y(mask),z(mask),20,'filled','MarkerFaceAlpha',1);
   hold on
end
mdl = fitlm([x,y],z,'RobustOpts','on');
[X,Y] = meshgrid(xlin,ylin);
Z = reshape(mdl.predict([X(:),Y(:)]),size(X));
fitted = surf(X,Y,Z,'EdgeColor','none','FaceAlpha',0.5,'FaceColor','interp');
one2one = surf(X,Y,X+Y,'EdgeColor','k','FaceColor','none','EdgeAlpha',0.5,'LineWidth',1.25);
legend([scat,fitted,one2one], ...
    {sprintf('\\bfDOE Test-Track \\rm(\\itn=%u\\rm)',sum(nfc_tbl_aug.set==1)),...
    sprintf('\\bfNRC Test-Track \\rm(\\itn=%u\\rm)',sum(nfc_tbl_aug.set==2)), ...
    sprintf('\\bfI-85 On-Road \\rm(\\itn=%u\\rm)',sum(nfc_tbl_aug.set==3)), ...
    sprintf('\\bfHwy-280 On-Road \\rm(\\itn=%u\\rm)',sum(nfc_tbl_aug.set==4)), ...
    sprintf('\nAssuming \\eta_{gen}=%.1f%%\n\\bfFitted Response (Robust OLS):\\rm\n\\DeltaF_{true}\\sim%.2f+\\kappa(%.2f\\DeltaP_{AD}+%.2f\\DeltaP_{aero})\n R^2=%.3f',eta*100,mdl.Coefficients.Estimate,  mdl.Rsquared.Ordinary), ...
    sprintf('\n\\bf1:1 Plane\n\\rm\\DeltaF_{true}\\sim\\kappa(\\DeltaP_{AD}+\\DeltaP_{aero})')},"Location","eastoutside")

set(gca(),"FontSize",12)
xlabel("\kappa\DeltaP_{AD} [L/hr]")
ylabel("\kappa\DeltaP_{aero} [L/hr]")
zlabel("\DeltaF_{true} [L/hr]")
end