function apply_highpass(starttime,stoptime,filename)


MAXSCAN = 4.35; % scan rate, degrees/sec?
SIGRFI = 15;

% Just look at freq for now:
d = read_arcSouth_nojunk(starttime, stoptime, {'array.frame.utc double', ...
    'array.frame.features double', 'array.frame.received', ...
    'antenna0.servo.fast_az_pos double', 'antenna0.servo.fast_el_pos double', ...
    'antenna0.roach1.utc double',  'antenna0.roach2.utc double', ...
    'antenna0.roach1.LLfreq double',  'antenna0.roach2.LLfreq double', ...
    'antenna0.roach1.RRfreq double',  'antenna0.roach2.RRfreq double', ...
    'antenna0.roach1.Qfreq double',  'antenna0.roach2.Qfreq double', ...
    'antenna0.roach1.Ufreq double',  'antenna0.roach2.Ufreq double'});

% Get intensity:
Intensity = (d.antenna0.roach1.LLfreq + d.antenna0.roach2.LLfreq + d.antenna0.roach1.RRfreq + d.antenna0.roach2.RRfreq)./4;

% Get polarization:

Q1 = d.antenna0.roach1.Qfreq;
Q2 = d.antenna0.roach2.Qfreq;
U1 = d.antenna0.roach1.Ufreq;
U2 = d.antenna0.roach2.Ufreq;

Q = (Q1 + Q2)./2;
U = (U1 + U2)./2;

Polarization = sqrt(Q.*Q + U.*U);

% Apply high pass filter:
d.antenna0.receiver.utc = d.antenna0.roach1.utc;
d.antenna0.receiver.data = [Intensity, Polarization];

d = both_filter(d, MAXSCAN,  MAXSCAN+0.2, 'cos', 0);
keyboard;

% let's look for outliers in the high-pass filtered data
rmsI = sqrt(var(d.antenna0.receiver.hi(:,1)));
rmsP = sqrt(var(d.antenna0.receiver.hi(:,2)));

sigI = abs(d.antenna0.receiver.hi(:,1))./rmsI;
sigP = abs(d.antenna0.receiver.hi(:,2))./rmsP;

rfiI = sigI > SIGRFI;


[si ei] = findStartStop(rfiI, 20);

glitches = (ei - si)  < 5;
fastrfi = ~glitches;


binsize = 100;
nbins = lower(length(Intensity)/binsize);

% Determine rms for each bin:

for m = 1:nbins - 1
    rmsval(m) = sqrt(var(Intensity((m-1)*100+1:m*100)));
end
brightRmsLimit = 4*median(rmsval)
rfiRms = rmsval > brightRmsLimit;
[ssi eei] = findStartStop(rfiRms, 1);

glitches = (ei - si)  < 5;
fastrfi = ~glitches;

ff = find(fastrfi);

for m=1:length(ff)
    rfistart = d.antenna0.receiver.utc(si(ff(m))) - 1/60/60/24;
    rfistop  = d.antenna0.receiver.utc(ei(ff(m))) + 1/60/60/24;
    
    



ff = find(fastrfi);

for m=1:length(ff)
    rfistart = d.antenna0.receiver.utc(si(ff(m))) - 1/60/60/24;
    rfistop  = d.antenna0.receiver.utc(ei(ff(m))) + 1/60/60/24;
    
    
    
    

end % function
