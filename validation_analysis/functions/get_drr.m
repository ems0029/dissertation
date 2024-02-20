function [avg_drr,gid] = get_drr(tbl)

[avg_drr,gid]=grpstats(tbl.drag_reduction_ratio,tbl.ID,{'mean','gname'});

end