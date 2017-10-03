classdef IvClassifierLL < ivis.classifier.IvClassifier
    % Singleton instantiation of IvClassifier, in which the decision
    % variable is weighted cumulative-loglikelihood proportions, computed
    % using some specified underlying probability-density-function(s).
    %
    % When using a log-likelihood classifier (IvClassifierLL), the
    % likelihoods are calculated in the Update method (and then stored
    % for future use). Except to be precise it is actually the relative
    % proportions of the log-likelihoods that is important, and it is
    % the cumulative sum of the log-likelihoods. So the key variable is
    % wcllp (the weighted-cumulative-log-likelihhood-proportions). This
    % method queries the eyetracker for data, queries the graphics
    % objects for their positions at each data timepoint, and
    % calculates the log-likelihoods accordingly. It is given all the
    % necessary handles on initialisation, so that it knows where/what
    % to ask for the data.
    %
    % n.b., currently 1D classifier will always use the x-axis only
    %
    % http://www-structmed.cimr.cam.ac.uk/Course/Likelihood/likelihood.html
    %
    % IvClassifierLL Methods:
    %   * IvClassifierLL- Constructor.
    %   * start         - Start accruing evidence towards each alternative.
	%   * update        - Update evidence.
    %   * getStatus     - Get current status code.
	%   * isUndecided   - Convenience wrapper for: obj.status == obj.STATUS_UNDECIDED.
	%   * interogate    - Make an (optionally forced) response, based on current level of evidence (if unforced may return obj.NULL_OBJ).
    %   * draw          - Visualise classifier on a PTB OpenGL screen.
	%   * show          - Enable automatic PTB screen texture drawing, allowing the observer to see the classification area(s).
	%   * hide          - Disable automatic PTB screen texture drawing.
    %
    % See Also:
    %   IvClassifierBox, IvClassifierGrid, IvClassifierVector
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

    properties (GetAccess = private, SetAccess = private)
        hitFuncs = {}
        xyWeights = [1 1];
        % for drawing
        stdNullrect
        stdRect
        drawColor
        % misc
        printDebugInfoToConsole = false;
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
      
    methods (Access = public)

    	%% == CONSTRUCTOR =================================================
        
        function obj = IvClassifierLL(graphicObjs, likelihoodThresh, bufferlength, GUIidx, timeout_secs, xyWeight, printDebugInfoToConsole)
            % IvClassifierLL Constrcutor.
            %
            % @param    graphicObjs         IvGraphic object(s) to classify
            % @param    likelihoodThresh    require log-likelihood threshold
            % @param    bufferlength        size of circular data buffer
            % @param    GUIidx              GUI panel number
            % @param    timeout_secs      	amount of time to wait before forcing a decision
            % @param    xyWeight            relative weight to give the X and Y data dimensions
            % @param    printDebugInfoToConsole     for debugging
            % @return 	obj                 IvClassifierLL object
            %
            % @date     26/06/14
            % @author   PRJ
            %    

            % parse inputs
            params = ivis.main.IvParams.getInstance();
            if nargin < 2 || isempty(likelihoodThresh)
                likelihoodThresh = params.classifier.loglikelihood.likelihoodThresh;
            end
            if nargin < 3 || isempty(bufferlength)
                bufferlength = [];
            end
            if nargin < 4 || isempty(GUIidx)
                GUIidx = params.classifier.GUIidx;
            end
            if nargin < 5
                timeout_secs = [];
            end
            if nargin < 6
                xyWeight = [];
            end
            if nargin < 7
                printDebugInfoToConsole = [];
            end

            % validate
            if ~isempty(GUIidx) && ~params.GUI.useGUI
               fprintf('IvClassifier: GUI is disabled, so specified GUI index will be ignored\n'); 
               GUIidx = [];
            end
            %if any(likelihoodThresh>=1 | likelihoodThresh<0)
            %    warning('some likelihood thresholds lie outside of 0-1 range (can never be reached)')
            %end
            
            % call superclass
            obj = obj@ivis.classifier.IvClassifier(graphicObjs, likelihoodThresh, timeout_secs, bufferlength);

            % init draw params
            nGraphicObjs = length(graphicObjs);
            obj.stdRect = nan(4, nGraphicObjs);
            obj.drawColor = repmat([255 100 255]', 1, nGraphicObjs); % 1 column per rect
            
            % construct hit functions (and draw params)
            hitFuncs = {};
            for i = 1:nGraphicObjs
                if graphicObjs{i}.type() == graphicObjs{i}.TYPE_PRIOR
                    hitFuncs{i} = ivis.math.pdf.IvHfUniform2D();
                else
                    mu_px   	= [graphicObjs{i}.getX() graphicObjs{i}.getY()];
                    sigma_px    = [graphicObjs{i}.width graphicObjs{i}.height] / 2; % ARBITRARY?
                    minmaxBounds_px  = [];
                    pedestalMagn_p = [];
                    hitFuncs{i} = ivis.math.pdf.IvHfGauss2D(mu_px, sigma_px, minmaxBounds_px, pedestalMagn_p);
                    % 2D draw params
                    w = sigma_px(1) * 4; % 4std in diameter (2std in radius)
                    h = sigma_px(2) * 4;
                    obj.stdNullrect(:,i) = [0 0 w h] - [w h w h]/2;
                end
            end
            obj.hitFuncs = hitFuncs;

            % initialise rawbuffer
            obj.rawbuffer = CCircularBuffer(obj.bufferLength, obj.nAlternatives);
            
            % initialise GUI element if GUIidx specified
            if ~isempty(GUIidx)
                obj.guiElement = ivis.gui.IvGUIclassifierLL(GUIidx, obj.criterion, graphicObjs, hitFuncs);
            end
            
            % set xyWeight
            if ~isempty(xyWeight)
                obj.setXYWeights(xyWeight);
            end
            
            % store
            if ~isempty(printDebugInfoToConsole)
                obj.printDebugInfoToConsole = printDebugInfoToConsole;
            end
        end
        
        %% == METHODS =====================================================
        
        function [] = draw(obj, ~, ~) % interface implementation
            if isempty(obj.winhandle)
                % get winhandle
                params = ivis.main.IvParams.getInstance();
                obj.winhandle = params.graphics.winhandle;
            end
            
            % draw
          	Screen('FrameOval', obj.winhandle, obj.drawColor, obj.stdRect, 3);
          	%Screen('FrameRect', obj.winhandle, obj.drawColor, obj.stdRect, 3); % 1D version: actually appears as 2 vertical lines
        end
        
        function [] = setXYWeights(obj, w)
            if size(w,2)~=2
                error('weight vector must be a 2 column matrix')
            end
            if max(w)~=1
                error('the largest weight must equal 1')
            end
            if any(w)<0
                error('no weight may be less than 0')
            end
            
            % set
            obj.xyWeights = w;
        end
        
    end

    
	%% ====================================================================
    %  -----PROTECTED METHODS-----
    %$ ====================================================================
      
    methods (Access = protected)
        
        function [] = updateParams(obj) % interface implementation
            for i = 1:length(obj.graphicObjs)
                % update hitbox rectangles
                if obj.graphicObjs{i}.type() ~= obj.graphicObjs{i}.TYPE_PRIOR % ??????
                    xy = obj.graphicObjs{i}.getXY();
                    obj.hitFuncs{i}.update(xy);
                    obj.stdRect(:,i) = obj.stdNullrect(:,i) + [xy xy]';
                end
            end
        end
        
        function [] = updateEvidence(obj, xyt, varargin) % interface implementation
            nGraphicObjs = length(obj.graphicObjs);
            
            % calc log-likelihood 
            ll = nan(size(xyt,1),nGraphicObjs);
            for i = 1:nGraphicObjs % any way to vectorize this?
                itrackxy = xyt(:,1:2);
                ll(:,i) = obj.hitFuncs{i}.getPDF(itrackxy, obj.xyWeights);
            end
            
            % convert to proper probabilities (alternatives sum to 1), and
            % log
            ll = log(bsxfun(@rdivide, ll, sum(ll,2)));

            % apply temporal weighting
            w = obj.getOnsetRamp(xyt(:,3));
            ll = bsxfun(@times, ll, w);
            
            % add to buffer
            obj.rawbuffer.put(ll);
            
            % cumulative       
            cll = nansum(obj.rawbuffer.get(),1); % sum loglikelihoods

            % convert to proportions
            y = (ones(nGraphicObjs,1)*cll)';
            cllp = cll - logsum(reshape(y(~eye(nGraphicObjs)),nGraphicObjs-1,nGraphicObjs));

            % for debugging (expensive!)
            if obj.printDebugInfoToConsole
                for i = 1:length(cll)
                    fprintf('%1.5f    ', cll(i));
                end
                for i = 1:length(cll)
                    fprintf('%1.5f    ', cllp(i));
                end
                fprintf('\n');
            end
            
            % store        
            obj.evidence = cllp;
        end

        function o = getClassObj(obj, i) % interface implementation       
            o = obj.graphicObjs{i};
        end
        
        function [] = classifierSpecificReset(obj) %#ok interface implementation
            % do nothing
        end
    end
    
end