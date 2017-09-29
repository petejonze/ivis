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
    end
    
    properties (GetAccess = private, SetAccess = private)
        % other internal parameters
        guiLayout       = [2 3];
        gui_x0y0wh_prop = [0 0.6 .9 .4];    % total extent of gui, in proportion of the screen width/height
        gui_x0y0wh_px   = [NaN NaN NaN NaN]
        resizeMatlabDesktop = false;
    end
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
      
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvGUI(screenNum)
            % IvGUI Constructor.
            %
            % @param    screenNum 	screen index to place GUI on
            % @return   obj         IvGUI object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % validate
            if sum(obj.gui_x0y0wh_prop([1 3]))>1
                warning('total GUI horizontal dimensions shouldnt exceed 1, clipping..');
                obj.gui_x0y0wh_prop(3) = 1 - obj.gui_x0y0wh_prop(1);
            elseif sum(obj.gui_x0y0wh_prop([2 4]))>1
                warning('total GUI vertical dimensions shouldnt exceed 1, clipping..');
                obj.gui_x0y0wh_prop(4) = 1 - obj.gui_x0y0wh_prop(2);
            end
          
            obj.screenNum = screenNum;

            obj = obj.createGUI();
        end
        
        function delete(~)
            % IvGUI Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % set focus on command window(?)
            commandwindow();
        end
        
        %% == METHODS =====================================================

        function hFig = subfigure(obj, p, figName)
            % Create a new java window covering the specified extent of the
            % GUI 'frame'
            %
            % @param    p           figure position (in same syle as
            %                       subplot, though does not need to be int
            % @param    figName 	figure title
            % @return   hFig        figure window handle
            %
            % @date     26/06/14
            % @author   PRJ
            %   

            % validate input
            if any(p<1)
                error('Invalid figure position: Figure position should not be < 1')
            elseif any(p>prod(obj.guiLayout))
                error('Invalid figure position: Figure position should not exceed prod(obj.guiLayout)')  
            end
            
            % determine position
            unitwidth = obj.gui_x0y0wh_px(3)/obj.guiLayout(2);
            unitheight = obj.gui_x0y0wh_px(4)/obj.guiLayout(1);
            x0y0x1y1_px = nan(length(p), 4);
            for k = 1:length(p)
                [x,y] = ind2sub([obj.guiLayout(2),obj.guiLayout(1)],p(k));
                y = obj.guiLayout(1)-(y-1); % flip y so 1==toprow, 2==2ndrow, etc.
                x0y0x1y1_px(k,:) = [(x-1)*unitwidth (y-1)*unitheight x*unitwidth y*unitheight];
            end
            x0y0x1y1_px = [min(x0y0x1y1_px(:,1:2),[],1) max(x0y0x1y1_px(:,3:4),[],1)]; % find total extent
            x0y0wh_px = [obj.gui_x0y0wh_px(1:2)+x0y0x1y1_px(1:2) x0y0x1y1_px(3:4)-x0y0x1y1_px(1:2)]; % convert to x0y0wh coordinate system, and place within gui area

            % create
            hFig = figure('Name',figName, 'NumberTitle','off', 'OuterPosition',x0y0wh_px, 'MenuBar','None');

            % update screen
            drawnow();    
        end 

        function hFig = addAsSubfigure(obj, hFig, p)
            % determine position
            unitwidth = obj.gui_x0y0wh_px(3)/obj.guiLayout(2);
            unitheight = obj.gui_x0y0wh_px(4)/obj.guiLayout(1);
            x0y0x1y1_px = nan(length(p), 4);
            for k = 1:length(p)
                [x,y] = ind2sub([obj.guiLayout(2),obj.guiLayout(1)],p(k));
                y = obj.guiLayout(1)-(y-1); % flip y so 1==toprow, 2==2ndrow, etc.
                x0y0x1y1_px(k,:) = [(x-1)*unitwidth (y-1)*unitheight x*unitwidth y*unitheight];
            end
            x0y0x1y1_px = [min(x0y0x1y1_px(:,1:2),[],1) max(x0y0x1y1_px(:,3:4),[],1)]; % find total extent
            x0y0wh_px = [obj.gui_x0y0wh_px(1:2)+x0y0x1y1_px(1:2) x0y0x1y1_px(3:4)-x0y0x1y1_px(1:2)]; % convert to x0y0wh coordinate system, and place within gui area

            % move
            set(hFig, 'NumberTitle','off', 'OuterPosition',x0y0wh_px, 'MenuBar','None');

            % update screen
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
            
            % Get dimensions of all monitors
            screens = Screen('Screens');
            if IsWin && length(screens)>1 % on Windows dual-screen setups, 0 is all monitors, 1=monitor 1, 2=monitor 2, etc.
                screens(1) = [];
                %obj.screenNum = obj.screenNum + 1; % automatically increment by 1 (for consistency with Mac)
                if obj.screenNum==0
                    warning('DANGER!')
                end
            end
            
            % monitorPositions = get(0,'MonitorPositions') % !NOT STABLE!
            monitorPositions = nan(length(screens), 4);
            for i = 1:length(screens)
                monitorPositions(i,:) = Screen('Rect', screens(i));
                if i > 1
                    monitorPositions(i,1) = monitorPositions(i-1,1)+monitorPositions(i-1,3)+1;
                end
            end

            % Get monitor screen properties
            if obj.screenNum < 0 || obj.screenNum > size(monitorPositions,1)
                error('createGUI:badMonitorNumber','Specified monitor number (%i) is outside No. of monitors (%i)',obj.screenNum,size(monitorPositions,1));
            end
            monitorIdx = find(screens==obj.screenNum, 1);
            if isempty(monitorIdx)
                error('GUI screenNum %i does not correspond to any of the detected screens (%s)', obj.screenNum, strjoin1(',',screens));
            end
            
            % get ACTUAL monitor dimensions
            monitor_x_px = monitorPositions(monitorIdx, 1);
            monitor_y_px = monitorPositions(monitorIdx, 2);
            monitor_w_px = monitorPositions(monitorIdx, 3);
            monitor_h_px = monitorPositions(monitorIdx, 4);
            %
            obj.gui_x0y0wh_px = [monitor_x_px + obj.gui_x0y0wh_prop(1)*monitor_w_px
                                monitor_y_px + obj.gui_x0y0wh_prop(2)*monitor_h_px
                                obj.gui_x0y0wh_prop(3)*monitor_w_px
                                obj.gui_x0y0wh_prop(4)*monitor_h_px
                             ]';

            % for debugging only:
            %warning('FOR DEBUGGING/DEVELOPMENT ONLY');
            %figure('OuterPosition', obj.gui_x0y0wh_px)
            %fprintf('%1.2f\n', get(gcf,'OuterPosition'))
            

            % move Matlab Command Window to specificied monitor, and
            % maximise
            if obj.resizeMatlabDesktop
                desktop = com.mathworks.mde.desk.MLDesktop.getInstance(); % get handle to the Matlab desktop
                desktopMainFrame = desktop.getMainFrame;
                z = desktopMainFrame.getLocation;
                if obj.gui_x0y0wh_prop(4)<=0.8
                    z.setLocation(monitor_x_px, monitor_h_px - monitor_h_px*obj.gui_x0y0wh_prop(2));
% warning('tmp hack! required when using surface and trying to put the GUI on the non-main-display (AAAAAARGH!)')
% z.setLocation(5115,964);
                    desktopMainFrame.setLocation(z);
                    desktopMainFrame.setSize(monitor_w_px, monitor_h_px*(1-obj.gui_x0y0wh_prop(4)));
                    desktopMainFrame.setMaximized(false)
                else
                    z.setLocation(monitor_x_px, monitor_y_px);
                    desktopMainFrame.setLocation(z);
                    desktopMainFrame.setSize(monitor_w_px, monitor_h_px);
                    desktopMainFrame.setMaximized(true);
                end
            end
            
            % get MATLAB ESTIMATED monitor dimensions (applicable for
            % figure window positioning) -- necessary due to stupid bugs in
            % Matlab..
            if ismac
                monitorPositions = flipud(get(0,'MonitorPositions')); % is this really correct??
            else
                monitorPositions = get(0,'MonitorPositions');
            end
            monitor_x_px = monitorPositions(monitorIdx, 1);
            monitor_y_px = monitorPositions(monitorIdx, 2);
%             if IsWin
%                 monitor_w_px = monitorPositions(monitorIdx, 3)-monitorPositions(monitorIdx, 1)
%             else % ismac or isunix
                monitor_w_px = monitorPositions(monitorIdx, 3);
%             end
            monitor_h_px = monitorPositions(monitorIdx, 4);
            %
            obj.gui_x0y0wh_px = [monitor_x_px + obj.gui_x0y0wh_prop(1)*monitor_w_px
                                monitor_y_px + obj.gui_x0y0wh_prop(2)*monitor_h_px
                                obj.gui_x0y0wh_prop(3)*monitor_w_px
                                obj.gui_x0y0wh_prop(4)*monitor_h_px
                             ]';
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