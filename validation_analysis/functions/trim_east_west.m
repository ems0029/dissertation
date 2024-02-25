function tbl = trim_east_west(tbl)

% Use these bounds

%east side geobounds
% geoBounds(1).startX =  2121.5;
% geoBounds(1).startY =  -1796.4;
% geoBounds(1).endX = 9360.5;
% geoBounds(1).endY = -4571.55;
geoBounds(1).startX =  1416.3;
geoBounds(1).startY =  -1221.99;
geoBounds(1).endX = 8140.47;
geoBounds(1).endY = -3940.34;
geoBounds(1).errorBound = 10.0;

%west side bounds
% geoBounds(2).startX =  8888.5;
% geoBounds(2).startY =  -4308.2;
geoBounds(2).startX =  8148;
geoBounds(2).startY =  -3896.43;
geoBounds(2).endX = 1418.5;
geoBounds(2).endY = -1170.1;
geoBounds(2).errorBound = 10.0;

winlength = 10*60*10; % 10 minute window, 10 hz

% how do we find the latlon EB/WB where the runs are valid?

tblArr = cell(max(tbl.ID),1);

for q = 1:max(tbl.ID)
    subtbl = tbl(tbl.ID==q,:);

    subtbl.eastbound = geobounded(subtbl,...
        geoBounds(1));
    subtbl.westbound = geobounded(subtbl,...
        geoBounds(2));
    tiledlayout(2,1)
    nexttile
    plot(subtbl.eastbound)
    hold on
    plot(subtbl.westbound)
    nexttile
% 
%     plot(subtbl.east,subtbl.north)
%     yline(geoBounds(1).startY)
%     xline(geoBounds(1).startX)
%     hold on
%     viscircles([geoBounds(1).startX,geoBounds(1).startY],geoBounds(1).errorBound)
%     yline(geoBounds(1).endY)
%     xline(geoBounds(1).endX)
%     viscircles([geoBounds(2).endX,geoBounds(2).endY],geoBounds(2).errorBound)
%     viscircles([geoBounds(2).startX,geoBounds(2).startY],geoBounds(2).errorBound)
%     yline(geoBounds(2).startY)
%     xline(geoBounds(2).startX)
%     yline(geoBounds(2).endY)
%     xline(geoBounds(2).endX)
%     viscircles([geoBounds(2).endX,geoBounds(2).endY],geoBounds(2).errorBound)
   

    tblArr{q} = subtbl;

end

tbl = vertcat(tblArr{:});

    function bounded = geobounded(tbl,geobounds)
        % returns a boolean vector that starts TRUE at the earliest
        % position in the errorbound and ends FALSE at the latest position
        % out of the errorbound
        start_diff = [tbl.east-geobounds.startX,...
            tbl.north-geobounds.startY];
        end_diff =[tbl.east-geobounds.endX,...
            tbl.north-geobounds.endY];
        d_i = sqrt(sum(start_diff.^2,2));
        d_f = sqrt(sum(end_diff.^2,2));

        mindx = find(d_i<geobounds.errorBound,1,'first');
        maxdx = find(d_f<geobounds.errorBound,1,'last');
        
        if isempty(mindx)&&isempty(maxdx)
            disp('no data in bound')
        elseif isempty(mindx)
            mindx = 1;
        elseif isempty(maxdx)
            maxdx = height(tbl);
        end
        
        bounded = false(height(tbl),1);
        bounded(mindx:maxdx)=true;

    end

end