histogram(aero_offset/10)
hold on
histogram(rr_offset/0.01)
histogram(mass_offset./mass_true')
legend('C_d','C_{rr}','mass')
ylim([0 600])
xlabel('Parameter Error')
ylabel('Counts')
xticklabels(sprintf('%.0f%% \n',-50:10:50))