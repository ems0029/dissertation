function [subtbl,v_veh] = body_axis_wind(subtbl,z0)
    v_gnd=convert2Cartesian(subtbl.v,subtbl.course);
    v_wind_adj = subtbl.wind_speed*log(2/z0)/log(10/z0);
    v_wind=convert2Cartesian(v_wind_adj,subtbl.wind_dir_abs*pi/180);
    
    v_veh.E = v_gnd.E+v_wind.E;
    v_veh.N = v_gnd.N+v_wind.N;
    
    v_veh.phi=atan2(v_veh.E,v_veh.N);
    v_veh.wind_yaw=subtbl.course-v_veh.phi;
    v_veh.wind_v = sqrt(v_veh.E.^2+v_veh.N.^2);
    v_veh.x = cos(v_veh.wind_yaw).*v_veh.wind_v ;
    v_veh.y = sin(v_veh.wind_yaw).*v_veh.wind_v;
    subtbl.wind_v = v_wind_adj;
    subtbl.wind_v_veh = v_veh.wind_v;
    subtbl.wind_yaw_veh = v_veh.wind_yaw;
    function v_out=convert2Cartesian(v,phi)
        v_out.E=v.*sin(phi);
        v_out.N=v.*cos(phi);
    end
end