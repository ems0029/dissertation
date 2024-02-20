function tbl = grade_spread_to_leader(tbl)
%%take in the table (which must have x and grade in it) and spread the
%%grade estimate to every truck

df = sortrows(tbl{:,{'x','grade_estimate'}},1);
[~,ia,~]=unique(df(:,1));
df = df(ia,:);
df_rm = rmmissing(df);
f = griddedInterpolant(df_rm(:,1),smoothdata(df_rm(:,2),'movmedian',20));

tbl.grade_estimate_lookup = f(tbl.x)

end


