function RLS_plot(subtbl,param_offsets)
% plot

figure(1);clf
ax(1)=subplot(3,1,1);
hold on
plot(subtbl.time,subtbl.a_modeled_w_drr)
plot(subtbl.time,subtbl.a_rls)
plot(subtbl.time,subtbl.a_estimate)
plot(subtbl.time,subtbl.a_true,'Color','k')
xline([0;subtbl.time(find(diff(subtbl.brake_pressure>0)~=0))])
xlabel('Time [s]')
ylabel('Acceleration [m/s^2]')
legend('Model Brakeless','Corrected Brakeless','Measured','True','Location','best')
subtitle('$\mathbf{\hat{a}}$','interpreter','latex')

ax(2)=subplot(3,1,2);
plot(subtbl.time,subtbl.a_modeled_w_drr-subtbl.a_estimate)
hold on
plot(subtbl.time,subtbl.a_rls-subtbl.a_estimate)
plot(subtbl.time,subtbl.PwrL_Brake./(subtbl.mass_eff-param_offsets.trailer_mass)./subtbl.v,'Color','k')
xlabel('Time [s]')
ylabel('Acceleration [m/s^2]')
legend('Model Brakeless','Corrected Brakeless','True','Location','best','AutoUpdate','off')
xline([0;subtbl.time(find(diff(subtbl.brake_pressure>0)~=0))])
subtitle('$\mathbf{\hat{a}_{decel}}$','interpreter','latex')

ax(3)=subplot(3,1,3);
P_AD_mean_true = cumtrapz(subtbl.time,subtbl.PwrL_Brake)/range(subtbl.time);
a_decel_hat = subtbl.a_rls-subtbl.a_estimate;
a_decel_hat(~subtbl.decel_on)=0;
P_AD_mean_est=cumtrapz(subtbl.time,a_decel_hat.*subtbl.mass_eff.*subtbl.v_noise)/range(subtbl.time);
a_decel_hat_ref = subtbl.a_modeled_w_drr-subtbl.a_estimate;
a_decel_hat_ref(~subtbl.decel_on)=0;
P_AD_mean_est_ref=cumtrapz(subtbl.time,a_decel_hat_ref.*subtbl.mass_eff.*subtbl.v_noise)/range(subtbl.time);
hold on
plot(subtbl.time,P_AD_mean_est_ref/1000)
plot(subtbl.time,P_AD_mean_est/1000)
plot(subtbl.time,P_AD_mean_true/1000,'Color','k')
xlabel('Time [s]')
ylabel('Braking Power [kW]')
legend('Model Brakeless','Corrected Brakeless','True','Location','best','AutoUpdate','off')
xline([0;subtbl.time(find(diff(subtbl.brake_pressure>0)~=0))])
subtitle('$\mathbf{\hat{P}_{AD}}$','interpreter','latex')

linkaxes(ax,'x')
structfun(@(x) set(x.Children,'LineWidth',1.5),ax)