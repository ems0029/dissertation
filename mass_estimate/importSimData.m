% import IPG results as a Table
% opts = delimitedTextImportOptions('DataLines',3,'RowNamesColumn',1,'VariableNamesLine',1,'VariableDescriptionsLine',0,'VariableUnitsLine',0,'Delimiter',{'#','\t'});
filename = 'C:\CM_Projects\ACM_scenario\SimOutput\gavlab-win92\20221024\straight_follow_acc_noEngineBrake.dat';
opts = detectImportOptions(filename);
opts.VariableUnitsLine = 2;
opts.DataLines = 4;
opts.RowNamesColumn = 0;
opts.SelectedVariableNames = opts.SelectedVariableNames(2:end);
T_IPG = readtable(filename,opts);

% add distance filter to remove runway

F = (T_IPG.PwrL_Total-T_IPG.PT_Engine_PwrO)./T_IPG.Car_v
F = (T_IPG.PwrD_Inert_Chassis)./T_IPG.Car_v
plot(F)

a = T_IPG.Car_ax

plot(F,a)