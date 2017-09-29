function [] = ivisDemo005_usingaPTBScreen()
% ivisDemo005_usingaPTBScreen. How to integrate a PsychToolBox OpenGL screen into your program.
%
%   Opens up a PTB screen. Note how a white 'dot' texture is automatically
%   drawn onto the screen at the point of fixation
%
% Requires:         ivis toolbox v1.5
%
% Matlab:           v2012 onwards
%
% See also:         ivisDemo004_eyeTracking.m
%                   ivisDemo006_trackboxVisualisation.m
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

    
    %% 1. Have IVIS open the screen
    % verify, initialise, and launch the ivis toolbox
  	setpref('ivis','disableScreenChecks',true); % for demo purposes
    IvMain.assertVersion(1.5);
    IvMain.initialise(IvParams.getDefaultConfig());
    [eyetracker, ~, InH, winhandle] = IvMain.launch();

    % run!
    try % wrap in try..catch to ensure a graceful exit
        
        % continue until keystroke
        fprintf('Try moving the mouse cursor around the target monitor.\nPress SPACE to exit\n');
        while ~any(InH.getInput() == InH.INPT_SPACE.code)
            Screen('Flip', winhandle); % n.b., requires that ivis.broadcaster.* has been imported
            eyetracker.refresh(false); % false to suppress data logging
            WaitSecs(1/60);
        end
        
    catch ME
        IvMain.finishUp();
        rethrow(ME);
    end

    % that's it! close open windows and release memory
    IvMain.finishUp();


    %% 2. open PTB screen manually
    % verify, initialise, and launch the ivis toolbox
    IvMain.assertVersion(1.5);
    IvMain.initialise(IvParams.getDefaultConfig('graphics.useScreen',false));
    [eyetracker, ~, InH] = IvMain.launch();
         
   	% open the screen
    Screen('Preference', 'SkipSyncTests', 1);
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput');
    winhandle = PsychImaging('OpenWindow', max(Screen('Screens')), .5);
    IvParams.registerScreen(winhandle);
    
    % run!
    try % wrap in try..catch to ensure a graceful exit
        
        % continue until keystroke
        fprintf('Try moving the mouse cursor around the target monitor.\nPress SPACE to exit\n');
        while ~any(InH.getInput() == InH.INPT_SPACE.code)
            Screen('Flip', winhandle); % n.b., requires that ivis.broadcaster.* has been imported
            eyetracker.refresh(false); % false to suppress data logging
            WaitSecs(1/60);
        end
        
    catch ME
        IvMain.finishUp();
        rethrow(ME);
    end

    % that's it! close open windows and release memory
    IvMain.finishUp();

end