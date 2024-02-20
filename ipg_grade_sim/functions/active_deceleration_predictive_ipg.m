function tbl = active_deceleration_predictive_ipg(tbl,decel_delay,plot_on)
%apppendDecel_experimental take an input table of a single ID and run the
%decel calculation algorithm

%instead of the error prone "before after" method, project the state in 1 second windows and
%get it at the end

% might want the runlength script that splits up a vector into pieces
% addpath('F:\other_scripts_2021\DOE_utils\RunLength_2017_04_08')
narginchk(1,3)

if ~exist('plot_on','var')
    plot_on = false;
elseif ~isa(plot_on,'logical')
    error('plot_on must be a logical variable')
end


tic
if any(diff(tbl.time)<0)
    error('non-monotonic time!')
end

tbl.decel_on=tbl.brake_pressure>0;

%for diagnostics
tbl.coasting_on = tbl.input_force<100&~tbl.decel_on;

%preallocate
tbl.a_decel_hat=nan(height(tbl),1);
tbl.P_AD=nan(height(tbl),1);
tbl.E_AD=nan(height(tbl),1);


%% routine to project state
eventIs = 0;
if nargin ==1
    decel_delay =0; % delay in decel between start of deceleration and actual deceleration
end
widen_by=20; % how far to extend the window. consectutive events that occur within "widen_by" of one another will be treated as one event
for q=2:height(tbl)
    % reassign widen_by to avoid window beyond end of vector
    widen_by = min(height(tbl)-q-1,widen_by); 
    if tbl.decel_on(q) %whatever condition to indicate braking is going
        if ~eventIs
            sIdx=q-1+decel_delay;%start index of the braking event
            eventIs=1;
        end
    elseif tbl.decel_on(q-1) && any(tbl.decel_on(q:q+widen_by)) % any within widen By are true
        %continue TODO do this before the routine
        % fprintf('consecutive braking found within window, lumping\n')
    elseif tbl.decel_on(q-1) %end condition, run routine
        eventIs = 0;
        eIdx=q+1+decel_delay+widen_by;
        % calculate residual
        try
            force = tbl.input_force(sIdx:eIdx)-tbl.coasting_force_w_drr(sIdx:eIdx);
        catch
            force = tbl.input_force(sIdx:eIdx)-tbl.coasting_force(sIdx:eIdx);
            warning('no drag reduction ratio in table')
        end
        mass = tbl.mass_eff(sIdx:eIdx);

        tbl.a_decel_hat(sIdx:eIdx)=force./mass-tbl.a_estimate(sIdx:eIdx);
        
        if plot_on
        v_proj = projectV(tbl.v(sIdx:eIdx), ...
            mass, ...
            force);


        head(tbl)
        figure(1)
        clf;
        subplot(2,1,1);plot(tbl.v(sIdx:eIdx));hold on;plot(v_proj)
        xlabel('time [s]')
        ylabel('velocity [m/s]')
        legend('actual','predicted')
        subplot(2,1,2);plot(v_proj-tbl.v(sIdx:eIdx));
        xlabel('time [s]')
        ylabel('difference [m/s]')
        figure(2)
        clf;
        plot(tbl.brake_pressure(sIdx:eIdx))
        title('brake pressure')
        end

    end
end
tbl.a_decel_hat  = fillmissing(tbl.a_decel_hat,'constant',0);
tbl.P_AD  = tbl.a_decel_hat.*tbl.v.*tbl.mass_eff;
tbl.E_AD  = cumtrapz(tbl.time,tbl.P_AD);
toc
end

