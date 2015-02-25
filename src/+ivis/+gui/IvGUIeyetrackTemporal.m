classdef (Sealed) IvGUIeyetrackTemporal < ivis.gui.IvGUIelement
	% Singleton for displaying gaze-location as a function of time.
    %
    % IvGUIeyetrackTemporal Methods:
    %   * IvGUIeyetrackTemporal - Constructor.
	%   * update                - Update figure window.
    %   * incrementVarType      - Cycle between decision varibles: {distance, acceleration, velocity}.
    %
    % See Also:
    %   IvGUIeyetrackSpatial
    %
    % Example:
    %   none
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.1 PJ 02/2013 : converted to Singleton\n    
    %   1.0 PJ 02/2013 : first_build\n
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
          
    properties (Constant)
        FIG_NAME = 'IvGUIeyetrackTemporal';
    end
    
    properties (GetAccess = public, SetAccess = private)
        % user specified parameters
        nDatPoints
        % other internal parameters
        hAxes
        hYLabel
        hDat
        hCriterion
        saccades % 1 for onset, -1 for offsets, NaN otherwise
        %
        varFlag = 1; % will actually increment to 2 when first set
    end
    

    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvGUIeyetrackTemporal(GUIidx, nDatPoints)
            % IvGUIeyetrackTemporal Constructor.
            %
            % @param    GUIidx      GUI frame index
            % @param    nDatPoints  number of gaze-coordinates to display
            % @return   obj         IvGUIeyetrackTemporal object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % parse inputs
            if nargin < 2 || isempty(nDatPoints)
                nDatPoints = 300;
            end
            
            % init figure
            obj.init(GUIidx);
            
            % init data
            obj.nDatPoints = nDatPoints;
            obj.hDat = plot(1:nDatPoints, nan(nDatPoints,1), '-');
            
            % add threshold lines & format axes
            obj.hAxes = gca();
            set(obj.hAxes, 'xlim', [0 nDatPoints], 'xtick', []);
            obj.hYLabel = ylabel('loading..');
            obj.hCriterion = [hline(ivis.main.IvParams.getInstance().saccade.accelCriterion_degsec2, 'g:') hline(-ivis.main.IvParams.getInstance().saccade.accelCriterion_degsec2, 'r:')];
            obj.incrementVarType()
            set(obj.hYLabel, 'HitTest', 'on', 'ButtonDownFcn', @(varargin)incrementVarType(obj), 'UserData', true, 'interpreter', 'tex');
            
            % initialise data buffer --------------------------------------
            obj.saccades = CCircularBuffer(nDatPoints,1);
            obj.saccades.put(nan(nDatPoints,1));
        end
        
        %% == METHODS =====================================================
        
        function [] = update(obj)
            % Update figure window.
            %
            % @date     26/06/14
            % @author   PRJ
            %            
            
            % query how much raw data is available
            n = min(obj.nDatPoints,ivis.log.IvDataLog.getInstance().getN());
            if n==0
                return;
            end
            
            % get data
            A = ivis.log.IvDataLog.getInstance().getLastN(n, 7 + obj.varFlag);
            
            % pad with nans if required
            if n < obj.nDatPoints
                n = obj.nDatPoints - length(A);
                A = [A; nan(n,1)];
            end

            % update data
            set(obj.hDat,'YData',A);
        end
        
        function [] = incrementVarType(obj)
            % Cycle between decision varibles: {distance, acceleration,
            % velocity}.
            %
            % @date     26/06/14
            % @author   PRJ
            %           
            obj.varFlag = mod(obj.varFlag + 1,3);
            
            switch mod(obj.varFlag,3)
                case 0
                    ylims = [-10 200];
                    ytick = 0:50:200;
                    ylbl = 'dist (\Deltadeg)';
                    criterionOn = ivis.main.IvParams.getInstance().saccade.distanceCriterion_deg;
                    criterionOff = NaN;
                case 1
                 	ylims = [-10 400];
                    ytick = 0:100:400;
                    ylbl = 'vel (\Deltadeg/s)';
                    criterionOn = ivis.main.IvParams.getInstance().saccade.velocityCriterion_degsec;
                    criterionOff = NaN;
                case 2
                 	ylims = [-600 600];
                    ytick = -600:200:600;
                    ylbl = 'Acc (\Deltadeg/s^2)';
                    criterionOn = ivis.main.IvParams.getInstance().saccade.accelCriterion_degsec2;
                    criterionOff = -criterionOn;
                otherwise
                    error('a:b','c');
            end
            
            % set vals
            set(obj.hAxes, 'ylim', ylims, 'ytick', ytick)
            set(obj.hYLabel,'String', ylbl)
            set(obj.hCriterion(1),'YData',[criterionOn criterionOn]);
            set(obj.hCriterion(2),'YData',[criterionOff criterionOff]);
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