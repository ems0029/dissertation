function [frac] = aero_benefit_hussein(tbl,plen,ppos,method)
%AERO_BENEFIT_HUSSEIN 
% 1. Hussein, A.A. and Rakha, H.A., 
% “Vehicle Platooning Impact on Drag Coefficients and 
% Energy/Fuel Saving Implications,” IEEE Trans. Veh. Technol. 
% 71(2):1199–1208, 2022, doi:10.1109/TVT.2021.3131305.

%   tbl is a subtable with one run in it
%   plen is the platoon length, an integer
%   ppos is the posistion in the platoon, an integer> <=plen
%   method is either power or RP
narginchk(3,4)

if ~exist('method','var')
    method = 'power';
elseif ~any(strcmpi(method,{'power','rp'}))
    error('incorrect method given')
end

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

switch method
    case 'power'
        switch plen
            case 2
                switch ppos
                    case 2 % follower
                        a=0.2241;
                        b=0.1369;
                        c=0.5016;
                        g0=320; 
                    case 1 % leader
                        a=0.7231;
                        b=0.0919;
                        c=0.000;
                        g0=34.0181;
                end


            case 4
                switch ppos
                    case 4 % trail
                        a=0.0726;
                        b=0.2842;
                        c=0.5794;
                        g0=480;
                    case 1 % leader
                        a=0.0035;
                        b=0.5997;
                        c=0.9662;
                        g0=480; % insertion by ES
                    otherwise % mid-platoon
                        a=0.1522;
                        b=0.2111;
                        c=0.5260;
                        g0=217.27;
                end

            otherwise
                a=1;
                b=1;
                c=0;
                g0=eps; %frac is always forced to one since g0 is small
        end
        
        frac=a*headway.^b+c;
        frac(headway>=g0)=1;
    case 'rp' %rational polynomial
        switch plen
            case 2
                switch ppos
                    case 1 % leader
                        a3  =3.1100E-02;
                        a2  =-5.2600E-01;
                        a1  =3.9748;
                        a0  =3.4752;
                        b3  =3.1400E-02;
                        b2  =-5.4990E-01;
                        b1  =4.3330E+00;
                        b0  =4.2828E+00;
                        G0  =inf;
                    case 2 %follower
                        a3  = 2.0595E-04;
                        a2  = 2.5317E-02;
                        a1  = -3.5899E-01;
                        a0  = 2.2499E+00;
                        b3  = 1.6232E-04;
                        b2  = 3.4562E-02;
                        b1  = -4.6773E-01;
                        b0  = 2.7848E+00;
                        G0  = 1.9997E+02;
                end


            case 4
                switch ppos
                    case 1 % leader
                        a3=	3.1331E-03;
                        a2=	-7.4406E-02;
                        a1=	4.3816E-01;
                        a0=	4.2539E+00;
                        b3=	3.0420E-03;
                        b2=	-6.5108E-02;
                        b1=	1.9037E-01;
                        b0=	6.3671E+00;
                        G0=	inf;
                    case 4 % trail
                        a3=  4.9858E-04;
                        a2=  9.7766E-02;
                        a1=  -1.9899E+00;
                        a0=  1.8372E+01;
                        b3=  4.3156E-04;
                        b2=  1.3238E-01;
                        b1=  -2.5572E+00;
                        b0=  2.3704E+01;
                        G0=  5.0056E+02;
                    otherwise % mid-platoon
                        a3= 5.1576E-05;
                        a2= 1.0138E-01;
                        a1= 1.2429E-01;
                        a0= 2.3616E+00;
                        b3= 5.4957E-07;
                        b2= 1.1700E-01;
                        b1= 3.4343E-01;
                        b0= 3.8255E+00;
                        G0= 3.2001E+02;
                end

            otherwise
                a3= 0;
                a2= 0;
                a1= 0;
                a0= 1;
                b3= 0;
                b2= 0;
                b1= 0;
                b0= 1;
                G0= eps;
        end
        
        frac=(a3*headway.^3 + a2*headway.^2 + a1.*headway + a0)./ ...
            (b3*headway.^3 + b2*headway.^2 + b1.*headway + b0);
        frac(headway>=G0)=1;
end

end

