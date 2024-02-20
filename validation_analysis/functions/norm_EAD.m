function EAD_out = norm_EAD(EAD,mass_eff,time_period_s)
    EAD_out = EAD./1000./mass_eff.*3600./time_period_s;

%     fprintf('%2.6f kJ/kghr\n',EAD_out)
end