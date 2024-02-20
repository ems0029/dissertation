function tbl = add_missing_rf_7(tbl)

stats = (grpstats(tbl.time(tbl.truck=="RF"&tbl.eastbound),tbl.ID(tbl.truck=="RF"&tbl.eastbound),'range'));

% number of samples to add
ns = round((median(stats)-stats(13))*10);

% first ID 13 run indexes
idxs = find(tbl.ID==13);

% dummy row generation
dummyRow=tbl(idxs(1),:);
dummyRow{:,{'alt','lat','lon','brakes_on','brake_by_driver',...
    'engine_pct_torque','engine_rpm','fan_state','fuel_rate','gear_number',...
    'gps_seconds','grade_estimate','north','range_estimate',...
    'retarder_pct_torque','v','brake_pedal_position',...
    'desired_ctrl_brake_rate','drtk_v2v_dist','east','up'}}=nan;
dummyRows = repmat(dummyRow,[ns,1]);
t_front = 0.1*(0:ns-1)';
dummyRows.time = t_front;
% add

%modify the time in the table for ID 13
tbl.time(idxs) = tbl.time(idxs)-tbl.time(idxs(1))+t_front(end)+0.1;

tbl = [tbl(1:idxs(1)-1,:);...
    dummyRows;...
    tbl(idxs(1):end,:)];


end
