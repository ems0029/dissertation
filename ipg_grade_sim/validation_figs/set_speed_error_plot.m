stats =readtable('..\processed\stats_wDrr.csv');
clearvars fig
close all
fig = figure() 
histogram(100*(stats.mean_set_v./3.6-stats.mean_v)./(stats.mean_set_v./3.6),'Normalization','probability') 
xlabel('Percent Error in Set Speed [%]')
ylabel('Probability')
exportgraphics(fig,'set_speed_discrepancy.png','Resolution',300)