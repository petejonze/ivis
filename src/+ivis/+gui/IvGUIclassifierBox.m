classdef (Sealed) IvGUIclassifierBox < ivis.gui.IvGUIclassifier
	% Singleton for displaying box classifier parameters and status.
    %
    % IvGUIclassifierBox Methods:
    %   * IvGUIclassifierBox - Constructor.
	%   * update          	 - Update figure window.
    %
    % See Also:
    %   ivis.classifier.IvClassifierBox
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
% make an abstract classifierGUI for holding things like printStatus

    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
          
    properties (Constant)
        FIG_NAME = 'IvGUIclassifierBox';
    end
    
    properties (GetAccess = public, SetAccess = ?ivis.classifier.IvClassifierBox)
        hPlot1Rects
    end
    
    properties (GetAccess = public, SetAccess = private)
        boxColours
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================

        function obj = IvGUIclassifierBox(GUIidx, npoints, rects)
            % IvGUIclassifierBox Constructor.
            %
            % @param    GUIidx   GUI frame index
            % @param    npoints  number of gaze coordinates to display
            % @param    rects    box coordinates
            % @return   obj      IvGUIclassifierBox object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % validate params
            nObjs = length(rects);
            if length(npoints) ~= nObjs
                error('IvGUIclassifierBox:InvalidInput', 'Num criteria (%i) must match num graphic objects (%i)', length(npoints), nObjs);
            end

            obj.nAlternatives = nObjs;
            % init plot colours (do it here rather than within each graphic
            % object so that each is maximally separable)
            obj.boxColours = num2cell(hsv(nObjs),2);
            
            % init figure
            obj.init(GUIidx);
            
            % init plots
            % plot1
            subplot(2,1,1);
            
            axis ij; % specify "matrix" axes mode. Coordinate system origin is at upper left corner.
            %xlabel('x (px)');
            %ylabel('y (px)');
            screenwidth = ivis.main.IvParams.getInstance().graphics.testScreenWidth;
            screenheight = ivis.main.IvParams.getInstance().graphics.testScreenHeight;
            xlim([0 screenwidth]);
            ylim([0 screenheight]);
            set(gca, 'XTick', round(linspace(0,screenwidth,4)), 'YTick', round(linspace(0,screenheight,4)) );
            %
            hold on
                % plot graphic object schemas
                for i = 1:nObjs
                    obj.hPlot1Rects{i} = rectangle('Position',rects{i});
                end
                obj.plot1Data = CCircularBuffer(obj.BUFFER_LENGTH,2);
                obj.plot1Data.put(nan(obj.BUFFER_LENGTH,2));
                obj.hPlot1Data = plot(obj.plot1Data.get(),'kx'); % plot on top
            hold off
            set(gca,'drawmode','fast')
            % improved aesthetics
            set(gca, 'DataAspectRatio',[1 1 1], 'XTick', [], 'YTick', []);
            set(gca,'Position',[0 .5 1 .5],'box','on');
            
            % plot2
            subplot(2,1,2);
            ylim([0 max(npoints)*1.1])
            xlim([0 nObjs+1]);
            xlabel('Rect')
            ylabel('N Observations')
            set(gca, 'XTick',[]);
            hold on          
                IvHline(npoints,  ':', [], obj.boxColours, []);
                obj.hPlot2Data = bar(nan(1,nObjs));
                obj.hPlot2Text = textLoc('','NorthEast'); % print some dummy text
            hold off

            drawnow();
        end
        
        %% == METHODS =====================================================
        
        function [] = update(obj, plot1obs, plot2Dat)
            % Update figure window.
            %
            % @param    plot1obs    graphic & gaze locations
            % @param    plot2Dat    evidence
            %
            % @date     26/06/14
            % @author   PRJ
            %       
            
            % plot distributions and data
            xy = obj.plot1Data.put(plot1obs);
            set(obj.hPlot1Data,'XData',xy(:,1), 'YData',xy(:,2)); % plot1
            
            % plot evidence
            for i = 1:length(plot2Dat)
                set(obj.hPlot2Data(i), 'YData', plot2Dat(:,i)); % plot2
            end
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