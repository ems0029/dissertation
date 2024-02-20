function tbl = add_missing_rows(tbl)
%add missing sections of data in the master table 
%   first, for each subtable, find any discontinuous times. determine if
%   this time is during a high velocity moment or not, and if it occured on
%   EB or WB ground insert
%   assumes 1 hertz timestep

tblArr = cell(max(tbl.ID),1);

for q = 1:max(tbl.ID)
    subtbl = tbl(tbl.ID==q,:);
    % identify points that are disjunct
    dt = diff(subtbl.time);
    jumps = ~ismembertol(dt,0.1,1.1,'DataScale',1);
    % determine if the truck was moving before and after at a sufficient
    % speed (over20 m/s)
    jump_idxs = find(jumps);
    
    % mask where v is < 20 and neither EB or WB
    mask = all([subtbl.v([jumps; false])'>20;...
        subtbl.v([false; jumps])'>20;...
        subtbl.eastbound([jumps;false])'|subtbl.westbound([jumps;false])']);

    jump_idxs = jump_idxs(mask);
    
    % get number of samples missing is the difference minus one sample for
    % the start of the jump (for example, 1 second and 2 seconds have 9
    % samples between)
    ns = round(dt(jump_idxs)*10)-1;
    
    % insert missing rows
    if ~isempty(jump_idxs)
        
        for qq = length(jump_idxs):-1:1 % in reverse order to avoid incorrect indexing
            % generate a missing table row
            dummyRow=subtbl(jump_idxs(qq),:);
            dummyRow{:,{'alt','lat','lon','brakes_on','brake_by_driver',...
                'engine_pct_torque','engine_rpm','fan_state','fuel_rate','gear_number',...
                'gps_seconds','grade_estimate','north','range_estimate',...
                'retarder_pct_torque','v','brake_pedal_position',...
                'desired_ctrl_brake_rate','drtk_v2v_dist','east','up'}}=nan;
            
            % linspace the time between
            dummyRows = repmat(dummyRow,[ns(qq),1]);
            dummyRows.time = linspace(subtbl.time(jump_idxs(qq)) + 0.1,...
                subtbl.time(jump_idxs(qq)+1) - 0.1,...
                ns(qq))';

            % add the missing rows
            subtbl = [subtbl(1:jump_idxs(qq),:);...
                dummyRows;...
                subtbl(jump_idxs(qq)+1:end,:)]; 

            
        end
        fprintf('Added %.1f seconds of missing to ID %i\n',sum(ns)/10,q)
    end
    tblArr{q} = subtbl;

end

%concat the subtables with missing rows
tbl = vertcat(tblArr{:});


end