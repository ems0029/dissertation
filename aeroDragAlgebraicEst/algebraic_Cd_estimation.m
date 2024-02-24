% algebraic_Cd_estimation.m Performs Cd estimation on real truck platooning
% data following the approach in [1]. The data is from a 30' following
% platoon in a test track setting with a C_dA ~= 4.46. 
% Code include the option to set the values constant for debugging purposes.
% Sources:
% [1] Wang, Zejiang, Adian Cook, Yunli Shao, Vivek Sujan, Paul Chambon, Dean Deter, and Nolan Perry. 
% "Heavy-Duty Vehicle Air Drag Coefficient Estimation: From an Algebraic Perspective." 
% In 2023 American Control Conference (ACC), pp. 3169-3174. IEEE, 2023.
clearvars
close all

%% debug switch (set values constant)
debugOn = false;

%% load data
subtbl = readtable('working_example.csv');

%% Assign inputs
t = (0:height(subtbl)-1)'/10;    
v = subtbl.v;
eta = v.^2;
m = median(subtbl.mass_eff);
F_c = subtbl.engine_power./subtbl.v;
theta = sind(subtbl.grade_estimate);
theta = fillmissing(theta,'previous');

if debugOn
    v = v*0+mean(v);
    eta = v.^2;
    F_c = F_c.*0+mean(F_c);
    theta = theta*0+mean(theta);
end


%% constants
g = 9.8;
k = 1.225*10/(2*m);

%% plot inputs
figure(1)
tiledlayout('flow')
nexttile
plot(t,t);ylabel('$t$','Interpreter','latex','fontsize',14)
nexttile
plot(t,v);ylabel('$v(t)$','Interpreter','latex','fontsize',14)
nexttile
plot(t,eta);ylabel('$\eta(t)$','Interpreter','latex','fontsize',14)
nexttile
plot(t,F_c);ylabel('$F_c(t)$','Interpreter','latex','fontsize',14)
nexttile
plot(t,theta);ylabel('$\theta(t)$','Interpreter','latex','fontsize',14)
annotation("textbox",[gcf().Children.Children(2).Position(1),gcf().Children.Children(1).Position(2:4)], ...
    'String',sprintf('Parameters\n\nMass = %.0f kg\nk = %.4s m^{-1}',m,k), ...
    'BackgroundColor',[1 1 1], ...
    'EdgeColor','k')

%% Calculate Solution
% cumulative integral for data
itg = @(x) cumtrapz(t,x);

% Need to construct p1(t) p2(t) and q(t)
p1 = itg(itg(t.^2.*v)) - 4*itg(itg(itg(t.*v))) + 2 * itg(itg(itg(itg(v))));
p2 = itg(itg(t.^2.*eta)) + itg(itg(itg(t.^2.*eta-2*t.*eta))) - 2 * itg(itg(itg(itg(t.*eta))));

P = [p1 p2];
q = 1/m*(itg(itg(t.^2.*F_c)) + itg(itg(itg(t.^2.*F_c-2*t.*F_c))) - 2 * itg(itg(itg(itg(t.*F_c)))) )...
    -g*(itg(itg(t.^2.*theta)) + itg(itg(itg(t.^2.*theta-2*t.*theta))) - 2 * itg(itg(itg(itg(t.*theta)))))...
    -(itg(t.^2.*v)-4*itg(itg(t.*v))+2*itg(itg(itg(v))));

Mpp = [itg(p1.*p1) itg(p1.*p2);
       itg(p2.*p1) itg(p2.*p2)];

Mpq = [itg(p1.*q) itg(p2.*q)]';

th_star=[];

for i = 1:length(p1)
    th_star(:,i) = inv(Mpp([2*i-1, 2*i],:))*Mpq(:,i);
end

eIdx = 1000;
figure(2)
subplot(2,1,1)
plot(t(1:eIdx),th_star(2,1:eIdx)/k)
xlabel('$t$','Interpreter','latex')
ylabel('$C_d$','Interpreter','latex')
yline(0.446,'--','C_{d,ref}=0.446')
ylim([-100 100])
subplot(2,1,2)
plot(t(1:eIdx),th_star(1,1:eIdx))
xlabel('$t$','Interpreter','latex')
ylabel('$\hat{b}_x$','Interpreter','latex')

linkaxes(gcf().Children,'x')