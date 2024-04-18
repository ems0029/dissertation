combine_datasets
addpath functions\
close all
figure
tiledlayout(["flow"],'Padding','tight','TileSpacing','compact')
for q = 1
nexttile
truck =nfc_tbl_aug.truck_plat(nfc_tbl_aug.G==q);
plotnsided(length(unique(C(C(:,1)==q,2))),truck);
end
