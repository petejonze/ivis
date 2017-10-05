function [] = ivisDemo008_advancedClassifiers1(classifiertype)
% ivisDemo008_advancedClassifiers1. Various advanced classifiers (box, log-likelihood, direction).
%
%   Edit the "classifiertype" variable to see different functionality
%
%   For more examples, see also the IvClassifier test classes in:
%       \src\+ivis\+test
%
% Requires:         ivis toolbox v1.5
%
% Matlab:           v2015 onwards
%
% See also:         ivisDemo007_classifyingFixations.m
%                   ivisDemo009_advancedClassifiers2.m
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

    % set workspace
    import ivis.classifier.* ivis.control.* ivis.graphic.* ivis.gui.* ivis.main.* ivis.log.*  ivis.broadcaster.*; 

    % user variables [Choose from the selection below]
    if nargin < 1 || isempty(classifiertype)
        fprintf('No classifier type chosen, picking a random classifer..\n');
        classifiers = {'grid', 'll', 'box', 'vector'};
        idx = randi(3); % we'll ignore vector for now, as it's unlikely to be of much interest to many users
        classifiertype = classifiers{idx};
        fprintf('Running using "%s"\n', classifiertype);
    end

    try
        % launch ivis
        IvMain.assertVersion(1.5);
        params = IvMain.initialise(IvParams.getDefaultConfig('GUI.useGUI',true, 'graphics.runScreenChecks',false));
        [eyeTracker, logs, InH, winhandle] = IvMain.launch();

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
        myGraphic2 = IvGraphic('targ2', tex, 500, 500, 100, 100, winhandle);
        
        % prepare a classifier
        timeout_secs = 15;
        switch lower(classifiertype)
            case 'll'
                myClassifier = IvClassifierLL({IvPrior(), myGraphic}, [inf 300], 360, [], timeout_secs, [], false);
            case 'box'
                %myClassifier = IvClassifierBox(myGraphic, [], [], timeout_secs); % simple 1-object case
                myClassifier = IvClassifierBox({myGraphic, myGraphic2}, [], [], timeout_secs); % more complex, 2-object case
            case 'grid'
                myClassifier = IvClassifierGrid(myGraphic, [], timeout_secs);
            case 'vector'
                myClassifier = IvClassifierVector([90 180 270 0], [], [], timeout_secs);
            otherwise
                error('mess_classifier_v4:InvalidInput','classifier type (%s) not recognisied.\nChoose from: %s', classifiertype, strjoin(',','ll2d','ll1d','box'));
        end
        % show on stimulus screen
        myClassifier.show(); % draw the box around the graphic
        
        % set background colour to white (to make cursor easier to see)     
        Screen('FillRect', winhandle, [255 255 255]);
        DrawFormattedText(winhandle, 'Press SPACE to start'); % give feedback on PTB screen
        Screen('Flip', winhandle);
            
        % handles to outputs
        dataOutputFiles = {};
        rawOutputFile = logs.raw.fullFn;
        diaryFile = params.log.diary.fullFn;
        
        % #################
        while ~aT.isFinished

            % WAIT FOR GO KEY
            fprintf('\nReady. Press SPACE to start trial\n');
            while InH.getInput() ~= InH.INPT_SPACE.code
              	eyeTracker.refresh(false); % false to supress logging
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
                if myGraphic.getX < (params.graphics.monitorWidth-aT.getDelta())
                    myGraphic.nudge(params.graphics.monitorWidth/150,0);
                end
                myGraphic.draw()

                % poll eyetracker & update classifier
                n = eyeTracker.refresh(); %#ok     
              	myClassifier.update();

                % Show rendered image at next vertical retrace:
                DrawFormattedText(winhandle, 'Look!'); % give feedback on PTB screen
                Screen('Flip', winhandle);
                WaitSecs(.01);
            end
            
            % computer whether was a hit
            whatLookingAt = myClassifier.interogate();
            anscorrect = strcmpi('targ', whatLookingAt.name());
            % update the track accordingly
            aT.update(anscorrect);
            
            % give feedback on PTB screen
            txt = sprintf('You looked at: "%s". Press SPACE to continue', whatLookingAt.name());
            DrawFormattedText(winhandle, txt);
            
            Screen('Flip', winhandle);
            fprintf('You looked at: %s\n', whatLookingAt.name());
            
            % save and reset data log
            [~, fullFn] = logs.data.save([], false); % ALT: IvDataLog.getInstance().save();
            dataOutputFiles{end+1} = fullFn; %#ok<AGROW>
        end

        % Finish up
        delete(aT);
        IvMain.finishUp();
        
        % Show files & delete if so desired
        fprintf('The current files were generated:\n')
        files = [dataOutputFiles rawOutputFile diaryFile];
        for i = 1:length(files)
            fprintf('  [%i] %s\n', i, files{i});
        end
        % query for deletion
        commandwindow(); % set focus on command window
        if getLogicalInput('Delete these files? (y/n): ')
            for i = 1:length(files)
                delete(files{i});
            end
            fprintf('deleted\n');
        end
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