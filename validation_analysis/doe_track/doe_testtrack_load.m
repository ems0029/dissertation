clearvars
% loads the doe table and renames it to work with the new variables here
tbl = load('F:\other_scripts_2021\SAE_2023_utils\Table_Experimental_all_track.mat','T').T;

tbl =renamevars(tbl,{'Truck','NumOfTrucks','Spacing','Iter','Year',...
    'gpsWeek','gpsTime','Time','grade_meas','rpv',...
    'EngineRPM','EnginePctTrq','EngineFuelFlow',...
    'GearNo','headway_est','Leading','FanState',...
    'RetPctTrq','BrByDrvr','BrOn','BrkAmt',...
    'a_est','trackPos_zeroTOone','grade_lookup'},...
    {'truck','numTrucks','spacing','runIter','year',...
    'gps_week','gps_seconds','time','grade_estimate','drtk_v2v_dist',...
    'engine_rpm','engine_pct_torque','fuel_rate',...
    'gear_number','range_estimate','leading','fan_state',...
    'retarder_pct_torque','brake_by_driver','brakes_on','brake_pedal_position',...
    'a_estimate','x','grade_estimate_lookup'});

tbl.desired_ctrl_brake_rate = tbl.brake_pedal_position;

addpath("../functions")
addpath(genpath("../lookups"))

%% add follower headway to leader

tbl.runID=findgroups(tbl.year,tbl.numTrucks,tbl.spacing,tbl.runIter);
tbl = add_follower_gap(tbl,"DOE_testtrack");

%% add features
tblArr=cell(max(tbl.ID),1);

for q=1:max(tbl.ID)
    fprintf('\n ********\tProcessing %u of %u\t ******** \n\n',q,max(tbl.ID))
    subtbl = tbl(tbl.ID==q,:);
    
    switch subtbl.truck(1)
        case "A1"
            param_path = "A1_doe.mat";
        case "A2"
            param_path = "A2_doe.mat";
        case "T13"
            param_path = "T13_JDSMC.mat";
        case "T14"
            param_path = "T14_JDSMC.mat";
        otherwise
            error("truck not found")
    end
    subtbl = add_features(subtbl,param_path);
%     subtbl = estimate_course(subtbl);
%     subtbl = get_weather_3_0_new_names(subtbl,60*40);
%     subtbl = body_axis_wind(subtbl,0.5);
    trim = find(subtbl.x>0.99,1,'first'):find(subtbl.x>0.99,1,'last');
    fprintf(['*-----------------------------------------------*' ...
           '\n Removing %u points before and after first lap' ...
           '\n*-----------------------------------------------*\n'],height(subtbl)-length(trim))
    tblArr{q} = subtbl(trim,:);
end

tbl = vertcat(tblArr{:});

truck_sel = ["A1","A2","T13","T14"];
tblArr =cell(4,1);
for q=1:4
    subtbl = tbl(tbl.truck==truck_sel(q),:);
    
    switch truck_sel(q)
        case "A1"
            param_path = "A1_doe.mat";
        case "A2"
            param_path = "A2_doe.mat";
        case "T13"
            param_path = "T13_JDSMC.mat";
        case "T14"
            param_path = "T14_JDSMC.mat";
        otherwise
            error("truck not found")
    end
    % TODO add wind velocity if possible
    load(param_path,'truck')
    subtbl.P_aero = 0.5*truck.c_d*truck.front_area*1.225*(subtbl.v).^3;
%     subtbl.P_aero_wind = 0.5*truck.c_d*truck.front_area*subtbl.amb_density.*(subtbl.wind_v_veh).^2.*subtbl.v;
%     subtbl.P_rr = truck.f_rr_c*9.81*(truck.tractor_mass+truck.trailer_mass).*subtbl.v;
%     subtbl.drag_frac = subtbl.P_aero./(subtbl.P_aero+subtbl.P_rr);
%     subtbl.drag_frac_w_fan = subtbl.P_aero./(subtbl.P_aero+subtbl.P_rr+subtbl.fan_power_est*1000);
    tblArr{q} = subtbl;
end

tbl = vertcat(tblArr{:});


