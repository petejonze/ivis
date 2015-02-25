classdef (Abstract) IvClassifier < ivis.broadcaster.IvListener
	% Generic class for maintaining the level of evidence in favour of each
	% potential Area of Interest. Provides methods for the user to query
	% what is the most likely fixation target.
    %
    % IvClassifier Abstract Methods:
    %   * draw  - Visualise classifier on a PTB OpenGL screen.
    %
    % IvClassifier Methods:
    %   * IvClassifier  - Constructor.
    %   * setCriterion  - Modify decision criteria.         
    %   * start         - Start accruing evidence towards each alternative.
	%   * update        - Update evidence.
    %   * getStatus     - Get current status code.
	%   * isUndecided   - Convenience wrapper for: obj.status == obj.STATUS_UNDECIDED.
	%   * interogate    - Make an (optionally forced) response, based on current level of evidence (if unforced may return obj.NULL_OBJ).
	%   * show          - Enable automatic PTB screen texture drawing, allowing the observer to see the classification area(s).
	%   * hide          - Disable automatic PTB screen texture drawing.
    %
    % See Also:
    %   none
    %
    % Example:
    %   none
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 02/2013 : first_build\n
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
       
    properties (GetAccess = public, SetAccess = protected)
        graphicObjs
        graphicObjNames
        guiElement
     	status = ivis.classifier.IvClassifier.STATUS_UNDECIDED;
        
        % decision variables
        nAlternatives	% number of possible fixation targets
        evidence        % evidence in favour of each alternative
        criterion       % level(s) of evidence necessary (can be set independently for each alternative)
        timeout         % time before a decision is forced, in seconds
        
        % buffer
        bufferLength
        rawbuffer
 
        % ramp
        startTime
        onsetRampStart
        onsetRampDuration
        onsetRampEnd
        
    	% for drawing
        winhandle
    end
    
    properties (Constant)
        STATUS_RETIRED = -1;
        STATUS_UNDECIDED = 0;
        STATUS_HIT = 1;
        STATUS_MISS = 2;    
        NULL_OBJ = struct('name', 'nothing');
        TIMEOUT_OBJ = struct('name', 'timeout');
    end

    
    %% ====================================================================
    %  -----ABSTRACT PUBLIC METHODS-----
    %$ ====================================================================
    
    methods(Abstract, Access = protected)
        
        % Update classifier parameters (e.g., if graphics have moved).
        % N.b., this is done separately from updateEvidence because we want
        % to update the GUI regularly even if the classifier isn't being
        % refreshed.
        %
        % @date     26/06/14
        % @author   PRJ
        %
        updateParams(obj)
        
        % Update evidence in favour of each alternative / classification
        % hypothesis.
        %
        % @date     26/06/14
        % @author   PRJ
        %
        updateEvidence(obj)
        
        % Return the object at index i. Each object is a possible area of
        % interest.
        %
        % @param    i   index number
        %
        % @date     26/06/14
        % @author   PRJ
        %
        o = getClassObj(obj,i)
        
        % perform any resetting specific to each classifier type - pass
    	% in any user-supplied arguments (i.e., from myClassifier.start()).
        %
        % @param    varargin   optional parameters
        %
        % @date     24/07/14
        % @author   PRJ
        %
        classifierSpecificReset(obj, varargin)
    end
    
    methods(Abstract, Access = public)

        % Visualise classifier on a PTB OpenGL screen (e.g., draw a hit-box
        % rectangle around the graphic). N.b., if this does not work,
        % ensure that you have called "import.broadcaster.*" in your
        % script, and that you have NOT used Screen('DrawingFinished').
        %
        % @param	src     Event source
        % @param	evnt    Event object
        %
        % @date     26/06/14
        % @author   PRJ
        %
        draw(obj, src, evnt)
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
      
    methods(Access = public)
        
        %% == CONSTRUCTOR =================================================
      
        function obj = IvClassifier(graphicObjsOrNAlternatives, criterion, timeout, bufferLength, onsetRampStart, onsetRampDuration)   
         	% IvClassifier Constructor.
            %
            % @param    graphicObjsOrNAlternatives  cell-array of IvGraphic objects, or the number of alternatives
            % @param    criterion           evidence threshld (scalar, or vector with 1 per alternative)
            % @param	timeout             time, in seconds, before forcing a choice
            % @param	bufferLength        number of gaze samples to store
            % @param	onsetRampStart      amount of time (secs) before starting to ramp evidence-weighting on
            % @param	onsetRampDuration   amount of time (secs) before evidence-weighting = 1
            % @return	obj                 IvClassifier object
            %
            % @date     26/06/14
            % @author   PRJ
            %  
            
            % parse inputs
            params = ivis.main.IvParams.getInstance();
            if nargin < 3 || isempty(timeout)
                timeout = inf;
            end
            if nargin < 4 || isempty(bufferLength)
                bufferLength = params.classifier.bufferLength;
            end            
            if nargin < 5 || isempty(onsetRampStart)
                onsetRampStart = params.classifier.onsetRampStart;
            end
            if nargin < 6 || isempty(onsetRampDuration)
                onsetRampDuration = params.classifier.onsetRampDuration;
            end
            
            % graphic objects (these are the things we will attempt to
            % classify)
            if isempty(graphicObjsOrNAlternatives)
                error('a:b','c');
            end
            if isPositiveInt(graphicObjsOrNAlternatives)
                obj.nAlternatives = graphicObjsOrNAlternatives;
                obj.graphicObjs = {};
            else
                if ~iscell(graphicObjsOrNAlternatives)
                    graphicObjsOrNAlternatives = {graphicObjsOrNAlternatives};
                end
                obj.graphicObjs = graphicObjsOrNAlternatives;
                obj.graphicObjNames = cell(1, length(obj.graphicObjs));
                for i = 1:length(obj.graphicObjs)
                    obj.graphicObjNames{i} = obj.graphicObjs{i}.name;
                end
                obj.nAlternatives = length(obj.graphicObjs);
            end
            
            % timout (max time to run before retiring)
            obj.timeout = timeout;
            
            % onset ramp
            obj.onsetRampStart = onsetRampStart;
            obj.onsetRampDuration = onsetRampDuration;
            obj.onsetRampEnd = onsetRampStart + onsetRampDuration;
            
            % evidence
            obj.evidence = zeros(1, obj.nAlternatives);
            if length(criterion)==1
                criterion = repmat(criterion,1,obj.nAlternatives); % assume same for all
            end
            obj.criterion = criterion;
            
            % create circular buffers for internal data
            obj.bufferLength = bufferLength;
        end
        
        function [] = delete(obj)
            % IvClassifier Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            for i = 1:length(obj.graphicObjs)
                if ishandle(obj.graphicObjs{i})
                    delete(obj.graphicObjs{i});
                end
            end
            obj.graphicObjs = [];
            
            obj.hide(); % includes broadcaster unsubscription
            obj.winhandle = [];
            obj.guiElement = [];
        end
        
                
        %% == METHODS =====================================================
        
        function [] = setCriterion(obj, criterion)
            % Modify decision criteria.
            %
            % @return   criterion   new value(s)
            %
            % @date     30/07/14
            % @author   PRJ
            %
            if length(criterion)==1
                criterion = repmat(criterion,1,obj.nAlternatives); % assume same for all
            end
            obj.criterion = criterion;
        end
        
        function t = start(obj, varargin)
            % Start accruing evidence towards each alternative.
            %
            % @return   t   time when classification commenced (secs)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.reset(varargin{:});
            t = GetSecs();
            obj.startTime = t;
        end
        
        function status = update(obj)
            % Update evidence.
            %
            % @return   status      classifier status (e.g., obj.STATUS_UNDECIDED)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if obj.status ~= obj.STATUS_UNDECIDED
                return;
            end
            
            % get data
            xyt = obj.getData();

            % update the classification parameters (e.g., hitbox position,
            % used to visualise the hitbox on the screen). n.b., this is
            % done here to ensure that it always accomplished, even if no
            % new eyetracking data has been delivered)
            obj.updateParams();
            
            % don't bother coninuing if no new data
            if ~isempty(xyt)
                % update evidence
                obj.updateEvidence(xyt);
                
                % check that during the evidence update the subclass
                % classifier hasn't forced a decision (e.g., a path
                % deviation during ClassifierBox)
                if obj.status ~= obj.STATUS_UNDECIDED
                    return;
                end
            
                % evaluate
                lookingAt = obj.interogate();
                status = obj.updateStatus(lookingAt);
                
                % update GUI if necessary
                if ~isempty(obj.guiElement)
                    obj.updateGUI(xyt(:,1:2),lookingAt);
                end
            end

        end
        
        function STATUS_CODE = getStatus(obj)
            % Get current status code.
            %
            % @return   STATUS_CODE  classifier status (e.g., obj.STATUS_UNDECIDED)   
            %
            % @date     26/06/14
            % @author   PRJ
            %
            STATUS_CODE = obj.status;
        end
        
        function isund = isUndecided(obj)
            % Convenience wrapper for: obj.status == obj.STATUS_UNDECIDED.
            %
            % @return   isund   if classifier is still undecided
            %
            % @date     26/06/14
            % @author   PRJ
            %
            isund = obj.status==obj.STATUS_UNDECIDED;
        end
        
        function mostLikelyGraphicObj = interogate(obj, forcedChoice)
            % Make an (optionally forced) response, based on current level
            % of evidence (if unforced may return obj.NULL_OBJ).
            %
            % @param    forcedChoice    whether to force the choice
            % @return   mostLikelyObj   the most likely fixation object
            %
            % @date     26/06/14
            % @author   PRJ
            %                
           
            % parse inputs
            if nargin < 2 || isempty(forcedChoice)
                forcedChoice = false;
            end
            
            % check for timeout
            if obj.status == obj.STATUS_RETIRED
                mostLikelyGraphicObj = obj.TIMEOUT_OBJ;
                return;
            end
            
            % init
          	mostLikelyGraphicObj = obj.NULL_OBJ;
                
            % return empty if currently no evidence
            if all(obj.evidence == 0)
                return
            end
            
            % find if any above threshold
            aboveThresh = obj.evidence > obj.criterion;
            if any(aboveThresh)
                tmp = Shuffle(find(aboveThresh)); idx = tmp(1); % only 1 should be above thresh, but if a tie-break should arise for some reason, shuffle and take the first
                mostLikelyGraphicObj = obj.getClassObj(idx);          
                return
            end
            
            % if a forced choice find the one with the greatest evidence
            % (even though not above threshold)
            if forcedChoice
                % get greatest
                [~,idx] = max(obj.evidence);
                tmp = Shuffle(find(idx)); idx = tmp(1); % only 1 should be above thresh, but if a tie-break should arise for some reason, shuffle and take the first
                mostLikelyGraphicObj = obj.getClassObj(idx);
            end
        end
        
        function [] = show(obj)
            % Enable automatic PTB screen texture drawing, allowing the
            % observer to see the classification area(s).
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % sign up to broadcast manager (called at every refresh
            % invocation)
            obj.startListening('PreFlip', @obj.draw);
        end
        
        function [] = hide(obj)
        	% Disable automatic PTB screen texture drawing.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % stop listening
            obj.stopListening('PreFlip');
        end
        
        function [] = forceAnswer(obj, i)
            if i == 0
                obj.updateStatus(ivis.graphic.IvPrior());
            else
                obj.evidence(i) = obj.criterion(i) + 1;
                obj.updateStatus(obj.interogate());
            end  
        end
        
    end
    
    
  	%% ====================================================================
    %  -----PROTECTED-----
    %$ ====================================================================
    
    methods(Access = protected)
        
        function [] = updateGUI(obj, xy, lookingAt)
        	% Refresh any associated GUI window.
            %
            % @param    xy          latest gaze estimate
            % @param 	lookingAt   most likely fixation target (potentially obj.NULL_OBJ)
            %
            % @date     26/06/14
            % @author   PRJ
            %   
            obj.guiElement.update(xy, obj.evidence);
            if (obj.status ~= obj.STATUS_UNDECIDED)
                obj.guiElement.printStatus(obj.status, lookingAt);
            end
        end
        
        function [] = reset(obj, varargin)
          	% Reset the classifier; clear buffers and graphics.
            %
            % @date     26/06/14
            % @author   PRJ
            %   
            
            % recreate circular buffers for internal data
            if ~isempty(obj.rawbuffer)
                obj.rawbuffer.clear();
            end
            % reset evidence vector
            obj.evidence = zeros(1, obj.nAlternatives);
            % set status flags
            obj.status = obj.STATUS_UNDECIDED;
            % reset plot
            if ~isempty(obj.guiElement)
                obj.guiElement.reset();
            end
            % if reusing the same graphic objects over and over (this way don't
            % have to bother making new objects and closing/opening gui
            % instances)
            for i = 1:length(obj.graphicObjs)
                obj.graphicObjs{i}.reset();
            end
            
            % perform any resetting specific to each classifier type - pass
            % in any user-supplied arguments (i.e., from
            % myClassifier.start()).
          	obj.classifierSpecificReset(varargin{:});
        end
       
        function xyt = getData(obj) %#ok
            % GETDATA dfdfdf.
            %
            % @return   xyt     latest xyt gaze data (+timestamp)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % get recent data (not previously processed)
            xyt = ivis.log.IvDataLog.getInstance().getTmpBuff(1:3); % n.b., this will include and drift-correction, etc
            
            % ALT(?):
            % xyt = ivis.log.IvDataLog.getInstance().getSinceT(obj.lastEvaluatedTimepoint, 1:3);
            % xyt = ivis.log.IvDataLog.getInstance().getLastN(4, 1:3);
            
            % remove any NaN points to prevent them screwing up the PDF
            % calc later
            xyt(any(isnan(xyt),2),:) = []; %ALT: xyt = xyt(~any(isnan(xyt),2),:);
        end
        
        function w = getOnsetRamp(obj, t)
            % Compute an on-ramp to weight evidence by (to prevent early/
            % spurious decisions).
            %
            % @param    t   time vector
            % @return   w   ramp vector (0 <= x <= 1)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if isempty(obj.startTime)
                warning('no start time was recorded, (re)starting the timer from now');
                obj.startTime = GetSecs();
            end
            
            if t(1) > (obj.onsetRampEnd+obj.startTime)
                w = ones(size(t));
            else
                w = min(1, max(0, ((t-obj.startTime)-obj.onsetRampStart)/(obj.onsetRampEnd-obj.onsetRampStart)));
            end
        end

        function status = updateStatus(obj, gObj)
            % Update the current classification estimate, check if any
            % evidence/time criteria have been reached
            % (obj.STATUS_UNDECIDED if no decision yet reached).
            %
            % @param    gObj    screen object
            % @return   status  classifier status (e.g., obj.STATUS_UNDECIDED)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if (GetSecs()-obj.startTime) > obj.timeout;
                status = obj.STATUS_RETIRED; % give up
            else
                switch lower(gObj.name)
                    case obj.NULL_OBJ.name
                        status = obj.STATUS_UNDECIDED;
                    case 'prior' % ALT: ivis.graphic.IvScreenObject.TYPE_PRIOR
                        status = obj.STATUS_MISS;
                    otherwise
                        status = obj.STATUS_HIT;
                end
            end        
            obj.status = status;
        end
    end
    
end