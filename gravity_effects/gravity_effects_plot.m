f = @(P_aero,P_etc,P_AD,gm,DRR) (P_aero.*(DRR+gm)+P_etc.*(1+gm)+P_AD./5)./(P_aero.*(1+gm)+P_etc.*(1+gm))
gm=-0.8+eps:0.01:1+eps
P_aero=10
P_etc=10
P_AD=0:0.1:10.1
DRR=0.8

[gm_,P_AD_]=meshgrid(gm,P_AD)
[gm__,P_AD__]=meshgrid(downsample(gm,11),downsample(P_AD,11))

figure
surf(P_AD_,100*gm_,f(P_aero,P_etc,P_AD_,gm_,DRR),'FaceColor','flat','EdgeColor','none','FaceAlpha',0.25)
hold on
contour3(P_AD_,100*gm_,f(P_aero,P_etc,P_AD_,gm_,DRR),'ShowText','on','ZLocation','zmin','FaceAlpha',0.5)
xlabel('P_{AD}/(P_{aero,ref}+P_{etc,ref}) [%]')
ylabel('P_{grvt}/(P_{aero,ref}+P_{etc,ref}) [%]')
zlabel('NPC')
view(3)
scatter(0,0,0.9,'red','filled')