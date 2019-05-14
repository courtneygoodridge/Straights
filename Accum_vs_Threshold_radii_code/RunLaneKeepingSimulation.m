function SOutputs = RunLaneKeepingSimulation(startTime, endTime, timeStep, ...
  initialLatPos, initialHeading, longSpeed, VRoadX, VRoadY, ...
  SLinearVehicleModelParameters, SControlModelParameters, SRoadNoiseParameters)


global SControlModelStates


% time stamp and samples
sampleRate = 1 / timeStep;
VTimeStamp = startTime:timeStep:endTime;
nSamples = length(VTimeStamp);

% get some canned yaw rate noise
[SRoadNoiseParameters.VYRNoiseFilterB, SRoadNoiseParameters.VYRNoiseFilterA] = ...
   butter(SRoadNoiseParameters.iYRNoiseFilterOrder, SRoadNoiseParameters.YRNoiseFilterCutoffFreq / (sampleRate/2));
 %rng(0)
% randn("seed",0)
 VYawRateNoise = randn(size(VTimeStamp)) * SRoadNoiseParameters.yawRateNoiseStdDev;
 VYawRateNoise = filter(SRoadNoiseParameters.VYRNoiseFilterB, SRoadNoiseParameters.VYRNoiseFilterA, VYawRateNoise);
%VYawRateNoise=0; %Don't have the toolboxes for this.

% initialise
% -- simulation vectors
VX = zeros(nSamples, 1);
VY = zeros(nSamples, 1);
VY(1) = initialLatPos;
VHeading = zeros(nSamples, 1);
VHeading(1) = initialHeading;
VYawRate = zeros(nSamples, 1);
VSWAngle = zeros(nSamples, 1);
VSWRate = zeros(nSamples, 1);
MSightPointAngles = zeros(2, nSamples);
MSightPointRates = zeros(2, nSamples);
% -- other init
VqDot = zeros(2, 1);
Vq = zeros(2, 1);
timeStampAtLastAdjustment = NaN;
nAdjustments = 0;
SControlModelStates = [];
%rng(0)
%randn("seed",0)
for i = 1:nSamples
  
  if mod(i-1, floor(nSamples/20)) == 0
    fprintf('.')
  end
  
  % dynamics update
  if i > 1
    % -- Euler step
    VX(i) = VX(i-1) + ...
      cos(VHeading(i-1)) * longSpeed * timeStep;
    VY(i) = VY(i-1) + ...
      sin(VHeading(i-1)) * longSpeed * timeStep;
    VHeading(i) = VHeading(i-1) + ...
      VYawRate(i-1) * timeStep;
        % -- linear bicycle model
        VqDot = SLinearVehicleModelParameters.MLinearModel_A * Vq + ...
          SLinearVehicleModelParameters.VLinearModel_b * VSWAngle(i-1);
        Vq = Vq + VqDot * timeStep;
        % -- store yaw rate, after adding noise
%         VYawRate(i) = Vq(2) + VYawRateNoise(i);
        VYawRate(i) = Vq(2); %+ VYawRateNoise(i); %%CDM - without the filtered road noise since do not have butter.m in current toolboxes.
        %     % -- simplified lateral model
%     VYawRate(i) = steeringGain * VSWAngle(i-1);
  end
  
  % get lane position on road
  %     VLatPosOnRoad(i) = ...
  %       GetLatPosOnRoad(VX(i), VY(i), ...
  %       VHeading(i), c_VRoadX, c_VRoadY);
  
  
  % get sight point angles and rates
  % - with arbitrary road
  MSightPointAngles(:, i) = GetSightPointAngles(VTimeStamp(i), ...
    VX(i), VY(i), VHeading(i), ...
    SControlModelParameters.VSightPointDistances, VRoadX, VRoadY);
%   % - assuming straight road along X axis
%   MSightPointAngles(:, i) = -VHeading(i) - ...
%     asin(VY(i) ./ SControlModelParameters.VSightPointDistances);
  if i > 1
    MSightPointRates(:, i) = ...
      (MSightPointAngles(:, i) - ...
      MSightPointAngles(:, i-1)) / timeStep;
  end
  
  % get perceptual control error (S&G model)
  perceptualControlError = ...
    SControlModelParameters.knI * MSightPointAngles(1, i) + ...
    SControlModelParameters.knP * MSightPointRates(1, i) + ...
    SControlModelParameters.kf * MSightPointRates(2, i);
 
  
  % do control model update
  [VSWRate(i), VSWAngle(i), ...
    SControlModelParameters] = ...
    DoControlModelTimeStep(VTimeStamp, timeStep, i, ...
    perceptualControlError, SControlModelParameters);
  
end % i for loop

fprintf('\n')

% get the data from the run
SOutputs.VTimeStamp = VTimeStamp;
SOutputs.VX = VX;
SOutputs.VY = VY;
SOutputs.VHeading = VHeading;
SOutputs.VYawRate = VYawRate;
SOutputs.VSWAngle = VSWAngle;
SOutputs.VSWRate = VSWRate;
SOutputs.MSightPointAngles = MSightPointAngles;
SOutputs.MSightPointRates = MSightPointRates;
SOutputs.VP = SControlModelStates.VP;
SOutputs.VP_p = SControlModelStates.VP_p;
SOutputs.VA = SControlModelStates.VA;
SOutputs.VAdjustmentAmplitudes = SControlModelStates.Vgtilde_i;
SOutputs.ViAdjustmentOnsetSamples = SControlModelStates.ViAdjustmentOnsetSamples;