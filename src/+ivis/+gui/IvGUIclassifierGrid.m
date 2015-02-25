classdef (Sealed) IvGUIclassifierGrid < ivis.gui.IvGUIclassifier
	% Singleton for displaying grid classifier parameters and status.
    %
    % IvGUIclassifierGrid Methods:
    %   * IvGUIclassifierGrid   - Constructor.
	%   * update                - Update figure window.
    %
    % See Also:
    %   ivis.classifier.IvClassifierGrid
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
        FIG_NAME = 'IvGUIclassifierGrid';
    end
    
    properties (GetAccess = public, SetAccess = private)
        % user specified parameters
        %none
        % other internal parameters
        %
        poly
        nPoly
        categoryObjs
        nCategoryObjs
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================

        function obj = IvGUIclassifierGrid(GUIidx, lMagThresh, poly, categoryObjs)
            % IvGUIclassifierGrid Constructor.
            %
            % @param    GUIidx          GUI frame index
            % @param    lMagThresh    	evidence threshold required for decision
            % @param    poly            polynomials constituting the grid
            % @param    categoryObjs	category objects to classify
            % @return   obj             IvGUIclassifierGrid object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % validate params
            if length(lMagThresh) ~= length(categoryObjs)
                error('IvGUIclassifierGrid:InvalidInput', 'Num criteria (%i) must match num category objects (%i)', length(lMagThresh), length(categoryObjs));
            end
            
            % store params
            obj.poly = poly;
            obj.nPoly = length(poly);
            obj.categoryObjs = categoryObjs;
            obj.nCategoryObjs = length(categoryObjs);
            obj.nAlternatives = obj.nCategoryObjs;
            
          	% init plot colours (do it here rather than within each graphic
            % object so that each is maximally separable)
            colours = num2cell(hsv(obj.nCategoryObjs),2);
            for i = 1:obj.nCategoryObjs
                obj.categoryObjs(i).plotColour = colours{i};
            end
            
            % init figure
            obj.init(GUIidx);
            
            % init plots
            % plot1
            subplot(2,1,1);
            axis ij; % specify "matrix" axes mode. Coordinate system origin is at upper left corner.
            screenwidth = ivis.main.IvParams.getInstance().graphics.testScreenWidth;
            screenheight = ivis.main.IvParams.getInstance().graphics.testScreenHeight;
            xlim([0 screenwidth]);
            ylim([0 screenheight]);
            set(gca, 'XTick', round(linspace(0,screenwidth,4)), 'YTick', round(linspace(0,screenheight,4)) );
            %
            hold on
                % plot polygons
                for i = 1:obj.nPoly
                    plot(poly(i).x, poly(i).y, 'k');
                end

                % plot data
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
            ylim([0 max(lMagThresh)*1.1])
            xlim([0 obj.nCategoryObjs+1]);
            xlabel('N Samples')
            ylabel('Log Likelihood Ratio')
            set(gca, 'XTick',1:obj.nCategoryObjs,  'XTickLabel',{obj.categoryObjs.name} );
            hold on          
                IvHline(lMagThresh,  ':', {obj.categoryObjs.name}, colours, []);
                obj.hPlot2Data = bar(nan(1,obj.nCategoryObjs));
                obj.hPlot2Text = textLoc('','NorthEast'); % print some dummy text
            hold off
        end

        %% == METHODS =====================================================
        
        function [] = update(obj, newPlot1Dat, plot2Dat)
            % Update figure window.
            %
            % @param    newPlot1Dat	 graphic & gaze locations
            % @param    plot2Dat   	 evidence
            %
            % @date     26/06/14
            % @author   PRJ
            %        
            
            % plot distributions and data
            xy = obj.plot1Data.put(newPlot1Dat);
            set(obj.hPlot1Data,'XData',xy(:,1), 'YData',xy(:,2)); % plot1

            % plot evidence
            set(obj.hPlot2Data, 'YData', plot2Dat); % plot2
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