function a_rls = RLS_keepUpdate(subtbl,lambda,p)
% take in a subtable with acceleration estimate and 
a_mdl = subtbl.a_modeled_w_drr;
a_est = subtbl.a_estimate;
%initialize
if nargin<3
p = 27;
end
x = zeros(p,1); %px1
w = zeros(p,1); %px1
d = zeros(p,1); %px1
a_rls = zeros(size(a_mdl));
del = 1e10;
P = eye(p)*del; %pxp
ri = 0;


% tic
for q = 1:height(subtbl)
    %recursive least squares here
    if subtbl.decel_on(q)
        x= [a_mdl(q);x(1:end-1)];
        a_rls(q) = x'*w;
        % no weight updates
    elseif any(subtbl.decel_on(max(1,q-p):q))
        x= [a_mdl(q);x(1:end-1)];
        a_rls(q) = x'*w;
        % no weight updates
    else
        lambda_A=lambda;%-0.05*max(tanh(subtbl.engine_power(q)/10000),0);
        d = a_est(q);
        x= [a_mdl(q);x(1:end-1)];
        alph=d-x'*w;
        g = P*x/(lambda_A+x'*P*x);
        P=1/lambda_A*P-g*x'/lambda_A*P;
        w=w+alph*g;
        % a posteriori a_dist
        a_rls(q) = x'*w;
    end
end
end