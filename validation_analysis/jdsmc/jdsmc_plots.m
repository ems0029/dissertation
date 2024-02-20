%% summary statistics
% travel time, fuel, EAD,
% get truck ID
[~,truck_v]=findgroups(tbl_e.truck);

truck_id_e =grpstats(findgroups(tbl_e.truck),tbl_e.ID);
truck_id_w =grpstats(findgroups(tbl_w.truck),tbl_w.ID);

% get trip time
[trip_time_e,gid_e] = get_trip_time(tbl_e);
[trip_time_w,gid_w] = get_trip_time(tbl_w);

% get fuel consumed [L/hr average]
fuel_e = get_fuel_consumed(tbl_e);
fuel_w = get_fuel_consumed(tbl_w);

% get active deceleration [kJ/kghr]
ead_e = get_ead(tbl_e);
ead_w = get_ead(tbl_w);

% get references
refs_e = grpstats(tbl_e.refID,tbl_e.ID,'mode');
refs_w = grpstats(tbl_w.refID,tbl_w.ID,'mode');

% get drag reduction ratio
drr_e = get_drr(tbl_e);
drr_w = get_drr(tbl_w);

%combine it all
fuel = [fuel_e;fuel_w];
ead = [ead_e;ead_w];
drr =[drr_e;drr_w];
truck_id = [truck_id_e;truck_id_w];

return

figure(1)
clf
hold on
t13 =scatter(ead(truck_id==2),fuel(truck_id==2),'filled')
t14 =scatter(ead(truck_id==3),fuel(truck_id==3),'filled')
rf =scatter(ead(truck_id==1),fuel(truck_id==1),'filled')

mdl = fitlm([ead,truck_id],fuel,'y~x2*x1','CategoricalVars','x2')

refline(mdl.Coefficients.Estimate(2),mdl.Coefficients.Estimate(1))
refline(sum(mdl.Coefficients.Estimate([2,5])),sum(mdl.Coefficients.Estimate([1,3])))
refline(sum(mdl.Coefficients.Estimate([2,6])),sum(mdl.Coefficients.Estimate([1,4])))

legend([t13,t14,rf],{'lead','follow','control'})
xlabel('E_{AD} [kJ/kghr]')
ylabel('Average Fuel Rate [L/hr]')

%models for NFC

mdl_rf = fitlm(ead(truck_id==1),fuel(truck_id==1))
mdl_t13 =fitlm(ead(truck_id==2),fuel(truck_id==2))
mdl_t14 =fitlm(ead(truck_id==3),fuel(truck_id==3))
nfc = nan(size(fuel))
nfc(truck_id==1)=fuel(truck_id==1)/mdl_rf.Coefficients.Estimate(1)
nfc(truck_id==2)=fuel(truck_id==2)/mdl_t13.Coefficients.Estimate(1)
nfc(truck_id==3)=fuel(truck_id==3)/mdl_t14.Coefficients.Estimate(1)


figure(2)
clf
hold on
t13 =scatter(ead(truck_id==2),nfc(truck_id==2),'filled')
t14 =scatter(ead(truck_id==3),nfc(truck_id==3),'filled')
rf =scatter(ead(truck_id==1),nfc(truck_id==1),'filled')

legend([t13,t14,rf],{'lead','follow','control'})

fitlm(ead,nfc)


load("linearModel_w_baselines.mat")
lm=lm4;
close all
col = colororder;
for q = 1:max(tbl_wfeat.ID)
    subtbl = tbl_e(tbl_e.ID==q,:);
    try
        switch subtbl.truck(1)
            case "T13"
                continue
                if subtbl.lead_ctrl(1)=="EC"
                    col_sel = col(1,:);
                else
                    col_sel = col(3,:);
                end
            case "T14"

                if subtbl.follow_ctrl(1)=="OPT"
                    if subtbl.lead_ctrl(1)=="EC"
                        col_sel = col(1,:);
                    else
                        col_sel = col(2,:);
                    end
                elseif subtbl.numTrucks(1)=="1T"
                    col_sel = [0 0 0];
                else
                    if subtbl.lead_ctrl(1)=="EC"
                        col_sel = col(3,:);
                    else
                        col_sel = col(4,:);
                    end
                end
            case "RF"
                continue
                col_sel = [0, 0, 0];
        end
        figure(3)
        hold on
        ead_norm =cumsum(subtbl.P_AD)*3.6./[1:height(subtbl)]'./subtbl.mass_eff;
        plot((1:height(subtbl))/10,ead_norm,'Color',col_sel)

        figure(4)
        hold on
        DRR = cumsum(subtbl.drag_reduction_ratio)./((1:height(subtbl))');
        [meanExp,confint]=lm.predict([ead_norm,DRR],'Prediction','curve');
        expected = plot((1:height(subtbl))/10,(1-meanExp)*100,'Color',col_sel);
        %     % confint plot
        %     plot(1:height(subtbl),(1-confint)*100,'LineStyle','--','Color',[0.5,0.5,0.5])

        figure(5)
        hold on
        DRR = cumsum(subtbl.drag_reduction_ratio)./((1:height(subtbl))');
        [meanExp,confint]=lm.predict([ead_norm,DRR*0+1],'Prediction','curve');
        expected = plot((1:height(subtbl))/10,(1-meanExp)*100,'Color',col_sel);
        %     % confint plot
        %     plot(1:height(subtbl),(1-confint)*100,'LineStyle','--','Color',[0.5,0.5,0.5])
    catch
    end

end

figure(3)
xlabel('Time Elapsed [s]')
ylabel('$\mathbf{E_{AD}} \left[\frac{\textbf{kJ}}{\textbf{kg}\cdot\textbf{hr}}\right]$','Interpreter','latex')

figure(4)
xlabel('Time Elapsed [s]')
ylabel('Expected Fuel Benefit [%]')

figure(5)
xlabel('Time Elapsed [s]')
ylabel('Impact of E_{AD} on Benefit [%] ')

