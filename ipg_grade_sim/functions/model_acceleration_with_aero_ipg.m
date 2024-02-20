function tbl = model_acceleration_with_aero_ipg(tbl,param_offsets)
if nargin == 1
    param_offsets=struct('front_area',0,'trailer_mass',0,'f_rr_c',0);
end
addpath('F:\dissertation\ipg_grade_sim\lookups\truck_params')
run('ipg_params_no_trailer.m')

truck.front_area=truck.front_area+param_offsets.front_area;
truck.f_rr_c=truck.f_rr_c+param_offsets.f_rr_c;
truck.trailer_mass=truck.trailer_mass+param_offsets.trailer_mass+tbl.ego_m(1);

% effective_mass = tractor_mass + trailer_mass + rotating_mass
effective_mass = @(gear) truck.tractor_mass + truck.trailer_mass + ...
    ((truck.i_t+truck.i_ds)*truck.n_diff.^2+ ...
    ((truck.i_e)*truck.n_trans(gear).^2*truck.n_diff^2)+...
    (truck.i_diff+truck.i_wheel))/(truck.r_eff^2);

% calculate input force
tbl.input_force=(tbl.engine_power) ...
    ./tbl.v;

%coasting force with and without DRR accounted for
tbl.coasting_force=(truck.tractor_mass+truck.trailer_mass)*...
    (9.81*(sin(tbl.grade)+truck.f_rr_c))... % ROLLING RESISTANCE IS A FUNCTION OF COSINE BUT THIS INTRODUCES EXCESSIVE ERROR
    +0.5*tbl.v.^2*1.205*truck.c_d*truck.front_area;

% give gear 0 zero moi
tbl.gear_number(tbl.gear_number==0)=11;
% effective mass
tbl.mass_eff = effective_mass(tbl.gear_number)';

%
tbl.a_modeled=(tbl.input_force ...
    -tbl.coasting_force)...
    ./tbl.mass_eff;
try
    tbl.coasting_force_w_drr=(truck.tractor_mass+truck.trailer_mass)*...
        (9.81*(sin(tbl.grade)+truck.f_rr_c))... % ROLLING RESISTANCE IS A FUNCTION OF COSINE BUT THIS INTRODUCES EXCESSIVE ERROR
        +0.5*tbl.v.^2*1.205*truck.c_d*truck.front_area.*tbl.drag_reduction_ratio;

    tbl.a_modeled_w_drr=(tbl.input_force ...
        -tbl.coasting_force_w_drr)...
        ./tbl.mass_eff;
catch ME
    disp(ME)
end

end