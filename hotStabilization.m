% Purpose is to see if lap-to-lap changes trended downward
clearvars -except Analysis*
if ~exist('AnalysisReadyNCAT2020','var')
load("..\matfileSummaries\lapSelected\allAnalysisReady.mat")
end

%initialize counter
i=1;
for qq = 3
    switch qq
        case 1
            sel = AnalysisReadyNCAT2019
        case 2
            sel = AnalysisReadyACM2019
        case 3
            sel = AnalysisReadyNCAT2020
        case 4
            sel = AnalysisReadyACM2021
    end
    %cleanup some types
    sel = sel([sel.truckNo]~='CutIn'& [sel.truckNo]~='Merge');

    for q = 1:length(sel)
        x{i}=1:length(sel(q).lapFuel);
        y{i}=sel(q).lapFuel/mean(sel(q).lapFuel);

        i = i+1;
    end
end
x = cat(2,x{:});
y = cat(2,y{:});
% delete last NCAT laps
y = y(x<25);
x = x(x<25);
lm = fitlm(x,y)
lm.plot
