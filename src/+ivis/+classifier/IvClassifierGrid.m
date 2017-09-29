classdef IvClassifierGrid < ivis.classifier.IvClassifier
    % Singleton instantiation of IvClassifier, in which the decision
    % variable is the num gaze samples falling in each quadrant of the
    % screen.
    %
    % IvClassifierGrid Methods:
    %   * IvClassifierGrid 	- Constructor.
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
    %   IvClassifierBox, IvClassifierLL, IvClassifierVector
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
    % @todo classification with graphicalObjects as input is shaky at best
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %
    
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (GetAccess = public, SetAccess = private)
        poly = struct('name',{'top-left', 'top-right', 'bottom-right', 'bottom-left', 'centre'})
        nPoly = 5;
        categoryObjs
        PTB_xy = {};
        drawColor = [255 100 255];
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvClassifierGrid(graphicObjs, npoints, nsecs, GUIidx)
            % IvClassifierGrid Constructor.
            %
            % @param    graphicObjs	IvGraphic object(s) to classify
            % @param    npoints  	num gaze points required inside quadrant
            % @param    nsecs       num secs to run before concluding Miss
            % @param    GUIidx    	GUI panel number
            % @return 	obj      	IvClassifierGrid object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            params = ivis.main.IvParams.getInstance();
            
            % parse inputs
            if nargin < 1 || isempty(graphicObjs) % optional
                graphicObjs = 5; % n.b., must be hardcoded
            end
            if nargin < 2 || isempty(npoints)
                npoints = params.classifier.grid.npoints;
            end
            if nargin < 3 || isempty(nsecs)
                nsecs = params.classifier.nsecs;
            end
            if nargin < 4
                GUIidx = params.classifier.GUIidx;
            end

            % validate
            if ~isempty(GUIidx) && ~params.GUI.useGUI
               fprintf('IvClassifier: GUI is disabled, so specified GUI index will be ignored\n'); 
               GUIidx = [];
            end
            
          	% call superclass
            obj = obj@ivis.classifier.IvClassifier(graphicObjs, npoints, nsecs);
            
            % should be user specified in future versions:
            mx = .5;
            my = .5;
            w = .33;
            h = .45;
            % top-left
            obj.poly(1).x = [0 mx mx mx-w/2 0 0];
            obj.poly(1).y = [1 1 my+h/2 my my my];
            % top-right
            obj.poly(2).x = 1 - obj.poly(1).x;
            obj.poly(2).y = obj.poly(1).y;
            % bottom-right
            obj.poly(3).x = obj.poly(2).x;
            obj.poly(3).y = 1 - obj.poly(2).y;
            % bottom-left
            obj.poly(4).x = obj.poly(1).x;
            obj.poly(4).y = obj.poly(3).y;
            % middle
            obj.poly(5).x = mx + [0 -w/2 0 w/2 0];
            obj.poly(5).y = my + [-h/2 0 h/2 0 -h/2];

            % convert to pixels (and flip y values so that origin is top-left, rather
            % than bottom-left)
            for i = 1:obj.nPoly
                obj.poly(i).x = obj.poly(i).x * params.graphics.testScreenWidth;
                obj.poly(i).y = (1-obj.poly(i).y) * params.graphics.testScreenHeight;
            end

            % if no graphical objects are specified, then we'll create an
            % niternal set of 'pseudo graphical-objects' out of the grid
            % polygons. We'll store them locally, but may need to return
            % them at some point via a call to getClassObj()
            if isempty(obj.graphicObjs)
                obj.categoryObjs = obj.poly;
            else
                obj.categoryObjs = obj.graphicObjs{1};
                if length(graphicObjs) > 1
                    for i = 2:length(graphicObjs)
                        obj.categoryObjs(i) = graphicObjs{i};
                    end
                end
            end
            
            % initialise GUI element if GUIidx specified
            if ~isempty(GUIidx)
                obj.guiElement = ivis.gui.IvGUIclassifierGrid(GUIidx, obj.criterion, obj.poly, obj.categoryObjs);
            end
        end
        
        %% == METHODS =====================================================
        
        function [] = draw(obj, ~, ~) % interface implementation
            if isempty(obj.winhandle)
                % get winhandle
                params = ivis.main.IvParams.getInstance();
                obj.winhandle = params.graphics.winhandle;
                
                % compute for convenience, so that we don't have to calculate prior
                % to any/every draw() call
                for i = 1:obj.nPoly
                    xy = [obj.poly(i).x; obj.poly(i).y]; % get
                    xy(:,end+1) = xy(:,1); %#ok ensure wraps back to the start
                    xy = reshape([xy(:,1:end-1); xy(:,2:end)],2,[]); % interleave for PTB DrawLines
                    obj.PTB_xy{i} = xy; % store
                end
            end

            % draw
            for i = 1:obj.nPoly
                Screen('DrawLines', obj.winhandle, obj.PTB_xy{i}, 5, obj.drawColor);
            end
        end
    end
    
    
	%% ====================================================================
    %  -----PROTECTED METHODS-----
    %$ ====================================================================
         
    methods (Access = protected)   

        function [] = updateParams(obj) %#ok interface implementation
        end
        
        function [] = updateEvidence(obj, xyt, varargin) % interface implementation       
            if isempty(obj.graphicObjs)
                % count n observations in each
                % if no objects are specified, just do a generic comparison
                % between the various grid coordinates
                for i = 1:obj.nPoly
                    obj.evidence(i) = obj.evidence(i) + sum(inpolygon(xyt(:,1),xyt(:,2), obj.poly(i).x, obj.poly(i).y)); 
                end  
            else
                % ... else compute in which grid location each graphic is,
                % and tally the votes for each graphical object accordingly
                for i = 1:obj.nAlternatives
                    if obj.graphicObjs{i}.isStationary
                        x = obj.graphicObjs{i}.getX();
                        y = obj.graphicObjs{i}.getY();
                        % find which polygone the graphic is in... <--- n.b., only uses a single point to compute this - would be nicer if the entire target area was used
                        for j = 1:obj.nPoly
                            if inpolygon(x, y, obj.poly(j).x, obj.poly(j).y)
                                % ... and count n observations
                                obj.evidence(i) = obj.evidence(i) + sum(inpolygon(xyt(:,1),xyt(:,2), obj.poly(j).x, obj.poly(j).y)); 
                                continue % no point continuing in loop
                                % do continue the loop, as graphics may be
                                % located in multiple grid locations
                            end
                        end
                    else
                        graphic_xy = obj.graphicObjs{i}.xyt.getBeforeEach(xyt(:,3),3,1:2);
                        for j = 1:obj.nPoly
                            obj.evidence(i) = obj.evidence(i) + sum(inpolygon(xyt(:,1),xyt(:,2), obj.poly(j).x, obj.poly(j).y) & inpolygon(graphic_xy(:,1),graphic_xy(:,2), obj.poly(j).x, obj.poly(j).y));
                        end
                    end
                end
            end
        end

        function o = getClassObj(obj, i) % interface implementation
            o = obj.categoryObjs(i);
        end
        
        function [] = classifierSpecificReset(obj) %#ok interface implementation
            % do nothing
        end
    end

end