classdef (Sealed) IvGUIclassifierVector < ivis.gui.IvGUIclassifier
	% Singleton for displaying vector classifier parameters and status.
    %
    % IvGUIclassifierVector Methods:
    %   * IvGUIclassifierVector - Constructor.
	%   * update                - Update figure window.
    %
    % See Also:
    %   ivis.classifier.IvClassifierVector
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
    % @todo Wind_rose.m for a fancier/forced-alternative version? 
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 
   
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
          
    properties (Constant)
        FIG_NAME = 'IvGUIclassifierVector';
    end
    
    properties (GetAccess = public, SetAccess = private)
        arrow
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
      	%% == CONSTRUCTOR =================================================

        function obj = IvGUIclassifierVector(GUIidx, rqdMagnitude, direction) % add possible classification directions
            % IvGUIclassifierVector Constructor.
            %
            % @param    GUIidx          GUI frame index
            % @param    rqdMagnitude 	evidence threshold required for decision
            % @param    direction     	target direction to check against
            % @return   obj             IvGUIclassifierVector object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % init figure
            obj.init(GUIidx);
            obj.nAlternatives = numel(rqdMagnitude);
            
            % init data
            obj.plot1Data = CCircularBuffer(obj.BUFFER_LENGTH,2);
            obj.plot2Data = CCircularBuffer(obj.BUFFER_LENGTH,obj.nAlternatives);
            % fill up with nans to start with
            obj.plot1Data.put(nan(obj.BUFFER_LENGTH,2));
            obj.plot2Data.put(nan(obj.BUFFER_LENGTH,obj.nAlternatives));
            
            % init plots
            % plot1
            subplot(2,1,1);
            axis ij; % specify "matrix" axes mode. Coordinate system origin is at upper left corner.
            %
            hold on
         	obj.hPlot1Data = plot(obj.plot1Data.get(),'kx'); % plot on top
            hold off
            %
            screenwidth = ivis.main.IvParams.getInstance().graphics.testScreenWidth;
            screenheight = ivis.main.IvParams.getInstance().graphics.testScreenHeight;
            xlim([0 screenwidth]);
            ylim([0 screenheight]);
            set(gca, 'XTick', round(linspace(0,screenwidth,4)), 'YTick', round(linspace(0,screenheight,4)) );
            set(gca,'drawmode','fast')
            % improved aesthetics
            set(gca, 'DataAspectRatio',[1 1 1], 'XTick', [], 'YTick', []);
            set(gca,'Position',[0 .5 1 .5],'box','on');

            % plot2
            subplot(2,1,2);
            obj.hPlot2Data = compass(0, max(rqdMagnitude), 'r');
            lims = [-max(rqdMagnitude) max(rqdMagnitude)*1.5];
            %remove lines and text objects except the main line
            delete(findall(ancestor(obj.hPlot2Data,'figure'),'HandleVisibility','off','type','line','-or','type','text'));
            %
            ylim(lims);
            xlim(lims);
            % store arrow for updating later
            xx = [0 1 .8 1 .8].';
            yy = [0 0 .08 0 -.08].';
            obj.arrow = xx + yy.*sqrt(-1); % form compass.m
            % annotate with target directions
            [x,y] = pol2cart(cmp2pol(direction), lims(2));
            text(x,y,num2cellstr(direction));
        end

        %% == METHODS =====================================================
        
        function [] = update(obj, newPlot1Dat, plot2Dat, theta, rho) %#ok
            % Update figure window.
            %
            % @param    newPlot1Dat	graphic & gaze locations
            % @param    plot2Dat  	evidence
            % @param    theta       current vector-direction estimate
            % @param    rho         current vector-magnitude estimate
            %
            % @date     26/06/14
            % @author   PRJ
            %       
            
            % plot distributions and data
            xy = obj.plot1Data.put(newPlot1Dat);
            set(obj.hPlot1Data,'XData',xy(:,1), 'YData',xy(:,2)); % plot1
            [x,y] = pol2cart(theta, rho);
            
            % update arrow / plot evidence
            a = obj.arrow * (x + y.*sqrt(-1)).';
            set(obj.hPlot2Data,'XData',real(a),'YData',imag(a));
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