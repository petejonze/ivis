function [] = ivisDemo007_classifyingFixations()
% ivisDemo007_classifyingFixations. Using a simple hitbox to see if the user is looking at a given object.
%
%   See ivisDemo011_advancedClassifiers.m for more advanced techniques
%
% Requires:         ivis toolbox v1.5
%
% Matlab:           v2012 onwards
%
% See also:         ivisDemo006_trackboxVisualisation.m
%                   ivisDemo008_playingVideos.m
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

    % Clear memory and set workspace
    clearAbsAll();
    import ivis.main.* ivis.control.*;
    
    % Initialise toolbox
    IvMain.assertVersion(1.5);
    params = IvMain.initialise(IvParams.getDefaultConfig());
    [eyeTracker, ~, InH, winhandle] = IvMain.launch();
    
    % Prepare graphic
    tex=Screen('MakeTexture', params.graphics.winhandle, ones(100,100,3));
    myGraphic = ivis.graphic.IvGraphic('targ', tex, params.graphics.mx, params.graphics.my, 200, 200, winhandle); % centre graphic in middle of screen
    
    % Prepare a classifier
    myClassifier = ivis.classifier.IvClassifierBox(myGraphic);
    myClassifier.show(); % draw the box around the graphic
    myClassifier.start();

    % Main loop (run until decision or user quits)
    while myClassifier.getStatus() == myClassifier.STATUS_UNDECIDED
        % poll peripheral devices for valid user inputs
        InH.getInput();
        % draw graphic
        myGraphic.draw()
        % poll eyetracker
        eyeTracker.getInstance().refresh();
        myClassifier.update();
        % Show rendered image at next vertical retrace:
        Screen('Flip', winhandle);
        % Pause for short period
        WaitSecs(.01);
    end
    
    % Report whether it was a hit
    anscorrect = strcmpi('targ', myClassifier.interogate().name());
    fprintf('look = %g\n', anscorrect);

    % Finish up
    IvMain.finishUp();
end