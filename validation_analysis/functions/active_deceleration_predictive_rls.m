function tbl = active_deceleration_predictive_rls(tbl,decel_delay,plot_on)
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
    warning('non-monotonic time!')
    try
        tbl =tbl(find(diff(tbl.time)<0,1,'last')+1:end,:);
        fprintf('Taking the last %u points after jump\n',height(tbl))
    catch ME
        disp(ME)

    end
end

tbl.decel_on=tbl.brake_by_driver |...
    tbl.brakes_on |...
    tbl.desired_ctrl_brake_rate<0 |...
    tbl.retarder_pct_torque~=0;

%for diagnostics
tbl.coasting_on = tbl.input_force<50&~tbl.decel_on;

%preallocate
tbl.a_decel_hat=nan(height(tbl),1);
tbl.a_decel_hat_rls=nan(height(tbl),1);
tbl.a_decel_hat_cadj=nan(height(tbl),1);
tbl.P_AD=nan(height(tbl),1);
tbl.E_AD=nan(height(tbl),1);

%% routine to project state
eventIs = 0;
if nargin ==1
    decel_delay =0; % delay in decel between start of deceleration and actual deceleration
end
widen_by=0; % how far to extend the window. consectutive events that occur within "widen_by" of one another will be treated as one event
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
        catch ME
            disp ME
            force = tbl.input_force(sIdx:eIdx)-tbl.coasting_force(sIdx:eIdx);
            warning('no drag reduction ratio in table')
        end
        mass = tbl.mass_eff(sIdx:eIdx);

        tbl.a_decel_hat(sIdx:eIdx)=force./mass-tbl.a_estimate(sIdx:eIdx);
        tbl.a_decel_hat_rls(sIdx:eIdx)=tbl.a_rls(sIdx:eIdx)-tbl.a_estimate(sIdx:eIdx);
        tbl.a_decel_hat_cadj(sIdx:eIdx)=tbl.a_cadj(sIdx:eIdx)-tbl.a_estimate(sIdx:eIdx);
        
        if plot_on
        v_proj = projectV(tbl.v(sIdx:eIdx), ...
            tbl.a_modeled_w_drr);
        v_proj_rls = projectV(tbl.v(sIdx:eIdx), ...
            tbl.a_modeled_w_drr);


        head(tbl)
        figure(1)
        clf;
        subplot(2,1,1);plot(tbl.v(sIdx:eIdx));hold on;
        plot(v_proj)
        plot(v_proj_rls)
        xlabel('time [s]')
        ylabel('velocity [m/s]')
        legend('actual','predicted')
        subplot(2,1,2);plot(v_proj-tbl.v(sIdx:eIdx));
        xlabel('time [s]')
        ylabel('difference [m/s]')
        figure(2)
        clf;
        tiledlayout(2,2)
        nexttile
        plot(tbl.desired_ctrl_brake_rate(sIdx:eIdx))
        title('brake amount')
        nexttile
        plot(tbl.brake_by_driver(sIdx:eIdx))
        title('brake by driver')
        nexttile
        plot(tbl.brakes_on(sIdx:eIdx))
        title('brake on')
        nexttile
        plot(tbl.retarder_pct_torque(sIdx:eIdx))
        title('retarder percent torque')
        pause
        end

    end
end
tbl.a_decel_hat  = fillmissing(tbl.a_decel_hat,'constant',0);
tbl.P_AD  = tbl.a_decel_hat.*tbl.v.*tbl.mass_eff;
tbl.E_AD  = cumtrapz(tbl.time,tbl.P_AD);
tbl.a_decel_hat_rls  = fillmissing(tbl.a_decel_hat_rls,'constant',0);
tbl.P_AD_rls  = tbl.a_decel_hat_rls.*tbl.v.*tbl.mass_eff;
tbl.E_AD_rls  = cumtrapz(tbl.time,tbl.P_AD_rls);
tbl.a_decel_hat_cadj  = fillmissing(tbl.a_decel_hat_cadj,'constant',0);
tbl.P_AD_cadj  = tbl.a_decel_hat_cadj.*tbl.v.*tbl.mass_eff;
tbl.E_AD_cadj  = cumtrapz(tbl.time,tbl.P_AD_cadj);
toc
end

