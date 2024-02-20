clearvars -except tbl
close all
if ~exist('tbl','var')
    load('..\processed\tbl_platoon_working.mat','tbl')
end
rng("default")

for i = 1
    
subtbl=tbl(tbl.ID==i,:);

addpath('..\functions\')
addpath('..\lookups\truck_params\')

%% define a vehicle model acceleration
param_offsets{i} = struct('front_area',0,'trailer_mass',0,'f_rr_c',0.01);
% fprintf('****OFFSETS****\n\nA_f: %.2f\nm: %.2f\nC_rr: %.2f\n',...
%     param_offsets{i}.front_area,...
%     param_offsets{i}.trailer_mass, ...
%     param_offsets{i}.f_rr_c)
subtbl = model_acceleration_with_aero_ipg(subtbl,param_offsets{i});

%% get the FIR zero-phase
order=29;
firf = designfilt('lowpassfir','FilterOrder',order, ...
    'CutoffFrequency',1.2,'SampleRate',10);
a_num=diff(subtbl.v_noise)*10; % 0.5 samples late
subtbl.a_fir=filter(firf,[a_num;0]); % +qq-0.5 samples late
% shift a_fir
subtbl.a_fir = [subtbl.a_fir((order+1)/2:end);zeros((order+1)/2-1,1)];

%% Get the force disturbance (noise wheelspeed, accel filter)
subtbl.a_estimate=subtbl.a_fir;
% scatter(subtbl.time,cumtrapz(a_est-a_mdl)/10)

a_rls = RLS(subtbl,0.99);

v_rls = RLS_velocity(subtbl,0.98);

figure(1);clf
ax(1)=subplot(2,1,1);
plot(v_rls)
hold on;plot(subtbl.v_noise)
plot(subtbl.v)
xline(find(diff(subtbl.brake_pressure>0)~=0))
legend('RLS','measured','truth','modeled','Location','best')
ax(2)=subplot(2,1,2);
plot(a_rls-a_est)
hold on
plot(a_mdl-a_est)
plot(subtbl.PwrL_Brake./(subtbl.mass_eff-param_offsets{i}.trailer_mass)./subtbl.v)
legend('aDecel RLS','aDecel modeled','aDecel truth','Location','best','AutoUpdate','off')
xline(find(diff(subtbl.brake_pressure>0)~=0))
subtitle('Error from truth')
linkaxes(ax,'x')
pause
%% do a lambda search

lambda = 0.97:0.01:1.0;
for q = 1:length(lambda)
    subtbl.a_rls = RLS(subtbl,lambda(q));
    % trim
    subtbl=subtbl(subtbl.x>=1000&subtbl.x<=4702,:);
    a_decel_hat = subtbl.a_rls-subtbl.a_estimate;
    a_decel_hat(~subtbl.decel_on)=0;
    P_AD_mean_est=trapz(subtbl.time,a_decel_hat.*subtbl.mass_eff.*subtbl.v_noise)/range(subtbl.time);
    if q==1
        P_AD_mean_true = trapz(subtbl.time,subtbl.PwrL_Brake)/range(subtbl.time);
        a_decel_hat_ref = subtbl.a_modeled_w_drr-subtbl.a_estimate;
        a_decel_hat_ref(~subtbl.decel_on)=0;
        P_AD_mean_est_ref=trapz(subtbl.time,a_decel_hat_ref.*subtbl.mass_eff.*subtbl.v_noise)/range(subtbl.time);
        e_ref=(P_AD_mean_true-P_AD_mean_est_ref);
    end
    e(q)=(P_AD_mean_true-P_AD_mean_est);
end
[~,mindx]=min(e,[],'all');
% disp(lambda(mindx))
% figure(2);hold on
% scatter(lambda, ...
%     100*e/P_AD_mean_true, ...
%     'MarkerEdgeColor','none', ...
%     'MarkerFaceColor','k', ...
%     'MarkerFaceAlpha',0.01)

%% storage
P_AD(i)=P_AD_mean_true;
e_rls{i}=e;
e_norls(i)=e_ref;
disp(i)
end
e_rls = (cell2mat(e_rls'))
trailer_mass =cellfun(@(a) a.trailer_mass,param_offsets)';
front_area =cellfun(@(a) a.front_area,param_offsets)';
c_rr =cellfun(@(a) a.f_rr_c,param_offsets)';
% fitdist(e_rls'./P_AD_mean_true','weibull')
histogram(e_rls(:,end)'./P_AD)
hold on 
histogram(e_norls./P_AD)
legend('RLS','No RLS')
