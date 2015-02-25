classdef (Sealed) IvGUIclassifierLL < ivis.gui.IvGUIclassifier
	% Singleton for displaying log-likelihood classifier parameters and
	% status.
    %
    % IvGUIclassifierLL Methods:
    %   * IvGUIclassifierLL - Constructor.
	%   * update            - Update figure window.
    %
    % See Also:
    %   ivis.classifier.IvClassifierLL
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
        FIG_NAME = 'IvGUIclassifierLL';
    end
    
    properties (GetAccess = public, SetAccess = private)
        % other internal parameters
        graphicObjs
        hitFuncs
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvGUIclassifierLL(GUIidx, lMagThresh, graphicObjs, hitFuncs)
            % IvGUIclassifierLL Constructor.
            %
            % @param    GUIidx     	 GUI frame index
            % @param    lMagThresh 	 evidence threshold required for decision
            % @param    graphicObjs	 graphic objects to monitor for movement
            % @param    hitFuncs   	 hit functions that supply likelihood data
            % @return   obj          IvGUIclassifierLL object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % validate params
            if length(lMagThresh) ~= length(graphicObjs)
                error('IvGUIclassifierLL:InvalidInput', 'Num criteria (%i) must match num graphic objects (%i)', length(lMagThresh), length(graphicObjs));
            end
            
            % store params
            obj.graphicObjs = graphicObjs;
            obj.hitFuncs = hitFuncs;
            nGraphicObjs = length(obj.graphicObjs);
            obj.nAlternatives = nGraphicObjs;
            
            % init plot colours (do it here rather than within each graphic
            % object so that each is maximally separable)
            colours = num2cell(hsv(nGraphicObjs),2);
            
            % init figure
            obj.init(GUIidx);
            
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
            screenwidth = ivis.main.IvParams.getInstance().graphics.testScreenWidth;
            screenheight = ivis.main.IvParams.getInstance().graphics.testScreenHeight;
            xlim([0 screenwidth]);
            ylim([0 screenheight]);
            set(gca, 'XTick', round(linspace(0,screenwidth,4)), 'YTick', round(linspace(0,screenheight,4)) );
            %
            hold on
                % plot graphic object schemas
                for i = 1:nGraphicObjs
                    obj.hitFuncs{i}.plot(obj.graphicObjs{i}.getXY(), colours{i});
                end
                obj.hPlot1Data = plot(obj.plot1Data.get(),'kx'); % plot on top
            hold off
            set(gca,'drawmode','fast')
            % improved aesthetics
            set(gca, 'DataAspectRatio',[1 1 1], 'XTick', [], 'YTick', []);
            set(gca,'Position',[0 .5 1 .5],'box','on');
            
            % plot2
            subplot(2,1,2);
            ylim([-max(lMagThresh) max(lMagThresh)*1.5])
            xlim([0 obj.BUFFER_LENGTH]);
            xlabel('N Samples')
            ylabel('Log Likelihood Ratio')
            set(gca,'XTick',xlim());
            hold on
                hline(0,'k:');             
                IvHline(lMagThresh,  ':', cellfun(@(x)x.name,obj.graphicObjs,'Uni',0), colours, []);                
                obj.hPlot2Data = plot(repmat(1:obj.BUFFER_LENGTH,2,1)', obj.plot2Data.get(), '-'); % plot some dummy data
                obj.hPlot2Text = textLoc('','NorthEast'); % print some dummy text
            hold off
            for i = 1:nGraphicObjs % tmp: todo: tidy up
                set(obj.hPlot2Data(i),'color',colours{i});
            end
        end
        
        %% == METHODS =====================================================
        
        function [] = update(obj, newPlot1Dat, plot2Dat)
            % Update figure window.
            %
            % @param    newPlot1Dat graphic & gaze locations
            % @param    plot2Dat    evidence
            %
            % @date     26/06/14
            % @author   PRJ
            %       
            
            % plot distributions and data
            xy = obj.plot1Data.put(newPlot1Dat);
            set(obj.hPlot1Data,'XData',xy(:,1), 'YData',xy(:,2)); % plot1
            DV = obj.plot2Data.put(plot2Dat);
            
            % plot evidence
            for i = 1:length(obj.hitFuncs)
                set(obj.hPlot2Data(i), 'YData', DV(:,i)); % plot2
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