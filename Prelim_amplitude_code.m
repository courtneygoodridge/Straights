% load in data
data = csvread('avgtimecourse.csv', 1, 1);
%data = csvread('avgtimecourse.csv', 1, 1); % data
frames = data(:,1); % number of frames 

% standard plotting data - -2 example
% figure
% plot(frames, data(:,2))
% axis([0 250 -0.30 0.30])
% title('-2 heading average yaw rate change time series')
% xlabel('Frames');
% ylabel('Yaw Rate Change')
% legend('Yaw Rate Change')
% grid on

%%%%% normal thresholding to find peaks (for plus headings?)

% [~,locs_ResponseStart] = findpeaks(data,'MinPeakHeight',-0.01,'MinPeakDistance',50);
                                
% inverted thresholding to find peak troughs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 0 heading %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zerodata = data(:,6);
[~,zeroPeakResponse] = findpeaks(zerodata,'MinPeakHeight',0.04,'MinPeakDistance',10); % find the response peak/trough: was originally 0.05, 30

limit = 0.01;                                    
indx = 1;
limitExceeded = false; % limit is not exceeded
while limitExceeded == false
    if abs(zerodata(indx)) >= limit % if yaw rate change is above threshold 
        limitExceeded = true; % limit is exceeded
    else
        break
    end
    indx = indx + 1;
end % first point before the trough

zeroresponseSTART = indx; % this indx is the response start

while limitExceeded == true % the limit is exceeded
    if abs(zerodata(indx)) <= limit % if yaw rate change is less than or equal to the limit
         limitExceeded = false; % limit is not exceeded
    end
    indx = indx + 1;
end % first point after the trough 

zeroresponseEND = indx; % response has ended

% smoothing the signal 
smoothzerodata = sgolayfilt(zerodata,7,21);

% response values of the smoothed data
[val_zeroPeakResponse, val_zeroresponseSTART, val_zeroresponseEND] = deal(smoothzerodata(zeroPeakResponse), smoothzerodata(zeroresponseSTART), smoothzerodata(zeroresponseEND));

% average fall and rise times

avg_riseTimezero = zeroresponseEND - zeroPeakResponse; % Average Rise time
avg_fallTimezero = zeroPeakResponse - zeroresponseSTART; % Average Fall time

avg_riseLevelzero = val_zeroresponseEND - val_zeroPeakResponse;  % Average Rise Level
avg_fallLevelzero = val_zeroPeakResponse - val_zeroresponseSTART;  % Average Fall Level

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% minus values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%-2 heading %%%%%%%%%

minus2data_inverted = -data(:,2);
[~,minus2PeakResponse] = findpeaks(minus2data_inverted,'MinPeakHeight',0.04,'MinPeakDistance',10); % find the response peak/trough

minus2data = data(:,2);
limit = 0.01;                                    
indx = 1;
limitExceeded = false; % limit is not exceeded
while limitExceeded == false
    if abs(minus2data(indx)) > limit % if yaw rate change is above threshold 
        limitExceeded = true; % limit is exceeded
    end
    indx = indx + 1;
end % first point before the trough

minus2responseSTART = indx; % this indx is the response start

while limitExceeded == true % the limit is exceeded
    if abs(minus2data(indx)) < limit % if yaw rate change is less than or equal to the limit
         limitExceeded = false; % limit is not exceeded
    end
    indx = indx + 1;
end % first point after the trough 

minus2responseEND = indx; % response has ended

% plotting average peak response trough on time series

% figure
% hold on 
% plot(frames,minus2data)
% plot(minus2PeakResponse,minus2data(minus2PeakResponse),'rs','MarkerFaceColor','b')
% plot(minus2responseSTART,minus2data(minus2responseSTART), 'rv','MarkerFaceColor','r')
% plot(minus2responseEND,minus2data(minus2responseEND),'rv','MarkerFaceColor','k')
% axis([0 250 -0.30 0.30])
% grid on
% legend('Yaw Rate', 'Peak Response', 'Response Start', 'Response end')
% xlabel('Frames');
% ylabel('Yaw Rate Change')
% title('-2 heading average time series')

% smoothing the signal 

smoothminus2data = sgolayfilt(minus2data,7,21);

% response values of the smoothed data

[val_minus2PeakResponse, val_minus2responseSTART, val_minus2responseEND] = deal(smoothminus2data(minus2PeakResponse), smoothminus2data(minus2responseSTART), smoothminus2data(minus2responseEND));

% average fall and rise times

avg_riseTimeminus2 = minus2responseEND - minus2PeakResponse; % Average Rise time
avg_fallTimeminus2 = minus2PeakResponse - minus2responseSTART; % Average Fall time

avg_riseLevelminus2 = val_minus2responseEND - val_minus2PeakResponse;  % Average Rise Level
avg_fallLevelminus2 = val_minus2PeakResponse - val_minus2responseSTART;  % Average Fall Level

%%%%%%%% - 1.5 heading %%%%%%%

minus1_5data_inverted = -data(:,3);
[~,minus1_5PeakResponse] = findpeaks(minus1_5data_inverted,'MinPeakHeight',0.04,'MinPeakDistance',10); % find the response peak/trough

minus1_5data = data(:,3);
limit = 0.01;                                    
indx = 1;
limitExceeded = false; % limit is not exceeded
while limitExceeded == false
    if abs(minus1_5data(indx)) > limit % if yaw rate change is above threshold 
        limitExceeded = true; % limit is exceeded
    end
    indx = indx + 1;
end % first point before the trough

minus1_5responseSTART = indx; % this indx is the response start

while limitExceeded == true % the limit is exceeded
    if abs(minus1_5data(indx)) <= limit % if yaw rate change is less than or equal to the limit
         limitExceeded = false; % limit is not exceeded
    end
    indx = indx + 1;
end % first point after the trough 

minus1_5responseEND = indx; % response has ended

% plotting average peak response on time series

% figure
% hold on 
% plot(frames,minus1_5data)
% plot(minus2PeakResponse,minus1_5data(minus1_5PeakResponse),'rs','MarkerFaceColor','b')
% plot(minus1_5responseSTART,minus1_5data(minus1_5responseSTART), 'rv','MarkerFaceColor','r')
% plot(minus1_5responseEND,minus1_5data(minus1_5responseEND),'rv','MarkerFaceColor','k')
% axis([0 250 -0.30 0.30])
% grid on
% legend('Yaw Rate', 'Peak Response', 'Response Start', 'Response end')
% xlabel('Frames');
% ylabel('Yaw Rate Change')
% title('-1.5 heading average time series')

% smoothing the signal 
smoothminus1_5data = sgolayfilt(minus1_5data,7,21);

% response values of the smoothed data

[val_minus1_5PeakResponse, val_minus1_5responseSTART, val_minus1_5responseEND] = deal(smoothminus1_5data(minus1_5PeakResponse), smoothminus1_5data(minus1_5responseSTART), smoothminus1_5data(minus1_5responseEND));

% average fall and rise times

avg_riseTimeminus1_5 = minus1_5responseEND - minus1_5PeakResponse; % Average Rise time
avg_fallTimeminus1_5 = minus1_5PeakResponse - minus1_5responseSTART; % Average Fall time

avg_riseLevelminus1_5 = val_minus1_5responseEND - val_minus1_5PeakResponse;  % Average Rise Level
avg_fallLevelminus1_5 = val_minus1_5PeakResponse - val_minus1_5responseSTART;  % Average Fall Level

%%%%%%%%% -1 heading %%%%%%%%%

minus1data_inverted = -data(:,4);
[~,minus1PeakResponse] = findpeaks(minus1data_inverted,'MinPeakHeight',0.04,'MinPeakDistance',10); % find the response peak/trough

minus1data = data(:,4);
limit = 0.01;                                    
indx = 1;
limitExceeded = false; % limit is not exceeded
while limitExceeded == false
    if abs(minus1data(indx)) > limit % if yaw rate change is above threshold 
        limitExceeded = true; % limit is exceeded
    end
    indx = indx + 1;
end % first point before the trough

minus1responseSTART = indx; % this indx is the response start

while limitExceeded == true % the limit is exceeded
    if abs(minus1data(indx)) <= limit % if yaw rate change is less than or equal to the limit
         limitExceeded = false; % limit is not exceeded
    end
    indx = indx + 1;
end % first point after the trough 

minus1responseEND = indx; % response has ended

% smoothing the signal for -1 heading 
smoothminus1data = sgolayfilt(minus1data,7,21);

% response values of the smoothed data
[val_minus1PeakResponse, val_minus1responseSTART, val_minus1responseEND] = deal(smoothminus1data(minus1PeakResponse), smoothminus1data(minus1responseSTART), smoothminus1data(minus1responseEND));

% average fall and rise times
avg_riseTimeminus1 = minus1responseEND - minus1PeakResponse; % Average Rise time
avg_fallTimeminus1 = minus1PeakResponse - minus1responseSTART; % Average Fall time

avg_riseLevelminus1 = val_minus1responseEND - val_minus1PeakResponse;  % Average Rise Level
avg_fallLevelminus1 = val_minus1PeakResponse - val_minus1responseSTART;  % Average Fall Level

%%%%%%%%% -0.5 heading %%%%%%%%%

minus0_5data_inverted = -data(:,5);
[~,minus0_5PeakResponse] = findpeaks(minus0_5data_inverted,'MinPeakHeight',0.04,'MinPeakDistance',10); % find the response peak/trough

minus0_5data = data(:,5);
limit = 0.01;                                    
indx = 1;
limitExceeded = false; % limit is not exceeded
while limitExceeded == false
    if abs(minus0_5data(indx)) > limit % if yaw rate change is above threshold 
        limitExceeded = true; % limit is exceeded
    end
    indx = indx + 1;
end % first point before the trough

minus0_5responseSTART = indx; % this indx is the response start

while limitExceeded == true % the limit is exceeded
    if abs(minus0_5data(indx)) <= limit % if yaw rate change is less than or equal to the limit
         limitExceeded = false; % limit is not exceeded
    end
    indx = indx + 1;
end % first point after the trough 

minus0_5responseEND = indx; % response has ended

% smoothing the signal for -1 heading 
smoothminus0_5data = sgolayfilt(minus0_5data,7,21);

% response values of the smoothed data
[val_minus0_5PeakResponse, val_minus0_5responseSTART, val_minus0_5responseEND] = deal(smoothminus0_5data(minus0_5PeakResponse), smoothminus0_5data(minus0_5responseSTART), smoothminus0_5data(minus0_5responseEND));

% average fall and rise times
avg_riseTimeminus0_5 = minus0_5responseEND - minus0_5PeakResponse; % Average Rise time
avg_fallTimeminus0_5 = minus0_5PeakResponse - minus0_5responseSTART; % Average Fall time

avg_riseLevelminus0_5 = val_minus0_5responseEND - val_minus0_5PeakResponse;  % Average Rise Level
avg_fallLevelminus0_5 = val_minus0_5PeakResponse - val_minus0_5responseSTART;  % Average Fall Level

%%%%%% plotting smooth data with average rise and fall %%%%%%

figure
hold on
plot(frames,smoothminus2data,'r')
plot(frames,smoothminus1_5data, 'y')
plot(frames,smoothminus1data,'b')
plot(frames,smoothminus0_5data, 'g')
plot(frames,smoothzerodata, 'k')
% -2 %
plot(minus2PeakResponse,smoothminus2data(minus2PeakResponse),'rs','MarkerFaceColor','b')
plot(minus2responseSTART,smoothminus2data(minus2responseSTART), 'rv','MarkerFaceColor','r')
plot(minus2responseEND,smoothminus2data(minus2responseEND),'rv','MarkerFaceColor','k')
% -1.5 %
plot(minus1_5PeakResponse,smoothminus1_5data(minus1_5PeakResponse),'rs','MarkerFaceColor','b')
plot(minus1_5responseSTART,smoothminus1_5data(minus1_5responseSTART), 'rv','MarkerFaceColor','r')
plot(minus1_5responseEND,smoothminus1_5data(minus1_5responseEND),'rv','MarkerFaceColor','k')
% -1 %
plot(minus1PeakResponse,smoothminus1data(minus1PeakResponse),'rs','MarkerFaceColor','b')
plot(minus1responseSTART,smoothminus1data(minus1responseSTART), 'rv','MarkerFaceColor','r')
plot(minus1responseEND,smoothminus1data(minus1responseEND),'rv','MarkerFaceColor','k')
% - 0.5 %
plot(minus0_5PeakResponse,smoothminus0_5data(minus0_5PeakResponse),'rs','MarkerFaceColor','b')
plot(minus0_5responseSTART,smoothminus0_5data(minus0_5responseSTART), 'rv','MarkerFaceColor','r')
plot(minus0_5responseEND,smoothminus0_5data(minus0_5responseEND),'rv','MarkerFaceColor','k')
% 0 %
% plot(zeroPeakResponse,smoothzerodata(zeroPeakResponse),'rs','MarkerFaceColor','b')
% plot(zeroresponseSTART,smoothzerodata(zeroresponseSTART), 'rv','MarkerFaceColor','r')
% plot(zeroresponseEND,smoothzerodata(zeroresponseEND),'rv','MarkerFaceColor','k')
axis([0 151 -0.30 0.30])
grid on
xlabel('Frames')
ylabel('Yaw Rate Change')
legend('-2 heading', '-1.5 heading', '-1 heading', '-0.5 heading', 'straight heading', 'Peak Response', 'Response Start', 'Response end')
title('Filtered Yaw Rate Signal for negative heading conditions')

% fall annotations for -2 heading
% % dim = [.50 .45 0 0 ];
% % str = sprintf('Average fall time is %f frames', avg_fallTimeminus2);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red', 'FontSize', 7);
% % 
% % dim = [.50 .41 0 0 ];
% % str = sprintf('Average decreased change in yaw rate is %f', avg_fallLevelminus2);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red', 'FontSize', 7);
% % 
% % % rise annotations for -2 heading
% % dim = [.50 .37 0 0 ]; 
% % str = sprintf('Average increased change in yaw rate is %f', avg_riseLevelminus2);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red', 'FontSize', 7);
% % 
% % dim = [.50 .33 0 0 ];
% % str = sprintf('Average rise time is %f frames', avg_riseTimeminus2);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red', 'FontSize', 7);
% % 
% % 
% % 
% % % fall annotations for -1.5 heading
% % dim = [.50 .29 0 0 ];
% % str = sprintf('Average fall time is %f frames', avg_fallTimeminus1_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','yellow', 'FontSize', 7);
% % 
% % dim = [.50 .25 0 0 ];
% % str = sprintf('Average yaw rate change decrease: %f', avg_fallLevelminus1_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','yellow', 'FontSize', 7);
% % 
% % % rise annotations for -1.5 heading
% % dim = [.50 .21 0 0 ]; 
% % str = sprintf('Average increased change in yaw rate is %f', avg_riseLevelminus1_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','yellow', 'FontSize', 7);
% % 
% % dim = [.50 .17 0 0 ];
% % str = sprintf('Average rise time is %f frames', avg_riseTimeminus1_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','yellow', 'FontSize', 7);
% % 
% % 
% % % fall annotations for -1 heading
% % dim = [.70 .45 0 0 ];
% % str = sprintf('Average fall time is %f frames', avg_fallTimeminus1);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue', 'FontSize', 6.5);
% % 
% % dim = [.70 .41 0 0 ];
% % str = sprintf('Average decreased change in yaw rate is %f', avg_fallLevelminus1);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue', 'FontSize', 6.5);
% % 
% % % rise annotations for -1 heading
% % dim = [.70 .37 0 0 ];
% % str = sprintf('Average increased change in yaw rate is %f', avg_riseLevelminus1);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue', 'FontSize', 6.5);
% % 
% % dim = [.70 .33 0 0 ];
% % str = sprintf('Average rise time is %f frames', avg_riseTimeminus1);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue', 'FontSize', 6.5);
% % 
% % 
% % 
% % % fall annotations for -0.5 heading
% % dim = [.70 .29 0 0 ];
% % str = sprintf('Average fall time is %f frames', avg_fallTimeminus0_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','green', 'FontSize', 6.5);
% % 
% % dim = [.70 .25 0 0 ];
% % str = sprintf('Average yaw rate change decrease: %f', avg_fallLevelminus0_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','green', 'FontSize', 6.5);
% % 
% % % rise annotations for -0,5 heading
% % dim = [.70 .21 0 0 ];
% % str = sprintf('Average yaw rate change increase: %f', avg_riseLevelminus0_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','green', 'FontSize', 6.5);
% % 
% % dim = [.70 .17 0 0 ];
% % str = sprintf('Average rise time is %f frames', avg_riseTimeminus0_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','green', 'FontSize', 6.5);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plus values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% 0.5 %%%%%%%%%%

plus0_5data = data(:,7);
[~,plus0_5PeakResponse] = findpeaks(plus0_5data,'MinPeakHeight',0.04,'MinPeakDistance',10);
                                
% inverted thresholding to find peak troughs

limit = 0.01;                                    
indx = 1;
limitExceeded = false; % limit is not exceeded
while limitExceeded == false
    if plus0_5data(indx) > limit % if yaw rate change is above threshold 
        limitExceeded = true; % limit is exceeded
    end
    indx = indx + 1;
end % first point before the trough

plus0_5responseSTART = indx; % this indx is the response start

while limitExceeded == true % the limit is exceeded
    if plus0_5data(indx) < limit % if yaw rate change is less than or equal to the limit
         limitExceeded = false; % limit is not exceeded
    end
    indx = indx + 1;
end % first point after the trough 

plus0_5responseEND = indx; % response has ended

% plot average peak response trough on time series
figure
hold on 
plot(frames,plus0_5data)
plot(plus0_5PeakResponse,plus0_5data(plus0_5PeakResponse),'rs','MarkerFaceColor','b')
plot(plus0_5responseSTART,plus0_5data(plus0_5responseSTART), 'rv','MarkerFaceColor','r')
plot(plus0_5responseEND,plus0_5data(plus0_5responseEND),'rv','MarkerFaceColor','k')
axis([0 151 -0.30 0.30])
grid on
legend('Yaw Rate', 'Peak Response', 'Response Start', 'Response end')
xlabel('Frames');
ylabel('Yaw Rate Change')
title('+0.5 heading average time series')

% smoothing the signal for -1 heading 
smoothplus0_5data = sgolayfilt(plus0_5data,7,21);

% response values of the smoothed data
[val_plus0_5PeakResponse, val_plus0_5responseSTART, val_plus0_5responseEND] = deal(smoothplus0_5data(plus0_5PeakResponse), smoothplus0_5data(plus0_5responseSTART), smoothplus0_5data(plus0_5responseEND));

% average fall and rise times

avg_riseTimeplus0_5 = plus0_5PeakResponse - plus0_5responseSTART ; % Average Rise time
avg_fallTimeplus0_5 = plus0_5responseEND - plus0_5PeakResponse; % Average Fall time

avg_riseLevelplus0_5 = val_plus0_5PeakResponse - val_plus0_5responseSTART;  % Average Rise Level
avg_fallLevelplus0_5 = val_plus0_5PeakResponse - val_plus0_5responseEND;  % Average Fall Level

%%%%%%%%%% +1 heading %%%%%%%%%%

% finding peaks
plus1data = data(:,8);
[~,plus1PeakResponse] = findpeaks(plus1data,'MinPeakHeight',0.04,'MinPeakDistance',10);
                                
% inverted thresholding to find peak troughs

limit = 0.01;                                    
indx = 1;
limitExceeded = false; % limit is not exceeded
while limitExceeded == false
    if plus1data(indx) > limit % if yaw rate change is above threshold 
        limitExceeded = true; % limit is exceeded
    end
    indx = indx + 1;
end % first point before the trough

plus1responseSTART = indx; % this indx is the response start

while limitExceeded == true % the limit is exceeded
    if plus1data(indx) <= limit % if yaw rate change is less than or equal to the limit
         limitExceeded = false; % limit is not exceeded
    end
    indx = indx + 1;
end % first point after the trough 

plus1responseEND = indx; % response has ended

% plot average peak response trough on time series
% figure
% hold on 
% plot(frames,plus1data)
% plot(plus1PeakResponse,plus1data(plus1PeakResponse),'rs','MarkerFaceColor','b')
% plot(plus1responseSTART,plus1data(plus1responseSTART), 'rv','MarkerFaceColor','r')
% plot(plus1responseEND,plus1data(plus1responseEND),'rv','MarkerFaceColor','k')
% axis([0 250 -0.30 0.30])
% grid on
% legend('Yaw Rate', 'Peak Response', 'Response Start', 'Response end')
% xlabel('Frames');
% ylabel('Yaw Rate Change')
% title('+1 heading average time series')

% smoothing the signal for -1 heading 
smoothplus1data = sgolayfilt(plus1data,7,21);

% response values of the smoothed data
[val_plus1PeakResponse, val_plus1responseSTART, val_plus1responseEND] = deal(smoothplus1data(plus1PeakResponse), smoothplus1data(plus1responseSTART), smoothplus1data(plus1responseEND));

% average fall and rise times

avg_riseTimeplus1 = plus1PeakResponse - plus1responseSTART ; % Average Rise time
avg_fallTimeplus1 = plus1responseEND - plus1PeakResponse; % Average Fall time

avg_riseLevelplus1 = val_plus1PeakResponse - val_plus1responseSTART;  % Average Rise Level
avg_fallLevelplus1 = val_plus1PeakResponse - val_plus1responseEND;  % Average Fall Level

%%%%%%%%%% 1.5 %%%%%%%%%

plus1_5data = data(:,9);
[~,plus1_5PeakResponse] = findpeaks(plus1_5data,'MinPeakHeight',0.04,'MinPeakDistance',10);
                                
% inverted thresholding to find peak troughs

limit = 0.01;                                    
indx = 1;
limitExceeded = false; % limit is not exceeded
while limitExceeded == false
    if plus1_5data(indx) > limit % if yaw rate change is above threshold 
        limitExceeded = true; % limit is exceeded
    end
    indx = indx + 1;
end % first point before the trough

plus1_5responseSTART = indx; % this indx is the response start

while limitExceeded == true % the limit is exceeded
    if plus1_5data(indx) <= limit % if yaw rate change is less than or equal to the limit
         limitExceeded = false; % limit is not exceeded
    end
    indx = indx + 1;
end % first point after the trough 

plus1_5responseEND = indx; % response has ended

% plot average peak response trough on time series
% figure
% hold on 
% plot(frames,plus1_5data)
% plot(plus1_5PeakResponse,plus1_5data(plus1_5PeakResponse),'rs','MarkerFaceColor','b')
% plot(plus1_5responseSTART,plus1_5data(plus1_5responseSTART), 'rv','MarkerFaceColor','r')
% plot(plus1_5responseEND,plus1_5data(plus1_5responseEND),'rv','MarkerFaceColor','k')
% axis([0 151 -0.30 0.30])
% grid on
% legend('Yaw Rate', 'Peak Response', 'Response Start', 'Response end')
% xlabel('Frames');
% ylabel('Yaw Rate Change')
% title('+1.5 heading average time series')

% smoothing the signal for -1.5 heading 
smoothplus1_5data = sgolayfilt(plus1_5data,7,21);

% response values of the smoothed data
[val_plus1_5PeakResponse, val_plus1_5responseSTART, val_plus1_5responseEND] = deal(smoothplus1_5data(plus1_5PeakResponse), smoothplus1_5data(plus1_5responseSTART), smoothplus1_5data(plus1_5responseEND));

% average fall and rise times

avg_riseTimeplus1_5 = plus1_5PeakResponse - plus1_5responseSTART ; % Average Rise time
avg_fallTimeplus1_5 = plus1_5responseEND - plus1_5PeakResponse; % Average Fall time

avg_riseLevelplus1_5 = val_plus1_5PeakResponse - val_plus1_5responseSTART;  % Average Rise Level
avg_fallLevelplus1_5 = val_plus1_5PeakResponse - val_plus1_5responseEND;  % Average Fall Level

%%%%%%%%% +2 heading %%%%%%%%%

% finding peaks
plus2data = data(:,10);
[~,plus2PeakResponse] = findpeaks(plus2data,'MinPeakHeight',0.04,'MinPeakDistance',10);

limit = 0.01;                                    
indx = 1;
limitExceeded = false; % limit is not exceeded
while limitExceeded == false
    if plus2data(indx) > limit % if yaw rate change is above threshold 
        limitExceeded = true; % limit is exceeded
    end
    indx = indx + 1;
end % first point before the trough

plus2responseSTART = indx; % this indx is the response start

while limitExceeded == true % the limit is exceeded
    if plus2data(indx) <= limit % if yaw rate change is less than or equal to the limit
         limitExceeded = false; % limit is not exceeded
    end
    indx = indx + 1;
end % first point after the trough 

plus2responseEND = indx; % response has ended

% plot average peak response trough on time series

% figure
% hold on 
% plot(frames,plus2data)
% plot(plus2PeakResponse,plus2data(plus2PeakResponse),'rs','MarkerFaceColor','b')
% plot(plus2responseSTART,plus2data(plus2responseSTART), 'rv','MarkerFaceColor','r')
% plot(plus2responseEND,plus2data(plus2responseEND),'rv','MarkerFaceColor','k')
% axis([0 250 -0.30 0.30])
% grid on
% legend('Yaw Rate', 'Peak Response', 'Response Start', 'Response end')
% xlabel('Frames');
% ylabel('Yaw Rate Change')
% title('+2 heading average time series')

% smoothing the signal for +2 heading 
smoothplus2data = sgolayfilt(plus2data,7,21);

% response values of the smoothed data
[val_plus2PeakResponse, val_plus2responseSTART, val_plus2responseEND] = deal(smoothplus2data(plus2PeakResponse), smoothplus2data(plus2responseSTART), smoothplus2data(plus2responseEND));

% average fall and rise times

avg_riseTimeplus2 = plus2PeakResponse - plus2responseSTART ; % Average Rise time
avg_fallTimeplus2 = plus2responseEND - plus2PeakResponse; % Average Fall time

avg_riseLevelplus2 = val_plus2PeakResponse - val_plus2responseSTART;  % Average Rise Level
avg_fallLevelplus2 = val_plus2PeakResponse - val_plus2responseEND;  % Average Fall Level

%%%%%% plotting smooth data with average rise and fall %%%%%%

figure
hold on
plot(frames,smoothplus2data,'r')
plot(frames,smoothplus1_5data, 'y')
plot(frames,smoothplus1data,'b')
plot(frames,smoothplus0_5data, 'g')
plot(frames,smoothzerodata, 'k')
% +2 %
plot(plus2PeakResponse,smoothplus2data(plus2PeakResponse),'rs','MarkerFaceColor','b')
plot(plus2responseSTART,smoothplus2data(plus2responseSTART), 'rv','MarkerFaceColor','r')
plot(plus2responseEND,smoothplus2data(plus2responseEND),'rv','MarkerFaceColor','k')
% +1.5 %
plot(plus1_5PeakResponse,smoothplus1_5data(plus1_5PeakResponse),'rs','MarkerFaceColor','b')
plot(plus1_5responseSTART,smoothplus1_5data(plus1_5responseSTART), 'rv','MarkerFaceColor','r')
plot(plus1_5responseEND,smoothplus1_5data(plus1_5responseEND),'rv','MarkerFaceColor','k')
% +1 %
plot(plus1PeakResponse,smoothplus1data(plus1PeakResponse),'rs','MarkerFaceColor','b')
plot(plus1responseSTART,smoothplus1data(plus1responseSTART), 'rv','MarkerFaceColor','r')
plot(plus1responseEND,smoothplus1data(plus1responseEND),'rv','MarkerFaceColor','k')
% +0.5 %
plot(plus0_5PeakResponse,smoothplus0_5data(plus0_5PeakResponse),'rs','MarkerFaceColor','b')
plot(plus0_5responseSTART,smoothplus0_5data(plus0_5responseSTART), 'rv','MarkerFaceColor','r')
plot(plus0_5responseEND,smoothplus0_5data(plus0_5responseEND),'rv','MarkerFaceColor','k')
% 0 %
% plot(zeroPeakResponse,smoothzerodata(zeroPeakResponse),'rs','MarkerFaceColor','b')
% plot(zeroresponseSTART,smoothzerodata(zeroresponseSTART), 'rv','MarkerFaceColor','r')
% plot(zeroresponseEND,smoothzerodata(zeroresponseEND),'rv','MarkerFaceColor','k')
axis([0 151 -0.30 0.30])
grid on
xlabel('Frames')
ylabel('Yaw Rate Change')
legend('+2 heading', '+1.5 heading', '+1 heading', '+0.5 heading', 'straight heading', 'Peak Response', 'Response Start', 'Response end')
% title('Filtered Yaw Rate Signal for positive heading conditions')

% rise annotations for +2 heading
% % dim = [.15 .50 0 0 ];
% % str = sprintf('Average increased change in yaw rate is %f', avg_riseLevelplus2);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red', 'FontSize', 7);
% % 
% % dim = [.15 .45 0 0 ];
% % str = sprintf('Average rise time is %f frames', avg_riseTimeplus2);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red', 'FontSize', 7);
% % 
% % % fall annotations for +2 heading
% % dim = [.15 .40 0 0 ]; 
% % str = sprintf('Average fall time is %f frames', avg_fallTimeplus2);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red', 'FontSize', 7);
% % 
% % dim = [.15 .35 0 0 ]; 
% % str = sprintf('Average decreased change in yaw rate is %f', avg_fallLevelplus2);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red', 'FontSize', 7);
% % 
% % 
% % 
% % % rise annotations for +1.5 heading
% % dim = [.15 .30 0 0 ];
% % str = sprintf('Average yaw rate change increase: %f', avg_riseLevelplus1_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','yellow', 'FontSize', 7);
% % 
% % dim = [.15 .25 0 0 ];
% % str = sprintf('Average rise time: %f frames', avg_riseTimeplus1_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','yellow', 'FontSize', 7);
% % 
% % % fall annotations for +1.5 heading
% % dim = [.15 .20 0 0 ]; 
% % str = sprintf('Average fall time: %f frames', avg_fallTimeplus1_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','yellow', 'FontSize', 7);
% % 
% % dim = [.15 .15 0 0 ]; 
% % str = sprintf('Average yaw rate change decrease: %f', avg_fallLevelplus1_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','yellow', 'FontSize', 7);
% % 
% % 
% % 
% % % rise annotations for +1 heading
% % dim = [.40 .80 0 0 ];
% % str = sprintf('Average increased change in yaw rate is %f', avg_riseLevelplus1);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue', 'FontSize', 7);
% % 
% % dim = [.40 .75 0 0 ];
% % str = sprintf('Average rise time is %f frames', avg_riseTimeplus1);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue', 'FontSize', 7);
% % 
% % % fall annotations for +1 heading
% % dim = [.40 .70 0 0 ]; 
% % str = sprintf('Average fall time is %f frames', avg_fallTimeplus1);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue', 'FontSize', 7);
% % 
% % dim = [.40 .65 0 0 ]; 
% % str = sprintf('Average decreased change in yaw rate is %f', avg_fallLevelplus1);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue','FontSize', 7);
% % 
% % 
% % 
% % % rise annotations for +0.5 heading
% % dim = [.40 .35 0 0 ];
% % str = sprintf('Average yaw rate change increase: %f', avg_riseLevelplus0_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','green', 'FontSize', 7);
% % 
% % dim = [.40 .30 0 0 ];
% % str = sprintf('Average rise time: %f frames', avg_riseTimeplus0_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','green', 'FontSize', 7);
% % 
% % % fall annotations for +0.5 heading
% % dim = [.40 .25 0 0 ]; 
% % str = sprintf('Average fall time: %f frames', avg_fallTimeplus0_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','green', 'FontSize', 7);
% % 
% % dim = [.40 .20 0 0 ]; 
% % str = sprintf('Average yaw rate change decrease: %f', avg_fallLevelplus0_5);
% % annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','green', 'FontSize', 7);

%%%%% data saving %%%%%

heading = [-2; -1.5; -1; -0.5; 0.5; 1; 1.5; 2];
responsestart = [val_minus2responseSTART; val_minus1_5responseSTART; val_minus1responseSTART; val_minus0_5responseSTART; val_plus0_5responseSTART; val_plus1responseSTART; val_plus1_5responseSTART; val_minus2responseSTART]; 
responsepeak = [val_minus2PeakResponse; val_minus1_5PeakResponse; val_minus1PeakResponse; val_minus0_5PeakResponse; val_plus0_5PeakResponse; val_plus1PeakResponse; val_plus1_5PeakResponse; val_minus2PeakResponse]; 
responseend = [val_minus2responseEND; val_minus1_5responseEND; val_minus1responseEND; val_minus0_5responseEND; val_plus0_5responseEND; val_plus1responseEND; val_plus1_5responseEND; val_minus2responseEND]; 
avgyawratechangeToPeak = [avg_fallLevelminus2; avg_fallLevelminus1_5; avg_fallLevelminus1; avg_fallLevelminus0_5; avg_riseLevelplus0_5; avg_riseLevelplus1; avg_riseLevelplus1_5; avg_riseLevelplus2];
avgyawratechangetime = [avg_fallTimeminus2; avg_fallTimeminus1_5; avg_fallTimeminus1; avg_fallTimeminus0_5; avg_riseTimeminus0_5; avg_riseTimeminus1; avg_riseTimeminus1_5; avg_riseTimeminus2];

% for analysis, I have to use absolute value of avgyawratechangeToPeak/responsepeak or split them by the sign of the heading offset
magnitudedata = [heading, responsestart, responsepeak, responseend, avgyawratechangeToPeak, avgyawratechangetime]; 

csvwrite('magnitudedata.csv', magnitudedata);


