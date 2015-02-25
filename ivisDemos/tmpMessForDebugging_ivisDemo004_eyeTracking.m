% ivisDemo004_eyeTracking. Connect to an eyetracker and track fixations on the screen.
%
%   Results are displayed in a GUI
%
% Requires:         ivis toolbox v1.4
%   
% Matlab:           v2012 onwards
%
% See also:         ivisDemo003_mouseTracking.m
%                   ivisDemo005_usingaPTBScreen.m
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
    
% verify, initialise, and launch the ivis toolbox
IvMain.assertVersion(1.4);
IvMain.initialise(IvParams.getSimpleConfig('graphics.testScreenNum',1, 'GUI.useGUI',false, 'eyetracker.GUIidx',2, 'eyetracker.type','tobiieyex', 'eyetracker.fixationMarker','cursor')); %, 'eyetracker.id','TX120-203-81900130'));
[eyetracker, ~, InH] = IvMain.launch();

% run!
try % wrap in try..catch to ensure a graceful exit
    
    % continue until keystroke
    fprintf('Try looking around the target monitor.\nPress SPACE to exit\n');
    while ~any(InH.getInput() == InH.INPT_SPACE.code)
        eyetracker.refresh(true); % false to suppress data logging
        WaitSecs(1/20);
    end
    
catch ME
    IvMain.finishUp();
    rethrow(ME);
end

% TMP (and remove graphics.testScreenNum when this goes, and set refersh to false)
log = ivis.log.IvDataLog.getInstance();
x = log.getLastN(log.getN());
fprintf('%1.4f   %1.4f   %1.4f   %1.4f\n', x(:,[1 2 10 11])')

% that's it! close open windows and release memory
IvMain.finishUp();