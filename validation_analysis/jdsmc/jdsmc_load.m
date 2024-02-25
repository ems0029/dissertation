clearvars
% put the T13/T14 and corresponding control runs in the matrix
matfiles =dir('../../../JDSMC_data/**/*.mat');
matfiles = rmfield(matfiles, 'datenum');
matfiles = rmfield(matfiles, 'isdir');
matfiles = rmfield(matfiles, 'date');
matfiles = rmfield(matfiles, 'bytes');

addpath("../functions")
addpath(genpath("../lookups"))

%% Load data and add metadata
tblArr=cell(length(matfiles),1);
for q = 1:length(matfiles)

    subtbl = flat_auburn_data(strcat(matfiles(q).folder,'\',matfiles(q).name));

    [truck,numTrucks,lead_ctrl,follow_ctrl,runIter] = file_id_jdsmc(matfiles(q).name);

    subtbl = [repmat(table(truck,numTrucks,lead_ctrl,follow_ctrl,runIter),height(subtbl),1),subtbl];
    
    tblArr{q}=subtbl;

end

tbl = vertcat(tblArr{:});

%% Cleaning

%-Add Identifiers----------------------------------------------------------

tbl.ID = findgroups(tbl.truck,tbl.numTrucks,tbl.lead_ctrl,tbl.follow_ctrl,tbl.runIter);

tbl.runID = findgroups(tbl.numTrucks,tbl.lead_ctrl,tbl.follow_ctrl,tbl.runIter);

% datetime construction
epoch = datetime(1980,1,6,'TimeZone','UTCLeapSeconds');
tbl.UTC_time = epoch + seconds(tbl.gps_week*7*24*60*60+tbl.gps_seconds);

% can't handle logicals/ints in some of the time math
tbl = convertvars(tbl,{'brake_by_driver','brakes_on','gear_number'},'double');

%% remove run 44 (this is EC fx 1 which was scrapped)
tbl(tbl.ID==44&tbl.time>1126,:) = [];

%% add follower headway to leader

tbl = add_follower_gap(tbl,"JDSMC");

%% divide east and west segments

% a preliminary step for east-west division
tbl = get_east_west_prelim(tbl,"JDSMC");

%%  trim east and west

% add the first east-west points, will need to repeat after imputation
tbl = trim_east_west(tbl);

%% imputation routine for missing data

tbl = add_missing_rows(tbl);

% add missing rows to the front of RF7
tbl = add_missing_rf_7(tbl);

% data_imputation
tbl = jdsmc_imputation(tbl);

%% create east/west ID and add reference IDs TODO
%repeated to deal with imputation
tbl = trim_east_west(tbl);

%% eastbound westboud cumulative distance and grade/course lookup
tblArr=cell(length(matfiles),1);
ID =findgroups(tbl.ID,tbl.westbound);
for q = 1:max(ID)
    subtbl = tbl(ID==q,:);
    mask =subtbl.eastbound|subtbl.westbound;
    %only integrate on east or westbound
    subtbl.x(mask) = cumtrapz(subtbl.time(mask),subtbl.v(mask));
    tblArr{q} = subtbl;
end
tbl = vertcat(tblArr{:});

west = [true false];
tbl.grade_estimate_lookup = nan(height(tbl),1);
for q = 1:2
    mask = tbl.westbound==west(q)&tbl.eastbound~=west(q);
    tbl(mask,:) = grade_spread_to_leader(tbl(mask,:));
    tbl(mask,:) = course_spread_to_leader(tbl(mask,:));
end

%% add features and further trim
tblArr=cell(length(matfiles),1);

for q = 21:max(tbl.ID)
    subtbl = tbl(tbl.ID==q,:);
    subtbl =sortrows(subtbl,"time");
    switch subtbl.truck(1)
        case "RF"
            param_path = "A2_JDSMC.mat";
        case "T13"
            param_path = "T13_JDSMC.mat";
        case "T14"
            param_path = "T14_JDSMC.mat";
        otherwise
            error("truck not found")
    end
    subtbl = add_features(subtbl,param_path);
    subtbl = get_weather_3_0_new_names(subtbl,180);
    subtbl = body_axis_wind(subtbl,0.5);
    %cut off any non-eastbound/westbound points
    subtbl = subtbl(subtbl.eastbound|subtbl.westbound,:);
    tblArr{q} = subtbl;
end

tbl_wfeat = vertcat(tblArr{:});

mask_rf = tbl_wfeat.truck~="RF";
try 
    tbl_wfeat.P_aero(mask_rf) = 0.5*10*0.7.*tbl_wfeat.amb_density(mask_rf)*(tbl_wfeat.v(mask_rf)).^2.*tbl_wfeat.v(mask_rf);
    tbl_wfeat.P_aero(~mask_rf) = 0.5*10*0.55.*tbl_wfeat.amb_density(~mask_rf)*(tbl_wfeat.v(~mask_rf)).^2.*tbl_wfeat.v(~mask_rf);
catch
    tbl_wfeat.P_aero(mask_rf) = 0.5*10*0.7.*1.225*(tbl_wfeat.v(mask_rf)).^2.*tbl_wfeat.v(mask_rf);
    tbl_wfeat.P_aero(~mask_rf) = 0.5*10*0.55.*1.225*(tbl_wfeat.v(~mask_rf)).^2.*tbl_wfeat.v(~mask_rf);
end

tbl_wfeat.runID = findgroups(tbl_wfeat.numTrucks,tbl_wfeat.lead_ctrl,tbl_wfeat.follow_ctrl,tbl_wfeat.runIter);

tbl_wfeat = add_reference_id(tbl_wfeat);

tbl = tbl_wfeat;


