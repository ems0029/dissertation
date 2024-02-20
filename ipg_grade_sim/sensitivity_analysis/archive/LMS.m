function a_rls = LMS(subtbl,p)
% take in a subtable with acceleration estimate and 
a_mdl = subtbl.a_modeled_w_drr;
a_est = subtbl.a_estimate;
%% initialize
if nargin<2
p = 5;
end
mu = 2/(300); %21 is the trace

x = zeros(p,1); %px1
h = zeros(p,1); %px1
a_rls = zeros(size(a_mdl));
ri = 0;


% tic
for q = 1:height(subtbl)
    %recursive least squares here
    if subtbl.decel_on(q)
        if ~subtbl.decel_on(q-1) % first index
            ri=a_rls(q-1)-a_mdl(q-1);
        end
        a_rls(q) = a_mdl(q)+ri;
        % no x refreshment
    elseif any(subtbl.decel_on(max(1,q-p):q))
        a_rls(q) = a_mdl(q)+ri;
        % no x refreshment
    else
        x= [a_mdl(q);x(1:end-1)];
        e(q) = a_est(q)-h'*x;
        a_rls(q) = h'*x;
%         h'*x
        % h update
        h = h+mu*e(q)*x;
    end
    %     if mod(q,2)==0
    %     scatter(q,d-x'*w,'rx');scatter(q,d-a_mdl(q),'bx');
    %     drawnow
    %     end
%     toc
end
end