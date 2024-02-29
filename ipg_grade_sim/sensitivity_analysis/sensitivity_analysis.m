clearvars -except tbl
close all
if ~exist('tbl','var')
    load('..\processed\tbl_platoon_working.mat','tbl')
end
rng("default")
addpath('..\functions\')
addpath('..\lookups\truck_params\')

%% preallocate results
P_aero_true = zeros(max(tbl.ID),1);
P_AD_true = zeros(max(tbl.ID),1);
NPC_true = zeros(max(tbl.ID),1);
P_aero_inf = zeros(max(tbl.ID),1);
P_AD_inf = zeros(max(tbl.ID),1);
NPC_inf = zeros(max(tbl.ID),1);
aero_offset = zeros(max(tbl.ID),1);
rr_offset = zeros(max(tbl.ID),1);
mass_offset = zeros(max(tbl.ID),1);

%% load lookups
load('..\processed\nn_brakeless_lookup.mat','nn_C')
load('..\processed\pd_grade.mat','pd_grade')
load('..\processed\pd_v.mat','pd_v')

% begin monte-carlo loop
for i = 1:max(tbl.ID)
    
    subtbl=tbl(tbl.ID==i,:);

    %% get truth
    P_aero_true(i) = mean(subtbl.PwrL_Aero);
    P_AD_true(i) = mean(subtbl.PwrL_Brake);
    NPC_true(i) = mean(subtbl.engine_power)/nn_C.predict([mean(subtbl.v),subtbl.ego_m(1)+15000]);

    %% add noise
    subtbl.grade = subtbl.grade+pd_grade.random(size(subtbl.grade))*pi/180;
    subtbl.v = subtbl.v + pd_v.random(size(subtbl.v));

    %% get vehicle model acceleration for a random parameter offsets
    aero_offset(i) = 10*(rand(1)-0.5);
    rr_offset(i) = 0.01*(rand(1)-0.5);
    mass_offset(i) = 10000*(rand(1)-0.5);
    fprintf('****OFFSETS****\n\nA_f: %.2f\nm: %.2f\nC_rr: %.2f\n',...
        aero_offset(i),...
        mass_offset(i), ...
        rr_offset(i))

    subtbl_aero = model_acceleration_with_aero_ipg(subtbl,...
        struct('front_area',aero_offset(i),'trailer_mass',0,'f_rr_c',0));
    subtbl_rr = model_acceleration_with_aero_ipg(subtbl,...
        struct('front_area',0,'trailer_mass',0,'f_rr_c',rr_offset(i)));
    subtbl_mass = model_acceleration_with_aero_ipg(subtbl,...
        struct('front_area',0,'trailer_mass',mass_offset(i),'f_rr_c',0));
    subtbl = model_acceleration_with_aero_ipg(subtbl,...
        struct('front_area',aero_offset(i),'trailer_mass',mass_offset(i),'f_rr_c',rr_offset(i)));
    
    %% get the FIR zero-phase
    order=27;
    firf = designfilt('lowpassfir','FilterOrder',order, ...
        'CutoffFrequency',1.2,'SampleRate',10);
    a_num=diff(subtbl.v_noise)*10; % 0.5 samples late
    subtbl.a_fir=filter(firf,[a_num;0]); % +qq-0.5 samples late
    
    % shift a_fir
    subtbl.a_fir = [subtbl.a_fir((order+1)/2:end);zeros((order+1)/2-1,1)];
    
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