function tbl= add_reference_id_ew(tbl)
%add_reference_id get the closest baseline in gps time
%   uses the mean gps time and finds the nearest neighbor
% get gps time means, requires the runID in East West!

[gs,gid,gs_range]=grpstats(tbl.gps_seconds,tbl.runID_ew,{'mean','gname','range'});

% create subtables to find the control/partner runs for each run
reftbl = sortrows(tbl(tbl.truck=="RF",:),'UTC_time');
leadtbl = sortrows(tbl(tbl.truck=="T13",:),'UTC_time');
followtbl = sortrows(tbl(tbl.truck=="T14",:),'UTC_time');
noreftbl = [leadtbl;followtbl];


% get mean ref times of the baselines
refIDs = unique(reftbl.runID_ew);
runIDs = unique(noreftbl.runID_ew);
ref_times = gs(refIDs);
run_times = gs(runIDs);

%find closest ref number in gps time
for q = 1:length(run_times)
    [d,mindx]=min(abs(run_times(q)-ref_times));
    %     refID(q) = refIDs(mindx);
    tbl.refID_ew(tbl.runID_ew==q)=refIDs(mindx);
end

% visualize each match start to finish for all subs

end