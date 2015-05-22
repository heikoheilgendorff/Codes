%% This code will use two methods to characterise the RFI events in
%% the cbass data timestream. It will save the processed data and
%% plot it up.

function RFI_Char()
cbass_startup

start_time = '13-Jun-2014:09:04:00';
%stop_time = '13-Jun-2014:23:12:25';
stop_time = '13-Jun-2014:09:12:25';

d = read_arcSouth_nojunk(start_time, stop_time, {'array.frame.utc double', ...
    'array.frame.features double', 'array.frame.received', ...
    'antenna0.roach1.utc double',  'antenna0.roach2.utc double', ...
    'antenna0.roach1.LLfreq double',  'antenna0.roach2.LLfreq double', ...
    'antenna0.roach1.RRfreq double',  'antenna0.roach2.RRfreq double', ...
    'antenna0.roach1.Qfreq double',  'antenna0.roach2.Qfreq double', ...
    'antenna0.roach1.Ufreq double',  'antenna0.roach2.Ufreq double'});

LL1 = d.antenna0.roach1.LLfreq;
LL2 = d.antenna0.roach2.LLfreq;
RR1 = d.antenna0.roach1.RRfreq;
RR2 = d.antenna0.roach2.RRfreq;

Q1 = d.antenna0.roach1.Qfreq;
Q2 = d.antenna0.roach2.Qfreq;
U1 = d.antenna0.roach1.Ufreq;
U2 = d.antenna0.roach2.Ufreq;


% Determine the intensity:
I1 = (LL1 + RR1)/2; 
I2 = (LL2 + RR2)/2; 

% Determine the polarisation:
P1 = sqrt(Q1.*Q1 + U1.*U1);
P2 = sqrt(Q2.*Q2 + U2.*U2);


%% Method 1: RMS
% Establish a bin size:

% Note: a smaller binsize results in the top 10 rms hits all being part of
% the same RFI event. Bigger bin size gets more events, but smoothes the
% rms value across a larger sample value ie possibly including more RFI
% events in one sample

binsize = 100;
nbins = lower(length(I1)/binsize);

% Determine rms for each bin:
for m = 1:nbins - 1
    rmsval_I1(m) = sqrt(var(I1((m-1)*100+1:m*100)));
    rmsval_I2(m) = sqrt(var(I2((m-1)*100+1:m*100)));
    rmsval_P1(m) = sqrt(var(P1((m-1)*100+1:m*100)));
    rmsval_P2(m) = sqrt(var(P2((m-1)*100+1:m*100)));
end % for loop

% Pick a brightness limit:
brightRmsLimit_I1 = 2*median(rmsval_I1);
brightRmsLimit_I2 = 4*median(rmsval_I2);
brightRmsLimit_P1 = 4*median(rmsval_P1);
brightRmsLimit_P2 = 4*median(rmsval_P2);

% Pick RFI events above limit:
f_I1 = find(rmsval_I1 > brightRmsLimit_I1)
f_I2 = find(rmsval_I2 > brightRmsLimit_I2);
f_P1 = find(rmsval_P1 > brightRmsLimit_P1);
f_P2 = find(rmsval_P2 > brightRmsLimit_P2);

for m=1:size(f_I1,2)
    if(f_I1(m)==1)
        tstart = d.antenna0.roach1.utc(1)-1/24/60/60;
    else
        tstart = d.antenna0.roach1.utc((f_I1(m)-1)*100)-1/24/60/60;
    end % if statement
    tstop  = d.antenna0.roach1.utc(f_I1(m)*100)+1/24/60/60;
    drfi_I1{m} = read_arcSouth(mjd2string(tstart), mjd2string(tstop));  
end % for loop

for m=1:size(f_I2,2)
    if(f_I2(m)==1)
        tstart = d.antenna0.roach1.utc(1)-1/24/60/60;
    else
        tstart = d.antenna0.roach1.utc((f_I2(m)-1)*100)-1/24/60/60;
    end % if statement
    tstop  = d.antenna0.roach1.utc(f_I2(m)*100)+1/24/60/60;
    drfi_I2{m} = read_arcSouth(mjd2string(tstart), mjd2string(tstop));  
end % for loop

for m=1:size(f_P1,2)
    if(f_P1(m)==1)
        tstart = d.antenna0.roach1.utc(1)-1/24/60/60;
    else
        tstart = d.antenna0.roach1.utc((f_P1(m)-1)*100)-1/24/60/60;
    end % if statement
    tstop  = d.antenna0.roach1.utc(f_P1(m)*100)+1/24/60/60;
    drfi_P1{m} = read_arcSouth(mjd2string(tstart), mjd2string(tstop));  
end % for loop

for m=1:size(f_P2,2)
    if(f_P2(m)==1)
        tstart = d.antenna0.roach1.utc(1)-1/24/60/60;
    else
        tstart = d.antenna0.roach1.utc((f_P2(m)-1)*100)-1/24/60/60;
    end % if statement
    tstop  = d.antenna0.roach1.utc(f_P2(m)*100)+1/24/60/60;
    drfi_P2{m} = read_arcSouth(mjd2string(tstart), mjd2string(tstop));  
end % for loop

plotfigs_I(drfi_I1)
plotfigs_I(drfi_I2)
%plotfigs_P(drfi_P1)
%plotfigs_P(drfi_P2)

end % RFI_Char


%%%  plotting figures
function plotfigs_I(drfi)
%clc
%close all
%cbass_startup

% first, let's just find the peak and see what its spectrum looks like
figure()
allspectra = [];
Intensity_freq1 = [];
Intensity1 = [];
Intensity_freq2 = [];
Intensity2 = [];

for m=1:size(drfi,2)

    LL1freq = drfi{m}.antenna0.roach1.LLfreq;
    LL2freq = drfi{m}.antenna0.roach2.LLfreq;
    RR1freq = drfi{m}.antenna0.roach1.RRfreq;
    RR2freq = drfi{m}.antenna0.roach2.RRfreq;
    Intensity_freq1{m} = (LL1freq + RR1freq)/2;
    Intensity_freq2{m} = (LL2freq + RR2freq)/2;
    
    LL1 = drfi{m}.antenna0.roach1.LL;
    LL2 = drfi{m}.antenna0.roach2.LL;
    RR1 = drfi{m}.antenna0.roach1.RR;
    RR2 = drfi{m}.antenna0.roach2.RR;
    Intensity1{m} = (LL1 + RR1)/2;
    Intensity2{m} = (LL2 + RR2)/2;
    
    aa1 = find(Intensity_freq1{m} == max(Intensity_freq1{m}));
    aa2 = find(Intensity_freq2{m} == max(Intensity_freq2{m}));
    
    
    % to visualize them (First step)
    subplot(2,1,1); plot(Intensity1{m}(aa1,:));hold on
    title('Peak Intensity Values Across All Channels: Roach1')
    xlabel('Channels')
    ylabel('Intensity')
    subplot(2,1,2); plot(Intensity2{m}(aa2,:)); hold on
    title('Peak Intensity Values Across All Channels: Roach2')
    xlabel('Channels')
    ylabel('Intensity')
    allspectra(m,:) = [Intensity1{m}(aa1,:), Intensity2{m}(aa2,:)];
    %allspectra(m,:) = [drfi{m}.Intensity(aa,:)];
    %hold on
end
hold off
%{
keyboard;

figure()
for m=1:length(drfi)
  disp('New Event');
  f = find(drfi{m}.antenna0.roach1.LLfreq == max(drfi{m}.antenna0.roach1.LLfreq));
  minInt = f-200;
  maxInt = f+200;
  if(minInt < 1)
    minInt = 1;
  end
  if(maxInt > length(drfi{m}.antenna0.roach1.LLfreq))
    maxInt = length(drfi{m}.antenna0.roach1.LLfreq);
  end
  
  maxval = max(drfi{m}.antenna0.roach1.LL(:));
  cc = [drfi{m}.antenna0.roach1.LL(f,:) , drfi{m}.antenna0.roach2.LL(f,:)];
  for mm=minInt:maxInt
     bb = [drfi{m}.antenna0.roach1.LL(mm,:) , drfi{m}.antenna0.roach2.LL(mm,:)];
     plot(bb);
     ylim([0,maxval]);
     hold on
     plot(cc, 'r-');
     txt = sprintf('Event # %d', m);
     title(txt);
     pause(0.025);
     hold off     
  end
  pause(1)
  
end

keyboard;
%}
figure()
plot(allspectra');
title('Each RFI Event Across All Channels')
ylabel('Intensity')
xlabel('Channels')
end






