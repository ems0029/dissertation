clearvars
close all
figure(2)
load("..\lookups\tbl_ew_11_22.mat")
tbl_elev_e = [tbl_e.east,tbl_e.alt,tbl_e.north];
tbl_elev_e=sortrows(tbl_elev_e);
tbl_elev_e(:,2) = smoothdata(tbl_elev_e(:,2),'movmedian',100);
plot(tbl_elev_e(:,1),tbl_elev_e(:,2))
hold on
tbl_elev_w = [tbl_w.east,tbl_w.alt,tbl_w.north];
tbl_elev_w=sortrows(tbl_elev_w);
tbl_elev_w(:,2) = smoothdata(tbl_elev_w(:,2),'movmedian',100);
plot(flip(tbl_elev_w(:,1)),flip(tbl_elev_w(:,2)))
