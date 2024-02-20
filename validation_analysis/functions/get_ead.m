function [avg_PAD,gid] = get_ead(tbl)
%get_ead this function returns the energy lost to active deceleration by
%using the average power of active deceleration, instead of the
%integration. The final answer must be in units of kJ/kghr, which depends
%on the mass of the vehicle as a known quantity.

[avg_PAD,gid]=grpstats(tbl.P_AD./tbl.mass_eff.*3600./1000,tbl.ID,{'mean','gname'});

end

