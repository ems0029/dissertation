clearvars
% put the T13/T14 and corresponding control runs in the matrix
matfiles =dir('..\..\..\PatrickSmith\DOE_on_road\**\*.mat');
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

    [truck,numTrucks,spacing,runIter] = file_id_doeOnRoad(matfiles(q).name);

    subtbl = [repmat(table(truck,numTrucks,spacing,runIter),height(subtbl),1),subtbl];

    tblArr{q}=subtbl;

end

tbl = vertcat(tblArr{:});

%% Cleaning

%-Add Identifiers----------------------------------------------------------

tbl.ID = findgroups(tbl.truck,tbl.numTrucks,tbl.spacing,tbl.runIter);

tbl.runID = findgroups(tbl.numTrucks,tbl.spacing,tbl.runIter);

% can't handle logicals/ints in some of the time math
tbl = convertvars(tbl,{'brake_by_driver','brakes_on','gear_number'},'double');

%% add follower headway to leader

tbl = add_follower_gap(tbl,"DOE_onroad");


%% mask the non I85 data
% geoplot
mask = tbl.lat<32.6435&tbl.lon<-85.3518;
clf;geoscatter(tbl.lat(1:10:end),tbl.lon(1:10:end),'Marker','.','MarkerEdgeAlpha',0.1,'MarkerEdgeColor',[12, 35, 64]./255)
hold on
geoscatter(tbl.lat(mask),tbl.lon(mask),'Marker','.','MarkerEdgeAlpha',0.1,'MarkerEdgeColor',[232, 119, 34]./255)
geobasemap topographic
exportgraphics(gcf,'DOE_onroad_geomap.png','Resolution',300)
tbl = tbl(mask,:);

%% get the distance traveled



%% divide east and west segments

% add enu, and a preliminary east-west division
tbl = get_east_west_prelim(tbl,"DOE_onroad");

%%  bounding boxes
% theta0 = [-3.185e4,-1.887e4];
% theta=atan2(tbl.east-theta0(1),tbl.north-theta0(2));
% tbl.eastbound = [false;rem(cumsum(diff(theta)>5),2)];
% tbl.westbound = ~tbl.eastbound;
tbl.eastbound = tbl.course>0.5&tbl.course<1.9;
tbl.westbound = tbl.course>-2.9&tbl.course<-1.32;


%% add features and further trim
tblArr=cell(length(matfiles),1);

for q = 1:max(tbl.ID)
    subtbl = tbl(tbl.ID==q,:);
    if isempty(subtbl)
        continue
    end
    subtbl.time = subtbl.time-subtbl.time(1);
    %% distance traveled
    subtbl.x = cumtrapz(subtbl.time,subtbl.v);
    % bwd=cumtrapz(tbl.time(end:-1:1),tbl.v(end:-1:1));
    % bwd = flip(bwd)-bwd(end);
    % plot(tbl.x-bwd)
    % pause
    tblArr{q} = subtbl;
end

tbl = vertcat(tblArr{:});

%% add grade lookups
tbl = grade_spread_to_leader(tbl);
tbl = grade_google_lookup(tbl);

%% add further features
tblArr=cell(length(matfiles),1);

for q = 1:max(tbl.ID)
    subtbl = tbl(tbl.ID==q,:);
    if isempty(subtbl)
        continue
    end

    switch subtbl.truck(1)
        case "A1"
            param_path = "A1_doe.mat";
        case "A2"
            param_path = "A2_doe.mat";
        otherwise
            error("truck not found")
    end
    subtbl = get_weather_3_0_new_names(subtbl,300);
    subtbl = body_axis_wind(subtbl,0.5);
    subtbl = add_features(subtbl,param_path);
    tblArr{q} = subtbl;
end

tbl = vertcat(tblArr{:});