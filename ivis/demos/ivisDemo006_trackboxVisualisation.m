function [] = ivisDemo006_trackboxVisualisation()
% ivisDemo006_trackboxVisualisation. Visualising the Tobii trackbox in realtime.
%
%   Showing how the trackbox and associated 3D eye positions of the two
%   eyes can be represented on a PTB screen
%   n.b., this code must be written as a function (rather than a script) to
%   allow for dot-referencing 
%
% Requires:         ivis toolbox v1.5
%
% Matlab:           v2015 onwards
%
% See also:         ivisDemo005_usingaPTBScreen.m
%                   ivisDemo007_classifyingFixations.m
%
% Author(s):    	Pete R Jones <petejonze@gmail.com>
% 
% Version History:  1.0.0	PJ  23/06/2013    Initial build.
%                   1.1.0	PJ  18/10/2013    General tidy up (ivis 1.4).
%
%
% Copyright 2017 : P R Jones <petejonze@gmail.com>
% *********************************************************************
% 

    % clear memory and set workspace
    clearAbsAll();
    import ivis.main.* ivis.control.* ivis.video.* ivis.calibration.* ivis.broadcaster.* ivis.eyetracker.*;

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
    IvMain.initialise(IvParams.getDefaultConfig('eyetracker.type',trackertype, 'graphics.runScreenChecks',false, 'log.raw.enable',false, 'log.diary.enable',false));
    [eyetracker, ~, InH, winhandle] = IvMain.launch();

    try % wrap in try..catch to ensure a graceful exit

        % Turn trackbox on
        TrackBox.getInstance().toggle();
        
        % continue until keystroke
        fprintf('Try looking around the target monitor.\nPress SPACE to exit\n');
        while ~any(InH.getInput() == InH.INPT_SPACE.code)
          	DrawFormattedText(winhandle, 'press SPACE when done'); % give feedback on PTB screen
            Screen('Flip', winhandle); % n.b., requires that ivis.broadcaster.* has been imported
            eyetracker.refresh(false); % false to suppress data logging
            WaitSecs(1/60);
        end
        
        % Turn trackbox off (not strictly necessary, but good practice)
        TrackBox.getInstance().toggle();
    catch ME
        IvMain.finishUp();
        rethrow(ME);
    end

    % that's it! close open windows and release memory
    IvMain.finishUp();
end