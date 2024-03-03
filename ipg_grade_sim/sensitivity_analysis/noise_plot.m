tiledlayout(1,3,'TileSpacing','compact','Padding','tight')
nexttile
plot(subtbl.time,subtbl.v,'LineWidth',3)
hold on
plot(subtbl.time,subtbl.v_true,'LineWidth',1.25)
xlabel('Time [s]')
ylabel('Velocity [m/s]')
nexttile
plot(subtbl.time,subtbl.grade*180/pi,'LineWidth',3)
hold on
plot(subtbl.time,subtbl.grade_true*180/pi,'LineWidth',1.25)
xlabel('Time [s]')
ylabel('Grade [deg]')
legend('With Noise','Truth','Location','northoutside','Orientation','horizontal')
nexttile
plot(subtbl.time,subtbl.engine_power/1000,'LineWidth',3)
hold on
plot(subtbl.time,subtbl.engine_power_true/1000,'LineWidth',1.25)
xlabel('Time [s]')
ylabel('Engine Power [kW]')
linkaxes(gcf().Children.Children,'x')
set(gcf().Children.Children,'FontSize',10)
