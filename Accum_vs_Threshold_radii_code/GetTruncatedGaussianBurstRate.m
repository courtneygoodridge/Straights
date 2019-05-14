function VBurstRate = GetTruncatedGaussianBurstRate(...
  VTimeStamp, burstCenterTime, burstDuration, nBurstGaussianStdDevs)

gaussianStdDev = (burstDuration / 2) / nBurstGaussianStdDevs;
VBurstRate = normpdf(VTimeStamp, burstCenterTime, gaussianStdDev);
gaussianValueAtTruncationCutoff = normpdf(-burstDuration/2, 0, gaussianStdDev);
VBurstRate = VBurstRate - gaussianValueAtTruncationCutoff;
VBurstRate(VBurstRate < 0) = 0;
% areaUnderTruncatedPartOfGaussian = normcdf(-burstDuration/2, 0, gaussianStdDev);
% areaOfTruncatedGaussian = 1 - 2 * areaUnderTruncatedPartOfGaussian - gaussianValueAtTruncationCutoff * burstDuration;
areaOfTruncatedGaussian = trapz(VTimeStamp, VBurstRate);
VBurstRate = VBurstRate / areaOfTruncatedGaussian;
