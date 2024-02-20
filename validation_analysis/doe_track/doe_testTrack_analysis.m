load('..\lookups\tbl_doeTestTrack_2_14_2024.mat','tbl')

truck_sel = ["A1","A2","T13","T14"];
tblArr =cell(4,1);
for q=1:4
    subtbl = tbl(tbl.truck==truck_sel(q),:);
    
    switch truck_sel(q)
        case "A1"
            param_path = "A1_doe.mat";
        case "A2"
            param_path = "A2_doe.mat";
        case "T13"
            param_path = "T13_JDSMC.mat";
        case "T14"
            param_path = "T14_JDSMC.mat";
        otherwise
            error("truck not found")
    end
    % TODO add wind velocity if possible
    load(param_path,'truck')
    subtbl.P_aero = 0.5*truck.c_d*truck.front_area*1.225*(subtbl.v).^3;
    subtbl.P_rr = truck.f_rr_c*9.81*(truck.tractor_mass+truck.trailer_mass).*subtbl.v;
    subtbl.drag_frac = subtbl.P_aero./(subtbl.P_aero+subtbl.P_rr);
    subtbl.drag_frac_w_fan = subtbl.P_aero./(subtbl.P_aero+subtbl.P_rr+subtbl.fan_power_est*1000);
    tblArr{q} = subtbl;
end

tbl = vertcat(tblArr{:});

nfc_tbl = grpstats(tbl,{'year','truck','numTrucks','spacing','ID'},"mean",'DataVars',{'fuel_rate','engine_power','P_AD_cadj','P_AD','P_AD_rls','P_aero','drag_reduction_ratio','drag_reduction_ratio_husseinpwr','drag_reduction_ratio_husseinrp','v','fan_power_est'})
nfc_tbl.trip_time = grpstats(tbl,{'year','truck','numTrucks','spacing','ID'},"range",'DataVars',{'time'}).range_time


