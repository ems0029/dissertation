clearvars -except tbl
close all
if ~exist('tbl','var')
    load('..\processed\tbl_sensitivity_analysis.mat','tbl')
    tbl = tbl(tbl.truck~="C",:);
end

tbl.ID = findgroups(tbl.truck,tbl.ego_m,tbl.other_m,tbl.set_velocity,tbl.drag_reduction_ratio);
try
    tbl = addprop(tbl,{'offsets','noise'},{'table','table'});
catch ME
    disp(ME)
end
tbl.Properties.CustomProperties.noise = struct('v',true,'grade',true,'engine_power',true);
tbl.Properties.CustomProperties.offsets = struct('front_area',0,'trailer_mass',0,'f_rr_c',0);

rng("default")
addpath('..\functions\')
addpath('..\lookups\truck_params\')

%% preallocate results
P_aero_true = zeros(max(tbl.ID),1);
P_AD_true = zeros(max(tbl.ID),1);
NPC_true = zeros(max(tbl.ID),1);
mass_true = zeros(max(tbl.ID),1);
P_aero_inf = cell(max(tbl.ID),1);
P_AD_inf = cell(max(tbl.ID),1);
NPC_inf = cell(max(tbl.ID),1);
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
    mass_true(i)=subtbl.ego_m(1)+15000;
    
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

    subtbl_aero.Properties.CustomProperties.offsets = struct('front_area',aero_offset(i),'trailer_mass',0,'f_rr_c',0);
    subtbl_rr.Properties.CustomProperties.offsets = struct('front_area',0,'trailer_mass',0,'f_rr_c',rr_offset(i));
    subtbl_mass.Properties.CustomProperties.offsets = struct('front_area',0,'trailer_mass',mass_offset(i),'f_rr_c',0);
    subtbl.Properties.CustomProperties.offsets = struct('front_area',aero_offset(i),'trailer_mass',mass_offset(i),'f_rr_c',rr_offset(i));
    
    %% get outputs for all

    % here goes the function to run rls and cadj
    [P_AD_inf{i}, P_aero_inf{i}, NPC_inf{i},...
        P_AD_true(i), P_aero_true(i), NPC_true(i)] = the_wringer({subtbl_aero,subtbl_rr,subtbl_mass,subtbl},nn_C);
    % need a way of getting the percent error in P_AD, P_aero, NPC

end
P_AD_inf = vertcat(P_AD_inf{:});
P_aero_inf = vertcat(P_aero_inf{:});
NPC_inf = vertcat(NPC_inf{:});

%% aero errors
figure(1)
clf
hold on
plot(100*aero_offset./10,100*(cellfun(@(x) x,P_aero_inf(:,1))-P_aero_true)./P_aero_true,'.','DisplayName','P_{aero}')
plot(100*aero_offset./10,100*(cellfun(@(x) x(1),P_AD_inf(:,1),'uniformoutput',true)-P_AD_true)./P_AD_true,'.','DisplayName','P_{AD} - RLS')
plot(100*aero_offset./10,100*(cellfun(@(x) x(2),P_AD_inf(:,1),'uniformoutput',true)-P_AD_true)./P_AD_true,'.','DisplayName','P_{AD} - Constant Offset')
plot(100*aero_offset./10,100*(cellfun(@(x) x(1),NPC_inf(:,1),'uniformoutput',true)-NPC_true),'.','DisplayName','NPC - RLS')
plot(100*aero_offset./10,100*(cellfun(@(x) x(2),NPC_inf(:,1),'uniformoutput',true)-NPC_true),'.','DisplayName','NPC - Constant Offset')
legend('Location','northwest')
xtickformat('percentage')
ytickformat('percentage')
xlabel('Error in C_dA_f')
ylabel('Error in Inferred Value')

%% RR errors
figure(2)
clf
hold on
scatter(100*rr_offset./0.01,100*(cellfun(@(x) x, P_aero_inf(:,2))-P_aero_true)./P_aero_true,'.','DisplayName','P_{aero}','MarkerFaceAlpha',0.5)
scatter(100*rr_offset./0.01,100*(cellfun(@(x) x(1),P_AD_inf(:,2),'uniformoutput',true)-P_AD_true)./P_AD_true,'.','DisplayName','P_{AD} - RLS')
% plot(100*rr_offset./0.01,100*(cellfun(@(x) x(2),P_AD_inf(:,2),'uniformoutput',true)-P_AD_true)./P_AD_true,'.','DisplayName','P_{AD} - Constant Offset')
scatter(100*rr_offset./0.01,100*(cellfun(@(x) x(1), NPC_inf(:,2),'uniformoutput',true)-NPC_true),'.','DisplayName','NPC - RLS')
% plot(100*rr_offset./0.01,100*(cellfun(@(x) x(2), NPC_inf(:,2),'uniformoutput',true)-NPC_true),'.','DisplayName','NPC - Constant Offset')
legend('Location','best')
xtickformat('percentage')
ytickformat('percentage')
xlabel('Error in C_{rr}')
ylabel('Error in Inferred Value')

%% mass errors
figure(3)
clf
hold on
plot(100*mass_offset./mass_true',100*(cellfun(@(x) x, P_aero_inf(:,3))-P_aero_true)./P_aero_true,'.','DisplayName','P_{aero}')
plot(100*mass_offset./mass_true',100*(cellfun(@(x) x(1),P_AD_inf(:,3),'uniformoutput',true)-P_AD_true)./P_AD_true,'.','DisplayName','P_{AD} - RLS')
plot(100*mass_offset./mass_true',100*(cellfun(@(x) x(2),P_AD_inf(:,3),'uniformoutput',true)-P_AD_true)./P_AD_true,'.','DisplayName','P_{AD} - Constant Offset')
plot(100*mass_offset./mass_true',100*(cellfun(@(x) x(1), NPC_inf(:,3),'uniformoutput',true)-NPC_true),'.','DisplayName','NPC - RLS')
plot(100*mass_offset./mass_true',100*(cellfun(@(x) x(2), NPC_inf(:,3),'uniformoutput',true)-NPC_true),'.','DisplayName','NPC - Constant Offset')
legend('Location','best')
xtickformat('percentage')
ytickformat('percentage')
xlabel('Error in Mass')
ylabel('Error in Inferred Value')
