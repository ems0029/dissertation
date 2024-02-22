% trying to get the memsense data into the accelration filter
%A1 test
'F:\ACM_2019_data\2T_100\A1_T14\A1_2T_100_1_2019-10-16-07-41-42.mat'
%A2 test
load('F:\ACM_2019_data\4T_100\A2_4T_100_2_2019-10-24-10-33-42.mat')
%T13 test
load('F:\ACM_2019_data\4T_50\T13_4T_50_2_2019-10-24-14-17-32.mat')
%T14 test
load('F:\ACM_2019_data\CutIns\T14_CutIn_Videoshoot_2019-11-01-10-15-30.mat')

addpath F:\other_scripts_2021\SAE_2023_utils\feature_engineering

a_x = data.memsense.imuTimeReference.linearAcceleration(3,:);
t = data.memsense.imuTimeReference.time;
v = data.j1939.vehicle_speed.wheelBasedSpeed/3.6;
t_v = data.j1939.vehicle_speed.time
%% upsample v
v_  =interp1(data.j1939.vehicle_speed.time,v,t,'previous','extrap');
% see the bias?
plot(cumtrapz(t,a_x),'.');

%% variance of accelerometer data
var_a = var(a_x-(smoothdata(a_x,'sgolay',500)));
var_v = 4e-4;
q2r=5.0;

T= 0.01;
G = [1/6*T^3 0
    .5*T^2 0
    T 0
    0 1];
C = [1 0 0 0
    0 1 0 1]; %2x4
H = [0 0 ;0 0];
R = diag([var_v var_v*2]); % noise variance of the measurement
Q=diag([q2r*var_v eps]); %unknown plant noise, specified?
A=[ 1 T 0.5*(T^2) 0
    0 1 T 0
    0 0 1 0
    0 0 0 1]; % state matrix
sys = ss(A,[G],C,[H],T/10);
warning('off','Control:analysis:LsimStartTime')
[Est,L,P,M]=kalman(sys,Q,R,0,'current');
Filt=Est(:,1:2)

%test it out
%resample for lsim
[va_r t_r]=resample([v_; a_x]',t,1/T);
%raw accel and jerk calc for delay calc

[Y,t_r,X]=lsim(Filt,va_r,t_r,[va_r(1,:) 0 fitlm(t,a_x,'constant').Coefficients.Estimate(1)]);

a_simple=fKalmanFiltSpeed(t_v',v',q2r,0);

clf
plot(t_v,gradient(v)*10)
hold on
plot(t_v',a_simple)
plot(t_r,X(:,2))

firf = designfilt('lowpassfir','FilterOrder',20, ...
'CutoffFrequency',1.5,'SampleRate',10);
a_fir=filtfilt(firf,gradient(v));
clf
plot(t_v,gradient(v)*10)
hold on
plot(t_v,a_fir*10)
plot(t_v',a_simple)

%%fir filter cutoff selection
w_c=0.25:0.25:1.5;
clf
for q = 1:length(w_c)
firf = designfilt('lowpassfir','FilterOrder',10, ...
'CutoffFrequency',0.7,'SampleRate',10);
a_fir=filtfilt(firf,gradient(v));
% a_simple=fillmissing(fKalmanFiltSpeed(t_v',v',50,0),"nearest");
figure(1)
clf
plot(t_v,gradient(v)*10)
hold on
plot(t_v,a_fir*10)
colormap parula
figure(2)

hold on
plot(cumtrapz(gradient(v))-cumtrapz(a_fir))
% plot(cumtrapz(gradient(v))-cumtrapz(a_simple))

% pause
end


figure
AUcolors=auburnColormap;
lowQRColor=AUcolors(4,:);%[0.3 0.3 0.3]
highQRColor=AUcolors(3,:);%[1 1 1]
Q2R = logspace(0,log10(150),7)
for q =1:length(Q2R)
Q = R*Q2R(q)
[Est,L,P,M]=kalman(sys,Q,R);
Filt=Est(3,2);
color(q,:) = (q-1)/(length(Q2R)-1)*highQRColor +...
                (length(Q2R)-q)/(length(Q2R)-1)*lowQRColor;
grpdelay(ss2sos(Filt.A,Filt.B,Filt.C,Filt.D),1000,"whole",10)
hold on
pause
end
xlim([0 5])
for q=1:length(Q2R)
    set(gca().Children(q),'Color',color(q,:))
end
hleg=legend(gca,cellstr(num2str([Q2R]', '%2.0f')),...
'Location','northeast');
htitle = get(hleg,'Title');
set(htitle,'String','Kalman Filter Q/R')
xlabel('Time')
ylabel('Accel')
hold on


% jerkd=diff(acceld)./diff(timed)
% timedd=time(2:end-1)



% fuse = imufilter("SampleRate",100,"DecimationFactor",5)
% 
% [q,omega] = fuse(readings.linearAcceleration',readings.angularVelocity')
% 
% time = readings.time;
% 
% plot(time,eulerd(q,'ZYX','frame'))
% title('Orientation Estimate')
% legend('Z-axis', 'Y-axis', 'X-axis')
% xlabel('Time (s)')
% ylabel('Rotation (degrees)')