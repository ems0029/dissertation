function out = flat_nrc_data(filepath)
%add_canada_nrc_fields Read NRC csv and pull out relevant fields indexed by
%gps second and week
%
% filepath = "F:\PatrickSmith\Canada_Fuel_Test\RF\NRC\A2\T_TimeSeriesData_10Hz_RF1_Truck2_Run4.csv";
% data = load("F:\PatrickSmith\Canada_Fuel_Test\RF\A2\RF-3_2019-06-11-16-28-15.mat")
% data = data.data;
tbl = readtable(filepath);

% A2 variable naming inconsistency fix
currentVariableNames = tbl.Properties.VariableNames;
tbl.Properties.VariableNames = cellfun(@(x) replace(x,["__","513c","4154c","190c"],["_","513","4154","190"]),...
    currentVariableNames,'UniformOutput',false);


out = table();

[out.gps_week,out.gps_seconds] = convert_unix2gps(tbl.TimeUnixEpoch_s_);
out.caseId = string(cell2mat(tbl.Config));
out.truck = truckId(tbl.Truck);
out.runIter = tbl.Run;
out.ambTemp = tbl.AmbientTemperature_deg_;
out.ambPressure = tbl.AmbientPressure_milibar_*100;
out.windSpeed_WS = tbl.WeatherStationWidnSpeed_m_s_;
out.windDir_WS = tbl.WeatherStationWindDirection_deg_;
out.windSpeed_veh = tbl.WindSpeedCobraFilteredCorrected_m_s_;
out.windDir_veh = tbl.WindAngleCobraFilteredAndCorrected_deg_;
out.lat = tbl.GPSLatitude_deg_;
out.lon = tbl.GPSLongitude_deg_;
out.v_gps = tbl.GPSSpeedFilteredUpsampled_m_s_;
out.v = tbl.WheelBasedSpeed_m_s_;
out.engine_pct_tq = tbl.EnginePercentTorque_Actual_513+tbl.EnginePercentTorque_ActualHighResolution_4154;
out.engine_speed =  tbl.EngineSpeed_190;
out.engine_fuel_rate = tbl.EngineFuelRate_l_hr_;
out.track_straight = tbl.TrackSegment_1_straight_0_curved_;
out.track_north = tbl.TrackSide_0_North_1_South_;

% add NRC to the labels
out.Properties.VariableNames = cellfun(@(x) [x,'_NRC'],out.Properties.VariableNames,'UniformOutput',false);

%% checking with auburn data

% clf
% plot(data.novatel_local.llhPositionTagged.gpsSeconds,interp1(data.j1939.fuel_economy.time,data.j1939.fuel_economy.fuelRate,data.novatel_local.llhPositionTagged.time))
% hold on
% plot(out.gps_seconds,tbl.EngineFuelRate_l_hr_)

    function out = truckId(truck)
        switch truck(1)
            case 1
                out = repmat("A1",size(truck));
            case 2
                out = repmat("A2",size(truck));
            case 3
                out = repmat("Ctrl",size(truck));
        end
    end

    function [gps_weeks,gps_seconds] = convert_unix2gps(time_nrc)
        time_utc_nrc = datetime(time_nrc,'ConvertFrom','posixtime');
        time_utc_nrc.TimeZone = 'UTC';

        gps_reference = datetime('06/01/1980',...
            'InputFormat', 'dd/MM/yyyy',...
            'TimeZone',    'UTC');

        dt = between(gps_reference,time_utc_nrc(1), 'Days');
        total_days = caldays(dt);
        total_seconds = total_days*86400;
        total_weeks = total_seconds/604800;

        % GPS Week
        gps_week_nrc = floor(total_weeks);
        remaining_week = total_weeks - gps_week_nrc;

        % GPS Seconds
        day_in_week = round(remaining_week*7);
        seconds_in_week = day_in_week*86400;

        dt_time = between(gps_reference, time_utc_nrc);
        [t] = split(dt_time,{'time'});
        seconds_in_day = seconds(t);

        CURRENT_NUM_LEAP_SECONDS = 19; %for some reason there is a 1 second difference I didn't expect, should only be 18 leapseconds

        gps_seconds_nrc = seconds_in_week + seconds_in_day + CURRENT_NUM_LEAP_SECONDS;

        gps_weeks = gps_week_nrc*ones(length(time_nrc),1);
        gps_seconds = gps_seconds_nrc;
    end

end