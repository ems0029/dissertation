function [trip_time,gid] = get_trip_time(tbl)

[trip_time,gid] = grpstats(tbl.time,tbl.ID,{'range','gname'});

end
