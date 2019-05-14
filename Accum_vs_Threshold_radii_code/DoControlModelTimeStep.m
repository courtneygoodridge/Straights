function [controlRate, control, SParameters] = ...
  DoControlModelTimeStep(VTimeStamp, timeStep, iSample, perceptualControlError, ...
  SParameters)

global SControlModelStates

% is this the first time step?
if isempty(SControlModelStates)
  
  % check sample numbering and regular time step (to precision) once now, 
  % assume that caller gets it right on later calls
  assert(iSample == 1)
  assert(all(abs(diff(VTimeStamp) - timeStep) < timeStep * 0.001))
  
  % set default values for any unspecified model parameters
  if ~isfield(SParameters, 'bThresholdModel')
    SParameters.bThresholdModel = false;
  end
  if ~isfield(SParameters, 'tau_s')
    SParameters.tau_s = 0;
  end
  if ~isfield(SParameters, 'tau_d')
    SParameters.tau_d = 0;
  end
  if ~isfield(SParameters, 'lambda')
    SParameters.lambda = 0;
  end
  if ~isfield(SParameters, 'sigma_n')
    SParameters.sigma_n = 0;
  end
  if ~isfield(SParameters, 'epsilon_0')
    SParameters.epsilon_0 = 0;
  end
  if ~isfield(SParameters, 'sigma_m')
    SParameters.sigma_m = 0;
  end
  if ~isfield(SParameters, 'C_0')
    SParameters.C_0 = 0;
  end
  if ~isfield(SParameters, 'Delta_min')
    SParameters.Delta_min = 0;
  end
  
  % store delays as number of samples
  SParameters.nSensoryDelaySamples = ceil(SParameters.tau_s / timeStep);
  SParameters.nMotorDelaySamples = ceil(SParameters.tau_m / timeStep);
  
  % initialise internal model states
  SControlModelStates.VA = zeros(size(VTimeStamp));
  SControlModelStates.VC = zeros(size(VTimeStamp));
  SControlModelStates.VCdot_undelayed = zeros(size(VTimeStamp));
  SControlModelStates.VCdot = zeros(size(VTimeStamp));
  SControlModelStates.VP_undelayed = zeros(size(VTimeStamp));
  SControlModelStates.VP = zeros(size(VTimeStamp));
  SControlModelStates.VP_p = zeros(size(VTimeStamp));
  SControlModelStates.Vepsilon = zeros(size(VTimeStamp));
  SControlModelStates.nAdjustments = 0;
  SControlModelStates.ViAdjustmentOnsetSamples = [];
  SControlModelStates.Vt_i = [];
  SControlModelStates.Vepsilon_i = [];
  SControlModelStates.Vepsilontilde_i = [];
  SControlModelStates.Vg_i = [];
  SControlModelStates.Vgtilde_i = [];
  
  % just set initial control value
  SControlModelStates.VP_undelayed(1) = perceptualControlError;
  SControlModelStates.VC(1) = SParameters.C_0;
  
else
  
  % this is not the first time step, so do model update
  
  
  % store undelayed perceptual control error
  SControlModelStates.VP_undelayed(iSample) = perceptualControlError;
  
  % get delayed perceptual control error
  if iSample > SParameters.nSensoryDelaySamples
    SControlModelStates.VP(iSample) = ...
      SControlModelStates.VP_undelayed(iSample - SParameters.nSensoryDelaySamples);
  end
  
  % update epsilon
  SControlModelStates.Vepsilon(iSample) = SControlModelStates.VP(iSample) - SControlModelStates.VP_p(iSample); %S&G perceptual control error - predicted error
  
  if SParameters.bThresholdModel
    % set accumulator to epsilon + a random noise term
    SControlModelStates.VA(iSample) = SControlModelStates.Vepsilon(iSample) + randn * SParameters.sigma_n;  %adding noise to prediction perceptual error
  else
    % do accumulator update
    accumulatorChange = ...
      (gammaGatingFcn(SParameters.k * SControlModelStates.Vepsilon(iSample), ...
      SParameters.epsilon_0) - ... %epsilon_0 seems to be zero
      SParameters.lambda * SControlModelStates.VA(iSample-1)) * timeStep + ...%leakage term, dependant on magnitude of current accumulator value; where is Lambda set?
      randn * SParameters.sigma_n * sqrt(timeStep); %noise, why sqrt(timestep)
    SControlModelStates.VA(iSample) = SControlModelStates.VA(iSample-1) + accumulatorChange;
  end
  
  % get elapsed time since last adjustment
  if SControlModelStates.nAdjustments > 0
    timeSinceLastAdjustmentOnset = VTimeStamp(iSample) -  ...
      SControlModelStates.Vt_i(SControlModelStates.nAdjustments);
  else
    timeSinceLastAdjustmentOnset = Inf;
  end
  
  % new adjustment?
  if abs(SControlModelStates.VA(iSample)) >= SParameters.Athreshold && ...
      timeSinceLastAdjustmentOnset >= SParameters.Delta_min
    
    % reset accumulator
    SControlModelStates.VA(iSample) = 0;
    
    % some basic housekeeping
    SControlModelStates.nAdjustments = SControlModelStates.nAdjustments + 1;
    SControlModelStates.ViAdjustmentOnsetSamples(SControlModelStates.nAdjustments) = iSample;
    SControlModelStates.Vt_i(SControlModelStates.nAdjustments) = VTimeStamp(iSample);
    
    % get magnitude of new adjustment, with and without motor noise
    epsilon_i = SControlModelStates.Vepsilon(iSample);
    g_i = SParameters.K * epsilon_i;
    epsilontilde_i = (1 + randn * SParameters.sigma_m) * epsilon_i;
    gtilde_i = SParameters.K * epsilontilde_i;
    
    % store this info
    SControlModelStates.Vepsilon_i(SControlModelStates.nAdjustments) = epsilon_i;
    SControlModelStates.Vepsilontilde_i(SControlModelStates.nAdjustments) = epsilontilde_i;
    SControlModelStates.Vg_i(SControlModelStates.nAdjustments) = g_i;
    SControlModelStates.Vgtilde_i(SControlModelStates.nAdjustments) = gtilde_i;
    
    % add new control adjustment to superposition
    ViGdotRange = iSample : min(length(VTimeStamp), ...
      iSample+length(SParameters.VGdot)-1);
    SControlModelStates.VCdot_undelayed(ViGdotRange) = ...
      SControlModelStates.VCdot_undelayed(ViGdotRange) + ...
      gtilde_i * SParameters.VGdot(1:length(ViGdotRange));
    
    % add new control error prediction to superposition
    ViHRange = iSample : min(length(VTimeStamp), ...
      iSample+length(SParameters.VH)-1);
    SControlModelStates.VP_p(ViHRange) = SControlModelStates.VP_p(ViHRange) + ...
      epsilontilde_i * SParameters.VH(1:length(ViHRange));
    
  end % if accumulator reached threshold
  
  % get delayed control rate
  if iSample > SParameters.nMotorDelaySamples
    SControlModelStates.VCdot(iSample) = ...
      SControlModelStates.VCdot_undelayed(iSample - SParameters.nMotorDelaySamples);
  end
  
  % get control
  SControlModelStates.VC(iSample) = ...
    SControlModelStates.VC(iSample-1) + SControlModelStates.VCdot(iSample-1) * timeStep;

  
end % if doing model update (rather than initialisation)


% return control information for this time step
control = SControlModelStates.VC(iSample);
controlRate = SControlModelStates.VCdot(iSample);
return


% gating function
function gamma = gammaGatingFcn(epsilon, epsilon_0)
gamma = sign(epsilon) * max(0, abs(epsilon) - epsilon_0); %epsilon_0 cancels out epsilon

