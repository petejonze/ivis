% ivisDemo002_keyboardHandling. Shows how to use the InputHandler class to deal with keyboard inputs.
%
%   Demonstrates the basics of how to deal with user inputted keystrokes
%
% Requires:         ivis toolbox v1.3
%   
% Matlab:           v2012 onwards
%
% See also:       	ivisDemo001_checkInstalled.m
%                   ivisDemo003_mouseTracking.m
%
% Author(S):    	Pete R Jones <petejonze@gmail.com>
% 
% Version History:  1.0.0	PJ  22/06/2013    Initial build.
%                   1.1.0	PJ  18/10/2013    General tidy up (ivis 1.4).
%
% @todo: check timestamp and multiple inputs and invalid mappings
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
IvMain.initialise(IvParams.getSimpleConfig());
[~, ~, InH] = IvMain.launch();

try

    % Wait for space
    fprintf('\nPress space to continue\n');
    while ~any(InH.getInput() == InH.INPT_SPACE.code)
        WaitSecs(1/60);
    end

    % Wait for return [alternate form A]
    fprintf('\nPress return to continue\n');
    InH.waitForInput(InH.INPT_RETURN.code);

    % Wait for space [alternative form B, from the ivis.control package]
    InH.waitForInput(InH.INPT_SPACE, '\nPress space again to continue to Part B (will restart ivis)\n');

    % Finish up
    IvMain.finishUp();

    %% Try again with a custom class and some more advanced functionality
    fprintf('\n--------------------------------------------------------------\n\n');
    fprintf('Now we''ll try again, using a custom class that has additional keys mapped\n\n');

    % Re-load ivis
    params = IvParams.getSimpleConfig('keyboard.handlerClass','MyDemoInputHandler'); % substitute our custom input handler class (see the resources subdirectory)
    IvMain.initialise(params);
    [~, ~, InH] = IvMain.launch();

    % Wait for custom input
    InH.waitForInput(InH.INPT_B, '\nPress INPT_B (''b'') to continue\n');

    % All the standard inputs still work with custom classes
    InH.waitForInput(InH.INPT_SPACE, '\nPress space like before\n');

    % multiple possible inputs can be used, and the users response can be used
    % to control what happens next
    resp = InH.waitForInput([InH.INPT_A InH.INPT_B], '\nPress A or B\n');
    if resp == InH.INPT_A.code
        fprintf('You pressed A. Good choice\n');
    else
        fprintf('You pressed B. Fair enough\n');
    end

    % Escape will always be detected and throw an error (unless explictly asked
    % not to)
    fprintf('\nPress escape to break out of an endless while loop\n');
    try
        while 1
            InH.getInput();
            WaitSecs(1/60);
        end
    catch ME
        beep()
        fprintf('\n-----------------------------------------\n\n');
        fprintf('  The following exception was thrown:\n\n');
        disp(ME)
        fprintf('-----------------------------------------\n');
    end

    % And standard PTB commands still work
    fprintf('\nPress any key to finish\n');
    KbWait([], 2);

    % Finish up
    IvMain.finishUp();

    % Final thoughts
    fprintf('\n\nn.b., try running InputHandler.test() to see what your keyboard inputs look like\n');

catch ME % ensure keyboard isn't frozen if user quits or program crashes
   IvMain.finishUp();
   rethrow(ME);
end