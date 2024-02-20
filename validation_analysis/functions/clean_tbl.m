function tbl = clean_tbl(tbl)
%clean_tbl General cleaup procedures to call on tbl, derived from cleanT and 
% the import experimental data scripts from EAD analysis.

% fill the missing data
tbl = fillmissing(tbl,'nearest');

% cleanup the gear numbers for interpolation errors
tbl.gear_number(tbl.gear_number<4)=NaN;
tbl.gear_number = fillmissing(tbl.gear_number,'nearest');
tbl.gear_number = round(tbl.gear_number);
% totally drop any rows where gear is zero
tbl=tbl(tbl.gear_number~=0,:);

% clean up grade lookup (cannot always)
if isvarname('tbl.grade_lookup')
    tbl.grade_lookup = fillmissing(tbl.grade_lookup,'linear');
end

% remove implausible velocity
tbl.v = filloutliers(tbl.v,'nearest','movmedian',100);


%cleanup brake_pedal_position
tbl.brake_pedal_position(ismembertol(tbl.brake_pedal_position,0,0.5,'DataScale',1))=0;

% change variable types
tbl = convertvars(tbl,{'gear_number'},'int8');
tbl = convertvars(tbl,{'brake_by_driver','brakes_on'},'logical');
tbl.v = tbl.v/3.6; %convert to m/s from km/h

end