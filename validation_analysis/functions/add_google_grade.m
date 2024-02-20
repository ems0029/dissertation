function lookuptbl = add_google_grade(tbl)
% Requires X, lat, lon, 
% returns google elevation lookup per meter
API_key = getenv("googleKey");

% Every 10 meters get the elevation
df = sortrows(tbl{:,{'x','lat','lon','alt','grade_estimate'}},1);
[~,ia,~]=unique(df(:,1));
df = df(ia,:);
f =griddedInterpolant(df(:,1),df(:,2:3));
x=[0:1:max(df(:,1)),max(df(:,1))]';
fx=f(x);
lookuptbl=table(x,fx(:,1),fx(:,2),nan(size(x)),nan(size(x)),nan(size(x)),nan(size(x)),'VariableNames',{'x','lat','lon','lat_google','lon_google','alt_google','grade_google'});

%% snap to roads, return new lat, lon
for q = 1:100:height(lookuptbl)-1
    idx = min(height(lookuptbl),q+99);
    path=sprintf('%.6f%%2C%.6f|',reshape(permute([lookuptbl.lat(q:idx),lookuptbl.lon(q:idx)],[2 1]),1,[]));
    path = path(1:end-1);
    snapUrl = sprintf('https://roads.googleapis.com/v1/snapToRoads?interpolate=false&path=%s&key=%s',...
        path,API_key);
    res=webread(snapUrl);
    o_idx=arrayfun(@(x) x.originalIndex,res.snappedPoints);
    lat_google=arrayfun(@(x) x.location.latitude,res.snappedPoints);
    lon_google=arrayfun(@(x) x.location.longitude,res.snappedPoints);
    lookuptbl.lat_google(o_idx+q)=lat_google;
    lookuptbl.lon_google(o_idx+q)=lon_google;
end

lookuptbl(:,{'lat_google','lon_google'}) =fillmissing(lookuptbl(:,{'lat_google','lon_google'}) ,'linear');
for q = 1:512:height(lookuptbl)-1
    idx = min(height(lookuptbl),q+511);
    path=sprintf('%.6f%%2C%.6f|',reshape(permute([lookuptbl.lat_google(q:idx),lookuptbl.lon_google(q:idx)],[2 1]),1,[]));
    path = path(1:end-1);
%     url = sprintf('https://maps.googleapis.com/maps/api/elevation/json?locations=%f%%2C%f&key=%s',...
    url = sprintf(['https://maps.googleapis.com/maps/api/elevation/json?' ...
        'path=%s&samples=%u&key=%s'],...
        path,idx-q+1,API_key);
    try
        res = webread(url).results;
        lookuptbl.alt_google(q:idx) = arrayfun(@(x) x.elevation,res);
        lookuptbl.alt_google_res(q:idx) = arrayfun(@(x) x.resolution,res);
    catch ME
        disp(ME)
    end
end


end