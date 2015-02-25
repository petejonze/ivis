classdef (Sealed) IvGUIcalibration < ivis.gui.IvGUIelement
	% Singleton for displaying calibration interactive panel and fit
	% results.
    %
    %     Click individual swing icons to trigger calibration, right click
    %     on the background to trigger a calibration computation.
    %
    % IvGUIcalibration Methods:
    %   * IvGUIcalibration      - Constructor.
	%   * callbackMeasurePoint	- Method to execute once an intruction to measure a specific coordinate is recorded; start data gathering and log the results.
    %   * callbackMouseClick	- Method to execute once a mouse click occurs; if a right click, proceed to compute a new calibration given all existing measurements..
    %   * showMeasurements  	- Visualise raw measurements in the GUI.
    %   * showButtons           - Visualise measurement-trigger-buttons in the GUI.. 
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
    % £todo     add 'clear calib' button?
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 
   
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
          
    properties (Constant)
        FIG_NAME = 'IvGUIcalibration';
    end
    
    properties (GetAccess = public, SetAccess = private)
        targCoordinates 
        targCoordinates_px
        presentationFcn
        jButton = {};
        % handles
        hStatusFrame;
        hRawUsed
        hRawExcluded
        %
        showingMeasurements = false;
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        function obj = IvGUIcalibration(GUIidx, targCoordinates, presentationFcn)
            % IvGUIcalibration Constructor.
            %
            % @param    GUIidx              numeric gui panel index
            % @param    targCoordinates     user specified calibration coordinates (2 column matrix of xy, in pixels)
            % @param    presentationFcn     handle to stim presentation function
            % @return   obj                 IvGUIcalibration object
            %
            % @date     26/06/14
            % @author   PRJ
            %

            % init figure
            normaliseDims = [ivis.main.IvParams.getInstance().graphics.testScreenWidth, ivis.main.IvParams.getInstance().graphics.testScreenHeight]; % screen width, height         
            [effectiveFDims,fDims] = obj.init(GUIidx, normaliseDims);

            % add a border within the figure window
            xlim([-.1 1.1]); ylim([-.1 1.1]); % fix axes

            % store params
            obj.targCoordinates = targCoordinates;
            obj.presentationFcn = str2func(presentationFcn);
            
            % convert coordinates to pixels
            obj.targCoordinates_px = round(bsxfun(@times, targCoordinates, normaliseDims));
            
            % MAKE SWING ELEMENTS -----------------------------------------
            toolboxHomedir = ivis.main.IvParams.getInstance().toolboxHomedir;
            import javax.swing.*;
            
            img_calib = ImageIcon(fullfile(toolboxHomedir,'resources','images','cross.png'));
            for i = 1:size(obj.targCoordinates,1)
                % set position
                w = 25; % width
                h = 25; % height
                
                % remap [0 - 1] range to encorporate the border (above)
                targ = obj.targCoordinates(i,:);
                targ(2) = 1 - targ(2); % flipud
                targ = targ * (.9 - .1) + .1;
                
                % remap to 'pixel' units
                x0 = targ(1)*effectiveFDims(1) - floor(w/2) + (fDims(1) - effectiveFDims(1)); % probably a much easier way of writing this
                y0 = targ(2)*effectiveFDims(2) - floor(h/2) + (fDims(2) - effectiveFDims(2));
                
                % create the swing component
                obj.jButton{i} = javacomponent(javax.swing.JButton('',img_calib),[x0,y0,w,h], obj.hFig);
                
                % set hover text / cursor
                obj.jButton{i}.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
                obj.jButton{i}.setToolTipText(sprintf('%i: [%1.2f %1.2f], Click to calib (%s.m)',i, obj.targCoordinates(i,:), presentationFcn));

                % set onClick event
                set(obj.jButton{i},'ActionPerformedCallback', @(src, event)callbackMeasurePoint(obj, src, event, i) ); % execute on release
                
                % set background
                %   hide background of button (the panel background will still
                %   remain)
                obj.jButton{i}.setBorderPainted(false);
                obj.jButton{i}.setContentAreaFilled(false);
                %   because of the use of heavyweight panels, this background
                %   cannot be made transparent. For now we shall just set it to
                %   be the same colour as the underlying figure
                drawnow(); % must call before next line
                jButtonparent = obj.jButton{i}.getParent;
                jButtonparent.setBackground(java.awt.Color(0,0,0))
                
                % set rollover icon
                obj.jButton{i}.setRolloverIcon(img_calib)
            end

            % set onMouseClick to trigger calibration-compute function
            set(obj.hFig, 'windowButtonDownFcn', @(src, event)callbackMouseClick(obj, src, event) );

            
            % init status border
            obj.hStatusFrame = rectangle('Position',[0 0 .99 .99], 'EdgeColor', 'y');
            
            % init raw markers
            hold on
                obj.hRawUsed = plot(.1, .1, 'go');
                obj.hRawExcluded = plot(.7, .7, 'rx');
            hold off
            
            % init status border
            obj.hStatusFrame = rectangle('Position',[0 0 .99 .99], 'EdgeColor', 'y');
            
            % update the figure window
            drawnow();
        end
        
        function [] = delete(obj)
            % IvGUIcalibration Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            try
                % delete buttons
                for i = 1:length(obj.jButton)
                    delete(obj.jButton{i});
                end
            catch ME
                fprintf('%s\n',ME.message);
            end
        end
    end

    
    %% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================
    
    methods (Access = private)
        
        function [] = callbackMeasurePoint(obj, src, event, i) %#ok
            % Method to execute once an intruction to measure a specific
            % coordinate is recorded; start data gathering and log the
            % results.
            %
            % @param    src     callback source
            % @param    event   callback event
            % @param    i       coordiante index
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % init
            targ = [obj.targCoordinates_px(i,1), obj.targCoordinates_px(i,2)];
            
            % get new measurements
            resp = obj.presentationFcn(targ(1), targ(2));
            
            % remove any previous points for this targ
            ivis.calibration.IvCalibration.getInstance().removeMeasurements(targ);

            % add new points
            ivis.calibration.IvCalibration.getInstance().addMeasurements(targ, resp);
        end
        
        function [] = callbackMouseClick(obj, src, event) %#ok
            % Method to execute once a mouse click occurs; if a right
            % click, proceed to compute a new calibration given all
            % existing measurements.
            %
            % @param    src
            % @param    event
            %
            % @date     26/06/14
            % @author   PRJ
            %            
           
            % if not right-click, ignore
            if ~strcmpi(get(src, 'selectionType'), 'alt')
                return
            end
            
            if obj.showingMeasurements
                obj.showButtons();
            else
                % compute calibration
                fprintf('Computing calibration...\n');
                ok = ivis.calibration.IvCalibration.getInstance().compute();

                % signal status
                if ok
                    set(obj.hStatusFrame, 'EdgeColor', 'g');
                    obj.showMeasurements();
                else
                    set(obj.hStatusFrame, 'EdgeColor', 'r');
                end
            end
        end
        
        function [] = showMeasurements(obj)
            % Visualise raw measurements in the GUI.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            [resp_used, resp_excluded] = ivis.calibration.IvCalibration.getInstance().getMeasurements;
            
            screenDims = [ivis.main.IvParams.getInstance().graphics.testScreenWidth, ivis.main.IvParams.getInstance().graphics.testScreenHeight];
            
            % set
            if ~isempty(resp_used)
                resp_used = bsxfun(@rdivide, resp_used, screenDims); % normalise to between 0 and 1
                set(obj.hRawUsed, 'XData',resp_used(:,1), 'YData',resp_used(:,2));
            else
                set(obj.hRawUsed, 'XData',NaN, 'YData',NaN);
            end
            if ~isempty(resp_excluded)
                resp_excluded = bsxfun(@rdivide, resp_excluded, screenDims);
                set(obj.hRawExcluded, 'XData',resp_excluded(:,1), 'YData',resp_excluded(:,2));
            else
                set(obj.hRawExcluded, 'XData',NaN, 'YData',NaN); 
            end
            
            % hide buttons
            for i = 1:size(obj.targCoordinates,1)
                obj.jButton{i}.setVisible(false);
                obj.showingMeasurements = true;
            end
            
            drawnow();
        end
        
        function [] = showButtons(obj)
            % Visualise measurement-trigger-buttons in the GUI.
            %
            % @date     26/06/14
            % @author   PRJ
            %            
            for i = 1:size(obj.targCoordinates,1)
                obj.jButton{i}.setVisible(true);
                obj.showingMeasurements = false;
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