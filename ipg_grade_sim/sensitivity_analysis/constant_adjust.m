function a_brakeless = constant_adjust(subtbl)
% take in a subtable with acceleration estimate and 
a_mdl = subtbl.a_modeled_w_drr;
a_est = subtbl.a_estimate;
%initialize

a_brakeless = zeros(size(a_mdl));
del_B=20;
win=100;
ebar = 0;
ri = 0;
i=1;

for q = 1:height(subtbl)
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