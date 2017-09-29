function [usrInput,xpos,ypos,nPoints] = myFlip(graphicParams)

    persistent lastTimerCheck
  	if isempty(lastTimerCheck)
        lastTimerCheck = GetSecs();
    end
    persistent vbl
    if isempty(vbl)
        vbl = 0; % init counter
    end
    persistent buttonsPrior
    if isempty(buttonsPrior)
        buttonsPrior = [0 0 0]; % init buttons
    end
    
    % Draw graphics
    % [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', windowPtr [, when] [, dontclear] [, dontsync] [, multiflip]);
    vbl = Screen('Flip', graphicParams.winhandle, vbl + graphicParams.waitDuration);
    

    % Poll input devices for activity
    
    % keyboard
   	[keyIsDown, secs, keyCode] = KbCheck();
 	responseKey=KbName(keyCode);  %find out which key was pressed & translate code into letter (string, or strcell)
    
    % mouse
    [x,y,buttons] = GetMouse(graphicParams.winhandle); % find out if any mouse buttons press (3 item vector)
    if all(buttonsPrior == buttons) % prevent buttons being held down (i.e. only detect onPress)
        buttons = buttons * 0;
    else
        buttonsPrior = buttons;
    end

    usrInput = [];
    
%     % tobii
%     xpos = [];
%     ypos = [];
%     nPoints = 0;
%     %WaitSecs(8/60);
%     timeNow = GetSecs();
%     updateSecs = graphicParams.tobiiFrames/60;
%     if timeNow-lastTimerCheck > updateSecs
%         lastTimerCheck = timeNow;
%         [xpos,ypos,nPoints] = iv_getXY(graphicParams.screenWidth, graphicParams.screenHeight);  
%     end
% 
%     usrInput = InputMapper.mapInput(responseKey, buttons);
end
