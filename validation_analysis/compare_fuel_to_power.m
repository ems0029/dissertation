% table fuel vs power
mdl = plotAbsPlanes(nfc_tbl_aug)

cf =mdl.Coefficients.Estimate
cfcov =mdl.CoefficientCovariance
r1=cf(2)+[0;cf(4:6)]
r2=cf(3)+[0;cf(7:end)]
se1=sqrt(cfcov(2,2)+[0;diag(cfcov([4:6],4:6))]+[0;2*cfcov(4:6,2)])*1.96
se2=sqrt(cfcov(3,3)+[0;diag(cfcov([7:end],7:end))]+[0;2*cfcov(7:end,3)])*1.96

mdl = plotAbsPlanes(nfc_tbl_aug,0.306);
cf =mdl.Coefficients.Estimate;
cfcov =mdl.CoefficientCovariance;
r1=(cf(2)+[0;cf(4:6)]-r1)./r1
r2=(cf(3)+[0;cf(7:end)]-r2)./r2
se1=sqrt(cfcov(2,2)+[0;diag(cfcov([4:6],4:6))]+[0;2*cfcov(4:6,2)])*1.96
se2=sqrt(cfcov(3,3)+[0;diag(cfcov([7:end],7:end))]+[0;2*cfcov(7:end,3)])*1.96
