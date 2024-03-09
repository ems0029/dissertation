function out = kappa(varargin)
    if nargin==0
        eta = 0.366;
    elseif nargin==1
        eta = varargin{1};
    else
        error('More than 1 argument is not accepted')
    end
    out = 3600/eta/36e6; %3600 s/hr,fuel conversion efficiency,LHV in J/L
end