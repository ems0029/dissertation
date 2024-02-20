function tbl = add_follower_gap(tbl,campaign)
% based on getLeadGap.m
%   get gap for the leading trucks by finding the matching run from a
%   follower and filling with mean spacing estimate
%   For baseline runs, set the gap to 1000

switch lower(campaign)
    case "jdsmc"
        bsln_str ={'NA','1T'};
        tbl.leading = tbl.truck=="T13"|tbl.numTrucks=="1T"|tbl.truck=="RF";
        spacing = 35;
        runID = findgroups(tbl.numTrucks,tbl.lead_ctrl,tbl.follow_ctrl,tbl.runIter);
    case "doe_onroad"
        bsln_str ="NA";
        tbl.leading = tbl.truck=="A1";
        runID = findgroups(tbl.westbound,tbl.spacing,tbl.runIter);
    case "doe_testtrack"
        bsln_str ={'BASELINE','NMPC_CRUISE'};
        tbl.leading = tbl.truck=="A1"|(tbl.truck =="T13" & tbl.numTrucks == "2T");
        runID = findgroups(tbl.numTrucks,tbl.year,tbl.spacing,tbl.runIter);
    case "canada"
        bsln_str ="RF";
        tbl.leading = tbl.truck=="A1";
        runID = findgroups(tbl.numTrucks,tbl.otherId,tbl.spacing,tbl.runIter);
    otherwise
        error("not implemented")
end


%% parallelization is not worth it here
tblArr = cell(max(runID),1);
% for q=1:max(tbl.runID)
%     tblArr{q} = tbl(runID==q,:);
% end

fcn = @applyFollowSpacing2Leader;

for q=1:max(runID)
    subtbl=tbl(runID==q,:);

    % check if the run is a baseline, in which case, apply a headway of 500
    % to those
    if any(strcmpi(string(subtbl.numTrucks(end)),bsln_str))
        subtbl.range_estimate(:)=500;
        tblArr{q}=subtbl;
        continue
    end

    try
        spacing = str2double(erase(string(subtbl.spacing(1)),"opt"))/3.28;
    catch
        warning("35m spacing assumed")
        spacing = 35;
    end

    if campaign=="DOE_testtrack"
        T14_idx=subtbl.truck=="T14";
        A1_idx=subtbl.truck=="A1";
        subtbl = fcn(subtbl,A1_idx,T14_idx,spacing);
        if subtbl.numTrucks(1)=="2T"
            T13_idx=subtbl.truck=="T13";
            A2_idx=subtbl.truck=="A2";
            subtbl = fcn(subtbl,T13_idx,A2_idx,spacing);
        end
    else
        subtbl = fcn(subtbl,subtbl.leading,~subtbl.leading,spacing);
    end
    % find matches within table match

    tblArr{q}=subtbl;
end

tbl=vertcat(tblArr{:});
tbl = convertvars(tbl,'leading','double');
    function tbl = applyFollowSpacing2Leader(tbl,lead_idx,follow_idx,spacingBackup)
        % condition: there are too few follow data (chosen arbitrarily)
        if sum(follow_idx)<100
            tbl.range_estimate(lead_idx)=spacingBackup;
            return
        end

        try
            [x,ia]=unique(tbl.gps_seconds(follow_idx));
            v=tbl.range_estimate(follow_idx);
            tbl.range_estimate(lead_idx)=interp1(x,v(ia),tbl.gps_seconds(lead_idx),'nearest','extrap');
        catch ME
            disp(ME)
            tbl.range_estimate(lead_idx)=nanmean(tbl.range_estimate(follow_idx));
        end
    end
end