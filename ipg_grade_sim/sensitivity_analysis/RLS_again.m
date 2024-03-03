function a_rls = RLS_again(subtbl,lambda,p)
% take in a subtable with acceleration estimate and 
a_mdl = fillmissing(subtbl.a_modeled_w_drr,'nearest');
a_est = fillmissing(subtbl.a_estimate,'nearest');

if ~exist('p','var')
    p=1;
end
%initialize
x = [1;zeros(p,1)]; %p+1 x 1
w = zeros(p+1,1); %p+1 x 1
a_rls = zeros(size(a_mdl));
del = 1e10;
del_B = 20;
P = eye(p+1)*del; %pxp

for q = 1:height(subtbl)
    if p > 1
        x(3:p+1) = x(2:p); % shift out old measurement
    end
    x(2) = a_mdl(q);
    if all(~(subtbl.decel_on(max(1,q-del_B):q)))
        d = a_est(q);
        alph=d-x'*w;
        g = P*x/(lambda+x'*P*x);
        P=1/lambda*P-g*x'/lambda*P;
        w=w+alph*g;
        % weights for plotting
%         w_(q,:)=w;
    end
    a_rls(q) = x'*w;
end
% error in mass

end
