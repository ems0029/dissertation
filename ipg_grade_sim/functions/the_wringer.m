function [P_AD_inf, P_aero_inf, NPC_inf, P_AD_true, P_aero_true, NPC_true] = the_wringer(subtbl_array,nn_C)
%the_wringer just adds RLS and Constant offset, followed by a trimming
%step
if ~exist('nn_C','var')
    load('..\lookups\nn_brakeless_lookup.mat','nn_C')
end
fNPC_inf = @(st,P_AD,P_aero) mean(st.engine_power)/...
    (mean(st.engine_power) + ((1-mean(st.drag_reduction_ratio))*P_aero-P_AD));
P_AD_inf = cell(1,length(subtbl_array));
P_aero_inf = cell(1,length(subtbl_array));
NPC_inf = cell(1,length(subtbl_array));

for q = 1:length(subtbl_array)
    subtbl=subtbl_array{q};
    subtbl_array{q}.P_AD_rls = subtbl.mass_eff.*subtbl.v.*(RLS_again(subtbl,0.995,5)-subtbl.a_estimate);
    subtbl_array{q}.P_AD_cadj = subtbl.mass_eff.*subtbl.v.*(constant_adjust(subtbl)-subtbl.a_estimate);
    subtbl_array{q}.P_AD_rls(~subtbl.decel_on)=0;
    subtbl_array{q}.P_AD_cadj(~subtbl.decel_on)=0;

    %trim
    subtbl_array{q} = subtbl_array{q}(subtbl.x>=1000&subtbl.x<=4702,:);
    %error report
%     fprintf('******\nRLS:  %.3f vs\n Cadj: %.3f \n******\n', ...
%         100*(trapz(subtbl_array{q}.P_AD_rls)-trapz(subtbl_array{q}.PwrL_Brake))/trapz(subtbl_array{q}.PwrL_Brake), ...
%         100*(trapz(subtbl_array{q}.P_AD_cadj)-trapz(subtbl_array{q}.PwrL_Brake))/trapz(subtbl_array{q}.PwrL_Brake))
    P_AD_inf{q} = [mean(subtbl_array{q}.P_AD_rls), mean(subtbl_array{q}.P_AD_cadj)];
    P_aero_inf{q} = mean(0.5*1.205*0.845*(10+subtbl_array{q}.Properties.CustomProperties.offsets.front_area)*subtbl.v.^3);
    NPC_inf{q} = [ fNPC_inf(subtbl_array{q},P_AD_inf{q}(1),P_aero_inf{q}), ...
                    fNPC_inf(subtbl_array{q},P_AD_inf{q}(2),P_aero_inf{q}) ];
end
P_AD_true = mean(subtbl_array{end}.PwrL_Brake);
P_aero_true = mean(subtbl_array{end}.PwrL_Aero./subtbl_array{end}.drag_reduction_ratio);
NPC_true = mean(subtbl_array{end}.engine_power)/nn_C.predict([mean(subtbl_array{end}.v),subtbl_array{end}.ego_m(1)+15000]);
end
