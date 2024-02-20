function [truck,numTrucks,spacing,runIter] = file_id_doeOnRoad(filenameStr)

% Example inputs (uncomment for testing)
% filenameStr = 'A1_F1_RF_asdfasdf.mat';
% filenameStr = 'A2_F20_platoon_150.mat';

filenameStr =erase(filenameStr,".mat");

splitName   = upper(string(strsplit(filenameStr,"_")));


%% Truck
truck = splitName(1);
runIter = splitName(2);
%% controller and number of trucks
if splitName(3) == "RF"
    numTrucks = "NA";
    spacing = "NA";
else
    numTrucks = "2T";
    spacing= splitName(4);
end


end

