function tbl = get_east_west_prelim(tbl,campaign)
%get_east_west_prelim add a column to tbl that includes whether the run was
% eastbound or westbound
%   Use the gradient of the distance to the turnaround to determine if the
%   truck is eastbound or westbound.
addpath ..\wgs_conversions\
switch campaign
    case "JDSMC"
        referenceLocation = [32.626597, -85.280392 , 0];
    case "DOE_onroad"
        referenceLocation = [32.6436, -85.3526, 0];
        eastCourse =[0.5909,1.4542];
        westCourse =[-2.6960,-1.5692]; 
    otherwise
        error("not implemented")
end

enu=lla2enu([tbl.lat,tbl.lon,tbl.alt],referenceLocation,"ellipsoid");
tbl.east = enu(:,1); %m
tbl.north = enu(:,2); %m
tbl.up = enu(:,3); %m

%magnitude
% gradient (could also do this for each ID, but we'll try it)
for q = 1:max(tbl.ID)
    subtbl = tbl(tbl.ID==q,:);
    if isempty(subtbl)
        continue
    end
    enu=lla2enu([subtbl.lat,subtbl.lon,subtbl.alt],referenceLocation,"ellipsoid");
    mag = sqrt(enu(:,1).^2+enu(:,2).^2);
    mag_gradient = smoothdata(gradient(mag),'movmedian',100);
%     scatter(enu(:,1),enu(:,2),'Cdata',double(mag_gradient>0))

    subtbl.eastbound = mag_gradient>1.5;
    subtbl.westbound = mag_gradient<-1.5;

    tblArr{q} = subtbl;
end
tbl = vertcat(tblArr{:});
