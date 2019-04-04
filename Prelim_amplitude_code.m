% load in data
data = csvread('avgtimecourseGENUINE.csv', 1, 1);
%data = csvread('avgtimecourse.csv', 1, 1); % data
frames = 1:241; % number of frames 

% standard plotting data
% figure
% plot(frames,minus2data)
% axis([0 250 -0.30 0.30])
% title('-2 heading average yaw rate change time series')
% xlabel('Frames');
% ylabel('Yaw Rate Change')
% legend('Yaw Rate Change')
% grid on

%%%%% normal thresholding to find peaks (for plus headings?)

% [~,locs_ResponseStart] = findpeaks(data,'MinPeakHeight',-0.01,'MinPeakDistance',50);
                                
% inverted thresholding to find peak troughs

%%%%% 0 heading %%%%%%%

zerodata = data(:,3);
[~,zeroPeakResponse] = findpeaks(zerodata,'MinPeakHeight',0.1,'MinPeakDistance',30); % find the response peak/trough

limit = 0.005;                                    
indx = 1;
limitExceeded = false; % limit is not exceeded
while limitExceeded == false
    if abs(zerodata(indx)) > limit % if yaw rate change is above threshold 
        limitExceeded = true; % limit is exceeded
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
[val_zeroPeakResponse, val_zeroresponseSTART, val_zeroresponseEND] = deal(smoothminus2data(minus2PeakResponse), smoothminus2data(minus2responseSTART), smoothminus2data(minus2responseEND));

% average fall and rise times

avg_riseTimezero = zeroresponseEND - zeroPeakResponse; % Average Rise time
avg_fallTimezero = zeroPeakResponse - zeroresponseSTART; % Average Fall time

avg_riseLevelzero = val_zeroresponseEND - val_zeroPeakResponse;  % Average Rise Level
avg_fallLevelzero = val_zeroPeakResponse - val_zeroresponseSTART;  % Average Fall Level

%%%%% -2 heading %%%%%

minus2data_inverted = -data(:,1);
[~,minus2PeakResponse] = findpeaks(minus2data_inverted,'MinPeakHeight',0.1,'MinPeakDistance',30); % find the response peak/trough

minus2data = data(:,1);
limit = 0.005;                                    
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
    if abs(minus2data(indx)) <= limit % if yaw rate change is less than or equal to the limit
         limitExceeded = false; % limit is not exceeded
    end
    indx = indx + 1;
end % first point after the trough 

minus2responseEND = indx; % response has ended

% plot average peak response trough on time series
figure
hold on 
plot(frames,minus2data)
plot(minus2PeakResponse,minus2data(minus2PeakResponse),'rs','MarkerFaceColor','b')
plot(minus2responseSTART,minus2data(minus2responseSTART), 'rv','MarkerFaceColor','r')
plot(minus2responseEND,minus2data(minus2responseEND),'rv','MarkerFaceColor','k')
axis([0 250 -0.30 0.30])
grid on
legend('Yaw Rate', 'Peak Response', 'Response Start', 'Response end')
xlabel('Frames');
ylabel('Yaw Rate Change')
title('-2 heading average time series')

% smoothing the signal 
smoothminus2data = sgolayfilt(minus2data,7,21);

% figure
% plot(frames,minus2data,'b',frames,smoothminus2data,'r')
% axis([0 250 -0.30 0.30])
% grid on
% xlabel('Frames')
% ylabel('Yaw Rate Change')
% legend('Noisy Yaw Rate Change Signal','Filtered Signal')
% title('Filtering Noisy Yaw Rate Signal')

% response values of the smoothed data
[val_minus2PeakResponse, val_minus2responseSTART, val_minus2responseEND] = deal(smoothminus2data(minus2PeakResponse), smoothminus2data(minus2responseSTART), smoothminus2data(minus2responseEND));

% average fall and rise times

avg_riseTimeminus2 = minus2responseEND - minus2PeakResponse; % Average Rise time
avg_fallTimeminus2 = minus2PeakResponse - minus2responseSTART; % Average Fall time

avg_riseLevelminus2 = val_minus2responseEND - val_minus2PeakResponse;  % Average Rise Level
avg_fallLevelminus2 = val_minus2PeakResponse - val_minus2responseSTART;  % Average Fall Level

%%%%% -1 heading %%%%%

minus1data_inverted = -data(:,2);
[~,minus1PeakResponse] = findpeaks(minus1data_inverted,'MinPeakHeight',0.1,'MinPeakDistance',30); % find the response peak/trough

minus1data = data(:,2);
limit = 0.005;                                    
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

% plotting smooth data with average rise and fall

figure
hold on
plot(frames,smoothminus2data,'r')
plot(frames,smoothminus1data,'b')
plot(frames,smoothzerodata, 'k')
plot(minus2PeakResponse,smoothminus2data(minus2PeakResponse),'rs','MarkerFaceColor','b')
plot(minus2responseSTART,smoothminus2data(minus2responseSTART), 'rv','MarkerFaceColor','r')
plot(minus2responseEND,smoothminus2data(minus2responseEND),'rv','MarkerFaceColor','k')
plot(minus1PeakResponse,smoothminus1data(minus1PeakResponse),'rs','MarkerFaceColor','b')
plot(minus1responseSTART,smoothminus1data(minus1responseSTART), 'rv','MarkerFaceColor','r')
plot(minus1responseEND,smoothminus1data(minus1responseEND),'rv','MarkerFaceColor','k')
plot(zeroPeakResponse,smoothzerodata(zeroPeakResponse),'rs','MarkerFaceColor','b')
plot(zeroresponseSTART,smoothzerodata(zeroresponseSTART), 'rv','MarkerFaceColor','r')
plot(zeroresponseEND,smoothzerodata(zeroresponseEND),'rv','MarkerFaceColor','k')
axis([0 250 -0.30 0.30])
grid on
xlabel('Frames')
ylabel('Yaw Rate Change')
legend('-2 heading', '-1 heading', 'straight heading', 'Peak Response', 'Response Start', 'Response end')
title('Filtered Yaw Rate Signal for negative heading conditions')

% fall annotations for -2 heading
dim = [.30 .40 0 0 ];
str = sprintf('Average fall time is %f frames', avg_fallTimeminus2);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red');

dim = [.30 .35 0 0 ];
str = sprintf('Average decreased change in yaw rate is %f', avg_fallLevelminus2);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red');

% rise annotations for -2 heading
dim = [.30 .30 0 0 ]; 
str = sprintf('Average increased change in yaw rate is %f', avg_riseLevelminus2);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red');

dim = [.30 .25 0 0 ];
str = sprintf('Average rise time is %f frames', avg_riseTimeminus2);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red');

% fall annotations for -1 heading
dim = [.60 .40 0 0 ];
str = sprintf('Average fall time is %f frames', avg_fallTimeminus1);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue');

dim = [.60 .35 0 0 ];
str = sprintf('Average decreased change in yaw rate is %f', avg_fallLevelminus1);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue');

% rise annotations for -1 heading
dim = [.60 .30 0 0 ];
str = sprintf('Average increased change in yaw rate is %f', avg_riseLevelminus1);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue');

dim = [.60 .25 0 0 ];
str = sprintf('Average rise time is %f frames', avg_riseTimeminus1);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





% finding peaks
plus1data = data(:,4);
[~,plus1PeakResponse] = findpeaks(plus1data,'MinPeakHeight',0.1,'MinPeakDistance',30);
                                
% inverted thresholding to find peak troughs

%%%%% +1 heading %%%%%

limit = 0.005;                                    
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

figure
hold on 
plot(frames,plus1data)
plot(plus1PeakResponse,plus1data(plus1PeakResponse),'rs','MarkerFaceColor','b')
plot(plus1responseSTART,plus1data(plus1responseSTART), 'rv','MarkerFaceColor','r')
plot(plus1responseEND,plus1data(plus1responseEND),'rv','MarkerFaceColor','k')
axis([0 250 -0.30 0.30])
grid on
legend('Yaw Rate', 'Peak Response', 'Response Start', 'Response end')
xlabel('Frames');
ylabel('Yaw Rate Change')
title('+1 heading average time series')

% smoothing the signal for -1 heading 
smoothplus1data = sgolayfilt(plus1data,7,21);

% response values of the smoothed data
[val_plus1PeakResponse, val_plus1responseSTART, val_plus1responseEND] = deal(smoothplus1data(plus1PeakResponse), smoothplus1data(plus1responseSTART), smoothplus1data(plus1responseEND));

% average fall and rise times

avg_riseTimeplus1 = plus1PeakResponse - plus1responseSTART ; % Average Rise time
avg_fallTimeplus1 = plus1responseEND - plus1PeakResponse; % Average Fall time

avg_riseLevelplus1 = val_plus1PeakResponse - val_plus1responseSTART;  % Average Rise Level
avg_fallLevelplus1 = val_plus1PeakResponse - val_plus1responseEND;  % Average Fall Level

%%%%% +2 heading %%%%%

% finding peaks
plus2data = data(:,5);
[~,plus2PeakResponse] = findpeaks(plus2data,'MinPeakHeight',0.1,'MinPeakDistance',30);

limit = 0.005;                                    
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

% plotting smooth data with average rise and fall

figure
hold on
plot(frames,smoothplus2data,'r')
plot(frames,smoothplus1data,'b')
plot(frames, smoothzerodata,'k')
plot(plus1PeakResponse,smoothplus1data(plus1PeakResponse),'rs','MarkerFaceColor','b')
plot(plus1responseSTART,smoothplus1data(plus1responseSTART), 'rv','MarkerFaceColor','r')
plot(plus1responseEND,smoothplus1data(plus1responseEND),'rv','MarkerFaceColor','k')
plot(plus2PeakResponse,smoothplus2data(plus2PeakResponse),'rs','MarkerFaceColor','b')
plot(plus2responseSTART,smoothplus2data(plus2responseSTART), 'rv','MarkerFaceColor','r')
plot(plus2responseEND,smoothplus2data(plus2responseEND),'rv','MarkerFaceColor','k')
plot(zeroPeakResponse,smoothzerodata(zeroPeakResponse),'rs','MarkerFaceColor','b')
plot(zeroresponseSTART,smoothzerodata(zeroresponseSTART), 'rv','MarkerFaceColor','r')
plot(zeroresponseEND,smoothzerodata(zeroresponseEND),'rv','MarkerFaceColor','k')
axis([0 250 -0.30 0.30])
grid on
xlabel('Frames')
ylabel('Yaw Rate Change')
legend('+2 heading', '+1 heading', 'straight heading', 'Peak Response', 'Response Start', 'Response end')
title('Filtered Yaw Rate Signal for positive heading conditions')

% rise annotations for +2 heading
dim = [.15 .35 0 0 ];
str = sprintf('Average increased change in yaw rate is %f', avg_riseLevelplus2);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red');

dim = [.15 .30 0 0 ];
str = sprintf('Average rise time is %f frames', avg_riseTimeplus2);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red');

% fall annotations for +2 heading

dim = [.15 .25 0 0 ]; 
str = sprintf('Average fall time is %f frames', avg_fallTimeplus2);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red');

dim = [.15 .20 0 0 ]; 
str = sprintf('Average decreased change in yaw rate is %f', avg_fallLevelplus2);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','red');


% rise annotations for +1 heading
dim = [.40 .35 0 0 ];
str = sprintf('Average increased change in yaw rate is %f', avg_riseLevelplus1);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue');

dim = [.40 .30 0 0 ];
str = sprintf('Average rise time is %f frames', avg_riseTimeplus1);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue');

% fall annotations for +1 heading
dim = [.40 .25 0 0 ]; 
str = sprintf('Average fall time is %f frames', avg_fallTimeplus1);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue');

dim = [.40 .20 0 0 ]; 
str = sprintf('Average decreased change in yaw rate is %f', avg_fallLevelplus1);
annotation('textbox',dim,'String',str,'FitBoxToText','on','Color','blue');


                                
