clearvars
load('..\lookups\tbl_doeTestTrack_2_14_2024.mat','tbl')

mask = tbl.truck~="A1";

plot(tbl.x(mask),tbl.grade_estimate(mask)-tbl.grade_estimate_lookup(mask),'.')

pd_grade = fitdist(tbl.grade_estimate(mask)-tbl.grade_estimate_lookup(mask),'tLocationScale');

%% velocity
for q = 1:max(tbl.ID)
    ve{q} = tbl.v(tbl.ID==q)-smoothdata(tbl.v(tbl.ID==q),'sgolay','SmoothingFactor',0.01);
end    
e = vertcat(ve{:});
e(~ismembertol(e,0,1e-12,'DataScale',1));
pd_v =fitdist(e,'tLocationScale');

