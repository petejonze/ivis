function [xy, isSignal, maxSecs, xy_est, classification, timings] = mess_classifierComparison_v2(classifierType, nTrialsPerCell, nCells, breakAfterTrial, xy, isSignal, maxSecs)

    % init
    IvMain.finishUp();
    close all
    Screen('closeall');
    clearJavaMem();
    import ivis.classifier.* ivis.control.* ivis.graphic.* ivis.gui.* ivis.main.* ivis.data.*; 

    % variables
    minTrialDuration = 1.6;
    dotSize = 30; % width/diameter in pixels
    maxTrialDuration = 4.5;

    % validate user input
    classifierType = lower(classifierType);
    if ~ismember(classifierType,{'box','ll'})
        error('mess_classifierComparison_v1:invalidInput','Unknown classifier type ''%s''', classifierType)
    end
    if ~isPositiveInt(nTrialsPerCell)
        error('a:b','c');
    end
    if ~isPositiveInt(nCells)
        error('a:b','c');
    end
    if nargin < 5
        xy = [];
        isSignal = [];
        maxSecs = [];
    elseif size(xy,1) ~= (nTrialsPerCell * nCells^2) || size(isSignal,1) ~= (nTrialsPerCell * nCells^2) || size(maxSecs,1) ~= (nTrialsPerCell * nCells^2)
        error('a:b','c');
    end

    % ###########
    try
        % Is the script running in OpenGL Psychtoolbox?
        AssertOpenGL();
        
%         [eyeTracker,params] = IvMain.initialise('_configs/IvConfig_mess_classifierComparison.xml');
        [eyeTracker,params] = IvMain.initialise('_configs/IvConfig_mess_classifierComparison_kite.xml');
        
        %get handle to an InputHandler object, that will map inputs to
        InH = InputHandler(false, [], {'w','q','a','s','x','z'});
        
        winhandle = params.graphics.winhandle;
        
        Screen('BlendFunction', winhandle, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        % PREPARE
        nTrialsTotal = nTrialsPerCell * nCells^2;
        %
        if isempty(xy)
            cellW = 1/nCells; % width of each grid (normalised units)
            cellLB = linspace(0,1-cellW,nCells); % lower bounds
            
            xLB = ones(nCells,1)*cellLB;
            yLB = (ones(nCells,1)*cellLB)';
            xLB = repmat(xLB(:), nTrialsPerCell, 1);
            yLB = repmat(yLB(:), nTrialsPerCell, 1);
            
            xy = rand(nTrialsTotal,2)*cellW + [xLB yLB];
            idx = Shuffle(1:nTrialsTotal);
            xy = xy(idx,:);
            % convert to pixels
            xy = bsxfun(@times, xy, [params.graphics.testScreenWidth params.graphics.testScreenHeight]);
            % for testing
            % close all;
            % scatter(xy(:,1), xy(:,2))
            
            isSignal = rand(nTrialsTotal,1) > .1; % 10%
        end
        if isempty(maxSecs)
            maxSecs = .4 + (rand(nTrialsTotal,1)*1.2);
        end
        xy_est = nan(nTrialsTotal,2);
      	classification = nan(nTrialsTotal,1);
        timings = nan(nTrialsTotal,3);
        
        % ########
        myGraphic = IvGraphic('target', [], [], [], [], [], IvHfGUmix2D([0 0], [125 125], .95, false), winhandle);
        myPrior = IvPrior(IvHfUniform2D());
        %
        switch lower(classifierType)
            case 'box'
                myClassifier = IvClassifierBox();
            case 'll'
                myClassifier = IvClassifierLL({myPrior, myGraphic});
            otherwise % defensive. Checked above already
               	error('mess_classifierComparison_v1:invalidInput','Unknown classifier type ''%s''', classifierType)
        end
        

        

                
ivis.gui.showTrackBox();

%         WAIT FOR GO KEY
        while InH.getInput() ~= InH.INPT_SPACE.code
            eyeTracker.refresh(false); % false to supress logging
            WaitSecs(.05);
        end
        
dataLog = ivis.data.IvDataLog.getInstance();



        fprintf('Started\n\n');   
        % #################
        for i = 1:nTrialsTotal

% if ~isSignal(i)
%     fprintf('noise\n');
% 	beep();
% end
            % add some random jitter to prevent the human observer from
            % guessing
            WaitSecs(.2 + rand()*.3);
            

            % set graphic position
            myGraphic.reinitXY(xy(i,1), xy(i,2));
            
            % flush eyetracker?
            eyeTracker.flush();
            
            % start...####
            myClassifier.start();
            
            % Animation loop: Run until key 'QUIT' press...
            startTime = GetSecs();
            userSaccadeTime = [];
            autoSaccadeTime = [];
            %while (myClassifier.lookedAt() == myClassifier.STATUS_UNDECIDED) && ((GetSecs()-startTime) < maxSecs) 
            while 1
                timeElapsed = (GetSecs()-startTime);
                if (timeElapsed > maxTrialDuration)
                    beep();
                    break;
                end
                if (timeElapsed > minTrialDuration) && ~isempty(userSaccadeTime)
                    if ~isempty(autoSaccadeTime) || (GetSecs() > (userSaccadeTime(1)+.3))
                        break;
                    end
                end

                % poll peripheral devices for valid user inputs
                [usrInput, t] = InH.getInput();
                if usrInput == InH.INPT_SPACE.code
                    userSaccadeTime = [userSaccadeTime t];
                end
                
                % update graphics
                if isSignal(i)
                    Screen('DrawDots', winhandle, xy(i,:), dotSize, [.1 .8 .5], [], 1);
                    Screen('DrawingFinished', winhandle);
                end
                
                % poll eyetracker
                [n,t] = eyeTracker.getInstance().refresh();
                if ~isempty(t)
                    autoSaccadeTime = [autoSaccadeTime t];
                end
                
                if (n > 0) && (timeElapsed <= maxSecs(i)) %(myClassifier.lookedAt() == myClassifier.STATUS_UNDECIDED)
                    myClassifier.update();
                end

                % Show rendered image at next vertical retrace:
                Screen('Flip', winhandle);
                
                WaitSecs(.01);
            end
            
            xy_est(i,:) = mean(dataLog.getLastN(20, 1:2));
            
            if isempty(userSaccadeTime)
                userSaccadeTime = NaN;
            end
            if isempty(autoSaccadeTime)
                autoSaccadeTime = NaN;
            end
            timings(i,:) = [startTime userSaccadeTime(1) autoSaccadeTime(1)];
            
            % computer whether was a hit   
            lookObj = myClassifier.interogate();
            if isempty(lookObj)
                classification(i) = NaN;
            else
                if strcmpi(classifierType,'box')
                    targName = myClassifier.getPolyName(xy(i,1),xy(i,2));
                else
                    targName = 'target';
                end
                
                classification(i) = strcmpi(lookObj.name, targName);
%                 if classification(i)
%                     beep()
%                 end
            end
            
            % Reset
            myClassifier.reset();
            dataLog.reset(); %IvDataLog.getInstance().dumpLog();
            
        	% (check for) break-time
            if ismember(i, breakAfterTrial) % take a break if one due
                fprintf('Trial %i of %i\n<<<<<<<<<<<< BREAK >>>>>>>>>>>>\n\n', i, nTrialsTotal);
                ivis.gui.showTrackBox();
            end   
        end

        % Finish up
        dataLog = [];
        try
            delete(myClassifier);
            lcl_finishUp(InH);
        catch ME1
            disp(ME1)
        end
        fprintf('\n\nall done!\n');
        
        % END OF SCRIPT
    catch ME

        try
            lcl_finishUp(InH);
        catch ME1
            disp(ME1)
        end
        
        fprintf('\n\nABORTED (error)\n');
        rethrow(ME);
    end
end

function [] = lcl_finishUp(InH)
    % Close onscreen window and release all other ressources:
    Screen('CloseAll');

    % Finish up
    try
        delete(InH); % ensure no objects hanging around in memory
    catch ME
        disp(ME);
    end

    try
        ivis.main.IvMain.finishUp();
    catch ME
        disp(ME);
    end
end