function model_checks_ipg(tbl)
% this takes a subtable! Plots the mass expectation and the modeled forces

mass = 15000+tbl.ego_m(1);

close all
% F versus a slope:
lm=fitlm(tbl.a_true,(tbl.engine_power-tbl.PwrL_Aero-tbl.PwrL_Brake-tbl.PwrD_Grvt-tbl.PwrL_Tire)./tbl.v,RobustOpts="on");
%trailer hitch force  
mask =tbl.PwrL_Brake==0;
lm = fitlm(tbl.a_true(mask),tbl.PwrL_Hitch(mask)./tbl.v(mask),RobustOpts="on")
fprintf("Mass is estimated as: %0f", lm.Coefficients.Estimate(2)    )
figure
lm.plot
xlim([-5 5])
hold on
a=refline(mass,0); a.Color='r';
b=refline(flip(lm.Coefficients.Estimate));
legend([a,b],{'Supposed Static Mass','Sensed'})

%% rolling resistance
figure
ax(1) = subplot(3,1,1);
hold on
title('Rolling Resistance')
plot(tbl.PwrL_Tire)
plot((15000+tbl.ego_m(1))*(9.81*(truck.f_rr_c)).*tbl.v)
legend('true','model')

ax(2) =subplot(3,1,2);
title('Grade')
hold on
figure;plot(tbl.PwrD_Grvt)
hold on
plot((truck.tractor_mass+truck.trailer_mass)*(9.81*(sind(tbl.grade))))
legend('true','model')

ax(3) = subplot(3,1,3);
title('Drag')
hold on
plot(tbl.PwrL_Aero)
plot(0.5*tbl.v.^3*1.205*truck.c_d*truck.front_area)
legend('true','model')


end
