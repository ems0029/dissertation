load("..\processed\tbl_12_12_23.mat")

%% trimming

start_pad = 800;
track_length = 3702+400;
tbl_trim = tbl(tbl.x>=start_pad&tbl.x<=start_pad+track_length,:);


%% Check for groups that couldn't stay together
%travel time
%mean speed
%vi, vf
%range
pct_diff = @(v1,v2) 200.*(v1-v2)./(v1+v2);
v_avg = grpstats(tbl_trim.v,tbl_trim.ID,'mean');
v_diff = grpstats(tbl_trim.v,tbl_trim.ID,@(x) x(1)-x(end));
tt = grpstats(tbl_trim.time,tbl_trim.ID,'range');
gap = grpstats(tbl_trim.radar_range./tbl_trim.v,tbl_trim.ID,"mean");
v_set = grpstats(tbl_trim.set_velocity,tbl_trim.ID,'mean');
ego_mass = grpstats(tbl_trim.ego_m,tbl_trim.ID,'mean');
other_mass = grpstats(tbl_trim.other_m,tbl_trim.ID,'mean');
id = grpstats(tbl_trim.ID,tbl_trim.ID,'mean');
leadID = 1:length(v_avg);
for q = 1:max(tbl_trim.ID)
    subrow = tbl_trim(find(tbl_trim.ID==q,1),1:4);
    if subrow.truck=="L"
        continue
    else
    %matching leader
    leadID(q) = tbl_trim.ID(find(tbl_trim.truck=="L"& ...
        tbl_trim.set_velocity==subrow.set_velocity& ...
        tbl_trim.ego_m==subrow.other_m,1));
    end
end


all_stats=[id,v_set,ego_mass,other_mass,v_avg,tt,v_diff,gap];
lead_stats=all_stats(leadID,:);
%get rid of the lead runs in the all array
mask = ~all(all_stats-lead_stats==0,2);
all_stats=all_stats(mask,:);
lead_stats=lead_stats(mask,:);

validID = all(~isoutlier(all_stats(:,7)),2);
disp(sum(validID))

hold on;boxchart(pct_diff(all_stats(:,7),lead_stats(:,7)))
boxchart(pct_diff(all_stats(validID,7),lead_stats(validID,7)))
