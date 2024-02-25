function tbl = course_spread_to_leader(tbl)
%%take in the table (which must have x and course in it) and spread the
%%course to every truck

df = sortrows(tbl{:,{'x','course'}},1);
[~,ia,~]=unique(df(:,1));
df = df(ia,:);
df_rm = rmmissing(df);
f = griddedInterpolant(df_rm(:,1),smoothdata(df_rm(:,2),'movmedian',20),'linear','nearest');

tbl.course = f(tbl.x);

end