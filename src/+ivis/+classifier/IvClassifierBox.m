classdef IvClassifierBox < ivis.classifier.IvClassifier
    % Singleton instantiation of IvClassifier, in which the decision
    % variable is the num gaze samples falling inside one or rectangle
    % (i.e., which is generally centred on a graphical object).
    %
    % Can also optionally specify a path_maxDeviation_px parameter, in which
    % case a 'miss' is reported, if N gaze coordinates fall
    % 'path_maxDeviation_px' pixels outside of a linear corridoor, extending
    % from the starting gaze position to the box position at start (n.b.,
    % not appropriate for moving boxes).
    %
    % IvClassifierBox Methods:
    %   * IvClassifierBox   - Constructor.
    %   
    % IvClassifier Methods:
    %   * IvClassifier  - Constructor.
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
    %   IvClassifierGrid, IvClassifierLL, IvClassifierVector
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
    % if no graphicObjs specified, just test for most likely polygon area (quadrant)
    % (currently the latter will crash, due to some crude hacks [simple fixes])
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (GetAccess = public, SetAccess = private)
        % user specified parameters
        margin_px                     	% margin to place around the target graphic rectangle (px)
        npoints                       	% num gaze points required inside box
        nsecs                           % num secs to run before concluding Miss
        % other internal parameters
        rectColour = [255; 100; 255];   % RGB vector (max = 255)
        nullrects                       % e.g. [-10 100 -10 100];
        xyrects_xywh                    % last known rectangle position [x y w h]
        xyrects_xyxy                    % last known rectangle position [x0 y0 x1 y1]
        %
        path_enabled = false
        path_maxDeviation_px             % for constructing valid vector corridors
        path_n
        path_criterion_n = 60; % in future versions this should be user-specifiable [was 60]
        path_xyStart_px
        path_xyEnd_px
        stationarity_criterion_degsec = 60;  % in future versions this should be user-specifiable
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvClassifierBox(graphicObjs, margin_deg, npoints, nsecs, GUIidx, path_maxDeviation_px)
            % IvClassifierBox Constructor.
            %
            % @param    graphicObjs             IvGraphic object(s) to classify
            % @param    margin_deg              margin to place around the object (deg)
            % @param    npoints                 num gaze points required inside box
            % @param    nsecs                   num secs to run before concluding Miss
            % @param    GUIidx                  GUI panel number
            % @param    path_maxDeviation_px 	amount of deviation allowed from a straight line vector from the starting position to the target position
            % @return 	obj         IvClassifierBox object
            %
            % @date     26/06/14
            % @author   PRJ
            %

            % parse inputs
            params = ivis.main.IvParams.getInstance();
            if nargin < 1 || isempty(graphicObjs)
                graphicObjs = []; % optional
            end
            if nargin < 2 || isempty(margin_deg)
                margin_deg = params.classifier.box.margin_deg;
            end
            if nargin < 3 || isempty(npoints)
                npoints = params.classifier.box.npoints;
            end
            if nargin < 4 || isempty(nsecs)
                nsecs = params.classifier.nsecs;
            end
            if nargin < 5 || isempty(GUIidx)
                GUIidx = params.classifier.GUIidx;
            end       
            if nargin < 6 || isempty(path_maxDeviation_px)
                path_maxDeviation_px = [];
            end
            
            % validate
            if ~isempty(GUIidx) && ~params.GUI.useGUI
               fprintf('IvClassifier: GUI is disabled, so specified GUI index will be ignored\n'); 
               GUIidx = [];
            end
            
          	% call superclass
            obj = obj@ivis.classifier.IvClassifier(graphicObjs, npoints, nsecs);

            % convert to pixels and set
            obj.setBoxMargins(ivis.math.IvUnitHandler.getInstance().deg2px(margin_deg));

            % initialise GUI element if GUIidx specified
            if ~isempty(GUIidx)
                obj.guiElement = ivis.gui.IvGUIclassifierBox(GUIidx, obj.criterion, obj.xyrects_xywh);
            end
            
            % store any additional parameters
            obj.path_maxDeviation_px = path_maxDeviation_px;
        end
        
        function [] = delete(obj)
            % IvClassifierBox Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.stopListening('PostSet');
        end
        
        %% == METHODS =====================================================
        
        function [] = draw(obj, ~, ~) % interface implementation          
            if isempty(obj.winhandle)
                % get winhandle
                params = ivis.main.IvParams.getInstance();
                obj.winhandle = params.graphics.winhandle;
            end

            % neaten up!
            dstRect = reshape(cell2mat(obj.xyrects_xyxy),4,[])'; % 1 column per rect

            % draw
            Screen('FrameRect', obj.winhandle, obj.rectColour, dstRect, 3);
        end    
        
        function [] = setBoxMargins(obj, margin_px)
            
            % expand margin if necessary (i.e., if only supplied a single
            % scalar value, assuming the user wants uniform margins)
            switch numel(margin_px)
                case 1
                    obj.margin_px = repmat(margin_px, 1, 4);
                case 2
                    obj.margin_px = [margin_px margin_px];
                case 4
                    obj.margin_px = margin_px;
                otherwise
                    error('IvClassifierBox:InvalidInput','Margin must be a scalar, a 1x2 vector (left/right, top/bottom), or a 1x4 row vector (left, bottom, right, top)');
            end

            % convert to additive values
            obj.margin_px([1 2]) = -obj.margin_px([1 2]);
            obj.margin_px([3 4]) = obj.margin_px([3 4]);
            
            % (re)construct polygons
            n = length(obj.graphicObjs);
            obj.nullrects = cell(n, 1);
            obj.xyrects_xywh = cell(1, n);
            obj.xyrects_xyxy = cell(1, n);
            for i = 1:n
                obj.nullrects{i} = [0 0 obj.graphicObjs{i}.width obj.graphicObjs{i}.height] + obj.margin_px; % [x y w h]
                obj.xyrects_xywh{i} = obj.nullrects{i} + [obj.graphicObjs{i}.getX0Y0() 0 0]; % [x y w h] format
                obj.xyrects_xyxy{i} = obj.nullrects{i} + [obj.graphicObjs{i}.getX0Y0() obj.graphicObjs{i}.getX0Y0()]; % [x0 y0 x1 y1] format                
                % listen for any updates to the "nullrect" property in this
                % object
                obj.startListeningTo(obj.graphicObjs{i}, 'nullrect',  'PostSet', @obj.graphicChangeEventHandler)
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
                gObjX0Y0_current = obj.graphicObjs{i}.getX0Y0(); % get current position
                rect = obj.nullrects{i} + [gObjX0Y0_current gObjX0Y0_current]; % [x0 y0 x1 y1] format
                obj.xyrects_xyxy{i} = rect;
                obj.xyrects_xywh{i} = rect(end,:) - [0 0 rect(end,1:2)];  % [x y w h] format
                
                % update rectangles in GUI
                if ~isempty(obj.guiElement)
                    set(obj.guiElement.hPlot1Rects{i},'Position', obj.xyrects_xywh{i});
                end
            end                 
        end
        
        function [] = updateEvidence(obj, xyt, v) % interface implementation
            for i = 1:length(obj.graphicObjs)
                % count n observations in each
                gObjX0Y0_prior = obj.graphicObjs{i}.getX0Y0(xyt(:,3)); % get x0y0 prior to each datum
                rect = bsxfun(@plus, obj.nullrects{i}, [gObjX0Y0_prior gObjX0Y0_prior]); % [x0 y0 x1 y1] format
                inrect = (rect(:,1) < xyt(:,1)) ...
                        & (rect(:,3) > xyt(:,1)) ...
                        & (rect(:,2) < xyt(:,2)) ...
                        & (rect(:,4) > xyt(:,2));
                isStationary = v < obj.stationarity_criterion_degsec;
                obj.evidence(i) = obj.evidence(i) + sum(inrect & isStationary);  
            end
            
            if obj.path_enabled
                % compute distance, in pixels, from the ideal path
                % (probably a smart way to vectorize this)
                n = size(xyt,1);
                d_px = nan(1, n);
                for i = 1:n
                    d_px(i) = abs(det([obj.path_xyEnd_px-obj.path_xyStart_px; xyt(i,1:2)-obj.path_xyStart_px]))/norm(obj.path_xyEnd_px-obj.path_xyStart_px);
                end
                
                % compute number of points (if any) that deviate from the
                % optimal path, by more than the specified criterion amount
                n = sum(d_px > obj.path_maxDeviation_px);
                
                % update counter
                obj.path_n = obj.path_n + n; 
                
                % check if counter has exceeded a criterion
                if obj.path_n > obj.path_criterion_n
                    fprintf('IvClassifierBox: Path deviation detected. Forcing a miss\n')
                    obj.updateStatus(ivis.graphic.IvPrior()); % force classifier to report obj.STATUS_MISS
                end
            end
        end

        function o = getClassObj(obj, i) % interface implementation
            o = obj.graphicObjs{i};
        end

        function [] = classifierSpecificReset(obj, path_xyStart_px, path_xyEnd_px) % interface implementation
            
            if ~isempty(obj.path_maxDeviation_px)

                % parse inputs, get defaults
                if nargin < 2 || isempty(path_xyStart_px)
                    path_xyStart_px = ivis.log.IvDataLog.getInstance().getLastKnownXY(1, false, false); % important that post-processing, and not nan
                end

                if nargin < 3 || isempty(path_xyEnd_px)
                    path_xyEnd_px =  obj.graphicObjs{1}.getXY();
                end

                % validate
                if isempty(path_xyStart_px) || isempty(path_xyEnd_px)
                    warning('IvClassifierBox: start/end coordinates missing? Path deviation will be suppressed.');
                    obj.path_enabled = false;
                    return
                end
            
                % store
                obj.path_xyStart_px = path_xyStart_px;
                obj.path_xyEnd_px = path_xyEnd_px;

                % enable, initialise counter
                obj.path_enabled = true;
                obj.path_n = 0;
            end
        end
    end
    

	%% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================

    methods (Access = private)
        
        function [] = graphicChangeEventHandler(obj, src, evt) %#ok
          	% Fired any time a IvGraphic object is resized.
            %
            % @param    src  broadcast source
            % @param    evt  broadcast event          
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            %fprintf('\nFiring IvClassifierBox.graphicChangeEventHandler\n');
            
            [w,h] = RectSize(evt.AffectedObject.nullrect);
            
            i = ismember(obj.graphicObjNames, evt.AffectedObject.name);
            
            obj.nullrects{i} = [0 0 w h] + obj.margin_px; % [x y w h]
            obj.xyrects_xywh{i} = obj.nullrects{i} + [obj.graphicObjs{i}.getX0Y0() 0 0]; % [x y w h] format
            obj.xyrects_xyxy{i} = obj.nullrects{i} + [obj.graphicObjs{i}.getX0Y0() obj.graphicObjs{i}.getX0Y0()]; % [x0 y0 x1 y1] format
        end
    end
    
end