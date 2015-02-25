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
    %   * IvClassifierLL	- Constructor.
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
        is2D
        % for drawing
        stdNullrect
        stdRect
        drawColor
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
      
    methods (Access = public)

    	%% == CONSTRUCTOR =================================================
        
        function obj = IvClassifierLL(dims, graphicObjs, lMagThresh, hitFuncs, GUIidx, timeout_secs)
            % IvClassifierLL Constrcutor.
            %
            % @param    dims        '1D' or '2D'
            % @param    graphicObjs IvGraphic object(s) to classify
            % @param    lMagThresh  require log-likelihood threshold
            % @param    hitFuncs 	IvHitFunc object(s)
            % @param    GUIidx      GUI panel number
            % @return 	obj         IvClassifierLL object
            %
            % @date     26/06/14
            % @author   PRJ
            %    

            % parse inputs
            params = ivis.main.IvParams.getInstance();
            if nargin < 2 || isempty(dims)
                dims = '1D';
            end
            if nargin < 3 || isempty(lMagThresh)
                lMagThresh = params.classifier.loglikelihood.lMagThresh;
            end
            if nargin < 4 || isempty(hitFuncs)
                hitFuncs = {};
            end
            if nargin < 5
                GUIidx = params.classifier.GUIidx;
            end
            if nargin < 6
                timeout_secs = [];
            end

            % validate
            if ~strcmpi(dims,{'1D','2D'})
                error('IvClassifierLL:invalidDimensionality','Input not recognised (%s)\nMust be one of: 1D, 2D', dims);
            end
            if ~isempty(GUIidx) && ~params.GUI.useGUI
               fprintf('IvClassifier: GUI is disabled, so specified GUI index will be ignored\n'); 
               GUIidx = [];
            end
            
            % call superclass
            obj = obj@ivis.classifier.IvClassifier(graphicObjs, lMagThresh, timeout_secs);
            
            if strcmpi(dims, '2D')
                obj.is2D = true;
            else
                obj.is2D = false;
            end
            
            % init draw params
            n = length(graphicObjs);
            obj.stdRect = nan(4, n);
            obj.drawColor = repmat([255 100 255]', 1, n); % 1 column per rect
            
            % construct hit functions (and draw params)
            if isempty(hitFuncs)
                for i = 1:n
                    if obj.is2D
                        if graphicObjs{i}.type() == graphicObjs{i}.TYPE_PRIOR
                            hitFuncs{i} = ivis.math.pdf.IvHfUniform2D();
                        else
                            muOffset = [0 0];
                            sigma = [graphicObjs{i}.width graphicObjs{i}.height] / 2 % ARBITRARY?
                            gaussRatio = .95;
                            hitFuncs{i} = ivis.math.pdf.IvHfGUmix2D(muOffset, sigma, gaussRatio);
                            % 2D draw params
                            w = sigma(1) * 4; % 4std in diameter (2std in radius)
                            h = sigma(2) * 4;
                            obj.stdNullrect(:,i) = [0 0 w h] - [w h w h]/2;
                        end
                    else
                        if graphicObjs{i}.type() == graphicObjs{i}.TYPE_PRIOR
                            hitFuncs{i} = ivis.math.pdf.IvHfUniform();
                        else
                            muOffset = 0;
                            sigma = [graphicObjs{i}.width] / 8 % ARBITRARY?
                            gaussRatio = .95;
                            hitFuncs{i} = ivis.math.pdf.IvHfGUmix(muOffset, sigma, gaussRatio);
                            % 1D draw params
                            w = sigma * 16;  % 8std in diameter (4std in radius)
                            h = ivis.main.IvParams.getInstance().graphics.testScreenHeight / .55; % slightly bigger than half the screen, to ensure it goes off the top/bottom
                            obj.stdNullrect(:,i) = [0 0 w h] - [w h w h]/2;
                        end
                    end
                end
            end
            obj.hitFuncs = hitFuncs;

            % initialise rawbuffer
            obj.rawbuffer = CCircularBuffer(obj.bufferLength, obj.nAlternatives);
            
            % initialise GUI element if GUIidx specified
            if ~isempty(GUIidx)
                obj.guiElement = ivis.gui.IvGUIclassifierLL(GUIidx, obj.criterion, graphicObjs, hitFuncs);
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
            if obj.is2D
                Screen('FrameOval', obj.winhandle, obj.drawColor, obj.stdRect, 3);
            else
                Screen('FrameRect', obj.winhandle, obj.drawColor, obj.stdRect, 3); % actually appears as 2 vertical lines
            end
        end
    end

    
	%% ====================================================================
    %  -----PROTECTED METHODS-----
    %$ ====================================================================
      
    methods (Access = protected)
        
        function [] = updateParams(obj) % interface implementation
            for i = 1:length(obj.graphicObjs)
                % update hitbox rectangles
                if obj.graphicObjs{i}.type() ~= obj.graphicObjs{i}.TYPE_PRIOR
                    xy = obj.graphicObjs{i}.getXY();
                    if obj.is2D
                        obj.hitFuncs{i}.updatePlot(xy);
                    else
                        if ~isempty(xy) % defensive, since we've already excluded TYPE_PRIOR
                            obj.hitFuncs{i}.updatePlot(xy(1));
                        end
                    end
                    obj.stdRect(:,i) = obj.stdNullrect(:,i) + [xy xy]';
                end
            end     
        end
        
        function [] = updateEvidence(obj, xyt) % interface implementation
            n = length(obj.graphicObjs);
            
            % calc log-likelihood 
            ll = nan(size(xyt,1),n);
            w = obj.getOnsetRamp(xyt(:,3)); % now ramp applied twice(!)
            for i = 1:n % any way to vectorize this?     
                if obj.is2D
                    itrackxy = xyt(:,1:2);
                    gfcxy = obj.graphicObjs{i}.getXY(xyt(:,3));
                    y = obj.hitFuncs{i}.getPDF(itrackxy, gfcxy);
                else
                    itrackx = xyt(:,1);
                    gfcx = obj.graphicObjs{i}.getX(xyt(:,3));
                    y = obj.hitFuncs{i}.getPDF(itrackx, gfcx);
                end
              	
                ll(:,i) = w .* reallog(y);
                %ll(:,i) = nansum(reallog(obj.hitFuncs{i}.getPDF(xyt(:,1:2), obj.graphicObjs{i}.getXY(xyt(:,3)))));
            end
            % add to buffer
            obj.rawbuffer.put(ll);
            % cumulative
            cll = nansum(obj.rawbuffer.get(),1); % sum loglikelihoods

            % convert to proportions
            y = (ones(n,1)*cll)';
            cllp = cll - logsum(reshape(y(~eye(n)),n-1,n));
 
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