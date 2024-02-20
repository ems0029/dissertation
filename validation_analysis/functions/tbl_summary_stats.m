function tbl_summary_stats(tbl)

[~,truck_v]=findgroups(tbl.truck);

truck_id =grpstats(findgroups(tbl.truck),tbl.ID);

% get trip time
[trip_time,gid] = get_trip_time(tbl);

% get fuel consumed [L/hr average]
fuel = get_fuel_consumed(tbl);

% get active deceleration [kJ/kghr]
ead = get_ead(tbl);

% get tc ratio for valid runs (resulting vector is shorter)
refs = grpstats(tbl.refID,tbl.ID,'mode');
tc = nan(size(fuel));
tc(truck_id==2) = fuel(truck_id==2)./fuel(refs(truck_id==2));
tc(truck_id==3) = fuel(truck_id==3)./fuel(refs(truck_id==3));

% get drag reduction ratio
drr = get_drr(tbl);


%% raw plots
figure(1)

hold on
t13 =scatter(ead(truck_id==2),fuel(truck_id==2),'filled')
t14 =scatter(ead(truck_id==3),fuel(truck_id==3),'filled')
rf =scatter(ead(truck_id==1),fuel(truck_id==1),'filled')

%% NFC plots
mdl_rf = fitlm(ead(truck_id==1),fuel(truck_id==1))
mdl_t13 =fitlm(ead(truck_id==2),fuel(truck_id==2))
mdl_t14 =fitlm(ead(truck_id==3),fuel(truck_id==3))
nfc = nan(size(fuel))
nfc(truck_id==1)=fuel(truck_id==1)/mdl_rf.Coefficients.Estimate(1)
nfc(truck_id==2)=fuel(truck_id==2)/mdl_t13.Coefficients.Estimate(1)
nfc(truck_id==3)=fuel(truck_id==3)/mdl_t14.Coefficients.Estimate(1)

figure(2)

hold on
t13 =scatter(ead(truck_id==2),nfc(truck_id==2),'filled')
t14 =scatter(ead(truck_id==3),nfc(truck_id==3),'filled')
rf =scatter(ead(truck_id==1),nfc(truck_id==1),'filled')


%% TC plots
mdl_tc_t13=fitlm(ead(truck_id==2),tc(truck_id==2));
mdl_tc_t14=fitlm(ead(truck_id==3),tc(truck_id==3));
tc_nfc = nan(size(fuel));
tc_nfc(truck_id==2)=tc(truck_id==2)/mdl_tc_t13.Coefficients.Estimate(1)
tc_nfc(truck_id==3)=tc(truck_id==3)/mdl_tc_t14.Coefficients.Estimate(1)

figure(3)

hold on
t13 =scatter(ead(truck_id==2),tc(truck_id==2),'filled')
t14 =scatter(ead(truck_id==3),tc(truck_id==3),'filled')

fitlm([ead,drr],tc)

end


