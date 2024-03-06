function subtbl = estimate_course(subtbl)
%estimate_course estimate the course of a subtable from latitude and
%longitude
%   requires x and lat,lon. Uses the lla2enu to first place in east north u
%  p coordinates


x = subtbl.x;
% get the gradient
lla = [subtbl{:,{'lat','lon'}},zeros(height(subtbl),1)];
ENU = lla2enu(lla,nanmedian(lla),"ellipsoid");
[~,dENU]=gradient(ENU);
az = atan2d(dENU(:,1),dENU(:,2));

df = sortrows([x,az],1);
[~,ia,~]=unique(df(:,1));
df = df(ia,:);
df_rm = rmmissing(df);
f = griddedInterpolant(df_rm(:,1),smoothdata(df_rm(:,2),'movmedian',200));

subtbl.course = f(subtbl.x)*pi/180;

end