function [frac] = aero_benefit_schmid(tbl,plen,ppos)
% AERO_BENEFIT_SCHMID
% Evan Stegner
% 1. Schmid, M., Liu, D., Eksioglu, B., Huynh, N., Comert, G., and College, B.,
% “Prediction Model for Energy Consumption in Heavy-Duty Vehicle Formations,” 7, 2020.
% The original paper has an error in the coefficients, I recovered them
% and wrote about it here: 
% https://gitlab.com/ems0029/reverse-engineering-the-correct-schmid-drag-reduction-coefficients

headway= tbl.range_estimate;

%TODO move this to the table cleaning step, unless we want to preserve the
%headway estimate
    function h = cleanHeadway(h)
        h(isnan(h))=1000;
        if sum(h<2) > 10
            warning('Small headways found, possible aero benefit issue')
            fprintf('\n %i points less than 2 meters\n',sum(h<2))
        end
        h(h<2)=2;
        h(h>500)=1000;
%         h = filloutliers(h,"center",'movmedian',100);
    end

headway=cleanHeadway(headway);

% these coefficients are my own fit
X1= 5.4543;
X2= 1.5197;
X3= 0.6610;
X4= 8.9289;
X5= 0.3374;
X6= -0.0422;

% DRR1 function delta-Cdb1/Cds1
DRR1 = @(headway_r) 1-(1-(X1./(headway_r+X1*X2)).^3).^2;
% DRR2 function
zeta = @(headway_f) X3.*(1-DRR1(headway_f)).^X4.*headway_f.^(-2/3);
DRR2 =@(headway_f,headway_r) 1-(1-zeta(headway_f)).^2.*(1-(DRR1(headway_r)));
% DRR3 function
del_Cdc = @(headway_f) 1 + min(repmat(0.23391,size(headway_f)), X5.*exp(X6.*headway_f));
DRR3 = @(headway_2f,headway_f,headway_r) 1-(1-DRR2(headway_2f,headway_f)).*...
    (1-zeta(headway_f)).^2.*...
    del_Cdc(headway_f).*...
    (1-(DRR1(headway_r)));
% DRR4 function
DRR4 = @(headway_3f,headway_2f,headway_f) 1-(1-DRR3(headway_3f,headway_2f,headway_f)).*...
    (1-zeta(headway_f)).^2.*...
    del_Cdc(headway_f);


switch plen
    case 2
        if ppos==1
            frac = 1-DRR1(headway);
        elseif ppos ==2
            frac = 1-DRR2(headway,1000);
        else 
            error('platoon position not in length')
        end
    case 4
        if ppos==1
            frac = 1-DRR1(headway);
        elseif ppos==2
            frac = 1-DRR2(headway,headway);
        elseif ppos == 3
            frac = 1-DRR3(headway,headway,headway);
        elseif  ppos ==4
            frac = 1-DRR4(headway,headway,headway);
        else 
            error('platoon position not in length')    
        end
    otherwise
        frac = ones(size(headway));
end

end

