function [] = ivisDemo015_identifyingSaccades()
% ivisDemo015_identifyingSaccades. Saccade identification.
%
%     n.b. currently requires the user to manually set
%     IvDataInput.TAG_AND_CLEAN = true (and requires some pretty vigorous mouse
%     movements! See: IvParams.getDefaultConfig saccade criteria...
%
% Requires:         ivis toolbox v1.5
%
% Matlab:           v2012 onwards
%
% See also:         ivisDemo014_eyetrackerCalibration.m
%                   ivisDemo016_audio.m
%
% Author(s):    	Pete R Jones <petejonze@gmail.com>
% 
% Version History:  1.0.0	PJ  22/06/2013    Initial build.
%                   1.1.0	PJ  18/10/2013    General tidy up (ivis 1.4).
%
%
% Copyright 2017 : P R Jones <petejonze@gmail.com>
% *********************************************************************
% 



    % clear memory and set workspace
    clearAbsAll();
    import ivis.main.* ivis.control.*;

    % verify expected version of ivis toolbox is installed
    IvMain.assertVersion(1.5);

    % initialise ivis
    IvMain.initialise(IvParams.getSimpleConfig('GUI.useGUI',true, 'eyetracker.GUIidx',2, 'eyetracker.saccade.GUIidx',3, 'eyetracker.saccade.doBeep',true));

    % luanch ivis
    [eyetracker, ~, InH] = IvMain.launch();

    % run!
    try % wrap in try..catch to ensure a graceful exit
        
        % continue until keystroke
        fprintf('Try moving the mouse cursor around the target monitor.\nPress SPACE to exit\n');
        while ~any(InH.getInput() == InH.INPT_SPACE.code)
            eyetracker.refresh(true); % false to suppress data logging
            WaitSecs(1/60);
        end
        
    catch ME
        IvMain.finishUp();
        rethrow(ME);
    end
    
    % that's it! close open windows and release memory
    IvMain.finishUp();
    
end    