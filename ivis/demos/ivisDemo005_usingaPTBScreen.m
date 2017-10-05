function [] = ivisDemo005_usingaPTBScreen()
% ivisDemo005_usingaPTBScreen. How to integrate a PsychToolBox OpenGL screen into your program.
%
%   Opens up a PTB screen. Note how a white 'dot' texture is automatically
%   drawn onto the screen at the point of fixation
%
% Requires:         ivis toolbox v1.5
%
% Matlab:           v2015 onwards
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

    %% 2. v1: have ivis open PTB screen on launch
    fprintf('Version 1: have ivis open PTB screen on launch\n\n');
    
    % query user for which screen to use as the stimulus display
    screenNums = Screen('Screens');
    fprintf('Which screen do you want to use for your stimuli?\n');
    for i = 1:length(screenNums)
        fprintf('  [%i] %s\n', i-1, screenNums(i));
    end
    testScreenNum = getIntegerInput('Enter number: ', false, 99, [0 length(screenNums)-1]);

    % verify, initialise, and launch the ivis toolbox
    IvMain.assertVersion(1.5);
    IvMain.initialise(IvParams.getDefaultConfig('graphics.testScreenNum',testScreenNum, 'graphics.runScreenChecks',false, 'log.raw.enable',false, 'log.diary.enable',false)); % disable screen checks for demo purposes
    [eyetracker, ~, InH, winhandle] = IvMain.launch();

    % run!
    try % wrap in try..catch to ensure a graceful exit
        
        % continue until keystroke
        fprintf('Try moving the mouse cursor around the target monitor.\nPress SPACE to exit\n');
        while ~any(InH.getInput() == InH.INPT_SPACE.code)
          	DrawFormattedText(winhandle, 'press SPACE to continue'); % give feedback on PTB screen
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
    fprintf('Version 1: open PTB screen manually\n\n');
    
    % verify, initialise, and launch the ivis toolbox
    IvMain.assertVersion(1.5);
    IvMain.initialise(IvParams.getDefaultConfig('graphics.useScreen',false, 'log.raw.enable',false, 'log.diary.enable',false));
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
          	DrawFormattedText(winhandle, 'press SPACE to continue'); % give feedback on PTB screen
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