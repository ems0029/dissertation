function a_rls = RLS(subtbl,lambda)
% take in a subtable with acceleration estimate and 
a_mdl = fillmissing(subtbl.a_modeled_w_drr,"nearest");
a_est = fillmissing(subtbl.a_estimate,"nearest");

p=1;
%initialize
x = zeros(p+1,1); %px1
w = zeros(p+1,1); %px1
d = zeros(p+1,1); %px1
a_rls = zeros(size(a_mdl));
del = 1e10;
del_B = 1;
P = eye(p+1)*del; %pxp

for q = 1:height(subtbl)
    if any(subtbl.decel_on(max(1,q-del_B):q))
        a_rls(q) = [1;a_mdl(q)]'*w;
        % no x refreshment
    else
        lambda_A=lambda;%-0.05*max(tanh(subtbl.engine_power(q)/10000),0);
        x= [1;a_mdl(q)];
        d = a_est(q);
        alph=d-x'*w;
        g = P*x/(lambda_A+x'*P*x);
        P=1/lambda_A*P-g*x'/lambda_A*P;
        w=w+alph*g;
        % a posteriori a_dist
        w_(q,:)=w;
        a_rls(q) = x'*w;
    end
end
% error in mass


end
