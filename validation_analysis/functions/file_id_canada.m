function [caseId,spacing,runIter,otherId] = file_id_canada(filenameStr)

% Example inputs (uncomment for testing)
% filenameStr = 'AL-S75-3_2019-06-17-12-57-23.mat';
% filenameStr = 'RF-9_2019-06-27-18-22-46.mat';

filenameStr =erase(filenameStr,".mat");

splitName   = upper(string(strsplit(filenameStr,"_")));
splitName   = strsplit(splitName(1),"-");

%% Truck
caseId = splitName(1);
runIter = splitName(end);
%% controller and number of trucks
if caseId == "RF"
    spacing = "NA";
else
    spacing = erase(splitName(end-1),"S");
end

if length(splitName)>3
    otherId = strjoin(splitName(2:end-2));    
else
    otherId = "NA";
end

end

