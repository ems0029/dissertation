function mdl = plotAbsPdiff(nfc_tbl_aug)
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

% tiledlayout(2,3)
x = nfc_tbl_aug.delPAD/1000;xlin = linspace(min(x),max(x),15);
y = nfc_tbl_aug.delPaero/1000;ylin = linspace(min(y),max(y),15);
z = nfc_tbl_aug.delP_true/1000;
% nexttile([2 2])
for q = 1:4
   mask = nfc_tbl_aug.set==q;
   scat(q) = scatter3(gca(),x(mask),y(mask),z(mask),20,'filled','MarkerFaceAlpha',1);
   hold on
end
mdl = fitlm([x,y],z,'RobustOpts','ols');
[X,Y] = meshgrid(xlin,ylin);
Z = reshape(mdl.predict([X(:),Y(:)]),size(X));
fitted = surf(X,Y,Z,'EdgeColor','none','FaceAlpha',0.5,'FaceColor','interp');
one2one = surf(X,Y,X+Y,'EdgeColor','k','FaceColor','none','EdgeAlpha',0.5,'LineWidth',1.25);
legend([scat,fitted,one2one], ...
    {sprintf('\\bfDOE Test-Track \\rm(\\itn=%u\\rm)',sum(nfc_tbl_aug.set==1)),...
    sprintf('\\bfNRC Test-Track \\rm(\\itn=%u\\rm)',sum(nfc_tbl_aug.set==2)), ...
    sprintf('\\bfI-85 On-Road \\rm(\\itn=%u\\rm)',sum(nfc_tbl_aug.set==3)), ...
    sprintf('\\bfHwy-280 On-Road \\rm(\\itn=%u\\rm)',sum(nfc_tbl_aug.set==4)), ...
    sprintf('\n\n\\bfFitted Response (OLS):\\rm\n\\DeltaP_{true}\\sim%.2f+%.2f\\DeltaP_{AD}+%.2f\\DeltaP_{aero}\n R^2=%.3f',mdl.Coefficients.Estimate,  mdl.Rsquared.Ordinary), ...
    sprintf('\n\\bf1:1 Plane\n\\rm\\DeltaP_{true}\\sim\\DeltaP_{AD}+\\DeltaP_{aero}')},"Location","eastoutside")

set(gca(),"FontSize",12)
xlabel("\Delta P_{AD} [kW]")
ylabel("\Delta P_{aero} [kW]")
zlabel("\Delta P_{true} [kW]")
end