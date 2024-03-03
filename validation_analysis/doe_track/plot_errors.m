clearvars
load('..\lookups\tbl_doeTestTrack_2_14_2024.mat','tbl')

mask = tbl.truck~="A1";

plot(tbl.x(mask),tbl.grade_estimate(mask)-tbl.grade_estimate_lookup(mask),'.')

ge = tbl.grade_estimate(mask)-tbl.grade_estimate_lookup(mask);

[cdf_grade gi] = ecdf(ge); 
cdf_grade = decimate([cdf_grade],1000);
gi = decimate([gi],1000);
%% velocity
    for q = 1:max(tbl.ID)
    ve{q} = tbl.v(tbl.ID==q)-smoothdata(tbl.v(tbl.ID==q),'sgolay','SmoothingFactor',0.01);
end    
e = vertcat(ve{:});
e = e(~ismembertol(e,0,1e-12,'DataScale',1));
% pd_v =fitdist(e,'tLocationScale');
[cdf_v vi] = ecdf(e);
cdf_v = decimate(cdf_v,1000);
vi = decimate(vi,1000);
%% cdf plots
tiledlayout('flow')
nexttile
% plot(gi,cdf_grade,'LineWidth',2)
plot(gi,smoothdata(gradient(cdf_grade)./gradient(gi),'movmedian',10),'LineWidth',2)
hold on
makedist('tLocationScale',0,0.113026,2.32649).plot('Parent',gca())
xlabel('Grade Error [deg]')
ylabel('PDF')
legend('Empirical','~\itt\rm(\mu = 0, \sigma = 0.113, \nu = 2.33)')
nexttile
plot(vi,smoothdata(gradient(cdf_v)./gradient(vi),'movmedian',10),'LineWidth',2)
hold on
makedist('tLocationScale',0,0.0106063,2.02047).plot('Parent',gca())
legend('Empirical','~\itt\rm(\mu = 0, \sigma = 0.0106, \nu = 2.02)')
% plot(vi,cdf_v)
xlabel('Velocity Error [m/s]')
ylabel('PDF')






