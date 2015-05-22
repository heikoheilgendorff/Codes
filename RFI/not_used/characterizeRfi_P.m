function characterizeRfi_P(starttime, stoptime, savefilename);
cbass_startup

% This code bins the timestream and determines the RMS of each bin. This in
% turn allows us to look at the top RFI events across the entire
% timestream. If we didn't bin, the top RFI events could all be part of the
% same overall event.
close all
clc

%starttime = '08-jun-2014:21:27:00';
%stoptime  = '09-jun-2014:10:52:00';
%stoptime  = '08-jun-2014:21:52:00';


d = read_arcSouth_nojunk(starttime, stoptime, {'array.frame.utc double', ...
    'array.frame.features double', 'array.frame.received', ...
    'antenna0.roach1.utc double',  'antenna0.roach2.utc double', ...
    'antenna0.roach1.LLfreq double',  'antenna0.roach2.LLfreq double', ...
    'antenna0.roach1.RRfreq double',  'antenna0.roach2.RRfreq double', ...
    'antenna0.roach1.Qfreq double',  'antenna0.roach2.Qfreq double', ...
    'antenna0.roach1.Ufreq double',  'antenna0.roach2.Ufreq double'});

% try removing the steps
% This didn't work, and caused issues on cyclops, so I removed it.

% Determine the intensity:
% I = sqrt(((Q1+Q2)/2)^2 + ((U1+U2)/2)^2) 
Q1 = d.antenna0.roach1.Qfreq;
Q2 = d.antenna0.roach2.Qfreq;
U1 = d.antenna0.roach1.Ufreq;
U2 = d.antenna0.roach2.Ufreq;

Q = (Q1 + Q2)./2;
U = (U1 + U2)./2;

Polarization = sqrt(Q.*Q + U.*U);


% Establish bin size:

% Note: a smaller binsize results in the top 10 rms hits all being part of
% the same RFI event. Bigger bin size gets more events, but smoothes the
% rms value across a larger sample value ie possibly including more RFI
% events in one sample

binsize = 100;
nbins = lower(length(Polarization)/binsize);

% Determine rms for each bin:

for m = 1:nbins - 1
    rmsval(m) = sqrt(var(Polarization((m-1)*100+1:m*100)));
end

% Sort the rms values into highest to lowest:

[rmssort I] = sort(rmsval,'descend');


top_ten = rmssort(1,1:10); % top 10 RFI rms values
top_ten_bin = I(1,1:10); % bin numbers relating to top 10 RFI rms values



%pick the RMS which are 5 sigma above the median rms
brightRmsLimit = 4*median(rmsval);

f = find(rmsval > brightRmsLimit);
% with those N points, we want to read in the full data, and look at a
% spectrum for each

for m=1:size(f,2)
    if(f(m)==1)
        tstart = d.antenna0.roach1.utc(1)-1/24/60/60;
    else
        tstart = d.antenna0.roach1.utc((f(m)-1)*100)-1/24/60/60;
    end   
    
    tstop  = d.antenna0.roach1.utc(f(m)*100)+1/24/60/60;
    drfi{m} = read_arcSouth(mjd2string(tstart), mjd2string(tstop));
   
end

% Save the variables:
drfisave = drfi;
numEvents = length(drfi);
if(numEvents >100)
    disp('splitting it up'); % splitting up into sets of 100 events (else too big)
    numFiles = ceil(numEvents/100);
    for m=1:numFiles
        if(m==numFiles)
            dd = drfisave((m-1)*100+1:numEvents);
        else
            dd = drfisave((m-1)*100+1:(m-1)*100);
        end
        newsavefile = strcat(savefilename, '_', num2str(m));
        drfi = dd;
        
        txt = sprintf('save %s drfi', newsavefile);        
        eval(txt);
    end
else
    txt = sprintf('save %s drfi', savefilename);
    eval(txt);
end


end % function
