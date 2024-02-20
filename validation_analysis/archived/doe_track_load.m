clearvars
%% this is too much work, archiving and using the old data with new names instead.
% put the aligned platoon data and corresponding control runs in the matrix
matfiles =dir('../../../NCAT_2019_Data/**/*.mat');
% matfiles =[matfiles;dir('../../../PatrickSmith/Canada_Fuel_Test/RF/*/*.mat')];

addpath("../functions")
addpath(genpath("../lookups"))

%% Load data and add metadata
tblArr=cell(length(matfiles),1);
for q = 1:length(matfiles)

    subtbl = flat_auburn_data(strcat(matfiles(q).folder,'\',matfiles(q).name));
    folder = strsplit(matfiles(q).folder,"\");
     [truck,numTrucks,spacing,runIter,otherInfo] =...
         file_id_doe_track(matfiles(q).name,true);

    subtbl = [repmat(table(truck,numTrucks,spacing,runIter,otherInfo),height(subtbl),1),subtbl];
    %% on/off condition (initial trim)
    subtbl = subtbl(find(subtbl.v>19,1,'first'):find(subtbl.v>19,1,'last'),:);
    tblArr{q}=subtbl;

end

tbl = vertcat(tblArr{:});
tbl = convertvars(tbl,{'brakes_on','brake_by_driver','gear_number'},'double');

tbl.ID = findgroups(tbl.truck,tbl.numTrucks,tbl.spacing,tbl.runIter);
tbl.runID = findgroups(tbl.numTrucks,tbl.spacing);

%% add UTC
epoch = datetime(1980,1,6,'TimeZone','UTCLeapSeconds');
tbl.UTC_time = epoch + seconds(tbl.gps_week*7*24*60*60+tbl.gps_seconds);

tbl = add_follower_gap(tbl,"DOE_testtrack");

geoscatter(tbl.lat(1:100:end),tbl.lon(1:100:end))
