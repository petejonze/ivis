classdef (Sealed) IvGUI < Singleton
	% Singleton responsible for maintaining the overall frame, in which
	% individual Java windows may be embedded.
    %
    %     clear all
    %     import ivis.gui.*;
    %     IvGUI.init(1,1)
    %     IvGUI.getInstance().addFigurePanel(2,'blah')
    %     IvGUI.getInstance()
    %     IvGUI.finishUp
    %     IvGUI.init(1,3)    
    %
    % IvGUI Methods:
    %   * IvGUI             - Constructor.
	%   * addFigurePanel  	- Create a new java window and at it to the GUI frame, at the specified index location..
    %   * addFigureToPanel	- Add an existing java window to the GUI frame, at the specified index location.
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
    %   1.0 PJ 02/2013 : first_build\n
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 

    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
      
    properties (GetAccess = public, SetAccess = private)
        % user specified parameters
        screenNum
        dockFlag
        % other internal parameters
        hFig
    end
    
    properties (GetAccess = private, SetAccess = private)
        % other internal parameters
        guiName
        monitorAnchor
        guiLayout = [2 3];
    end
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
      
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvGUI(screenNum, dockFlag)
            % IvGUI Constructor.
            %
            % @param    screenNum 	screen index to place GUI on
            % @param    dockFlag 	whether to dock the GUI in the Matlab IDE
            % @return   obj         IvGUI object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            obj.screenNum = screenNum;
            obj.dockFlag = dockFlag;
            
            % set toolkit name
            params = ivis.main.IvParams.getInstance();
            obj.guiName = sprintf('%s %s GUI', params.main.ivName, num2str(params.main.ivVersion));
            
            obj.hFig = nan(1, prod(obj.guiLayout)); % init
            
            obj = obj.createGUI();
        end
        
        function delete(obj)
            % IvGUI Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % close figure panel window
            try
                desktop = com.mathworks.mde.desk.MLDesktop.getInstance;      % Matlab 7+
            catch ME %#ok
                desktop = com.mathworks.ide.desktop.MLDesktop.getMLDesktop;  % Matlab 6
            end
            desktop.removeGroup(obj.guiName); % e.g., so no longer returned by "desktop.getGroupTitles"
            
            % set focus on command window(?)
            commandwindow();
        end
        
        %% == METHODS =====================================================

        function obj = addFigurePanel(obj, figIndex, figName)
            % Create a new java window and at it to the GUI frame, at the
            % specified index location.
            %
            % @param    figIndex 	GUI frame index (determines position)
            % @param    figName 	figure title
            % @return   obj         IvGUI object
            %
            % @date     26/06/14
            % @author   PRJ
            %   
            
            obj.hFig(figIndex) = figure('visible','off', 'Name',figName,'NumberTitle','off');
            if obj.dockFlag == 0
                set(obj.hFig(figIndex),'position', obj.monitorAnchor + get(obj.hFig(figIndex),'position').*[0 0 1 1]);
            else
                %add items to group
                setfigdocked('GroupName',obj.guiName,'Figure',obj.hFig(figIndex),'Figindex',figIndex);
            end
            % draw
            set(obj.hFig(figIndex),'visible','on');
            drawnow();
        end 
        
        function obj = addFigureToPanel(obj, hFig, figIndex)
            % Add an existing java window to the GUI frame, at the specified
            % index location.
            %
            % @param    hFig        handle of Matlab figure window
            % @param    figIndex 	GUI frame index
            % @return   obj         IvGUI object
            %
            % @date     26/06/14
            % @author   PRJ
            %               
            obj.hFig(figIndex) = hFig;
            if obj.dockFlag == 0
                set(obj.hFig(figIndex),'position', obj.monitorAnchor + get(obj.hFig(figIndex),'position').*[0 0 1 1]);
            else
                %add items to group
                setfigdocked('GroupName',obj.guiName,'Figure',obj.hFig(figIndex),'Figindex',figIndex);
            end
            drawnow();
        end 
    end
    
    
    %% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================
          
    methods (Access = private)
        
        function obj = createGUI(obj)
            % Create the GUI frame, dock it inside the Matlab IDE if so
            % requested, or otherwise generate a standalone window. This
            % involves so slightly hacky java commands, and may not be
            % completely stable.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            fprintf('IVIS: constructing GUI...\n');
            
            % init
            monitorPositions = get(0,'MonitorPositions');
            if obj.screenNum < 0 || obj.screenNum > size(monitorPositions,1)
                error('createGUI:badMonitorNumber','Specified monitor number (%i) is outside No. of monitors (%i)',obj.screenNum,size(monitorPositions,1));
            end
            close all
            
            monitorIdx = max(1,obj.screenNum);
            
            obj.monitorAnchor = [monitorPositions(monitorIdx, 1:2)+99 0 0];
            %             set(0, 'DefaultFigureVisible', 'off');
            
            if obj.dockFlag < 1
                return % do nothing
            end
            
            % seriously, i think i'm gonna cry...
            close all
            
            % get handle to the Matlab desktop
            try
                desktop = com.mathworks.mde.desk.MLDesktop.getInstance;      % Matlab 7+
            catch ME %#ok
                desktop = com.mathworks.ide.desktop.MLDesktop.getMLDesktop;  % Matlab 6
            end
            if isempty(desktop)
                error('a:b','failed to retrieve desktop object');
            end
            
            % make figure group
            % remove previous figure groups
            if desktop.hasGroup(obj.guiName)
                fprintf('Clearning old GUI group');
                desktop.removeGroup(obj.guiName); % remove any old (defensive) e.g., so no longer returned by "desktop.getGroupTitles"
                while desktop.hasGroup(obj.guiName)
                    fprintf(' .');
                    WaitSecs(0.01);
                end
                fprintf('\n');
            end

            % create new figure group
            setfigdocked('GroupName',obj.guiName,'GridSize',obj.guiLayout,'SpanCell',[1 1 2 1]); % tmp hack [row col occupiedrows occupiedcols]
                 
            % Dock the figure container inside the Matlab system GUI
            % (or not if dockFlag ~= 1)
            try
                %fprintf('Try to dock I\n');
                javaMethod('setGroupDocked',obj.guiName,obj.dockFlag==1);
            catch ME %#ok
                %fprintf('Try to dock II\n');
                desktop.setGroupDocked(obj.guiName,obj.dockFlag==1);
            end
            
            if obj.dockFlag == 1
                desktopMainFrame = desktop.getMainFrame;
                z = desktopMainFrame.getLocation;
                z.setLocation(monitorPositions(monitorIdx,1), monitorPositions(monitorIdx,2));
                desktopMainFrame.setLocation(z);
                desktopMainFrame.setSize(monitorPositions(monitorIdx, 3)-monitorPositions(monitorIdx, 1),monitorPositions(monitorIdx, 4));
                desktopMainFrame.setMaximized(true);
                
            elseif obj.dockFlag > 1
                
                % plot a dummy figure so we have a container to play
                % with
                obj.hFig(1) = figure('visible','off', 'Name','null','NumberTitle','off');
                setfigdocked('GroupName',obj.guiName,'Figure',obj.hFig(1),'Figindex',1);
                
                % get handle
                container = desktop.getGroupContainer(obj.guiName).getTopLevelAncestor;
                
                % set size &  position(/monitor)
                if obj.dockFlag == 2
                    container.setMaximized(false);
                    container.setLocation(obj.monitorAnchor(1),obj.monitorAnchor(2));
                    container.setSize(1000,600);
                elseif obj.dockFlag == 3
                    container.setLocation(monitorPositions(monitorIdx, 1), monitorPositions(monitorIdx, 2));
                    container.setSize(monitorPositions(monitorIdx, 3)-monitorPositions(monitorIdx, 1),monitorPositions(monitorIdx, 4));
                    container.setMaximized(true);
                end
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