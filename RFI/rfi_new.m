function [intensityID] = rfi_new(starttime,stoptime)

addpath(['/home/johannes/Heiko_cbass_analysis/'])
cbass_startup

intensityID = [];

[intensityID] = read_data(starttime,stoptime)
 
end % rfi_test

function [d] = read_data(starttime,stoptime)

d = read_arcSouth(starttime,stoptime)

% Open a file to dump report to:
fid = fopen('data_report.txt','w');
fprintf(fid,'Data Report \n\n');
fclose(fid);

intensity(d);
polarisation(d);
drfi_I = find_rfi(I,'I');
%drfi_P = find_rfi(P,'P');

%investigate(drfi_I1);
%investigate(drfi_I2);

%plotfigs_I(drfi_I,starttime,stoptime)

function intensity(d)
LL = d.antenna0.roach1.LL(:,:);
RR = d.antenna0.roach1.RR(:,:);
LL2 = d.antenna0.roach2.LL(:,:);
RR2 = d.antenna0.roach2.RR(:,:);
I1 = (LL+RR)/2;
I2 = (LL2+RR2)/2;
I = horzcat(I1,I2);
end % intensity

function polarisation(d)
Q1 = d.antenna0.roach1.Q(:,:);
U1 = d.antenna0.roach1.U(:,:);
Q2 = d.antenna0.roach2.Q(:,:);
U2 = d.antenna0.roach2.U(:,:);
%Q = (Q1 + Q2)./2;
%U = (U1 + U2)./2;
%P = sqrt(Q.*Q + U.*U);
P1 = sqrt(Q1.*Q1 + U1.*U1);
P2 = sqrt(Q2.*Q2 + U2.*U2);
P = horzcat(P1,P2);
end % Polarisation


function [drfi] = find_rfi(K,K2)
% now have an array with many rows and 53 columns.
% want to create a bin array with many rows and 53 columns

% Let this function know what it is analysing...
  name = [];
if K2 == 'I'
  name = 'Intensity';

elseif K2 == 'P'
  name = 'Polarisation';

end %if

% Split each channel into bins of 100 samples
binsize = 100;
nbins = lower(length(K)/binsize);

% find RMS in each channel
for m = 1:nbins - 1
	  rmsval(m,:) = sqrt(var(K((m-1)*binsize+1:m*binsize,:)));
end % for 

% find RMS brightness limit for each channel
brightRMSLim_chan = 4*median(rmsval);

% find where RMS value exceeds 4*limit in each channel
brightRMSLim_chan = repmat(brightRMSLim_chan, [size(rmsval,1) 1]);


rfiID = rmsval > brightRMSLim_chan;

indexRfi = find(sum(rfiID,2)>0);
% sum each row to see which rows had ones
% returns a matrix of ones and zeros, ones indicating where rmsval > limit

% To see what percentage of data is affected by RFI


fid = fopen('data_report.txt','a');
fprintf(fid,'Analysing %s:\n', name);
fprintf(fid,'Length of binned data: %f\n', length(rmsval));
fprintf(fid,'Length of events array: %f\n', length(indexRfi));
fprintf(fid,'Percentage of Data affected by RFI: %f\n\n', (length(indexRfi)/length(rmsval))*100);

fclose(fid)


figure()
[x, y] = find(rfiID);
hist(y(:), size(rfiID,2));
title(sprintf('Number of times each channel is flagged in %s', name));
xlabel('Channel Number');
ylabel('Amount flagged');


% with those N points, we want to read in the full data, and look at a
% spectrum for each

for m=1:size(indexRfi,1) % for each bin with RFI
    if(indexRfi(m)==1)
	tstart = d.antenna0.roach1.utc(1)-1/24/60/60;
    else
	tstart = d.antenna0.roach1.utc((indexRfi(m)-1)*100)-1/24/60/60;
    end % if
    tstop  = d.antenna0.roach1.utc(indexRfi(m)*100)+(1/24/60/60)*2;
    %tstop  = d.antenna0.roach1.utc(indexRfi(m)*100)+1/24/60/60;
    drfi{m} = read_arcSouth(mjd2string(tstart), mjd2string(tstop));
    drfi{m}.badChans = find(rfiID(indexRfi(m),:) > 0);
    end % for
          
end % find_rfi

function investigate(drfi)

for m = 1: size(drfi,2)
    LL1 = drfi{m}.antenna0.roach1.LL(:,:);
    size(LL1)
    %badc = drfi{m}.badChans
    %size(badc)
end % for
 

LL1 = drfi{5}.antenna0.roach1.LL(:,:);

%hist(LL1,size(LL1,2))
%badc =  drfi{4}.badChans
%val = LL1(:,badc-1:badc+1)
figure()
plot(LL1(10,:))
		   

end % investigate




function plotfigs_I(drfi,A,B)

% first, just find the peak and see what its spectrum looks like
figure(1)
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
    
    aa1 = find(Intensity_freq1{m} == max(Intensity_freq1{m}),1);
    aa2 = find(Intensity_freq2{m} == max(Intensity_freq2{m}),1);
    

    
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
%savename = strcat(dirname,'/Plots/','Int_',A,'_',B)
%saveas(1,savename,'png')

figure(2)
plot(allspectra');
title('Each RFI Event in Intensity Across All Channels')
ylabel('Intensity')
xlabel('Channels')
%savename = strcat(dirname,'/Plots/','Int_Allspectra',A,'_',B)
%  saveas(2,savename,'png')
  %{
% Changed settings for presentation...
a = findobj(gcf);
allaxes = findall(a,'Type','axes');
alllines = findall(a,'Type','line');
alltext = findall(a,'Type','text');

set(allaxes,'FontName','Arial','FontWeight','Bold','LineWidth',2, ...
    'FontSize',16);
set(alltext,'FontName','Arial','FontWeight','Bold','FontSize',16);
set(alllines,'Linewidth',2);
%}
end % plotfigs_I

end % read_data




