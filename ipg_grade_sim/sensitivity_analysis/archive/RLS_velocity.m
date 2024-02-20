function v_rls = RLS_velocity(subtbl,lambda)
% take in a subtable with acceleration estimate and 
v_in = (cumtrapz(subtbl.time,subtbl.a_modeled_w_drr)-subtbl.v_noise)./subtbl.v_noise;
v_out = 0*subtbl.v_noise+1;
%initialize
p = 30;
x = zeros(p,1); %px1
w = zeros(p,1); %px1
d = zeros(p,1); %px1
v_rls = zeros(size(v_in));
del = 1e10;
P = eye(p)*del; %pxp
ri = 0;

% tic
for q = 1:height(subtbl)
    %recursive least squares here
    if subtbl.decel_on(q)
        if ~subtbl.decel_on(q-1) % first index
            ri=v_rls(q-1)-v_in(q-1);
        end
        v_rls(q) = v_in(q)+ri;
        % no x refreshment
    else
        lambda_A=lambda;%-0.05*max(tanh(subtbl.engine_power(q)/10000),0);
        d = v_out(q);
        x= [v_in(q);x(1:end-1)];
        alph=d-x'*w;
        g = P*x/(lambda_A+x'*P*x);
        P=1/lambda_A*P-g*x'/lambda_A*P;
        w=w+alph*g;
        % a posteriori a_dist
        v_rls(q) = x'*w;
    end

end
end