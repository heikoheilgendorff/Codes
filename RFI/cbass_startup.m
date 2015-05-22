%[home,installeddir] = where_am_i();
home='/home/heikoh/';
installeddir='cbass/cbass_analysis/';
%addpath('/home/jons/cbass/matlab/');
addpath([home, '/',installeddir]);
addpath([home, '/',installeddir,'/comms']);
addpath([home, '/',installeddir,'/constants']);
addpath([home, '/',installeddir,'/matutils']);
addpath([home, '/',installeddir,'/matutils/angles']);
addpath([home, '/',installeddir,'/matutils/dateconv']);
addpath([home, '/',installeddir,'/matutils/fastextract']);
addpath([home, '/',installeddir,'/matutils/interf']);
addpath([home, '/',installeddir,'/matutils/interf/difmap']);
addpath([home, '/',installeddir,'/matutils/minuit']);
addpath([home, '/',installeddir,'/matutils/mosaic']);
addpath([home, '/',installeddir,'/pointing']);
addpath([home, '/',installeddir,'/reduc']);
addpath([home, '/',installeddir,'/reduc/flag']);
addpath([home, '/',installeddir,'/reduc/alpha']);
addpath([home, '/',installeddir,'/reduc/load']);
addpath([home, '/',installeddir,'/reduc/rfi']);
addpath([home, '/',installeddir,'/reduc/calcs']);
addpath([home, '/',installeddir,'/reduc/support']);
addpath([home, '/',installeddir,'/reduc/plotting']);
addpath([home, '/',installeddir,'/descart']);
addpath([home, '/',installeddir,'/descart/map_making']);
addpath([home, '/',installeddir,'/descart/data_processing']);
%addpath([home, '/',installeddir,'/rfi_tuning']);
addpath([home, '/',installeddir,'/scans/generate']);
addpath([home, '/',installeddir,'/scans/analysis']);
addpath([home, '/',installeddir,'/example_scripts']);
addpath([home, '/',installeddir,'/mfitsio']);
addpath([home, '/',installeddir,'/webpage_logging']);
addpath([home, '/',installeddir,'/antHealth']);
addpath([home, '/',installeddir,'/cbassSouthFunctions']);

%javaaddpath({
%   [home,'/cbass_analysis/java/eagpix/PixTools.jar']
%   [home,'/cbass_analysis/java/eagpix/vecmath.jar']
%});

set(0,'DefaultFigurePosition',[5 40 650 575])

% stephen likes pretty colors
set(0,'DefaultFigureColor',[0.85 0.85 0.85]);
set(0, 'DefaultFigureColormap', jet);
colormap('default');
set(0,'DefaultAxesFontName','Hours');
close


[a host] = system('hostname');
aa = strmatch('springbok', host);
bb = strmatch('haggis', host);
if(~isempty(aa) | ~isempty(bb))
  opengl neverselect
end

% Bit to add some paths in on Angela's laptop

angela = strfind(home, 'taylora');
if(~isempty(angela));
 addpath([home, '/',installeddir,'/angela_cbass/angela_beam']);
 addpath([home, '/',installeddir,'/angela_cbass/angela_beam/reducs']);
 addpath([home, '/',installeddir,'/angela_cbass/angela_beam/sim_beams']);
 addpath([home, '/',installeddir,'/angela_cbass/angela_beam/Beam_plotting']);
 addpath([home, '/',installeddir,'/angela_cbass/angela_beam/rasters']);
 addpath([home, '/',installeddir,'/angela_cbass/angela_beam/Tsys_stuff']);
 
end

%javaaddpath({
%   [home,'/cbass_analysis/java/eagpix/PixTools.jar']
%   [home,'/cbass_analysis/java/eagpix/vecmath.jar']
%});

