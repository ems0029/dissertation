function tbl = model_acceleration_with_aero(tbl,path_to_params)
%appendExpAccel_experimental This function will append the model accel
%based on the appropriate parameter file for the truck in question.
load(path_to_params,'truck')

% select which grade to use
try
    grade = tbl.grade_estimate_lookup;
    disp('using grade estimate lookup')
catch
    grade = tbl.grade_estimate;
    disp('using raw grade estimate')
end
% effective_mass = tractor_mass + trailer_mass + rotating_mass
effective_mass = @(gear) truck.tractor_mass + ...
    truck.trailer_mass + ...
    ((truck.i_t+truck.i_ds)*truck.n_diff.^2+ ...
    ((truck.i_e)*truck.n_trans(gear).^2*truck.n_diff^2)+...
    (truck.i_diff+truck.i_wheel))/(truck.r_eff^2);

% calculate engine power [W]
tbl.engine_power = truck.pk_tq*1.3558179483...
    *tbl.engine_pct_torque/100 ...
    .*(tbl.engine_rpm*pi/30);
% zero negative torque values
tbl.engine_power(tbl.engine_power<0,:)=0;

% calculate input force
tbl.input_force=(tbl.engine_power) ...
    ./tbl.v;
% clean any nans in input
tbl.input_force(tbl.input_force>17000)=NaN;

tbl.mass_eff = effective_mass(tbl.gear_number)';


if any(strcmp('drag_reduction_ratio',tbl.Properties.VariableNames))
    disp('including DRR in modeled acceleration')
    tbl.coasting_force_w_drr=(truck.tractor_mass+truck.trailer_mass)*...
        (9.81*(sind(grade)+truck.f_rr_c))... % ROLLING RESISTANCE IS A FUNCTION OF COSINE BUT THIS INTRODUCES EXCESSIVE ERROR
        +0.5*tbl.v.^2*1.225*truck.c_d*truck.front_area.*tbl.drag_reduction_ratio;

    tbl.a_modeled_w_drr=(tbl.input_force ...
        -tbl.coasting_force_w_drr)...
        ./tbl.mass_eff;

end
tbl.coasting_force=(truck.tractor_mass+truck.trailer_mass)*...
    (9.81*(sind(grade)+truck.f_rr_c))... % ROLLING RESISTANCE IS A FUNCTION OF COSINE BUT THIS INTRODUCES EXCESSIVE ERROR
    +0.5*tbl.v.^2*1.225*truck.c_d*truck.front_area;

% calculated model acceleration (round the gear)
tbl.a_modeled=(tbl.input_force ...
    -tbl.coasting_force)...
    ./tbl.mass_eff;

end