function tbl = grade_google_lookup(tbl)
table = readtable('..\lookups\google_I85_lookup.csv');

f = griddedInterpolant(table.x,atan(gradient...
    (smoothdata(table.alt_google,'movmean',100)).*180/pi));
f_alt = griddedInterpolant(table.x,table.alt_google);

tbl.alt_google = f_alt(tbl.x);
tbl.grade_google = f(tbl.x);