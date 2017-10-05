% ivisDemo004_eyeTracking. Connect to an eyetracker and track fixations on the screen.
%
%   Results are displayed in a GUI
%
% Requires:         ivis toolbox v1.5
%   
% Matlab:           v2015 onwards
%
% See also:         ivisDemo003_mouseTracking.m
%                   ivisDemo005_usingaPTBScreen.m
%
% Author(s):    	Pete R Jones <petejonze@gmail.com>
% 
% Version History:  1.0.0	PJ  22/06/2013    Initial build.
%                   1.1.0	PJ  18/10/2013    General tidy up (ivis 1.4).
%                   1.2.0	PJ  04/10/2017    Make tracker selectable (v1.5)
%
%
% Copyright 2017 : P R Jones <petejonze@gmail.com>
% *********************************************************************
% 

% clear memory and set workspace
clearAbsAll();
import ivis.main.* ivis.control.* ivis.eyetracker.*;
    
% query user for eyetracker type
trackertypes = IvDataInput.getTrackerTypes();
fprintf('Which tracker do you want to use?\n');
for i = 1:length(trackertypes)
    fprintf('  [%i] %s\n', i, trackertypes{i});
end
idx = getIntegerInput('Enter number: ', false, 99, [1 length(trackertypes)]);
trackertype = trackertypes{idx};

% verify, initialise, and launch the ivis toolbox
IvMain.assertVersion(1.5);
IvMain.initialise(IvParams.getSimpleConfig('graphics.testScreenNum',1, 'GUI.screenNum',1, 'GUI.useGUI',true, 'eyetracker.GUIidx',2, 'saccade.GUIidx',3, 'eyetracker.type',trackertype)); % , 'eyetracker.fixationMarker','cursor'));
[eyetracker, ~, InH] = IvMain.launch(1);

% run!
try % wrap in try..catch to ensure a graceful exit
    
    % continue until keystroke
    fprintf('Try looking around the target monitor.\nPress SPACE to exit\n');
    while ~any(InH.getInput() == InH.INPT_SPACE.code)
        eyetracker.refresh();
        WaitSecs(1/40); % loop at 40 Hz
    end
    
catch ME
    IvMain.finishUp();
    rethrow(ME);
end

% that's it! close open windows and release memory
IvMain.finishUp();