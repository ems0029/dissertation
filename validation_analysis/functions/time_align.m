function [x_int] = time_align(x_chars,data,t)
% x_chars is a character vector to a topic from data, eg
% 'j1939.vehicle_speed.wheelBasedSpeed'
try
    x_vals = eval(['data.',x_chars]);
    t_chars = ['data.',x_chars(1:max(find(x_chars=='.'))),'time'];
    t_vals = eval(t_chars);

    [~,ia,~]=unique(t_vals);

    if isa(x_vals,'integer') || isa(x_vals,'logical')
        x_int = interp1(t_vals(ia),double(x_vals(ia)),t,'nearest');
    else
        x_int = interp1(t_vals(ia),double(x_vals(ia)),t,'linear');
    end
catch ME
    disp(ME)
    x_int = nan(size(t));
end

end