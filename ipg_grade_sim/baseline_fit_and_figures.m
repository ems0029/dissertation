%% baseline figures and fits

load("processed\tbl_baseline_12_13_23.mat")

start_pad = 1000;
track_length = 3702;
tbl_trim = tbl(tbl.x>=start_pad&tbl.x<=start_pad+track_length,:);

%% outlier removal
dv = grpstats(tbl_trim.v,tbl_trim.ID,@(x) x(1)-x(end));
id = grpstats(tbl_trim.ID,tbl_trim.ID,'mode');
validID = id(~isoutlier(dv));

tbl_trim = tbl_trim(ismember(tbl_trim.ID,validID),:);

%% regression
power = grpstats(tbl_trim.engine_power,tbl_trim.ID,'mean');
fuel = grpstats(tbl_trim.fuel_rate,tbl_trim.ID,'mean');
rpm = grpstats(tbl_trim.engine_rpm,tbl_trim.ID,'mean');
[v,v_std] = grpstats(tbl_trim.v,tbl_trim.ID,{'mean','std'});
m_e = grpstats(tbl_trim.mass_eff,tbl_trim.ID,'mean');
m_s = grpstats(tbl_trim.ego_m,tbl_trim.ID,'mean')+15000;
res = table(m_s,m_e,v,rpm,power,fuel);
lm_power =stepwiselm(res,'power~v^3+m_s:v','Upper','interactions','PredictorVars',{'m_s','v'});
lm_power.plotResiduals('fitted')

lm_fuel =stepwiselm(res,'fuel~v^3+m_s-v^2-v','PredictorVars',{'m_s','v'});
lm_fuel.plotResiduals('fitted')
%% input data plot
figure(1);clf
xlin = linspace(min(v), max(v), 47);
ylin = linspace(min(m_s), max(m_s), 11);
[X,Y] = meshgrid(xlin, ylin);
Z = griddata(v,m_s,power,X,Y,'linear');
scatter3(v,m_s/1000,power/1000,'k.');hold on
surface(X,Y/1000,Z/1000,'FaceAlpha',0.5)
xlabel('Velocity [m/s]');ylabel('Truck Mass [mt]');zlabel('Mean Power Demand [kW]')
%% error contours
figure(2);clf
Z = griddata(v,m_s,power-lm_power.predict,X,Y,'linear');
contourf(X,Y/1000,Z/1000,'ShowText','on',"LabelFormat","%0.1f kW",'LabelSpacing',500)
title('Power Demand Regression Error Contour')
xlabel('Velocity [m/s]');ylabel('Truck Mass [mt]');


figure(3);clf
Z = griddata(v,m_s,fuel*3600-lm_fuel.predict*3600,X,Y,'linear');
contourf(X,Y/1000,Z,'ShowText','on',"LabelFormat","%.1f L/hr")
title('Fuel Rate Regression Error Contour')
xlabel('Velocity [m/s]');ylabel('Truck Mass [mt]');


