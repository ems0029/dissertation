clearvars
close all
figure(2)
load("..\lookups\tbl_ew_11_22.mat")
tbl_elev_e = [tbl.x(boolean(tbl.eastbound)),tbl.alt(boolean(tbl.eastbound))];
tbl_elev_e=sortrows(tbl_elev_e);
tbl_elev_e(:,2) = smoothdata(tbl_elev_e(:,2),'movmedian',100);
plot(tbl_elev_e(:,1),tbl_elev_e(:,2))
hold on
tbl_elev_w = [tbl.x(boolean(tbl.westbound)),tbl.alt(boolean(tbl.westbound))];
tbl_elev_w=sortrows(tbl_elev_w);
tbl_elev_w(:,2) = smoothdata(tbl_elev_w(:,2),'movmedian',100);
plot(flip(tbl_elev_w(:,1)),flip(tbl_elev_w(:,2)))
