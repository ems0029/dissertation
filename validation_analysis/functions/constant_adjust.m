function a_brakeless = constant_adjust(subtbl,win)
% take in a subtable with acceleration estimate and 
a_mdl = subtbl.a_modeled_w_drr;
a_est = subtbl.a_estimate;
skip  = ismissing(a_est)|ismissing(a_mdl);
%initialize

if ~exist('win','var')
    win=100; %100 corresponds to a 10 second time constant
end

a_brakeless = zeros(size(a_mdl));
del_B=20;
ebar = 0;
ri = 0;
i=1;

for q = 1:height(subtbl)
    if skip(q)
        continue
    end
    if all(~(subtbl.decel_on(max(1,q-del_B):q)))
        ebar= (ebar)*(i-1)/i+...
            (a_est(q)-a_mdl(q))/i;
        if i<win
        i=i+1;
        end
    end
    a_brakeless(q) = a_mdl(q)+ebar;
end
end