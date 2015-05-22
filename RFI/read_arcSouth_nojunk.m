function d = read_arcSouth_nojunk(start, finish, regs, arcdir, calfile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function d = read_arc(start, finish, regs, arcdir, calfile)
%
% start/finish=start finish times as strings with format e.g.:
% 01-Jan-2005:00:00:00
% optional regs=regs to extract if other than the standard set
% optional arcdir=directory containing archive files
% optional calfile=cal file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(~exist('regs'))
    regs=[];
end
if(~exist('arcdir'))
  arcdir=[];
end
if(~exist('calfile'))
  calfile=[];
end

if(isempty(regs))
  regs={'array.frame.received'...
      'array.frame.utc double',...
      'array.frame.features',...
      'antenna0.roach1.LL double',...
      'antenna0.roach1.LLfreq double',...
      'antenna0.roach1.RR double',...
      'antenna0.roach1.RRfreq double',...
      'antenna0.roach1.U double',...
      'antenna0.roach1.Ufreq double',...
       'antenna0.roach1.Utime double',...
      'antenna0.roach1.Q double',...
      'antenna0.roach1.Qfreq double',...
      'antenna0.roach1.Qtime double',...
      'antenna0.roach1.load1 double',...
      'antenna0.roach1.load1freq double',...
      'antenna0.roach1.load2 double',...
      'antenna0.roach1.load2freq double',...
      'antenna0.roach1.utc double',...
      'antenna0.roach1.intCount double',...
      'antenna0.roach1.ntpSeconds double',...
      'antenna0.roach1.ntpUSeconds double',...
      'antenna0.roach2.LL double',...
      'antenna0.roach2.LLfreq double',...
      'antenna0.roach2.RR double',...
      'antenna0.roach2.RRfreq double',...
      'antenna0.roach2.U double',...
      'antenna0.roach2.Ufreq double',...
      'antenna0.roach2.Utime double',...
      'antenna0.roach2.Q double',...
      'antenna0.roach2.Qfreq double',...
      'antenna0.roach2.Qtime double',...
      'antenna0.roach2.load1 double',...
      'antenna0.roach2.load1freq double',...
      'antenna0.roach2.load2 double',...
      'antenna0.roach2.load2freq double',...
      'antenna0.roach2.utc double',...
      'antenna0.roach2.intCount double',...
      'antenna0.roach1.switchstatus double',...
      'antenna0.roach2.switchstatus double',...
      'antenna0.roach2.ntpSeconds double',...
      'antenna0.roach2.ntpUSeconds double',...
      'antenna0.thermal.ccTemperatureLoad double',...
      'antenna0.thermal.ccHeaterCurrent double',...
      'antenna0.thermal.lsTemperatureSensors double',...
      'antenna0.thermal.utc double',...
      'antenna0.roach1.version double',...
      'antenna0.servo.fast_az_pos double',...
      'antenna0.servo.fast_el_pos double',...
      'antenna0.servo.fast_az_err double',...
      'antenna0.servo.fast_el_err double',...
      'antenna0.servo.utc double',...
    'antenna0.servo.ntpSecond double',...
    'antenna0.servo.ntpUSecond double',...
      'antenna0.tracker.lst double',...
	'antenna0.tracker.lacking double',...
	'antenna0.tracker.equat_geoc double',...
	'antenna0.tracker.horiz_topo double',...
	'antenna0.tracker.horiz_mount double',...
	'antenna0.tracker.flexure double',...
	'antenna0.tracker.horiz_off double',...
	'antenna0.tracker.tilts double',...
	'antenna0.tracker.fixedCollimation double',...
	'antenna0.tracker.encoder_off double',...
	'antenna0.tracker.sky_xy_off double',...
	'antenna0.tracker.source string',...
	'antenna0.tracker.scan_off double',...
	'antenna0.tracker.refraction double',...
	'antenna0.tracker.ut1utc double',...
	'antenna0.tracker.eqneqx double',...
	'antenna0.tracker.utc double',...
	'antenna0.tracker.time_diff double',...
	'antenna0.tracker.offSource double',...
	'antenna0.tracker.siteActual double',...
	'antenna0.tracker.siteFiducial double',...
    'array.weather.airTemperature double',...
    'array.weather.pressure double',...
    'array.weather.relativeHumidity double',...
    
  };
end

% Ensure regs unique
  if(any(size(unique(regs))~=size(regs)))
    error('regs should be unique');
end

% Here we want to have the function know which directory to look for the
% data depending on the machine name.
[defaultDataDir defaultCalFile defaultReaderPath] = whichHostSa();

if(isempty(arcdir))

  arcdir = defaultDataDir;
end
if(isempty(calfile))
  calfile = defaultCalFile;
end

eval(sprintf('addpath %s', defaultReaderPath));

% let's get the previous 5 seconds and post 5 seconds, and then cut it down
% to the right size.
mjdstartorig = tstr2mjd(start);
mjdstart = mjdstartorig - 5/60/60/24;
mjdstoporig  = tstr2mjd(finish);
mjdstop  = mjdstoporig  + 5/60/60/24;

%display('cbassMatReadArcOpt')
d = cbassMatReadArcOpt(regs, mjd2string(mjdstart), mjd2string(mjdstop), arcdir, calfile);


%display('MassageData')
d = massageDataSa(d);
%display('reshapeResgister');
% reshape the registers
d = reshapeRegisters(d);
%display('interpRegisters');
% interpolate as needed.
%d = interpRegistersSa(d,1); %second flag==1 means use NTP time
%display('cut Desired Date');
% cut to the desired data
%d = apparentAzElSouth(d);

%d = determineIndicesSouth(d);
%d = cutDesiredData(d, mjdstartorig, mjdstoporig);
%display('here')
return;

% update the separate functions
%function [defaultDataDir defaultCalfile defaultReader] = whichHost()
%
%% Here we want to have the function know which directory to look for the
%% data depending on the machine name.
%% For simplicity, we assign numbers to each hostname as follows:
%% 0 - cbasscontrol  (OVRO)
%% 1 - haggis  (CALTECH)
%% 2 - falcon  (MANCHESTER)
%% 3 - aslx10  (OXFORD)
%% 4 - asosx48 (OXFORD)
%% 5 - asosx39 (OXFORD)
%% 6  - aslx2   (OXFORD)
%% 7  - pravda  (Oliver)
%
%[s w] = unix('hostname');
%
%hostNum = nan;
%
%% check for cbasscontrol
%host = strfind(w, 'cbasscontrol');
%if(~isempty(host))
%  hostNum = 0;
%  defaultDataDir = '/mnt/data/cbass/arc';
%  defaultCalfile = '/home/cbass/gcpCbass/control/conf/cbass/cal';
%  defaultReader  = '/home/cbass/gcpCbass/matlab/common/';
%end
%
%% check for haggis
%host = strfind(w, 'haggis');
%if(~isempty(host))
%  hostNum = 1;
%  defaultDataDir = '/scr/cbassarc/data/arc';
%  defaultCalfile = '/home/cbassuser/cbass/gcpCbass/control/conf/cbass/cal';
%  defaultReader  = '/home/cbassuser/cbass/gcpCbass/matlab/common/';
%end
%
%% check for falcon
%host = strfind(w, 'falcon');
%if(~isempty(host))
%  hostNum = 2;
%  defaultDataDir = '/scratch/falcon_4/cdickins/cbass/cbassarc/data/arc';
%  defaultCalfile = '/home/muchovej/cbass/gcpCbass/control/conf/cbass/cal';
%  defaultReader  = '/home/muchovej/cbass/gcpCbass/matlab/common/';
%end
%
%% check for aslx
%host = strfind(w, 'aslx10');
%if(~isempty(host))
%  hostNum = 3;
%  defaultDataDir = '/data/cbassuser/data/arc';
%  defaultCalfile = '/home/Muchovej/cbass/gcpCbass/control/conf/cbass/cal';
%  defaultReader  = '/home/Muchovej/cbass/gcpCbass/matlab/common/';
%end
%
%% check for asosx48
%host = strfind(w, 'asosx48');
%if(~isempty(host))
%  hostNum = 4;
%defaultDataDir = '/Volumes/Data2/CBASS_ARC';
%%defaultDataDir = '/Volumes/C-BASS-1';
%%defaultDataDir = '/Volumes/C-BASS/data';
%
%defaultCalfile = '/Users/taylorA/CBASS/cbass/gcpCbass/control/conf/cbass/cal';
%defaultReader  = '/Users/taylorA/CBASS/cbass/gcpCbass/matlab/common/';
%end
%
%% check for pravda
%host = strfind(w, 'pravda');
%if(~isempty(host))
%  hostNum = 7;
%  defaultDataDir = '/Volumes/DATA/cbass/arc';
%  defaultCalfile = '/Users/oliver/C-BASS/software/cbass/gcpCbass/control/conf/cbass/cal';
%  defaultReader  = '/Users/oliver/C-BASS/software/cbass/gcpCbass/matlab/common/';
%end
%
%host = strfind(w, 'asosx39');
%if(~isempty(host))
%  hostNum = 5;
%defaultDataDir = '/Volumes/My Book/zuntz/cbass/arc';
%defaultCalfile = '/Users/zuntz/src/cbass/cbass/gcpCbass/control/conf/cbass/cal';
%defaultReader  = '/Users/zuntz/src/cbass/cbass/gcpCbass/matlab/common/';
%end
%
%host = strfind(w, 'aslx2');
%if(~isempty(host))
%  hostNum = 6;
%defaultDataDir = '/home/jxl/cbass_data/arc';
%defaultCalfile = '/home/jxl/cbass/gcpCbass/control/conf/cbass/cal';
%defaultReader  = '/home/jxl/cbass/gcpCbass/matlab/common/';
%end
%
host = strfind(w, 'aslx5');                                                     
if(~isempty(host))
 hostNum = 7; 
defaultDataDir = '/home/cbassuser/cbass_data/arc';
defaultCalfile = '/home/cbassuser/cbass/gcpCbass/control/conf/cbass/cal';
defaultReader  = '/home/cbassuser/cbass/gcpCbass/matlab/common/';
end                                                                                                                                                    
%             
%
%
%if(isnan(hostNum))
%  error('Can not match your host name to a recognized one');
%  error('Update read_arc.m to reflect your host');
%end
%
%return;




% cut to the desired data
function d = cutDesiredData(d, mjdstartorig, mjdstoporig)

if(~isfield(d, 'array'))
  return;
end

if(~isfield(d, 'antenna0'))
  return;
end

if(issubfield(d.antenna0, 'receiver', 'utc'))
  indFast = d.antenna0.receiver.utc>=mjdstartorig & ...
      d.antenna0.receiver.utc<mjdstoporig;
  noRx = 0;
else
  indFast = ones(length(d.array.frame.utc)*100,1);
  indFast = logical(indFast);
  noRx = 1;
end

if(isfield(d.antenna0, 'servo'))
  indMed  = d.antenna0.servo.utc>=mjdstartorig & ...
      d.antenna0.servo.utc<mjdstoporig;
  noServo = 0;
else
  indMed = ones(length(d.array.frame.utc)*5,1);
  indMed = logical(indMed);
  noServo = 1;
end

indSlow = d.array.frame.utc>=mjdstartorig & d.array.frame.utc<mjdstoporig;


indF = reshape(indFast, [5 20 length(indSlow)]);
indF = permute(indF, [3 1 2]);
indFs = mean(mean(indF,3),2)==1;

indM = reshape(indMed, [5 length(indSlow)]);
indM = permute(indM, [2 1]);
indMs = mean(indM,2)==1;

ind  = indMs & indFs & indSlow;

% these are the real ind on the slow scale.  now we up it to the longer
% scales -- already done in framecut.

d = framecut(d, ind, 'regular');

return;

