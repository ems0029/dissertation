function tbl = JDSMC_imputation_fillgaps(tbl)

% filling routine

tbl.imputed = ismissing(tbl.v);

for q = 1:max(tbl.ID)
    
    subtbl = tbl(tbl.ID==q,:);
    
    %split subtable into numeric and non-numeric subtables
    subtbl_numeric = subtbl(:,intersect(subtbl.Properties.VariableNames,...
        {'v','lat','lon','alt','east','north','up','gps_seconds', ...
        'engine_pct_torque',	'engine_rpm', ...
        'brake_pedal_position',	'desired_ctrl_brake_rate',	'retarder_pct_torque', ...
        'fuel_rate',	'grade_estimate',	'range_estimate'},'stable'));
    subtbl_nonnumeric = subtbl(:,setdiff(subtbl.Properties.VariableNames,subtbl_numeric.Properties.VariableNames,'stable'));
    
    % do the imputation on the numeric portion
    % get the array from the numeric table
    subarr = table2array(subtbl_numeric);
    
    subarr = fillgaps(subarr,100);

    subtbl_numeric = array2table(subarr,"VariableNames",subtbl_numeric.Properties.VariableNames);
    
    % do the imputation of the non-numeric table
    
    subtbl_nonnumeric = fillmissing(subtbl_nonnumeric,"nearest");

    % recombine the subtables
    subtbl = [subtbl_nonnumeric,subtbl_numeric];
    %reorder the subtables as they were
    %TODO

    % save subtable into table cell array for recombination post-loop
    tblArr{q} = subtbl;

end

tbl = vertcat(tblArr{:});

end