
clearvars
close all

files = {'F:\PatrickSmith\Canada_Fuel_Test\OT\A2\OT-CI-S75-1_2019-06-27-17-18-20.mat',...
'F:\PatrickSmith\Canada_Fuel_Test\AL\A2\AL-S75-1_2019-06-17-07-38-10.mat',...
'F:\PatrickSmith\Canada_Fuel_Test\AL\A2\AL-S75-2_2019-06-17-08-41-35.mat',...
'F:\PatrickSmith\Canada_Fuel_Test\AL\A2\AL-S75-3_2019-06-17-12-55-02.mat'};

addpath("..\functions\")
addpath(genpath("..\lookups\"))

load("linearModel_w_baselines.mat")

lm =lm5;
%

recenterScale = @(x) x-lm5.Coefficients.Estimate(1)/(1+lm5.Coefficients.Estimate(1));

for q  = 1%:length(files)
tbl=flat_auburn_data(files{q});
tbl.leading = false(height(tbl),1);
tbl = add_features(tbl,'A2_canada.mat',[1400:30000]);
figure(1)
hold on
plot(tbl.time,tbl.E_AD)

figure(2)
hold on
plot(tbl.time,norm_EAD(tbl.E_AD,median(tbl.mass_eff),tbl.time-tbl.time(1)))

figure(3)
hold on
DRF = cumsum(1-tbl.drag_reduction_ratio)./((1:height(tbl))');
fan_pwr = cumsum(tbl.fan_power_est)./((1:height(tbl))');
DRF_adj = DRF%*(65^2/45^2)/(65000/38000);warning('hacky business!')
% DRF_adj = DRF*1.35;warning('hacky business!')
[meanExp,confint]=lm.predict( ...
    [norm_EAD(tbl.E_AD,median(tbl.mass_eff),tbl.time-tbl.time(1)), ...
    DRF_adj,fan_pwr],'Prediction','observation');
expected(q) = plot(tbl.time,(recenterScale(meanExp))*-100);
% confint plot
plot(tbl.time,(recenterScale(confint))*-100,'LineStyle','--','Color',[0.5,0.5,0.5])

figure(4)
hold on
% with zero DRR
[meanExp,confint]=lm.predict( ...
    [norm_EAD(tbl.E_AD,median(tbl.mass_eff),tbl.time-tbl.time(1)), ...
    0*DRF,fan_pwr],'Prediction','observation');
expected(q) = plot(tbl.time,(recenterScale(meanExp))*-100);
% confint plot
plot(tbl.time,(recenterScale(confint))*-100,'LineStyle','--','Color',[0.5,0.5,0.5])


% plot(tbl.time,77.5*(DRR-1)+6.4*norm_EAD(tbl.E_AD,median(tbl.mass_eff),tbl.time-tbl.time(1)))
end
figure(1)
legend('75 ft. platoon with Cut-ins','75 ft. platoon run #1','75 ft. platoon run #2','75 ft. platoon run #3','Location','best')
xlabel('Time [s]')  
ylabel('$\mathbf{E_{AD}} \left[\textbf{J}\right]$','Interpreter','latex')

figure(2)
legend('75 ft. platoon with Cut-ins','75 ft. platoon run #1','75 ft. platoon run #2','75 ft. platoon run #3','Location','best')
xlabel('Time [s]')
ylabel('$\mathbf{E_{AD}} \left[\frac{\textbf{kJ}}{\textbf{kg}\cdot\textbf{hr}}\right]$','Interpreter','latex')

figure(3)
yline([10.7,1.0],'LineStyle',':','Color',[0.5 0.5 0.5])
conf(1)=patch([3500 0 0 3500],-1*[-10.7-1.2,-10.7-1.2,-10.7+1.2,-10.7+1.2],'b','facealpha',0.10,'edgecolor','none');
conf(2)=patch([3500 0 0 3500],-1*[-1.0-1.8,-1.0-1.8,-1.0+1.8,-1.0+1.8],'k','facealpha',0.10,'edgecolor','none');
legend(gca,[expected,conf],{'75 ft. platoon with Cut-ins','75 ft. platoon run #1','75 ft. platoon run #2','75 ft. platoon run #3','Baseline CI','Cut-in CI'},'Location','best')
xlabel('Time [s]')
ylabel('Expected Fuel Savings [%]')

figure(4)
yline(-9.7,':')
conf2=patch([3500 0 0 3500],-1*[9.7+2.16,9.7+2.16,9.7-2.16,9.7-2.16],'k','facealpha',0.10,'edgecolor','none');
legend([expected,conf2],{'75 ft. platoon with Cut-ins','75 ft. platoon run #1','75 ft. platoon run #2','75 ft. platoon run #3','CI'},'Location','best')
xlabel('Time [s]')
ylabel('Impact of E_{AD} on NFC [%] ')