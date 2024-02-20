function subtbl = get_weather_3_0_new_names(subtbl,freq)
%get_weather Use OpenWeather API to get the weather
%   The API key is mine, but one can be easily created
persistent n
if isempty(n)
    n=0;
end
if nargin==1
    freq=3600;
end

api_key = getenv("openWeatherMapKey");

% URL anon function
formatSpec = 'https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=%f&lon=%f&dt=%u&appid=%s';
url = @(lat,lon,t_start,t_end) sprintf(formatSpec,lat,lon,t_start,api_key);

% GPS time conversion base: https://www.mathworks.com/matlabcentral/answers/889447-how-to-convert-the-number-of-seconds-from-an-epoch-into-utc-using-the-datetime-function
epoch = datetime(1980,1,6,'TimeZone','UTCLeapSeconds');
t_gps = subtbl.gps_week*7*24*60*60+subtbl.gps_seconds;
% UTC time
dt = epoch + seconds(t_gps) ;
dt = fillmissing(dt,'linear');
dt = convertTo(dt,'epochtime');

%preallocate
subtbl.wind_speed = nan(height(subtbl),1);
subtbl.wind_dir_abs = nan(height(subtbl),1);
subtbl.amb_temp = nan(height(subtbl),1);
subtbl.amb_pressure = nan(height(subtbl),1);

%get weather data every weather_update_dt seconds
weather_update_dt = freq;
update_idxs = find(ismembertol(-diff(mod(t_gps,weather_update_dt)),weather_update_dt,10,'DataScale',1)==1);
dt_sub = dt(update_idxs);


for q = 1:length(dt_sub)
    n=n+1;
    disp(n)
    if n>999
        disp('too many requests today')
        return
    else
        df = webread(url(subtbl.lat(update_idxs(q)),...
            subtbl.lon(update_idxs(q)),...
            dt_sub(q)));
        subtbl.wind_speed(update_idxs(q))    = df.data.wind_speed;
        subtbl.wind_dir_abs(update_idxs(q))   = df.data.wind_deg;
        subtbl.amb_temp(update_idxs(q))       = df.data.temp;
        subtbl.amb_pressure(update_idxs(q))   = df.data.pressure*100;
    end

end

subtbl = fillmissing(subtbl,"nearest","DataVariables",{'wind_speed','wind_dir_abs','amb_temp','amb_pressure'});

subtbl.amb_density = subtbl.amb_pressure./(287.058*(subtbl.amb_temp));


end