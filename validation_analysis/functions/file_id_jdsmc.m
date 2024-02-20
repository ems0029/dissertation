function [truck,numTrucks,lead_ctrl,follow_ctrl,runIter] = file_id_canada(filenameStr)

% Example inputs (uncomment for testing)
% filenameStr = 'A1_F1_RF_asdfasdf.mat';
% filenameStr = 'RF_1.mat';

filenameStr =erase(filenameStr,".mat");

splitName   = upper(string(strsplit(filenameStr,"_")));


%% Truck
truck = splitName(1);

%% controller and number of trucks
if truck == "RF"
    lead_ctrl = "NA";
    follow_ctrl = "NA";
    numTrucks = "NA";
    runIter = splitName(end);
else
    numTrucks = splitName(2);
    runIter = splitName(end-1);
    if numTrucks == "2T"
        lead_ctrl = splitName(3);
        follow_ctrl = splitName(4);
    else
        lead_ctrl = splitName(3);
        follow_ctrl = "NA";
    end
end


end

