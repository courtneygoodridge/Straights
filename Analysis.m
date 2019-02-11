%Author = Callum Mole
%Script to analyse and plot Ben-Lui data.
%Participants experience a series of 'pop-up' single-line bends of varying radii.
%The bends stay visible for 2s, then disappear. 
%The programme then waits for the wheel to be centred, before waiting a
%further 2s to initial the next trial and the same Euler and Position of
%the driver.
%In the Pilot there are 10 conditions, and 10 trials in each condition.

%Data cols: ExperimentTime, Trialtype_signed, global_xpos, global_zpos,
%yaw, SWA, trialradius, roadVisibilityFlag.

%radiiPool = [50, 150, 250, 900, 1100, 1300, 2500, 3000, 3500, -1]

%STEP 2.
%Process SWA and Time to get time from onset to first steering adjustment

%STEP 3.
%Use SWA signal to get amplitude (magnitude of peak of movement).


%STEP 1.
%Read in Pilot data. Separate data into trials by using the Visibility
%Flag.

raw_data = dlmread('Pilot_CDM.dat');

ttime = 2; %Bend is visible for 2s per trial.
srate = 60;
samples = ttime*srate; %will include a little bit of invisible road, but that's fine since only interested in start..
nCndts = 9; %drop straight road.
nTrials = 10;
nTotal = nCndts * nTrials;
nVars = size(raw_data,2); %number of Columns
MData = zeros(ttime*srate,nVars,nTrials,nCndts); %Matrix to Hold Parameters.
iTrials = zeros(nCndts,1); %Trial Index
sz = size(raw_data,1); %number of rows.
MProc = zeros(3,nTrials,nCndts); %SWA_t, SWA_amp, maxRate
angles = linspace(-10, 10, 5);% 5000];    
cols = {'b--';'g--';'r--';'m--';'c-';'b-';'g-';'r-';'m-';'k--'};
cols2 = {'bo';'go';'ro';'mo';'c.';'b.';'g.';'r.';'m.';'k.'};
figure(1)
clf
% subplot(2,2,1);
pick = 1;
SWrate_thresh = .05;
SWamp_thresh = -.005;
for i = 1:sz
    vflag = raw_data(i,8); %visibility flag    
    if vflag == 1 && pick == 1 %if the road is visible and I am not analysing a trial
        %r = raw_data(i,:); %pick i row.        
        trialdata = raw_data(i:i+samples-1,:);
        cndt = abs(trialdata(1,2)); %cndt
        
        if cndt < 10
            

            SWA = trialdata(:,6)*sign(trialdata(1,2));        

            SWA = smooth(smooth(SWA));
            %plot wheel angle
    %         subplot(2,2,1)
    %         plot(1:length(SWA),SWA,cols{cndt}); hold on;

            %plot diff
            dSWA = diff(SWA);
%             subplot(2,2,1)        
%             cla(subplot(2,2,1))
%             plot(1:length(dSWA),dSWA,cols{cndt}); hold on;

            iTrials(cndt) = iTrials(cndt) + 1; %increment trial count.
            MData(1:length(trialdata),:,iTrials(cndt),cndt) = trialdata; %store trial data  


            %Find amplitude and time until first action.
            %This can be much more sophisticated.
            %First action
            time = trialdata(:,1);
            start = find(dSWA>SWrate_thresh); %some arbitrary threshold to avoid noise
            maxRate = max(dSWA);

            if start %if there is something in start                        
                %backpedal until you reach zero.
                a = find(start>10); %make sure they didn't start the trial at a high SWA
                start_i = start(a(1));            
                for d = 1:20
                    rate = dSWA(start_i-d); 
                    if rate <= 0
                       start_i = start_i-d; %pick the previous frame. 
                       break
                    end
                end
                initiation = time(start_i);
                FirstSWAction = time(start_i) - time(1); %minus start of trial
                %Check on plot.
%                 plot(start_i,dSWA(start_i),'k.','MarkerSize',10)

                %If there is a response, also get amplitude.
                %Amplitude.
%                 subplot(2,2,2)
%                 cla(subplot(2,2,2))
                ddSWA = diff(dSWA(start_i:end)); %take from the start of the wheel action 
%                 plot(1:length(ddSWA),ddSWA,cols{cndt}); hold on;        
                crest = find(ddSWA<SWamp_thresh); %some arbitarty threshold, showing that you are past a peak.
                %backpedal until zero-crossing
                crest_i = crest(1);
                for d = 1:20
                    rate = ddSWA(crest_i-d);
                    if rate >= 0
                       crest_i = crest_i-d; %pick the previous frame 
                       break
                    end
                end
                plot(crest_i,ddSWA(crest_i),'b.','MarkerSize',10)

                peak_i = crest_i + start_i;
%                 subplot(2,2,1)
%                 plot(peak_i,dSWA(peak_i),'b.','MarkerSize',10)    

                %retrieve amplitude.
                SWA_amp = dSWA(peak_i) - dSWA(start_i);

            else
                FirstSWAction = 2.0; %limit case. What to input if no response? 
                %plot at end of trial
%                 plot(size(dSWA,1),0,'r.','MarkerSize',20)            
                SWA_amp = 0.0;
                maxRate = 0.0;
            end

            %record SWA_t
            MProc(1,iTrials(cndt),cndt) = FirstSWAction;        
            MProc(2,iTrials(cndt),cndt) = SWA_amp; %record amplitude
            MProc(3,iTrials(cndt),cndt) = maxRate; %record max rate         
        end
        pick = 0; %hold off picking until you're done with the trial
        
    elseif vflag == 0 && pick ==0 %once the road is invisible reset pick.                    
        pick = 1; %reset repick flag.
    end           
end

%plot average abs and derivative.
%Also plot estimate of time initiation and amplitude in same graphs as
%the predictions.

meanSWA_t = zeros(nCndts,1);
meanSWA_a = zeros(nCndts,1);
for r = 1:length(angles)
   for i = 1:nTrials
       %Time
      SWA_t = squeeze(MProc(1,i,r));
      subplot(2,1,1)
      plot(angles(r),SWA_t,cols2{r},'MarkerSize',6); hold on
      
      %Amp
      SWA_a = squeeze(MProc(2,i,r));
      subplot(2,1,2)
      plot(angles(r),log(SWA_a),cols2{r},'MarkerSize',6); hold on
   end
   %plot average.
   vSWA_t = squeeze(MProc(1,:,r));
   avg_t = mean(vSWA_t);
   meanSWA_t(r) = avg_t;
   subplot(2,1,1)
   plot(angles(r),avg_t,'kx','MarkerSize',10); hold on
   
   vSWA_a = squeeze(MProc(2,:,r));
   avg_a = mean(vSWA_a);
   meanSWA_a(r) = avg_a;
   subplot(2,1,2)
   plot(angles(r),log(avg_a),'kx','MarkerSize',10); hold on
   
end

%labels
subplot(2,1,1)
ylabel('Time at first Wheel Correction')
xlabel('Radii')

angle = linspace(-10, 10, 5);
%line of best fit.
pfit = polyfit(angles',meanSWA_t,2); 
pval = polyval(pfit,angle);
plot(angle, pval, 'k-','LineWidth',2);

%labels
subplot(2,1,2)
ylabel('Log(Amplitude)')
xlabel('Radii')

%line of best fit.
pfit = polyfit(angles',log(meanSWA_a),2); 
pval = polyval(pfit,angle);
plot(angle, pval, 'k-','LineWidth',2);
%may need to logradii





