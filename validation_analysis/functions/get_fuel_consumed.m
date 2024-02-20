function [avg_fuel,gid,L_fuel] = get_fuel_consumed(tbl)
% get_fuel_consumed this function gets the grouped fuel consumed for each
% run in the given table, using the average fuel rate reported by CAN

[avg_fuel,gid]=grpstats(tbl.fuel_rate,tbl.ID,{'mean','gname'});

return

%% DIAGNOSTICS (just checking)
for q = 1:max(tbl.ID)
    subtbl = tbl(tbl.ID==q,:);
    totalfuel = trapz(subtbl.time,subtbl.fuel_rate/3600); % units of liters
    result{q} = totalfuel;
end
[trip_time] = grpstats(tbl.time,tbl.ID,{'range'});

L_fuel = vertcat(result{:});
L_fuel = L_fuel(~ismembertol(L_fuel,0,0.1,'DataScale',1));
L_h_fuel = L_fuel./trip_time*3600;

%compare the two on a percent difference basis
200*(L_h_fuel-avg_fuel)./(L_h_fuel+avg_fuel);

end