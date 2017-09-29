classdef IvClassifierVector < ivis.classifier.IvClassifier
    % Singleton instantiation of IvClassifier, in which the decision
    % variable is the additive movement vector, with a direction that must
    % lie within some prescribed bin, and a magnitude that must exceed some
    % arbitrary threshold.
    %
    % IvClassifierVector Methods:
    %   * IvClassifierVector	- Constructor.
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
    %   IvClassifierBox, IvClassifierGrid, IvClassifierLL
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
% n.b. '0' is due north in the deg form

    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (GetAccess = public, SetAccess = private)
        % user specified parameters
        targDirection_deg	% #####
        margin_deg       	% #####
        observedTheta     	% #####
        observedDeg      	% #####
        observedRho         % #####
        % for drawing
        drawColor = [255 100 255];   % #####
        mx                           % #####
        my                           % #####
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvClassifierVector(targDirection_deg, margin_deg, rqdMagnitude, nsecs, bufferlength, GUIidx)
            % IvClassifierVector Constructor.
            %
            % @param    targDirection_deg	target direction (deg)
            % @param    margin_deg          margin to place around the target direction (deg)
            % @param    rqdMagnitude        required vector/evidence magnitude
            % @param    nsecs               num secs to run before concluding Miss
            % @param    bufferlength        n points to store when computing vector aggregate
            % @param    GUIidx              GUI panel number
            % @return 	obj                 IvClassifierVector object
            %
            % @date     26/06/14
            % @author   PRJ
            %

            % parse inputs
            params = ivis.main.IvParams.getInstance();
            if nargin < 2 || isempty(margin_deg)
                margin_deg = params.classifier.vector.margin_deg;
            end
            if nargin < 3 || isempty(rqdMagnitude)
                rqdMagnitude = params.classifier.vector.rqdMagnitude;
            end
            if nargin < 4 || isempty(nsecs)
                nsecs = params.classifier.vector.nsecs;
            end
            if nargin < 5 || isempty(bufferlength)
                bufferlength = params.classifier.vector.bufferLength;
            end
            if nargin < 6
                GUIidx = params.classifier.GUIidx;
            end
            
            % validate
            if ~isempty(GUIidx) && ~params.GUI.useGUI
               fprintf('IvClassifier: GUI is disabled, so specified GUI index will be ignored\n'); 
               GUIidx = [];
            end
            
          	% call superclass
            obj = obj@ivis.classifier.IvClassifier(length(targDirection_deg), rqdMagnitude, nsecs, bufferlength);
            
            % wrap any negative values (and any > 360)
            targDirection_deg = mod(targDirection_deg,360);
            
            % store
            obj.targDirection_deg = targDirection_deg;
            obj.margin_deg = margin_deg;

         	% initialise rawbuffer
            obj.rawbuffer = CCircularBuffer(obj.bufferLength, 2); %[xy]
            
            % initialise GUI element if GUIidx specified
            if ~isempty(GUIidx)
                obj.guiElement = ivis.gui.IvGUIclassifierVector(GUIidx, rqdMagnitude, targDirection_deg);
            end
        end
        
        %% == METHODS =====================================================
        
        function [] = draw(obj, ~, ~) % interface implementation
            
            if isempty(obj.winhandle)
                % get winhandle
                params = ivis.main.IvParams.getInstance();
                obj.winhandle = params.graphics.winhandle;
                % for convenience, to avoid have to compute on every draw()
                % command
                obj.mx = params.graphics.mx;
                obj.my = params.graphics.my;
            end

            % get values
            [x,y] = pol2cart(obj.observedTheta, obj.observedRho);
            
            if ~isempty(x)
                % draw
                Screen('DrawLine', obj.winhandle, obj.drawColor, obj.mx, obj.my, obj.mx+x, obj.my-y, 5);
                % additional (debug) info
                DrawFormattedText(obj.winhandle, sprintf('%1.2f  -  %1.2f  -  %1.2f', pol2cmp(obj.observedTheta), obj.observedRho, obj.evidence(1)), [], [], 1);
            else
                warning('No data to draw??');
            end
        end   
    end

    
	%% ====================================================================
    %  -----PROTECTED METHODS-----
    %$ ====================================================================
      
    methods (Access = protected)    
     
        function [] = updateGUI(obj, xy, lookingAt) % overwriting parent
            obj.guiElement.update(xy, obj.evidence, obj.observedTheta, obj.observedRho)
            if (obj.status ~= obj.STATUS_UNDECIDED)
                obj.guiElement.printStatus(obj.status, lookingAt);
            end
        end
        
        function [] = updateParams(~) % interface implementation        
        end
        
        function [] = updateEvidence(obj, xyt, varargin) % interface implementation
            % add to buffer
            obj.rawbuffer.put(xyt(:,1:2));
            
            % sum first-derivative to get current direction-of-change vector
            dxdy = diff(obj.rawbuffer.get(),[],1);
            dxdy = nansum(dxdy,1);

            % convert to polar coordinates
            [obj.observedTheta, obj.observedRho] = cart2pol(dxdy(1), -dxdy(2)); %[direction speed/ma]
            obj.observedDeg = pol2cmp(obj.observedTheta); % convert to 0-360 deg reference (0 == north)

            % calculate deviations
            err = obj.targDirection_deg - obj.observedDeg; % deviation between targets and observed
            err = mod(err,360); % e.g. so -358 => 2
            
            obj.evidence = (err < obj.margin_deg) * obj.observedRho;
        end
        
        function o = getClassObj(obj, i) % interface implementation
            x = obj.targDirection_deg(i);
            o = struct('name',num2str(x));
        end

        function [] = classifierSpecificReset(obj, newTargDirection_deg, newCriteria, startXY) % interface implementation
            
            %
            obj.targDirection_deg = mod(newTargDirection_deg, 360);
            
            %
            if length(newCriteria)==1
                newCriteria = repmat(newCriteria,1,obj.nAlternatives); % assume same for all
            end
            obj.criterion = newCriteria;
            
            %
            obj.rawbuffer.put(startXY);
        end
    end
    
end