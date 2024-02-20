stats = readtable('..\processed\stats_wDrr.csv');
% residual function
m = stats.mean_mass_eff;
v = stats.mean_v;
NPC = stats.mean_NPC;
PAD = stats.mean_P_AD_true;
PRR = stats.PRR;

%residual
r = @(beta_1,alpha,gamma,beta_2) NPC - ...
    beta_1.*PAD./((m.^alpha).*(v.^gamma)) - ...
    beta_2.*stats.PRR;
%jacobian
J = @(beta_1,alpha,gamma,beta_2) [-PAD./(m.^alpha.*v.^gamma), ...
    (beta_1.*PAD.*m.^(-alpha).*log(m))./(v.^gamma), ...
    (beta_1.*PAD.*v.^(-gamma).*log(v))./(m.^alpha), ...
    -PRR];
J0 = @(beta_1,alpha,beta_2) [-PAD./(m.^alpha.*v.^2), ...
    (beta_1.*PAD.*m.^(-alpha).*log(m))./(v.^2), ...
    -PRR];


%initial guesses at the parameters

tol=1e-6;
alpha=.05;
len = 1000;

beta_1_hat = 0.75;
alpha_hat = 0.5;
gamma_hat = 2;
beta_2_hat =1.0;
% 0.204076584138994
% 0.381623422357172
% 1.55800094761922
% 1.00049686946786
X_hat = [beta_1_hat,alpha_hat,gamma_hat,beta_2_hat]';
X0_hat = [beta_1_hat,alpha_hat,beta_2_hat]';
rSq = [];
for q = 1:20000
    R = r(X_hat(1,q),X_hat(2,q),X_hat(3,q),X_hat(4,q));
    R0 = r(X0_hat(1,q),X0_hat(2,q),2,X0_hat(3,q));
    rSq(q) =R'*R;
    rSq0(q) =R0'*R0;
    if q>1&&(abs(rSq(q)-rSq(q-1))<tol)
       break
    end
    % pseudoinverse of jacobian
    pJ=pinv(J(X_hat(1,q),X_hat(2,q),X_hat(3,q),X_hat(4,q)));
   pJ0=pinv(J0(X0_hat(1,q),X0_hat(2,q),X0_hat(3,q)));
   X_hat(:,q+1)=X_hat(:,q) -alpha*pJ(:,:) * R;
   X0_hat(:,q+1)=X0_hat(:,q) -alpha*pJ0(:,:) * R0   ;
end



