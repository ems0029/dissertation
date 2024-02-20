clearvars
i=1;
% (no longer) minimum working example of a (not) bootstrap analysis
s = load("..\lookups\nfc_tbl_I85.mat",'nfc_tbl');
nfc_tbl = s.nfc_tbl;

%remove triptime outliers
nfc_tbl = rmoutliers(nfc_tbl,'median','DataVariables','trip_time');

nfc_tbl.runID = findgroups(nfc_tbl.truck,nfc_tbl.westbound);

ref = nfc_tbl(nfc_tbl.spacing=="NA",:);
plat = nfc_tbl(nfc_tbl.spacing~="NA",:);

f_pdiff = @(plat,ref)   (plat.mean_drag_reduction_ratio)*plat.mean_P_aero-ref.mean_P_aero-ref.mean_P_AD_rls+plat.mean_P_AD_rls;

kappa = 3600/0.366/36e6; %3600 s/hr,fuel conversion efficiency,LHV in J/L

for q = 1:max(nfc_tbl.runID)
    for qq =1:2
        if qq==1
        subplat=plat(plat.runID==q&plat.spacing=="75",:);
        else
        subplat=plat(plat.runID==q&plat.spacing=="150",:);
        end
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
                X.group(i) = (qq-1)*4+q;
                i=i+1;
            end
        end
        % plot(pdiff(:),fuel(:),'.')
    end
end
% mdl = fitlm([X.fuel_inf]',X.fuel_true')
% mdl.plotAdded
% mdl = fitlm(kappa*[X.drag_term;X.brake_term]',X.fuel_true')
% 
% mdl.plotAdded('x2')
hold on
a = scatter3(kappa*X.brake_term,kappa*X.drag_term,X.fuel_true,'filled','k')
xlabel('brake term')
ylabel('drag term')