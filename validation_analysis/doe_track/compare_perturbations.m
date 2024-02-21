clearvars

i=1;
% (no longer) minimum working example of a (not) bootstrap analysis
s = load("..\lookups\nfc_tbl_nrc.mat",'nfc_tbl');
nfc_tbl = s.nfc_tbl;
nfc_tbl.spacing(nfc_tbl.spacing=="N/A")="NA";
%remove triptime outliers
% nfc_tbl = rmoutliers(nfc_tbl,'median','DataVariables','trip_time');

nfc_tbl.runID = findgroups(nfc_tbl.truck);

nfc_tbl(nfc_tbl.ID==160,:)=[];
ref = nfc_tbl(nfc_tbl.spacing=="NA",:);
plat = nfc_tbl(nfc_tbl.spacing~="NA",:);
% plat = plat(plat.truck=="A2"|plat.truck=="A1",:); 

f_pdiff = @(plat,ref)   (plat.mean_drag_reduction_ratio)*plat.mean_P_aero-ref.mean_P_aero-ref.mean_P_AD_rls+plat.mean_P_AD_rls;

kappa = 3600/0.366/36e6; %3600 s/hr,fuel conversion efficiency,LHV in J/L

for q = 1:max(nfc_tbl.runID)
    subplat=plat(plat.runID==q,:);
    subref=ref(ref.runID==q,:);

    fuel = nan(height(subplat),height(subref));
    pdiff = nan(height(subplat),height(subref));
    for n = 1:height(subplat)
        for m = 1:height(subref)
            X.fuel_true(i) = subplat.mean_fuel_rate(n)-subref.mean_fuel_rate(m);
            X.fuel_inf(i) = kappa*f_pdiff(subplat(n,:),subref(m,:));
            X.power_true(i) = subplat.mean_engine_power(n)-subref.mean_engine_power(m);
            X.power_inf(i) = f_pdiff(subplat(n,:),subref(m,:));
            X.drag_term(i) = (subplat.mean_drag_reduction_ratio(n)).*subplat.mean_P_aero(n)-subref.mean_P_aero(m);
            X.brake_term(i) = subplat.mean_P_AD_cadj(n)-subref.mean_P_AD_cadj(m);
            i=i+1;
            label{i} = [subplat.Row{n},' VERSUS ',subref.Row{m}];
        end
    end
end

% mdl = fitlm([X.fuel_inf]',X.fuel_true')
% 
% mdl = fitlm(kappa*[X.drag_term;X.brake_term]',X.fuel_true','RobustOpts','off')
% 
% mdl.plotAdded('x2')
% % some outliers on ID 160 
% label{kappa*X.brake_term>12}
% 

% hold on
% scatter3(gca(),kappa*X.brake_term,kappa*X.drag_term,X.fuel_true,'filled','MarkerFaceAlpha',0.25)
% xlabel('Inferred effect of braking [L/hr]')
% ylabel('Inferred effect of drag reduction [L/hr]')
% zlabel('Actual fuel difference [L/hr]')
hold on
scatter(gca(),X.fuel_inf,X.fuel_true,'filled','MarkerFaceAlpha',0.25)
xlabel('Inferred fuel difference [L/hr]')
ylabel('Actual fuel difference [L/hr]')
