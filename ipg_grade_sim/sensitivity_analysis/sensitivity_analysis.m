clearvars -except tbl
close all
if ~exist('tbl','var')
    load('..\processed\tbl_sensitivity_analysis.mat','tbl')
    tbl = tbl(tbl.truck~="C",:);
end

tbl.ID = findgroups(tbl.truck,tbl.ego_m,tbl.other_m,tbl.set_velocity,tbl.drag_reduction_ratio);


rng("default")
addpath('..\functions\')
addpath('..\lookups\truck_params\')

%% preallocate results
P_aero_true = zeros(max(tbl.ID),1);
P_AD_true = zeros(max(tbl.ID),1);
NPC_true = zeros(max(tbl.ID),1);
aero_offset = zeros(max(tbl.ID),1);
rr_offset = zeros(max(tbl.ID),1);
mass_offset = zeros(max(tbl.ID),1);
subtbl_array = cell(max(tbl.ID),1);

%% load lookups
load('..\lookups\nn_brakeless_lookup.mat','nn_C')
load('..\lookups\ecdf_v_grade.mat','cdf_grade','cdf_v','gi','vi')
order=27;
firf = designfilt('lowpassfir','FilterOrder',order, ...
    'CutoffFrequency',1.2,'SampleRate',10);
    

% begin monte-carlo loop
for i = 1:max(tbl.ID)

    subtbl=tbl(tbl.ID==i,:);

    %% get truth
    P_aero_true(i) = mean(subtbl.PwrL_Aero);
    P_AD_true(i) = mean(subtbl.PwrL_Brake);
    NPC_true(i) = mean(subtbl.engine_power)/nn_C.predict([mean(subtbl.v),subtbl.ego_m(1)+15000]);

    %% add noise
    subtbl.grade_true = subtbl.grade;
    subtbl.v_true = subtbl.v;
    subtbl.engine_power_true = subtbl.engine_power;
    
    subtbl.grade = subtbl.grade+interp1(cdf_grade,gi,rand(size(subtbl.grade)),'linear','extrap')*pi/180;
    subtbl.v = subtbl.v + interp1(cdf_v,vi,rand(size(subtbl.v)),'linear','extrap');
    subtbl.engine_power = subtbl.engine_power+40*randn(size(subtbl.v)).*(subtbl.engine_rpm*pi/30); %40 N.m gaussian torque disturbance
    
    %% get the FIR zero-phase
    a_num=diff(subtbl.v)*10; % 0.5 samples late
    subtbl.a_fir=filter(firf,[a_num;0]); % +qq-0.5 samples late
    subtbl.a_fir = [subtbl.a_fir((order+1)/2:end);zeros((order+1)/2-1,1)];
    subtbl.a_estimate=subtbl.a_fir;
    

    %% get vehicle model acceleration for a random parameter offsets
    aero_offset(i) = 10*(rand(1)-0.5);
    rr_offset(i) = 0.01*(rand(1)-0.5);
    mass_offset(i) = 10000*(rand(1)-0.5);
    fprintf('****OFFSETS****\n\nA_f: %.2f\nm: %.0f\nC_rr: %.4f\n',...
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

    %% get outputs for all

    % here goes the function to run rls and cadj
    subtbl_array{i}=the_wringer({subtbl_aero,subtbl_rr,subtbl_mass,subtbl});
    
    P_AD_true(i) = trapz(subtbl.time,subtbl.PwrL_Brake)/range(subtbl.time);
    
end