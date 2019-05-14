function  [VH, VSimR] = GetHFromGWithLinearVehicleModel(...
  VTimeStamp, VG, MLinearModel_A, VLinearModel_b, nonAccumulatorDelay)

VSimVY = zeros(size(VTimeStamp));
VSimR = zeros(size(VTimeStamp));
for i = 2:length(VTimeStamp)
  VQ = [VSimVY(i-1); VSimR(i-1)];
  VQDot = MLinearModel_A * VQ + VLinearModel_b * VG(i);
  VNewQ = VQ + VQDot * (VTimeStamp(i) - VTimeStamp(i-1));
  VSimVY(i) = VNewQ(1);
  VSimR(i) = VNewQ(2);
end
VNonDelayedH = 1 - VSimR / VSimR(end);
VH = interp1(VTimeStamp, VNonDelayedH, VTimeStamp - nonAccumulatorDelay, ...
  'nearest', 'extrap');