function subtbl_array = the_wringer(subtbl_array)
%the_wringer just adds RLS and Constant offset, followed by a trimming
%step
P_AD_rls = cell(length(subtbl_array),1);
P_AD_cadj = cell(length(subtbl_array),1);
   for q = 1:length(subtbl_array)
       subtbl=subtbl_array{q};
       P_AD_rls{q} = subtbl.mass_eff.*subtbl.v.*(RLS_again(subtbl,0.995,5)-subtbl.a_estimate);
       P_AD_cadj{q} = subtbl.mass_eff.*subtbl.v.*(constant_adjust(subtbl)-subtbl.a_estimate);
       P_AD_rls{q}(~subtbl.decel_on)=0;
       P_AD_cadj{q}(~subtbl.decel_on)=0;
       %trim
       subtbl_array{q} = subtbl_array{q}(subtbl.x>=1000&subtbl.x<=4702,:);
       %error report
       fprintf('******\nRLS:  %.3f vs\n Cadj: %.3f \n******\n', ...
           100*(trapz(P_AD_rls{q})-trapz(subtbl.PwrL_Brake))/trapz(subtbl.PwrL_Brake), ...
           100*(trapz(P_AD_cadj{q})-trapz(subtbl.PwrL_Brake))/trapz(subtbl.PwrL_Brake))
   end
end    
       