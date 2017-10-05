function [x,t]=getPureTone(cf,Fs,d,wd,calib,targLeq,chans,tolerance,devID,devName,headID, doPlot)
% GETPURETONE Returns a pure tone sine wave, windowed and calibrated if so
% specified.
%
%   <Further Info>
%
% @Parameters:             
%
%     	cf              Real            #####
%                                           e.g. #####
%     	Fs           	Int         	#####
%                                           e.g. #####
%     	d               Real          	#####
%                                           e.g. #####
%     	[wd]        	Real            #####
%                                           e.g. #####
%     	[calib]         Struct/Char  	#####
%                                           e.g. #####
%     	[targLeq]   	Real        	#####
%                                           e.g. #####
%     	[chans]      Int         	#####
%                                           e.g. #####
%     	[tolerance]   	Real         	#####
%                                           e.g. #####
%     	[devID]      	Int             #####
%                                           e.g. #####
%     	[devName]     	Char            #####
%                                           e.g. #####
%     	[headID]      	Char            #####
%                                           e.g. #####
%     	[doPlot]      	Logical         #####
%                                           e.g. #####
% @Returns:  
%
%    	x       	Real      Signal vector (time-domain)
%
%       t       	Real      Time vector
%
% @Usage:           x=getPureTone(cf,Fs,d, [wd], [calib],[targLeq],[chans],[tolerance],[devID],[devName],[headID])   
% @Example:         calib=calib_makeDummy([0 1],[1000],[.9/sqrt(2); .4/sqrt(2)]);
%                   x = getPureTone(1000,44100,.5,.02,calib,100,[0 1], [], [], [], [], true);
%                   sound(x',44100);
%
% @Requires:        PsychTestRig2
%   
% @See also:        #####
%
% @Matlab:          v2008 onwards
%
% @Author(S):    	Pete R Jones
%
% @Creation Date:	24/02/2011
% @Last Update:     24/02/2011
%
% @Current Verion:  1.0.0
% @Version History: v1.0.0	24/02/2011    Initial build.
%
% @Todo:            Lots!
%                   Make phase optional? Binaural?
%                   Change to floor && (0:(n-1)) ? 
%
    
    %% INPUTS

    if nargin < 4;  wd          = []; end
    if nargin < 5;  calib       = []; end
    if nargin < 6;  targLeq     = []; end
    if nargin < 7;  chans       = []; end
    if nargin < 8;  tolerance   = []; end
    if nargin < 9;  devID       = []; end
    if nargin < 10; devName   	= []; end
    if nargin < 11; headID      = []; end
    if nargin < 12; doPlot      = []; end
    
    %% SYNTH
    
    % params
    n = floor(Fs * d);  % number of samples
    t = (0:(n-1)) / Fs;    	% time vector [sound data preparation]
	phase = 0;          % phase (Rad)
    % create
    x = sin(2 * pi * cf * t + phase); % audio vector
    
    %% CALIBRATE (optional)

    if ~isempty(calib)
        amp = sqrt(2) * calib_getTargRMS(calib,targLeq,chans,cf,tolerance,devID,devName,headID);
        x = amp * x; % set RMS (for sines: RMS = Amp/sqrt(2))
    end
    
    %% WINDOW (optional)
    if wd	%window
        w = getSquaredCosineWindow(Fs,d,wd,size(x,1));	% get window
        x = x.*w;                                               % apply window
    end
    
    %% PLOT (optional)
    
    if doPlot, figure(); plot(t,x); end
    
end