% SIMULATION CONSTANTS FOR STRAIGHTS

  StartTime = 0;
  EndTime = 10; %How long driver is on the road for
  TimeStep = 0.01;
  InitialOffset = 0 ; % initial lateral position of the vehicle
  InitialHeading = 0; % initial heading is 0 because the vehicle is facing straight on
  GroundSpeed = 10 ; % speed of vehicle in the simulation m/s
  LengthOfStraight = EndTime * GroundSpeed + 30; % time * speed = distance
  
%  Salvucci & Gray (2004) constant parameters from do_TestCurveDrivingSim

  NearPoint = 0.25; % s - based on values in Markkula et al (2018)
  FarPoint = 2; % s - based on values in Markkula et al (2018)
  SightPoint = [NearPoint; FarPoint] * GroundSpeed; % Distance between the near and far point in metres
  
% Model constants for threshold and acccumulator

  % Threshold
  Threshold.Accumulation = NaN; % no accumulation for threshold model
  Threshold.Perceptual_Noise = 0; % perceptual noise
  Threshold.Athreshold = .025; % threshold limit
  Threshold.Motor_Noise = 0; % motor noise
  
  % Accumulator
  Accumulator.Accumulation = 200;
  Accumulator.Perceptual_Noise = 0 ;% perceptual noise
  Accumulator.Athreshold = 1; % normalised to 1 
  Accumulator.Motor_Noise = 0 ;% motor noise
  
  % Perceptual error quantity parameters taken from Saluvvci & Gray
  % (2004)/Markkula et al (2018) 
  SGMarkkulaControlGains.knP = 0.2; % control gain for near point angle
  SGMarkkulaControlGains.knI  = 0.02; % control gain for near point rate
  SGMarkkulaControlGains.knF = 1.6; % control gain for far point rate
  
  % Following code equates to:
  % Near point rate control gain multiplied by near point visual angle
  % Near point angle control gain multiplied by near point visual angle
  % Far point rate control gain multiplied by far point visual angle
  
  % UNSURE HOW TO GENERATE VISUAL ANGLES (EQUATION 7 in Markkula et al
  % (2018)

  PerceptualControlErrorQuantity = ...
      SGMarkkulaControlGains.knI * NearPointVisualAngle +...
      SGMarkkulaControlGains.knP * NearPointVisualAngle +...
      SGMarkkulaControlGains.knF * FarPointVisualAngle;
  
  % Evidence Accumulation (without gating and leackage parameters - EQUATION 11)
  
  AccumulatorActivation = (Accumulator.Accumulation * PerceptualControlErrorQuantity) +... 
      (Accumulator.Perceptual_Noise + Accumulator.Motor_Noise);
   
  
  % Delays for intermittent controller (unsure of values)
  DelayTime.Perceptual
  DelayTime.Motor = 0.1;
  
  % Control adjustments
  t = LengthOfStraight / GroundSpeed; % distance / speed = time in seconds
  AdjustmentDuration = 0.5; % Adjustment duration in seconds
  if t <= Motor
      ControlAdjustment = 0;
  elseif t >= Motor + AdjustmentDuration
      ControlAdjustment = 1;
  end
  
  for t <= DelayTime.Motor && t => DelayTime.Motor + AdjustmentDuration
  RateOfControlChangeDuringControlAdjustment = 0;
  
 
  DelayTime.Perceptual + DelayTime.Motor + AdjustmentDuration / 2 == 0.2;
  
  
  
  % Prediction of control error 
 
  

  % Here V stands for virtual within the model simulation?
%   VTimeStamp = StartTime:TimeStep:EndTime; % Time stamp is the increments from start to end time
%   Samples = length(VTimeStamp); % Number of samples
%   VX = zeros(Samples, 1); % Virutal X coordinate 
%   VY = InitialOffset; % Virutal Y coordinate
%   VHeading = InitialHeading; % Heading for the simulation
%   VYawRate = zeros(Samples, 1);
%   VSWAngle = zeros(Samples, 1);
%   VSWRate = zeros(Samples, 1);
%   MSightPointAngles = SGControlModelParameters.Ki;
%   MSightPointRates = zeros(2, Samples);
  
% ROAD CONSTANTS FOR STRAIGHTS

  A = [0,0]; %start coordinates
  B = [0,500]; %end coordinates
  f1 = figure;
  plot(A, B)
  
% This runs through the angles and plots them
  
  Vangles = linspace(1,3,5);
  for i = 1:length(Vangles)
        deg = Vangles(i);
        rotation_angle = deg*pi/180;
  x_array = [A(1) B(2)];
  y_array = [A(2) B(1)];

  %define rotation matrix
  Rot_mat =[cos(rotation_angle) -sin(rotation_angle); sin(rotation_angle) cos(rotation_angle)]; %rotation matrix. ROtates point around origin

  Rotated_coords = Rot_mat * [x_array; y_array];

  plot(Rotated_coords(1,:),Rotated_coords(2,:),'b','linewidth',2)

  %specify straights.
  c_VRoadX = linspace(Rotated_coords(1,1),Rotated_coords(1,2));
  c_VRoadY = linspace(Rotated_coords(2,1),Rotated_coords(2,2));
  figure(99)
  clf(figure(99))
  plot(c_VRoadX, c_VRoadY, 'b')
  end
  
  