function m_est = RLS_mass(subtbl,lambda)
% take in a subtable with acceleration estimate and 
pwr = subtbl.engine_power-subtbl.PwrL_Brake;
dpwr_dm = subtbl.v_noise.*(subtbl.a_estimate+9.8*(0.0055+sin(subtbl.grade)));
%initialize
p = 1;
x = zeros(p+1,1); %px1
w = zeros(p+1,1); %px1
d = zeros(p+1,1); %px1
m_est = zeros(size(pwr));
del = .01;
P = eye(p+1)*del; %pxp


for q = 1:height(subtbl)
        if subtbl.decel_on(q)
        m_est(q) = [1;dpwr_dm(q)]'*w;
        else
        lambda_A=lambda;%-0.05*max(tanh(subtbl.engine_power(q)/10000),0);
        x= [1;dpwr_dm(q)];
        d = pwr(q);
        alph=d-x'*w;
        g = P*x/(lambda_A+x'*P*x);
        P=1/lambda_A*P-g*x'/lambda_A*P;
        w=w+alph*g;
        % a posteriori a_dist
        w_(q,:)=w;
        p_(q)=P(1,1);
        m_est(q) = x'*w;
        end
end
plot(w_(:,2))
% plot(p_)

% yline(31000)