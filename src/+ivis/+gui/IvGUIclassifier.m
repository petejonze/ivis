classdef (Abstract) IvGUIclassifier < ivis.gui.IvGUIelement
	% Generic class for displaying classifier parameters and status, to be
	% instantiated by a subclass.
    %
    % IvGUIclassifier Abstract Methods:
    %   * update            - Update figure window.
    %
    % IvGUIclassifier Methods:
    %   * IvGUIclassifier   - Constructor.
	%   * reset             - Reset the classifier panel; clear any accumulated data.
    %   * printStatus       - Write the classification estimate to the panel.
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
    %   1.1 PJ 02/2013 : converted to Singleton\n
    %   1.0 PJ 02/2013 : first_build\n
    %
    % @todo rename plots with discriptive names (spatial/temporal rather than plot1 plot2)
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 

    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
          
    properties (Constant)
        BUFFER_LENGTH = 100;
    end
    
    properties(GetAccess = protected, SetAccess = protected)
        % data buffers
        plot1Data       % top panel data (location)
        plot2Data       % bottom panel data (evidence)
        nAlternatives   % integer num hypotheses
        % handles
      	hPlot1Data      % top panel data handle
        hPlot2Data      % bottom panel data handle
        hPlot2Text      % bottom panel text handle
    end

    
    %% ====================================================================
    %  -----Abstract PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Abstract, Access = public)
        
        % Update figure window.
        %
        % @param    newPlot1Dat	graphic & gaze location data
        % @param    plot2Dat  	evidence data
        % @param    varargin    further details, particular to each classifer type
        %
        % @date     26/06/14
        % @author   PRJ
        %
        [] = update(obj, newPlot1Dat, plot2Dat, varargin)
    end
    

    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
      
        function [] = reset(obj)
            % Reset the classifier panel; clear any accumulated data.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % plot distributions and data
            obj.plot1Data = CCircularBuffer(obj.BUFFER_LENGTH,2);
            obj.plot2Data = CCircularBuffer(obj.BUFFER_LENGTH,obj.nAlternatives);
            % fill up with nans to start with
            obj.plot1Data.put(nan(obj.BUFFER_LENGTH,2));
            obj.plot2Data.put(nan(obj.BUFFER_LENGTH,obj.nAlternatives));
            
            % clear status text
            set(obj.hPlot2Text, 'String', '');
        end
        
        function [] = printStatus(obj, statusCode, gObjLookingAt)
            % Write the classification estimate to the panel.
            %
            % @param    statusCode      numeric status code
            % @param    gObjLookingAt   IvGraphic object name string
            %
            % @date     26/06/14
            % @author   PRJ
            %            
            switch statusCode
                case ivis.classifier.IvClassifier.STATUS_RETIRED
                    exitStr = 'Unknown (retirement)';
                case ivis.classifier.IvClassifier.STATUS_MISS % ALT: if gObjLookingAt.type == ivis.graphic.IvScreenObject.TYPE_PRIOR
                    exitStr = sprintf('Miss (%s)',gObjLookingAt.name);
                case ivis.classifier.IvClassifier.STATUS_HIT
                    exitStr = sprintf('Hit! : %s', gObjLookingAt.name);
                otherwise
                    error('a:b','Unknown status code: "%s"',statusCode);
            end
            str = sprintf('ANSWER = %s',exitStr);
            set(obj.hPlot2Text, 'String', str);
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