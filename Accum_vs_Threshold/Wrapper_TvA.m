%%Wrapper to Gustav Model. Threshold vs. Accumulator. CDM. 03/06/17

%Aim is to test many radii and lateral offset to see if they produce different starting times.
%First step, compare across radii, sans noise, to see if the time to SWAction differentially changes across models.

%Get parameters from Gustav's best fit.
%SBestFitThreshold = load('ThresholdModelFittingResults_ChiSquareCorrected_FurtherOptimised.mat');

Threshold.k = NaN; 
Threshold.sigma_n = 0 %0; %%%%% refers to noise
Threshold.Athreshold = .025 % .025; % 0.0183 %%%% point at which the threshold is set for this model
Threshold.sigma_m = 0 %0; %0.65547  %%%%% refers to noise
Threshold.bThreshold = true; %%%% indicates an arbitrary threshold

%SBestFitAccumulator = load('AccumulatorModelFittingResults_ChiSquareCorrected_FurtherOptimised.mat');
Accumulator.k = 200;
Accumulator.sigma_n = 0 %0; %0.8 %%%%% refers to noise
Accumulator.Athreshold = 1; %1; %%%% set at one as the threshold is overconme once enough evidence has been accumulated
Accumulator.sigma_m = 0 %0; %0.8 %%%%% refers to noise
Accumulator.bThreshold = false;

%Run model over many radii
initialoffset = 0; %for now, no offset.
Vangles = linspace(0.5, 2, 4); % array of angles - 0.2, 2, 9
NRuns = 1;
MStarts = zeros(NRuns,length(Vangles),2); %holds swaction times for each model run
MAmps = zeros(NRuns,length(Vangles),2); %holds swaction times for each model run
NoActionThreshold_radians = .0005; %threshold, below this threshold the driver does not execute a steering action durign the simulation 

for m = 1:2 %loop through threshold or accumulator model 
    for i = 1:length(Vangles)
        %loop through radii
        deg = Vangles(i);
        rotation_angle = deg*pi/180; %convert to rads

        for r = 1:NRuns          
            if m==1
                SWAction = do_TestCurveDrivingSimulation(initialoffset,Threshold, rotation_angle);
            elseif m==2
                SWAction = do_TestCurveDrivingSimulation(initialoffset,Accumulator, rotation_angle)   ;
            end  
        %        pause;
              %SWAction has VSWRate, VSWAngle, VTimeStamp.
              %Time til first action.
            nonzero = find(SWAction.VSWRate);
            if abs(rotation_angle) < NoActionThreshold_radians
                FirstSWAction = 0;
            else
                FirstSWAction = SWAction.VTimeStamp(nonzero(1));
            end
            MStarts(r,i,m) = FirstSWAction;

              %Amplitude. Find point were diff(VSWRate < 0)
        %%        [pks idx] = findpeaks(abs(SWAction.VSWRate)); %find peaks doesn't always seem reliable
        %        amp = abs(SWAction.VSWRate(idx(1))* 180/pi);
            if abs(rotation_angle) < NoActionThreshold_radians
                amp = 0;
            else
                amp = SWAction.VAdjustmentAmplitudes(1);
            end
            
        %        deriv = diff(SWAction.VSWRate);
        %        crest = find(deriv<0);
        %        amp  = SWAction.VSWRate(crest(1))*180/pi; %amp is simply height of first peak.
            MAmps(r,i,m) = amp;
        end
    end
end

MStarts
%then plot.

%%%Plot many parameterisations of threshold alongside each other?? 

figure(55);
clf
subplot(2,1,1)
set(gca, 'FontName', 'Arial')
set(gca, 'FontSize', 15)
thresh_ls = 'b-'; % 'c-o'
accum_ls = 'r-'; % 'm-o'
for r = 1:NRuns
  hold on

  plot(Vangles,squeeze(MStarts(r,:,1)),thresh_ls, 'LineWidth',1); 
  plot(Vangles,squeeze(MStarts(r,:,2)),accum_ls, 'LineWidth',1); 
  
end

%plot average.
for m=1:2
 modelstarts = squeeze(MStarts(:,:,m));
 modelstart_avg = mean(modelstarts,1);
 if m==1
   plot(Vangles,modelstart_avg,'--b','LineWidth',2);
 elseif m==2  
   plot(Vangles,modelstart_avg,'--r','LineWidth',2);
 end
end   

ylabel('First Steering RT(secs)', 'fontweight','bold', 'FontName', 'Arial', 'fontsize',16)
xlabel('Angles (degrees)', 'fontweight','bold', 'FontName', 'Arial', 'fontsize',16)
% legendstr = {'Thr','Acc'};
%%%% legend('Threshold', 'Accumulator') %Threshold, Accumulator, Threshold average, Accumulator average
% legend(legendstr,'Orientation','horizontal')

MAmps
subplot(2,1,2)
% set(gca, 'FontName', 'Arial')
% set(gca, 'FontSize', 15)
for r = 1:NRuns
  hold on
  plot(Vangles,log(squeeze(MAmps(r,:,1))),thresh_ls, 'LineWidth',1); 
  plot(Vangles,log(squeeze(MAmps(r,:,2))),accum_ls, 'LineWidth',1); 
end  
%%plot average.
for m=1:2
 modelamps = squeeze(MAmps(:,:,m));
 modelamps_avg = mean(modelamps,1);
 if m==1
   hold on
   %modelamps_avg
   plot(Vangles,log(modelamps_avg),'b-','LineWidth',2); % log(modelamps_avg)
 elseif m==2  
   plot(Vangles,log(modelamps_avg),'r-','LineWidth',2); % log(modelamps_avg)
 end
end   
ylabel('Steering Magnitude (degrees)', 'fontweight','bold', 'FontName', 'Arial', 'fontsize',16)
xlabel('Angles (degrees)', 'fontweight','bold', 'FontName', 'Arial', 'fontsize',16)
%%%% legend('Threshold', 'Accumulator') % , 'Threshold average', 'Accumulator average')
% legend(legendstr,'Orientation','horizontal')

% csvwrite('ModelMagnitudeValues.csv', MAmps)
% csvwrite('ModelRTValues.csv', MStarts)

