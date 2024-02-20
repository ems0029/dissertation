%
clearvars
API_key = "AIzaSyDRIHOqqDGRe_ne8VDWF6AaWem-Jtv1NSs";
filepath = "C:\Users\ems0029\Downloads\I-70 East of Glenwood Springs, CO.kml";
df = kmz2struct(filepath);
df = df(1);
%long list
ll_list_all=[df.Lat;df.Lon]';

win =10;

%shorter_list with waypoints
ll_list = ll_list_all(1:win:end,:);
while length(ll_list)>=100
    win = win+1;
    ll_list = ll_list_all(1:win:end,:);
end

%snap to point API
path = join(reshape([string(ll_list(:,1)), ...
    repmat("%2C",size(ll_list(:,1))), ...
    string(ll_list(:,2)), ...
    repmat("|",size(ll_list(:,1)))]',1,[]),'');
path = char(path);
path = path(1:end-1);
snapUrl = sprintf('https://roads.googleapis.com/v1/snapToRoads?interpolate=true&path=%s&key=%s',...
    path,API_key);
try
    df=webread(snapUrl);
    df_s = cellfun(@(x) x.location,df.snappedPoints)
    ll_tbl = struct2table(df_s);
catch ME
    disp(ME)
end

plot(ll_tbl,'latitude','longitude')
writetable(ll_tbl,erase(filepath,"kml")+"txt")

ll_tbl.altitude = nan(height(ll_tbl),1);

for q = 1:height(ll_tbl)
    url = sprintf('https://maps.googleapis.com/maps/api/elevation/json?locations=%f%%2C%f&key=%s',...
        ll_tbl.latitude(q),ll_tbl.longitude(q),API_key);
    try
        ll_tbl.altitude(q) = webread(url).results.elevation;
    catch ME
        disp(ME)
    end
end

ecef_tbl =lla2ecef(table2array(ll_tbl));