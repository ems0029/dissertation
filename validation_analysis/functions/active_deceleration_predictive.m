function tbl = active_deceleration_predictive(tbl,del_B,plot_on)
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
if ~exist('del_B','var')
    del_B = 0;
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
tbl.a_decel_hat=nan(height(tbl),1);tbl.a_decel_hat_rls=tbl.a_decel_hat;tbl.a_decel_hat_cadj=tbl.a_decel_hat;
tbl.P_AD=nan(height(tbl),1);tbl.P_AD_rls = tbl.P_AD;tbl.P_AD_cadj = tbl.P_AD;
tbl.E_AD=nan(height(tbl),1);tbl.E_AD_rls = tbl.E_AD;tbl.E_AD_cadj = tbl.E_AD;


%% routine to project state
for q=1:height(tbl)
    if any(tbl.decel_on(max(1,q-del_B):min(q+1,height(tbl)))) %end condition, run routine
        tbl.a_decel_hat(q)=tbl.a_residual(q);
        tbl.a_decel_hat_rls(q)=tbl.a_residual_rls(q);
        tbl.a_decel_hat_cadj(q)=tbl.a_residual_cadj(q);

        
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

