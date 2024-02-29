clearvars -except tbl
close all
if ~exist('tbl','var')
    load('..\processed\tbl_platoon_working.mat','tbl')
end
rng("default")
addpath('..\functions\')
addpath('..\lookups\truck_params\')
for i = 1:max(tbl.ID)

    subtbl=tbl(tbl.ID==i,:);

    subtbl.grade = subtbl.grade+randn(size(subtbl.grade))*2*pi*0.5/360;

    %% define a vehicle model acceleration
    param_offsets{i} = struct('front_area',10*(rand(1)-0.5),'trailer_mass',0*(rand(1)-0.5),'f_rr_c',0.01*(rand(1)-0.5));
    % fprintf('****OFFSETS****\n\nA_f: %.2f\nm: %.2f\nC_rr: %.2f\n',...
    %     param_offsets{i}.front_area,...
    %     param_offsets{i}.trailer_mass, ...
    %     param_offsets{i}.f_rr_c)
    subtbl = model_acceleration_with_aero_ipg(subtbl,param_offsets{i});

    %% get the FIR zero-phase
    order=27;
    firf = designfilt('lowpassfir','FilterOrder',order, ...
        'CutoffFrequency',1.2,'SampleRate',10);
    a_num=diff(subtbl.v_noise)*10; % 0.5 samples late
    subtbl.a_fir=filter(firf,[a_num;0]); % +qq-0.5 samples late
    % shift a_fir
    subtbl.a_fir = [subtbl.a_fir((order+1)/2:end);zeros((order+1)/2-1,1)];
    % dOrder = 50;
    % dfirf = designfilt('differentiatorfir','FilterOrder',dOrder, ...
    % 'SampleRate',10,'Passbandfrequency',0.5,'stopbandfrequency',1.75);
    % clf;plot(filter(dfirf,[subtbl.v_noise(25+1:end)]*10)-subtbl.a_true(1:end-25))
    % hold on
    % plot(subtbl.a_fir-subtbl.a_true)
    %
    % clf;plot(filter(dfirf,[subtbl.v_noise(25+1:end)]*10))
    % hold on
    % plot(subtbl.a_true)
    % plot(subtbl.a_fir)

    subtbl.a_estimate=subtbl.a_fir;

    % subtbl.a_estimate=[0;a_num];

    %% Get the force disturbance (noise wheelspeed, accel filter)
    % scatter(subtbl.time,cumtrapz(subtbl.a_estimate-subtbl.a_modeled_w_drr)/10)
    % subtbl.a_rls = RLS_again(subtbl,1.0);
    % % subtbl.a_rls = NLMS(subtbl,27);
    % subtbl=subtbl(subtbl.x>=1000&subtbl.x<=4702,:);
    %
    % adaptive_plot(subtbl,param_offsets{i})
    % pause

    %% do a lambda search

    lambda = 1.0;
    for q = 1:length(lambda)
        subtbl.a_rls = RLS_again(subtbl,lambda(q));
        subtbl.a_cadj = constant_adjust(subtbl);
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
            a_decel_hat_cadj = subtbl.a_cadj-subtbl.a_estimate;
            a_decel_hat_cadj(~subtbl.decel_on)=0;
            P_AD_mean_est_cadj=trapz(subtbl.time,a_decel_hat_cadj.*subtbl.mass_eff.*subtbl.v_noise)/range(subtbl.time);
            e_cadj(i)=(P_AD_mean_true-P_AD_mean_est_cadj);
        end
        e(q)=(P_AD_mean_true-P_AD_mean_est);
        %     RLS_plot(subtbl,param_offsets{i})
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
e_rls = (cell2mat(e_rls'));
trailer_mass =cellfun(@(a) a.trailer_mass,param_offsets)';
front_area =cellfun(@(a) a.front_area,param_offsets)';
c_rr =cellfun(@(a) a.f_rr_c,param_offsets)';
fitdist(e_rls(:,end)./P_AD_mean_true,"Normal")
boxplot([e_norls./P_AD;e_rls'./P_AD]')
clf
histogram(e_norls./P_AD*100,'Normalization','probability')
hold on
histogram(e_rls(:,end)'./P_AD*100,'Normalization','probability')
histogram(e_cadj./P_AD*100,'Normalization','probability')
legend('No RLS','RLS','Constant Offset')
xlabel('Percent Error')
ylabel('Probability')