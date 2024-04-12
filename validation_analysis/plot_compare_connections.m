combine_datasets
close all
figure
tiledlayout(4,8,'Padding','tight','TileSpacing','compact')
for q = 1:26
nexttile
truck =nfc_tbl_aug.truck_plat(nfc_tbl_aug.G==q);
plotnsided(length(unique(C(C(:,1)==q,2))),truck);
end
exportgraphics