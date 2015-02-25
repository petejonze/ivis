% ivisDemo003_mouseTracking. Track the mouse cursor around the screen.
%
%   Results are displayed in a GUI
%
% See also:         ivisDemo002_keyboardHandling.m
%
% Requires:         ivis toolbox v1.4
%   
% Matlab:           v2012 onwards
%
% See also:         ivisDemo002_keyboardHandling.m
%                   ivisDemo004_eyeTracking.m
%
% Author(s):    	Pete R Jones <petejonze@gmail.com>
% 
% Version History:  1.0.0	PJ  22/06/2013    Initial build.
%                   1.1.0	PJ  18/10/2013    General tidy up (ivis 1.4).
%
%
% Copyright 2014 : P R Jones
% *********************************************************************
% 

% clear memory and set workspace
clearAbsAll();
import ivis.main.* ivis.control.*;

% verify expected version of ivis toolbox is installed
IvMain.assertVersion(1.4);

% initialise ivis
IvMain.initialise(IvParams.getSimpleConfig('GUI.useGUI',true, 'eyetracker.GUIidx',2, 'saccade.GUIidx',3, 'calibration.GUIidx',4));
%IvMain.initialise(IvParams.getDefaultConfig('graphics.useScreen',false, 'audio.isConnected',false)); % This will also work, but will throw many more complaints

% luanch ivis
[eyetracker, logs, InH, winhandle] = IvMain.launch();

% run!
try % wrap in try..catch to ensure a graceful exit
    
    % continue until keystroke
    fprintf('Try moving the mouse cursor around the target monitor.\nPress SPACE to exit\n');
    while ~any(InH.getInput() == InH.INPT_SPACE.code)
        eyetracker.refresh(); % false to suppress data logging
        WaitSecs(1/60);
    end
    
catch ME
    IvMain.finishUp();
    rethrow(ME);
end

% get the raw output log file for our records
logFn = logs.raw.fullFn;

% that's it! close open windows and release memory
IvMain.finishUp();

% closing hint to user
fprintf('\nWhy not try running the following to read the raw data log:\n\n');
fprintf('    dat = ivis.eyetracker.IvMouse.readRawLog(''%s'')\n\n', logFn);
