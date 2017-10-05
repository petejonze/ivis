function [] = ivisDemo009_advancedClassifiers2()
% ivisDemo009_advancedClassifiers2. More on the use of
% loglikelihood classifiers, including the option to srt the relative
% weight given to the x- and y-domain eye-tracking data
%
% Requires:         ivis toolbox v1.5
%
% Matlab:           v2012 onwards
%
% See also:         ivisDemo008_advancedClassifiers1.m
%                   ivisDemo010_readingRawGazeData.m
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

    try
        % launch ivis
        IvMain.assertVersion(1.5);
        IvMain.initialise(IvParams.getDefaultConfig('GUI.useGUI',true, 'graphics.useScreen',false, 'eyetracker.type','mouse', 'saccade.GUIidx',3, 'log.raw.enable',false, 'log.diary.enable',false));
        [eyeTracker, ~, InH, winhandle] = IvMain.launch();
        
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
        myGraphic = IvGraphic('targ1', [], 300, 600, 200, 200, winhandle);
        myGraphic2 = IvGraphic('targ2', [], 1000, 600, 200, 200, winhandle);
        
        % prepare a classifier
        myClassifier = IvClassifierLL({IvPrior(), myGraphic, myGraphic2}, [inf 300 300], 360, [], [], [], false);

        % set xy weights
        w = [1 0]; % amount of weight to give the X-DIMENSION and Y-DIMENSION, respectively
        myClassifier.setXYWeights(w);
        fprintf('Weights: x=%1.2f, y=%1.2f\n', w);
        
        % run
        while ~aT.isFinished
            
            % WAIT FOR GO KEY
            fprintf('\nReady. Press SPACE to start trial\n');
            while InH.getInput() ~= InH.INPT_SPACE.code
              	eyeTracker.refresh(false); % false to supress logging
                WaitSecs(.05);
            end
            fprintf('Started\n\n');
            
            % flush eyetracker?
            eyeTracker.refresh(false);
            
            % start...
            myClassifier.start();
            myGraphic.reset(300,600, aT.getDelta(), aT.getDelta());
            % Animation loop: Run until key 'QUIT' press...
            
            while myClassifier.getStatus() == myClassifier.STATUS_UNDECIDED
                
                % poll peripheral devices for valid user inputs
                InH.getInput();

                % poll eyetracker & update classifier
                [n, saccadeOnTime, blinkTime] = eyeTracker.refresh(); %#ok
                if ~isempty(saccadeOnTime)  || ~isempty(blinkTime)
                    fprintf('Blink or saccade detected. Restarting classifier\n');
                    myClassifier.start(false); % restart classifier after a saccade or blink(!)
                else
                    myClassifier.update();
                end
                
                % in case want to track progress:
                [~,propComplete] = myClassifier.interogate(); %#ok

                % pause before proceeding
                WaitSecs(1/50);
            end
            
            % issue beep to signal trial complete
            beep()  
            
            % vary weights
            w = min(w + [0 0.2], 1);
            myClassifier.setXYWeights(w);
            fprintf('Weights: x=%1.2f, y=%1.2f\n', w);
            
            % computer whether was a hit
            whatLookingAt = myClassifier.interogate();
            anscorrect = strcmpi('targ', whatLookingAt.name());
            % update the track accordingly
            aT.update(anscorrect);
            
            % give feedback
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