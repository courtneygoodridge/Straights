%%Wrapper to Gustav Model. Threshold vs. Accumulator. CDM. 03/06/17

%Aim is to test many radii and lateral offset to see if they produce different starting times.
%First step, compare across radii, sans noise, to see if the time to SWAction differentially changes across models.

%Get parameters from Gustav's best fit.
%SBestFitThreshold = load('ThresholdModelFittingResults_ChiSquareCorrected_FurtherOptimised.mat');

Threshold.k = NaN; 
Threshold.sigma_n = 0 %0; %0.0057; %%%%% refers to noise
Threshold.Athreshold = .025 % .025 %.035%0.01829; %%%% point at which the threshold is set for this model
Threshold.sigma_m = 0 %0;%0.65547; %%%%% refers to noise
Threshold.bThreshold = true; %%%% indicates an arbitrary threshold

%SBestFitAccumulator = load('AccumulatorModelFittingResults_ChiSquareCorrected_FurtherOptimised.mat');
Accumulator.k = 200;
Accumulator.sigma_n = 0 ;%0, %0.8; %%%%% refers to noise
Accumulator.Athreshold = 1 %1; %%%% set at one as the threshold is overconme once enough evidence has been accumulated
Accumulator.sigma_m = 0 ;% 0, %0.8; %%%%% refers to noise
Accumulator.bThreshold = false;

%Run model over many radii
initialoffset = 0; %for now, no offset.
Vradii = 100:100:2000; 
NRuns = 1;
MStarts = zeros(NRuns,length(Vradii),2,3); %holds swaction times for each model run
MAmps = zeros(NRuns,length(Vradii),2,3); %holds swaction times for each model run
startTime = [0 0.5 1]; % does this manipulate visibility?
for m = 1:2
  for i = 1:length(Vradii)
    %loop through radii
    rad = Vradii(i);
    for st = 1:3
%      startTime(st)
      for r = 1:NRuns          
          if m==1
            SWAction = do_TestCurveDrivingSimulation(rad,initialoffset,Threshold, startTime(st));
          elseif m==2
            SWAction = do_TestCurveDrivingSimulation(rad,initialoffset,Accumulator, startTime(st))   ;
          end  
  %        pause;
          %SWAction has VSWRate, VSWAngle, VTimeStamp.
          %Time til first action.
          nonzero = find(SWAction.VSWRate);
          FirstSWAction = SWAction.VTimeStamp(nonzero(1));
          MStarts(r,i,m,st) = FirstSWAction;
          
          %Amplitude. Find point were diff(VSWRate < 0)
  %%        [pks idx] = findpeaks(abs(SWAction.VSWRate)); %find peaks doesn't always seem reliable
  %        amp = abs(SWAction.VSWRate(idx(1))* 180/pi);
           amp = SWAction.VAdjustmentAmplitudes(1);
  %        deriv = diff(SWAction.VSWRate);
  %        crest = find(deriv<0);
  %        amp  = SWAction.VSWRate(crest(1))*180/pi; %amp is simply height of first peak.
          MAmps(r,i,m,st) = amp;
      end
    end  
  end
end

MStarts
%then plot.

%%%Plot many parameterisations of threshold alongside each other?? 

figure(55);
clf
subplot(2,1,1)
thresh_ls = {'w--';'w-';'w--o'}; % original -> 'c--';'c-';'c--o'
accum_ls = {'w--';'w-';'w--o'}; % original -> 'm--';'m-';'m--o' 
for r = 1:NRuns
  hold on
  for st = 1:3
    plot(Vradii,squeeze(MStarts(r,:,1,st)),thresh_ls{st}, 'LineWidth',1); 
    plot(Vradii,squeeze(MStarts(r,:,2,st)),accum_ls{st}, 'LineWidth',1); 
  end  
end

%plot average.
for m=1:2
 modelstarts = squeeze(MStarts(:,:,m));
 modelstart_avg = mean(modelstarts,1);
 if m==1
   plot(Vradii,modelstart_avg,'b-','LineWidth',2);
 elseif m==2  
   plot(Vradii,modelstart_avg,'r-','LineWidth',2);
 end
end   

ylabel('Time until First Steering Wheel Movement (secs)')
xlabel('Radii (degrees)')
% legendstr = {'Thr-0s','Acc-0s','Thr-.5s','Acc-.5s','Thr-1s','Acc-1s'}; %
legendstr = {'Threshold','Accumulator'}
% legend(legendstr,'Orientation','horizontal')

MAmps
subplot(2,1,2)

for r = 1:NRuns
  hold on
  for st = 1:3
    plot(Vradii,log(squeeze(MAmps(r,:,1,st))),thresh_ls{st}, 'LineWidth',1); 
    plot(Vradii,log(squeeze(MAmps(r,:,2,st))),accum_ls{st}, 'LineWidth',1); 
  end
end  
%%plot average.
for m=1:2
 modelamps = squeeze(MAmps(:,:,m));
 modelamps_avg = mean(modelamps,1);
 if m==1
   plot(Vradii,log(modelamps_avg),'b-','LineWidth',2);
 elseif m==2  
   plot(Vradii,log(modelamps_avg),'r-','LineWidth',2);
 end
end   
ylabel('First Adjustment Amplitude log(gtilde)')
xlabel('Radii (degrees)')
legendstr = {'Threshold','Accumulator'}
legend(legendstr,'Orientation','horizontal')
% legend('Threshold','Accumulator')
% legend(legendstr,'Orientation','horizontal')
