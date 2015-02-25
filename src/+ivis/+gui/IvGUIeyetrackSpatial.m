classdef (Sealed) IvGUIeyetrackSpatial < ivis.gui.IvGUIelement
	% Singleton for displaying gaze-location as a function of space.
    %
    % dfdfdfdfdfdfdfdfdf
    %
    % IvGUIeyetrackSpatial Methods:
    %   * IvGUIeyetrackSpatial  - Constructor.
	%   * update                - Update figure window.
    %
    % See Also:
    %   IvGUIeyetrackTemporal
    %
    % Example:
    %   none
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.2 PJ 02/2013 : added clickable icon for display trackbox\n  
    %   1.1 PJ 02/2013 : converted to Singleton\n    
    %   1.0 PJ 02/2013 : first_build\n
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 
    % should more properly be termed IvGUIDataInput?

    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
      
    properties (Constant)
        FIG_NAME = 'IvGUIeyetrackSpatial';
    end
    
    properties (GetAccess = public, SetAccess = private)
        % user specified parameters
        showLastNPoints
        % other internal parameters
        normaliseDims
        
        jButtonMonitor
        
        % data handles
        hHistory
        hCurrentFixationPoint
        hStatusLight
        tmpObj
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvGUIeyetrackSpatial(GUIidx, bgcolor,showLastNPoints)
            % IvGUIeyetrackSpatial Constructor.
            %
            % @param    GUIidx          GUI frame index
            % @param    bgcolor         figure background colour
            % @param    showLastNPoints number of gaze-coordinates to display
            % @return   obj           	IvGUIeyetrackSpatial object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % validate params
            if nargin < 2 || isempty(bgcolor)
                bgcolor = [0 0 0];
            end
            if nargin < 3 || isempty(showLastNPoints)
                obj.showLastNPoints = 10;
            end
            
            % init figure
            obj.normaliseDims = [ivis.main.IvParams.getInstance().graphics.testScreenWidth, ivis.main.IvParams.getInstance().graphics.testScreenHeight];
            [~, ~, aDims] = obj.init(GUIidx, obj.normaliseDims, bgcolor);
            
            % init content
            currDotColor = [0 1 .9]; % turqoise
            currDotSize = 12; % Calib.TrackStat;
            histDotColor = [0 .33 .3]; % darker turqoise
            histDotSize = 12;
            statusLightSize = 8;
            statusLightColor = 'g';
            hold on
            obj.hHistory = plot(nan(obj.showLastNPoints,1), nan(obj.showLastNPoints,1), 'o','MarkerEdgeColor', 'none', 'MarkerFaceColor', histDotColor, 'MarkerSize', histDotSize);
            obj.hCurrentFixationPoint = plot(nan,nan,'o','MarkerEdgeColor', currDotColor, 'MarkerFaceColor', currDotColor, 'MarkerSize', currDotSize);
            obj.hStatusLight = plot(.05*aDims(2)/aDims(1),.05*aDims(2)/aDims(1),'o','MarkerEdgeColor', statusLightColor, 'MarkerFaceColor', statusLightColor, 'MarkerSize', statusLightSize);
            hold off
            
        end
        
        %% == METHODS =====================================================
        
        function [] = update(obj, xy)
            % Update figure window.
            %
            % @param    xy      current gaze-coordinate, in pixels
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            xx = xy(1)/obj.normaliseDims(1); % normalise
            yy = xy(2)/obj.normaliseDims(2);
            set(obj.hCurrentFixationPoint,'XData',xx,'YData',yy);

            if obj.showLastNPoints > 0
                if isempty(obj.tmpObj)
                    obj.tmpObj = ivis.log.IvDataLog.getInstance(); % performance optimisation
                end
                xy_hist = getLastN(obj.tmpObj, obj.showLastNPoints,1:2);
                set(obj.hHistory,'XData',xy_hist(:,1)/obj.normaliseDims(1),'YData',xy_hist(:,2)/obj.normaliseDims(2));
            end
            
            if any(isnan(xy))
                statusLightColor = 'r';
            elseif xx<0 || xx>1 || yy<0 || yy>1
                statusLightColor = [1 0.5 0.2]; % orange
            else
                statusLightColor = 'g';
            end
            set(obj.hStatusLight,'MarkerEdgeColor', statusLightColor, 'MarkerFaceColor', statusLightColor);    
        end
    end
    
    
  	%% ====================================================================
    %  -----SINGLETON BLURB-----
    %$ ====================================================================

    methods (Static, Access = ?Singleton)
        function obj = getSetSingleton(obj)
            persistent singleObj
            if nargin > 0, singleObj = obj; end
            obj = singleObj;
        end
    end
    methods (Static, Access = public)
        function obj = getInstance()
            obj = Singleton.getInstanceSingleton(mfilename('class'));
        end
        function [] = finishUp()
            Singleton.finishUpSingleton(mfilename('class'));
        end
    end  
    
end