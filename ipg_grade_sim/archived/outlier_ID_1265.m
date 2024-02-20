
%% outlier investigation Obs 703
subtbl = tbl(tbl.ID==stats( ...
    id(ismembertol(stats.mean_NPC,1.33492,0.0001,'DataScale',1)),:).ID,:);

t1 = subtbl(1:2441,:);
t2 = setdiff(subtbl,t1)