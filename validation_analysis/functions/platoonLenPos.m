function [plen,ppos] =platoonLenPos(tbl)

switch upper(string(tbl.numTrucks(1)))
    case {'2T','AL','OT'}
        plen = 2;
    case {'4T','MERGE','CUTIN','CUTINTEST'}
        plen = 4;
    case {'BASELINE','NMPC_CRUISE','NA','RF','1T'}
        plen = 1;
    otherwise
        plen = nan;
        error('fix this')
end
switch upper(string(tbl.truck(1)))
    case {'A1','RF'}
        ppos = 1;
    case {'A2'}
        if plen== 2
            ppos = 2;
        elseif plen == 4
            ppos = 4;
        else
            ppos = 1;
        end
    case {'T13'}
        if plen == 2
            ppos = 1;
        elseif plen==4
            ppos = 3;
        else
            ppos = 1;
        end
    case {'T14'}
        if any(plen == [2,4])
            ppos = 2;
        else
            ppos =1;
        end
    otherwise
        error('fix this')
end

end
