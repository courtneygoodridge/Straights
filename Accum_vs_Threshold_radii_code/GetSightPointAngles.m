function MSightPointAngle = ...
  GetSightPointAngles(VTimeStamp, VX, VY, VHeading, VSightPointDistances, VRoadX, VRoadY)

nSightPoints = length(VSightPointDistances);
nSamples = length(VX);

for i = 1:nSamples
  
  % get sight point angles
  % -- get vectors and distances to road points
  MVectorsToRoadPoints = [VRoadX(:)-VX(i) VRoadY(:)-VY(i)];
  VRoadPointDistances = sqrt(sum(MVectorsToRoadPoints.^2, 2));
  % -- get "straight ahead" distances to road points
  VForwardVector = [cos(VHeading(i)); sin(VHeading(i))];
  VStraightAheadDistanceToRoadPoints = MVectorsToRoadPoints * VForwardVector;
  % -- set distance to road points behind driver to Inf
  VRoadPointDistances(VStraightAheadDistanceToRoadPoints < 0) = Inf;
  % -- calculate for both sight points
  for iSightPoint = 1:nSightPoints
    % find the two road points ahead closest to being the sight distance away
    VAbsErrors = abs(VRoadPointDistances - VSightPointDistances(iSightPoint));
    [~, ViRoadPointSortOrder] = sort(VAbsErrors);
    % get the sight point somewhere between these two points
    iRoadPoint1 = ViRoadPointSortOrder(1);
    iRoadPoint2 = ViRoadPointSortOrder(2);
    absError1 = VAbsErrors(iRoadPoint1);
    absError2 = VAbsErrors(iRoadPoint2);
    totalAbsError = absError1 + absError2;
    sightPointX{iSightPoint} = (absError2 * VRoadX(iRoadPoint1) + absError1 * VRoadX(iRoadPoint2)) / ...
      totalAbsError;
    sightPointY{iSightPoint} = (absError2 * VRoadY(iRoadPoint1) + absError1 * VRoadY(iRoadPoint2)) / ...
      totalAbsError;
    % get the angle to the sight point
    VVectorToSightPoint = [sightPointX{iSightPoint} - VX(i); sightPointY{iSightPoint} - VY(i)];
    VLongDistanceToSightPointInDriverRef =  VVectorToSightPoint' * VForwardVector;
    VLatDistanceToSightPointInDriverRef = ...
      VVectorToSightPoint' * [cos(VHeading(i)+pi/2); sin(VHeading(i)+pi/2)];
    MSightPointAngleUnfiltered(i, iSightPoint) = atan(VLatDistanceToSightPointInDriverRef / ...
      VLongDistanceToSightPointInDriverRef);
    
  end % iSightPoint for loop
  
  if false
    figure(100)
    clf
    hold on
    plot(VRoadX, VRoadY, 'k-')
    plot(VX, VY, 'r-')
    plot(VX(i), VY(i), 'bo')
    plot(VX(i) + [0 10*cos(VHeading(i))], VY(i) + [0 10 * sin(VHeading(i))], 'b-')
    plot([VX(i) sightPointX{1}], [VY(i) sightPointY{1}], 'g-')
%     plot([VX(2) sightPointX{2}], [VY(i) sightPointY{2}], 'm-')
    axis equal
    MSightPointAngleUnfiltered(i, :) * 180/pi
    pause
  end
  
end % i for loop

if nSamples == 1
  MSightPointAngle = MSightPointAngleUnfiltered;
else
  c_filterStdDev = 0.05;
  for iSightPoint = 1:nSightPoints
    MSightPointAngle(:, iSightPoint) = ...
      GaussianFilter(VTimeStamp, MSightPointAngleUnfiltered(:, iSightPoint), c_filterStdDev);
  end
end
