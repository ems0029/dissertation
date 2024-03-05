clearvars
% put the aligned platoon data and corresponding control runs in the matrix
matfiles =dir('../../../PatrickSmith/Canada_Fuel_Test/AL/*/*.mat');
matfiles =[matfiles;dir('../../../PatrickSmith/Canada_Fuel_Test/RF/*/*.mat')];
matfiles =[matfiles;dir("F:\PatrickSmith\Canada_Fuel_Test\OT\A2\OT-CI-S75-1_2019-06-27-17-18-20.mat")];
csvfiles =dir('../../../PatrickSmith/Canada_Fuel_Test/AL/NRC/*/*.csv');
csvfiles =[csvfiles;dir('../../../PatrickSmith/Canada_Fuel_Test/RF/NRC/*/*.csv')];
csvfiles =[csvfiles;dir('../../../PatrickSmith/Canada_Fuel_Test/OT/NRC/Control/*.csv')];
addpath("../functions")
addpath(genpath("../lookups"))

%% Load data and add metadata
tblArr=cell(length(matfiles),1);
tic
parfor q = 1:length(matfiles)

    subtbl = flat_auburn_data(strcat(matfiles(q).folder,'\',matfiles(q).name));
    folder = strsplit(matfiles(q).folder,"\");
    truck = string(folder{end});
    [numTrucks,spacing,runIter,otherId] = file_id_canada(matfiles(q).name);

    subtbl = [repmat(table(truck,numTrucks,otherId,spacing,runIter),height(subtbl),1),subtbl];

    tblArr{q}=subtbl;

end
toc
tbl = vertcat(tblArr{:});
tbl = convertvars(tbl,{'brakes_on','brake_by_driver','gear_number'},'double');

tbl.ID = findgroups(tbl.truck,tbl.numTrucks,tbl.otherId,tbl.spacing,tbl.runIter);
tbl.runID = findgroups(tbl.numTrucks,tbl.otherId,tbl.spacing,tbl.runIter);

tbl = add_follower_gap(tbl,'canada');
tbl = convertvars(tbl,'leading','double');

%% Add NRC pieces where possible
tblArr=cell(length(csvfiles),1);
parfor q = 1:length(csvfiles)

    subtbl = flat_nrc_data(strcat(csvfiles(q).folder,'\',csvfiles(q).name));

    tblArr{q}=subtbl;

end

nrc_tbl = vertcat(tblArr{:});


%% time synchronization
tbl.gps_time = duration(seconds(tbl.gps_seconds+tbl.gps_week*24*7*60*60));
nrc_tbl.gps_time = duration(seconds(round(nrc_tbl.gps_seconds_NRC,1)+nrc_tbl.gps_week_NRC*24*7*60*60));
tbl = table2timetable(tbl);
nrc_tbl = table2timetable(nrc_tbl);

ctrl_tbl = nrc_tbl(nrc_tbl.truck_NRC=="Ctrl",:);
A1_tbl = nrc_tbl(nrc_tbl.truck_NRC=="A1",:);

tblArr =cell(max(tbl.ID),1);
for q = 1:max(tbl.ID)
    subtbl = tbl(tbl.ID==q,:);
    subtbl = synchronize(subtbl,ctrl_tbl,'intersection');
    disp(height(subtbl))
    subtbl = synchronize(subtbl,A1_tbl,'first');
    disp(height(subtbl))
    
    tblArr{q}=subtbl;
end

%% add features
param_path = "A2_canada.mat"; %same parameters as A1

parfor q = 1:length(tblArr)
    if isempty(tblArr{q})
        tblArr{q}=tblArr{q};
    else
        tblArr{q} = get_weather_3_0_new_names(tblArr{q},5*60);
        tblArr{q} = body_axis_wind(tblArr{q},0.2);
        tblArr{q} = add_features(tblArr{q},param_path);
        tblArr{q} = tblArr{q}(...
            find(diff(tblArr{q}.track_north_NRC_subtbl)==-1,1,'first') ...
            :find(diff(tblArr{q}.track_north_NRC_subtbl)==-1,1,'last'), :) 
    end
end
%remove empties
tblArr = tblArr(cellfun(@(x) ~isempty(x),(tblArr)));
tbl_all = vertcat(tblArr{:});

tbl_all.P_aero = 0.5*5.5*1.225.*(tbl_all.v).^2.*tbl_all.v;
tbl_all.P_aero_wind = 0.5*5.5.*tbl_all.amb_density.*(tbl_all.wind_v_veh).^2.*tbl_all.v;
