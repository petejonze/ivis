% init
clc
clear all

%check that Psychtoolbox is good to go
AssertOpenGL; % Make sure the script is running on Psychtoolbox-3

% !!!!required to work on slow computers!!! Use with caution!!!!!
Screen('Preference', 'SkipSyncTests', 1)

try
    winhandle  = Screen('OpenWindow',0,[],[0,0,600,400]);
    
    % begin key listener
    ListenChar(2);
    
    % open video
    myVid = Video('./samplemov.avi',winhandle);
    
    % Display instructions
    DrawFormattedText(winhandle, 'p to pause\nq to quit\n\nPress any key to begin', 'center', 'center');
    Screen('Flip', winhandle);
    KbWait([], 3); % Wait for key stroke.
    
    myVid.start();
    while ~isempty(myVid.playFrame)
        [down, secs, keyCode] = KbCheck();
        responseKey=firstStr(KbName(keyCode));
        if any(strcmpi(responseKey,{'q'}))
            break;
        end
        if any(strcmpi(responseKey,{'p'}))
            myVid.togglePause();
        end
        Screen('Flip', winhandle);
        WaitSecs(1/myVid.fps);
    end
catch ME
    ListenChar(0);
    delete(myVid);
    sca;
    rethrow(ME);
end

% Finish up
ListenChar(0);
delete(myVid);
sca;