clearvars rms_afir q75_afir q91_afir q98_afir max_afir
if ~exist('tbl','var')
load('..\ipg_grade_sim\processed\tbl_platoon_working.mat','tbl')
end
subtbl=tbl(tbl.ID==100,:);

addpath('..\functions\')
addpath('..\lookups\truck_params\')
for q = 1
    for qq = 1:25
        firf = designfilt('lowpassfir','FilterOrder',qq*2-1, ...
            'CutoffFrequency',q/40,'SampleRate',10);
        a_num=diff(subtbl.v_noise)*10; % 0.5 samples late
        subtbl.a_fir=filter(firf,[a_num;0]); % +qq-0.5 samples late
        % shift a_fir
        subtbl.a_fir = [subtbl.a_fir(qq:end);zeros(qq-1,1)];
        velocityError = @(a) subtbl.v-cumtrapz(a)/10-mean(subtbl.v-cumtrapz(a)/10);
        accelError = @(a) subtbl.a_true-subtbl.a_fir;
        % clf
        % hold on
        % plot(subtbl.time,velocityError(subtbl.a_estimate),'.')
        % plot(subtbl.time,velocityError(subtbl.a_fir),'.')
        % plot(subtbl.time,velocityError(subtbl.a_fir_0phase),'.')
        VE = velocityError(subtbl.a_fir);
        AE = accelError(subtbl.a_fir);
        rmse_vfir(q,qq) = rms(VE(25:end-25));
        rmse_afir(q,qq) = rms(AE(25:end-25));
        max_vfir(q,qq) = max(abs(VE(25:end-25)));
        q75_vfir(q,qq) = quantile(VE(25:end-25),0.75);
        q91_vfir(q,qq) = quantile(VE(25:end-25),0.9113);
        q98_vfir(q,qq) = quantile(VE(25:end-25),0.9785);
        fprintf('%.2f,%u, RMSE:%.4f\n',q/40,qq,rmse_afir(q,qq))
    end
end
min_rms_v =find(rmse_vfir==min(rmse_vfir(:)));
min_rms_a =find(rmse_afir==min(rmse_afir(:)));
min_maxVE =  find(max_vfir==min(max_vfir(:)));
min_q75afir =  find(q75_vfir==min(q75_vfir(:)));
min_q91afir =  find(q91_vfir==min(q91_vfir(:)));
min_q98afir =  find(q98_vfir==min(q98_vfir(:)));
% use this figure to justify that it will be important to remove the phase lag!
[Y,X]=meshgrid(1:2:49,[1:100]/40);
colormap turbo
clf
[~,con]=contour(X,Y,rmse_vfir,'ZLocation','zmax','LevelList',[0.008:0.0005:0.013,0.014],'ShowText','on','EdgeColor','black')
hold on
sf=surf(X,Y,max_vfir,'EdgeColor','none','FaceColor','interp')
clim([0.02 0.08])
rmse_v_pt=scatter3(X(min_rms_v),Y(min_rms_v),gca().ZLim(end),'markerfacecolor','green','markeredgecolor','black')
rmse_a_pt=scatter3(X(min_rms_a),Y(min_rms_a),gca().ZLim(end),'markerfacecolor','yellow','markeredgecolor','black')
sel_pt=scatter3(1.2,27,gca().ZLim(end),'markerfacecolor','red','markeredgecolor','black')
% min_pt=scatter3(X(min_maxVE),Y(min_maxVE),gca().ZLim(end),'markerfacecolor','green','markeredgecolor','black')
% q75_pt=scatter3(X(min_q75afir),Y(min_q75afir),gca().ZLim(end),'markerfacecolor','blue','markeredgecolor','black')
% q91_pt=scatter3(X(min_q91afir),Y(min_q91afir),gca().ZLim(end),'markerfacecolor','blue','markeredgecolor','black')
% q98_pt=scatter3(X(min_q98afir),Y(min_q98afir),gca().ZLim(end),'markerfacecolor','blue','markeredgecolor','black')
cbar = colorbar(gca(),'northoutside');cbar.Title.String="Maximum Velocity Error [m/s]";
legend([con,rmse_v_pt,rmse_a_pt,sel_pt],{'Velocity RMSE [m/s]','Min Velocity RMSE','Min. Accel. RMSE','Designed Filter'},'Location','southoutside','Orientation','horizontal')
view(2)
xlim([0.5 2.5])
ylim([2.5 49])
xlabel('Cutoff Frequency \omega_c [Hz]')
ylabel('FIR Filter Order [-]')
zlabel('RMSE [m/s]')
legend([rmse_v_pt],{'Minimum RMSE','Min. 75th     ','Minimum Max Abs. Error'},'AutoUpdate','off','Location','best')

