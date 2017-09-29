function [] = ivisDemo011_advancedClassifiers()
% ivisDemo011_advancedClassifiers. Various advanced classifiers (box, log-likelihood, direction).
%
%   Edit the "classifiertype" variable to see different functionality
%
% Requires:         ivis toolbox v1.5
%
% Matlab:           v2012 onwards
%
% See also:         ivisDemo010_readingRawGazeData.m
%                   ivisDemo012_externalConfigFiles.m
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
    import ivis.classifier.* ivis.control.* ivis.graphic.* ivis.gui.* ivis.main.* ivis.log.*  ivis.broadcaster.*; 

    % user variables [Choose from the selection below]
    classifiertype = 'box'; % 'grid1', 'grid2', 'LL1d' 'LL2d' 'box', 'direction'

    try
        % launch ivis
        IvMain.assertVersion(1.5);
        setpref('ivis','disableScreenChecks',true); % for demo purposes
        params = IvMain.initialise(IvParams.getDefaultConfig('GUI.useGUI',true));
        [eyeTracker, ~, InH, winhandle] = IvMain.launch();

        % make graphic texture (black square, 100 x 100 pixels)
        tex = Screen('MakeTexture', params.graphics.winhandle, zeros(100,100,3));

        % adaptive track
        aTparams = [];
        aTparams.startVal = 400;
        aTparams.stepSize = 80;
        aTparams.downMod = 1;
        aTparams.nReversals = inf;
        aTparams.nUp = 1;
        aTparams.nDown = 1;
        aTparams.isAbsolute = true;
        aTparams.minVal = 50;
        aTparams.maxVal = 800;
        aTparams.minNTrials = 1;
        aTparams.maxNTrials = 5;
        aTparams.verbosity = 0; % 2
        aT = AdaptiveTrack(aTparams);
        
        % prepare graphic
        myGraphic = IvGraphic('targ', tex, 0, 0, 100, 100, winhandle);
        
        % prepare a classifier
        switch lower(classifiertype)
            case 'll2d' % 2D version
                myClassifier = IvClassifierLL('2D', {IvPrior(), myGraphic});
            case 'll1d' % 1D version
                lmag = params.classifier.loglikelihood.lMagThresh;
                myClassifier = IvClassifierLL('1D', {IvPrior(), myGraphic},[lmag lmag*5]);
            case 'box'
                myClassifier = IvClassifierBox(myGraphic);
            case 'grid1'
                myClassifier = IvClassifierGrid();
            case 'grid2'
                myClassifier = IvClassifierGrid(myGraphic);
            case 'direction'
                myClassifier = IvClassifierVector([-70 0 70 200]);
            otherwise
                error('mess_classifier_v4:InvalidInput','classifier type (%s) not recognisied.\nChoose from: %s', classifiertype, strjoin(',','ll2d','ll1d','box'));
        end
        % show on stimulus screen
        myClassifier.show(); % draw the box around the graphic
        
        % set background colour to white (to make cursor easier to see)     
        Screen('FillRect', winhandle, [255 255 255]);

        % #################
        while ~aT.isFinished

            % WAIT FOR GO KEY
            while InH.getInput() ~= InH.INPT_SPACE.code
              	eyeTracker.getInstance().refresh(false); % false to supress logging
                WaitSecs(1/50);
            end
            fprintf('Started\n\n');
            
            % flush eyetracker?
            %#########
            
            % start...
            myClassifier.start();
            myGraphic.reset(300,600, aT.getDelta(), aT.getDelta());
            
            % Animation loop: Run until key 'QUIT' press...
            while myClassifier.getStatus() == myClassifier.STATUS_UNDECIDED
                
                % poll peripheral devices for valid user inputs
                InH.getInput();

                % update graphics
                if myGraphic.getX < 800
                    myGraphic.nudge(10,0);
                end
                myGraphic.draw()

                % poll eyetracker
                n = eyeTracker.getInstance().refresh(); %#ok     
              	myClassifier.update();

                % Show rendered image at next vertical retrace:
                Screen('Flip', winhandle);
                WaitSecs(.01);
            end
            
            % computer whether was a hit
            whatLookingAt = myClassifier.interogate();
            anscorrect = strcmpi('targ', whatLookingAt.name());
            % update the track accordingly
            aT.update(anscorrect);
            
            % tmp: give visual feedback
            DrawFormattedText(winhandle, whatLookingAt.name());
            
            Screen('Flip', winhandle);
            fprintf('You looked at: %s\n', whatLookingAt.name());
            
            % Reset
            IvDataLog.getInstance().save();
        end
        
        % Finish up
        delete(aT);
        IvMain.finishUp();
    catch ME
        try
            try
                delete(aT);
            catch % #ok
            end
            IvMain.finishUp();
        catch ME
            disp(ME)
        end
        fprintf('\n\nABORTED (error)\n');
        rethrow(ME);
    end
end