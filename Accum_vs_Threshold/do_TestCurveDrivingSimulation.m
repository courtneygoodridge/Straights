function Out = do_TestCurveDrivingSimulation(c_initialoffset, SNoiseParameters, rotation_angle)%clearvars
% function Out = do_TestCurveDrivingSimulation(c_radius, c_initialoffset, SNoiseParameters, startTime),%clearvars

  % clear
  % close all
  % for octave
  % pkg load signal
  % pkg load control

  % SIMULATION CONSTANTS FOR CURVED RADII
%   c_startTime = 0;
%   c_endTime = 4; %We only need the time of first movement.
%   c_timeStep = 0.01;
%   c_initialLatPos = c_initialoffset; 
%   c_initialHeading = 0;
%   c_longSpeed = 10.0;%13.4;%97 / 3.6; % m/s ; mean speed in lane keeping data
  
  %CDM add occlusion time.
   %occl_dist = startTime * c_longSpeed;

%%%%%  randn("seed","reset") % This was already commented out

  % ROAD CONSTANTS FOR CURVED RADII
%   c_curveRadius = c_radius; % m ; positive is leftward curve - rightward curve doesn't work with present code
%   c_roadPointInterval = .5;%1; % m
%   c_curveArcLengthRadians = pi/2;
%   c_curveArcLengthMetres = c_curveArcLengthRadians * abs(c_curveRadius);
%   c_nRoadPoints = 1 + c_curveArcLengthMetres / c_roadPointInterval;
%   c_circleCentreX = 0;
%   c_circleCentreY = c_curveRadius;
%   c_curveStartAngle = -sign(c_curveRadius) * pi/2;
%   c_VCircleAngles = linspace(c_curveStartAngle, ...
%   c_curveStartAngle + sign(c_curveRadius) * c_curveArcLengthRadians, c_nRoadPoints);
%   c_VRoadX = c_circleCentreX + c_curveRadius * cos(c_VCircleAngles) - occl_dist; %CDM add.
%   c_VRoadY = c_circleCentreY + c_curveRadius * sin(c_VCircleAngles);

% SIMULATION CONSTANTS FOR STRAIGHTS

  c_startTime = 0;
  c_endTime = 50; %How long driver is on the road for 
  c_timeStep = 0.01;
  c_initialLatPos = c_initialoffset; % initial lateral position of the vehicle
  c_initialHeading = 0; % initial heading is 0 because the vehicle is facing straight on
  c_longSpeed = 10 ;%13.4;%97 / 3.6; % m/s ; mean speed in lane keeping data
   % CDM add occlusion time.
   % occl_dist = startTime * c_longSpeed; % occlusion will not be nescessary for straights
  c_straightlength = c_endTime * c_longSpeed + 30;

% ROAD CONSTANTS FOR STRAIGHTS
    % plotting straights of different angles from origin. 

  A = [0,0]; %start coordinates
    
  B = [0,c_straightlength]; %end coordinates
  RdSize = 5000; %granularity

  x_array = [A(1) B(2)];
  y_array = [A(2) B(1)];

  %define rotation matrix
  Rot_mat =[cos(rotation_angle) -sin(rotation_angle); sin(rotation_angle) cos(rotation_angle)]; %rotation matrix. ROtates point around origin

  Rotated_coords = Rot_mat * [x_array; y_array];

  plot(Rotated_coords(1,:),Rotated_coords(2,:),'b','linewidth',2)

  %specify straights.
  c_VRoadX = linspace(Rotated_coords(1,1),Rotated_coords(1,2),RdSize);
  c_VRoadY = linspace(Rotated_coords(2,1),Rotated_coords(2,2),RdSize);
%     
%   
%   figure(99)
%   clf(figure(99))
%   plot(c_VRoadX, c_VRoadY, 'b')

  %%
  % vehicle dynamics constants

  load LinearVehicleModels
  c_iLaneKeeping = 1;

  % road noise constants
  c_SRoadNoiseParameters.YRNoiseFilterCutoffFreq = 0.5; % Hz
  c_SRoadNoiseParameters.iYRNoiseFilterOrder = 3;
  c_SRoadNoiseParameters.yawRateNoiseStdDev = 0; % set to zero for no road noise

  % steering model constants

  % -- delays
  c_SControlModelParameters.tau_s = 0.05; %s % control delay
  c_SControlModelParameters.tau_m = 0.1; %s % motor delay
  c_nonAccumulatorDelay = ...
    c_SControlModelParameters.tau_s + c_SControlModelParameters.tau_m;

  % -- accumulator / threshold
  % ---- accumulator
  % c_SControlModelParameters.bThresholdModel = bThreshold;
  % c_SControlModelParameters.k = 200; %gain on activation function
  % c_SControlModelParameters.sigma_n = 0;%0.8; % accumulator noise (perceptu
  % c_SControlModelParameters.Athreshold = 1; %control firing threshold
  % c_SControlModelParameters.sigma_m = 0;%0.8; % motor noise
  % % ---- threshold
  c_SControlModelParameters.bThresholdModel = SNoiseParameters.bThreshold;
  c_SControlModelParameters.k = SNoiseParameters.k;
  c_SControlModelParameters.sigma_n = SNoiseParameters.sigma_n; %0.0057;
  c_SControlModelParameters.Athreshold = SNoiseParameters.Athreshold;%0.0183;
  c_SControlModelParameters.sigma_m = SNoiseParameters.sigma_m;%0.6555;

  % -- motor control
  c_SControlModelParameters.K = 1;% SG 2pt model has k params so set overarching K to 1.
    
  % -- control adjustment (G)
  c_GDuration = 0.4; % s %adjustment period
  c_GStdDev = 0.1; % s
  c_nGStdDevsOnEachSide = (c_GDuration/2) / c_GStdDev;
  c_VGTimeStamp = 0:c_timeStep:c_GDuration; %vector of timepoints during control implementation
  c_SControlModelParameters.VGdot = GetTruncatedGaussianBurstRate(...
    c_VGTimeStamp, c_GDuration/2, c_GDuration, c_nGStdDevsOnEachSide); %vector for shape of rate of change G.
  c_VGdot = cumsum(c_SControlModelParameters.VGdot * c_timeStep); %vector of cumulative amplitude across timepoints (shape of G).
  c_SControlModelParameters.VG = c_VGdot;

  % -- error prediction (H)
  c_HDuration = 2; % s %why is this not the same as G?
  c_VPredictionHTimeStamp = 0:c_timeStep:c_HDuration;
  c_VSteeringBurstForH = GetBurstContribution(c_VPredictionHTimeStamp, ...
    c_GDuration/2, c_GDuration, c_nGStdDevsOnEachSide);
  c_VH = ...
    GetHFromGWithLinearVehicleModel(...
    c_VPredictionHTimeStamp, c_VSteeringBurstForH, ...
    SLinearVehicleModelPerTask(c_iLaneKeeping).MLinearModel_A, ...
    SLinearVehicleModelPerTask(c_iLaneKeeping).VLinearModel_b, ...
    c_SControlModelParameters.tau_s + c_SControlModelParameters.tau_m); %vector of predictions across timestamp. 
  c_VH(1) = 0;
  c_VH(end) = 0;
  c_SControlModelParameters.VH = c_VH;

  % -- Salvucci & Gray constants
  c_nearPointTime = 0.25; % s
  c_farPointTime = 5; % 2s
  c_SControlModelParameters.VSightPointDistances = [c_nearPointTime; c_farPointTime] * c_longSpeed;
  c_SControlModelParameters.knP = 0.2; % 0.2 % Control gains for near point angle
  c_SControlModelParameters.knI = 0.02; %0.02; % Control gains for near point rate
  c_SControlModelParameters.kf = 1.6; %1.6 % Control gains for far p



  SSimResults = RunLaneKeepingSimulation(c_startTime, c_endTime, ...
    c_timeStep, c_initialLatPos, c_initialHeading, c_longSpeed, ...
    c_VRoadX, c_VRoadY, ...
    SLinearVehicleModelPerTask(c_iLaneKeeping), c_SControlModelParameters, ...
    c_SRoadNoiseParameters);

%
%  %% plot
%  %CDM - for comparison
%  if c_SControlModelParameters.bThresholdModel
%      figure(2)
%  else
%      figure(1)
%  end
%  
%  c_nPlots = 6;
%
%  subplot(c_nPlots, 1, 1)
%  plot(SSimResults.VTimeStamp, SSimResults.VY, 'k-')
%  set(gca, 'XLim', [c_startTime  c_endTime]); ylabel('RoadY')
%
%
%  subplot(c_nPlots, 1, 2)
%  hold on
%  plot(SSimResults.VTimeStamp, SSimResults.MSightPointAngles(1, :) * 180/pi, 'g-') %Near angle
%  plot(SSimResults.VTimeStamp, SSimResults.MSightPointRates(1, :) * 180/pi, 'b-') %near rate
%  plot(SSimResults.VTimeStamp, SSimResults.MSightPointRates(2, :) * 180/pi, 'r-') %far rate
%  set(gca, 'XLim', [c_startTime  c_endTime]); ylabel('SPoints')
%
%  subplot(c_nPlots, 1, 3)
%  hold on
%  plot(SSimResults.VTimeStamp, SSimResults.VP_p * 180/pi, 'm-', 'LineWidth', 3) %predicted perceptual control error
%  plot(SSimResults.VTimeStamp, SSimResults.VP * 180 / pi, 'k-') %received perceptual control error
%  set(gca, 'XLim', [c_startTime  c_endTime]); ylabel('P')
%
%  subplot(c_nPlots, 1, 4)
%  plot(SSimResults.VTimeStamp, SSimResults.VA, 'k-'); hold on %accumulator (essentially, difference between predicted error and received, plus noise)
%  set(gca, 'XLim', [c_startTime  c_endTime]); ylabel('A')
%
%  subplot(c_nPlots, 1, 5)
%  plot(SSimResults.VTimeStamp, SSimResults.VSWAngle * 180/pi, 'k-'); hold on %steering wheel angle
%  set(gca, 'XLim', [c_startTime  c_endTime]); ylabel('SWangle')
%
%  subplot(c_nPlots, 1, 6)
%  plot(SSimResults.VTimeStamp, SSimResults.VSWRate * 180/pi, 'k-'); hold on
%  set(gca, 'XLim', [c_startTime  c_endTime]); xlabel('Time'); ylabel('SWrate') %steering wheel rate

%plot amplitude.
%[pks idx] = findpeaks(SSimResults.VSWRate, "DoubleSided");
%deriv = diff(SSimResults.VSWRate);
%crest = find(deriv<0);
%%plot(SSimResults.VTimeStamp(idx(1)),SSimResults.VSWRate(idx(1))*180/pi,'om')
%plot(SSimResults.VTimeStamp(crest(1)),SSimResults.VSWRate(crest(1))*180/pi,'om')
%
%  figure(99)
%  hold on
%  plot(SSimResults.VX, SSimResults.VY, 'k-')
%  axis([-10 80 -10 20])
%  pause
  
  %find the first instance of SWA<>0.
  
  Out.VSWRate = SSimResults.VSWRate;
%  Out.VSWAngle = SSimResults.VSWAngle;
  Out.VTimeStamp = SSimResults.VTimeStamp;
  Out.VAdjustmentAmplitudes = SSimResults.VAdjustmentAmplitudes;
  
  


end
