stats = readtable('..\processed\stats_wDrr.csv');
% residual function
m = stats.mean_mass_eff;
v = stats.mean_v;
NPC = stats.mean_NPC;
PAD = stats.mean_P_AD_true;
PRR = stats.PRR;

%residual
r = @(beta_1,alpha,gamma,beta_2,beta_3) NPC - ...
    beta_1.*PAD./(beta_3.*(m.^alpha)+(v.^gamma)) - ...
    beta_2.*stats.PRR;
%jacobian
J = @(beta_1,alpha,gamma,beta_2,beta_3) [-PAD./(beta_3.*(m.^alpha)+(v.^gamma)), ...
    (beta_1.*PAD.*beta_3.*m.^(alpha).*log(m))./(beta_3.*m.^alpha+v.^gamma).^2, ...
    (beta_1.*PAD.*v.^(gamma).*log(v))./(beta_3.*m.^alpha+v.^gamma).^2, ...
    -PRR,...
    (beta_1.*PAD.*m.^(alpha))./(beta_3.*m.^alpha+v.^gamma).^2];

%initial guesses at the parameters

tol=1e-6;
alpha=.05;
len = 1000;

beta_1_hat = 0.75;
alpha_hat = 0.5;
gamma_hat = 2;
beta_2_hat =1.0;
beta_3_hat =1.0;
% 0.204076584138994
% 0.381623422357172
% 1.55800094761922
% 1.00049686946786
X_hat = [beta_1_hat,alpha_hat,gamma_hat,beta_2_hat,beta_3_hat]';
rSq = [];
for q = 1:20000
    R = r(X_hat(1,q),X_hat(2,q),X_hat(3,q),X_hat(4,q),X_hat(5,q));
    rSq(q) =R'*R;
    if q>1&&(abs(rSq(q)-rSq(q-1))<tol)
        break
    end
    % pseudoinverse of jacobian
    pJ=pinv(J(X_hat(1,q),X_hat(2,q),X_hat(3,q),X_hat(4,q),X_hat(5,q)));
    X_hat(:,q+1)=X_hat(:,q) -alpha*pJ(:,:) * R;
end



