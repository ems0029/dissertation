function [l_bound, u_bound] = twoSidedMaybe(zeroclass,oneclass,alpha)
    l_bound = 1-(zeroclass.Threshold(find(zeroclass.FalsePositiveRate<alpha,1,"last")));
    u_bound = (oneclass.Threshold(find(oneclass.FalsePositiveRate<alpha,1,"last")));
end