function [truck,noTrucks,spacing,runIter,otherInfo,dateOfRun,timeOfRun] = file_id_doe_track(filenameStr,diagMessageBool)

% Example inputs (uncomment for testing)
% filenameStr = "A1_4T_50_1_1note_2019-09-23-11-05-58.mat";
% filenameStr = "T13_4T_50CutInTest_1_2019-09-23-14-54-35";
% filenameStr = "A2_baseline_6_2019-09-27-10-06-38.mat";

narginchk( 1, 2 )
if exist( 'diagMessageBool', 'var' )
   % Do some validation - optional
else
   diagMessageBool = 0;
end

filenameStr =erase(filenameStr,".mat");

splitName   = upper(string(strsplit(filenameStr,"_")));

if length(splitName)<4
    error("Too few identifiers. Check filename string nomenclature.")
end

%% Truck
truck = splitName(1);
%% Number of Trucks
noTrucks = splitName(2);
%% Spacing, Iteration, Conditions
switch string(noTrucks)
    case {"2T","4T"}
        spacing = splitName(3);
        runIter = splitName(4);
        otherInfo = strjoin(splitName(5:end));
        dateOfRun = otherInfo(:,1:end-13,end);
        timeOfRun = otherInfo(:,12:end-4,end);
    
    case {"BASELINE"}
        spacing = "N/A";
        runIter = splitName(3);
        otherInfo = strjoin(splitName(4:end));
        dateOfRun = otherInfo(:,1:end-13,end);
        timeOfRun = otherInfo(:,12:end-4,end);
    case {"CUTIN","MERGE"}
        spacing = "100";
        runIter = splitName(3);
        otherInfo = strjoin(splitName(4:end));
        dateOfRun = otherInfo(:,1:end-13,end);
        timeOfRun = otherInfo(:,12:end-4,end);
    otherwise
        error("Incorrect file nomenclature")
end
if diagMessageBool
fprintf('\nTruck: %s\n# of Trucks: %s\nSpacing: %s''\nRun Iteration: %s\nOther Info: %s\n',...
    truck,noTrucks,spacing,runIter,otherInfo)
end


