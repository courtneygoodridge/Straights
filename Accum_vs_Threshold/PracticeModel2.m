% Accumulator model values
Accumulator.Accumulation = 200;
Accumulator.Perceptual_Noise = 0 ;% perceptual noise
Accumulator.Athreshold = 1; % normalised to 1 
Accumulator.Motor_Noise = 0 

% Salvucci & Gray control gain
SGMarkkulaControlGains.knP = 0.2; % control gain for near point angle
SGMarkkulaControlGains.knI  = 0.02; % control gain for near point rate
SGMarkkulaControlGains.knF = 1.6; % control gain for far point rate

% Calculation of perceptual control error
PerceptualControlErrorQuantity = ...
      SGMarkkulaControlGains.knI * NearPoint +...
      SGMarkkulaControlGains.knP * NearPoint +...
      SGMarkkulaControlGains.knF * FarPoint;
  
StartTime = 0;
EndTime = 50; %How long driver is on the road for
Heading = [0,0]; % Initial heading direction
TimeStep = 0.01;
GroundSpeed = 10; % speed of simulated vehicle in m/s
StraightLength = EndTime * GroundSpeed + 30;

NearPoint = 0.25; % s - based on values in Markkula et al (2018)
FarPoint = 2; % s - based on values in Markkula et al (2018)
SightPoint = [NearPoint; FarPoint] * GroundSpeed; % Distance between the near and far point in metres
  
A = [0,0]; %start coordinates
B = [0,500]; %end coordinates
NearPoint = [0, 200];
f1 = figure;
plot(A, B) % plots straight road
hold on
f1;
plot(NearPoint(1), NearPoint(2), 'r*') %near point on straight road
hold off

% taken from original model code
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
  
  % Evidence Accumulation (without gating and leackage parameters -
  % EQUATION 11) - this is not right
  AccumulatorActivation = (Accumulator.Accumulation * PerceptualControlErrorQuantity) +... 
      (Accumulator.Perceptual_Noise + Accumulator.Motor_Noise);

% Running simulation - unsure how this works
 TimeStamp = StartTime:TimeStep:EndTime;
 Samples = length(TimeStamp);
 for i = 1:Samples
     if i > 1
     A(i) = A(i-1) + ...
       cos(Heading(i-1)) * LongSpeed * TimeStep;
     B(i) = B(i-1) + ...
      sin(Heading(i-1)) * LongSpeed * TimeStep;
     end
 end
  end
  

