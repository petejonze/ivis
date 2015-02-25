classdef (Sealed) IvMouse < ivis.eyetracker.IvDataInput
    % Singleton instantiation of IvDataInput, designed to be driven by a
    % mouse.
    % 
    %   Can be useful for simulating an eyetracker using more common
    %   hardware.
    %
   	% IvMouse Methods:
    %   * IvMouse   - Constructor.
    %   * connect	- Establish a link to the eyetracking hardware.
    %   * reconnect	- Disconnect and re-establish link to eyetracker.
    %   * refresh  	- Query the eyetracker for new data; process and store.
    %   * flush   	- Query the eyetracker for new data; discard.
    %   * readRawLog- Parse data stored in a .raw binary file (hardware-brand specific format).
    %   * validate  - Validate initialisation parameters.
    %
   	% IvMouse Static Methods:
    %   * readRawLog    - Parse data stored in a .raw binary file (hardware-brand specific format).
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
    
    properties (Constant)
        NAME = 'IvMouse';
        RAWLOG_PRECISION = 'single'; % 'double'
        RAWLOG_NCOLS = 3 % 2 + CPUtime
        RAWLOG_HEADERS = {'x','y','CPUtime'};    
    end
    
    properties (GetAccess = private, SetAccess = private)
        % other internal parameters
        oldSecs
        windowPtrOrScreenNumber = [];
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods(Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvMouse()
            % IvMouse Constructor.
            %
            % @return   IvMouse
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            obj.resetClock();
            obj.windowPtrOrScreenNumber = ivis.main.IvParams.getInstance().graphics.testScreenNum;
        end

        %% == METHODS =====================================================
        
        function [] = connect(obj) %#ok  interface implementation
        end
        
        function [] = reconnect(obj) %#ok  interface implementation
        end
        
        function n = refresh(obj, logData) % interface implementation
            if nargin < 2 || isempty(logData)
                % init
                logData = true; % may want to set false to suppress data logging
            end
            
            % ala IvSimulator
            n = floor(obj.getSecsElapsed()*obj.Fs); % Fs*t
            if n > 0
                % generate timestamps (linearly spaced from last refresh
                % time)
                t = obj.oldSecs + (1:n)'./obj.Fs;
                obj.resetClock();
                
                % generate data (linearly space from last position
                try
                    [x,y,buttons] = GetMouse(obj.windowPtrOrScreenNumber);
                catch % hack to stop crashing (e.g., after IvExampleCalibDisp1 (?))
                    return
                end
                x = repmat(x,n,1);
                y = repmat(y,n,1);
                
                % dummy vals
                vldty = ones(size(x));
                pd = ones(size(x));
                
                % use left-click to simulate a blink (represented by NaN data)
                if buttons(1) > 0
                    x(:) = NaN;
                    y(:) = NaN;
                    vldty(:) = 0;
                end
                
                %-----------Send Data to Buffer------------------------------
                % send the data to an internal buffer which handles filtering
                % and feature extraction, and then passes the data along to the
                % central DataLog and any relevant GUI elements
                obj.processData(x,y,t,vldty,pd, logData);
                
                % log data if requested in launch params (and not countermanded
                % by user's refresh call)
                if obj.LOG_RAW_DATA && logData
                    obj.RAWLOG.write([x y t], obj.RAWLOG_PRECISION);
                end
            end
        end
        
        function n = flush(obj) %  interface implementation
            n = floor(obj.getSecsElapsed()*obj.Fs); % Fs*t
            obj.resetClock();
        end
        
        % tmp hack:
        function dist_cm = getLastKnownViewingDistance(obj)
            dist_cm = 74;
        end
    end
    
    
    %% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================
    
    methods (Access = private)
        
        function secsElapsed = getSecsElapsed(obj)
            % ######### blaaaah.
            %
            % @return   secsElapsed
            %
            % @date     26/06/14
            % @author   PRJ
            %
            newSecs = GetSecs();
            secsElapsed = newSecs - obj.oldSecs;
        end
        
        function [] = resetClock(obj)
            % ######### blaaaah.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.oldSecs = GetSecs();
        end
    end
    

    %% ====================================================================
    %  -----PROTECTED STATIC METHODS-----
    %$ ====================================================================    
    
    methods (Static, Access = protected)
        
        function [] = validate(varargin) % interface implementation
            % ######### blaaaah.
            %
            % @param    varargin
            %
            % @date     26/06/14
            % @author   PRJ
            %    
            
            % ensure that GetMouse() is accessible
            GetMouse();
        end
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================
    
    methods (Static, Access = public)

        function [structure, xy, CPUtime, headers] = readRawLog(fullFn)
            % ######### blaaaah.
            %
            % @param    fullFn
            % @return   structure
            % @return   xy
            % @return   CPUtime
            % @return   headers
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % get data matrix
            data = ivis.log.IvRawLog.read(fullFn, ivis.eyetracker.IvMouse.RAWLOG_PRECISION, ivis.eyetracker.IvMouse.RAWLOG_NCOLS);
            
            % parse data in submatrices
            xy = data(:, 1:2);
            CPUtime = data(:, 3);

            % parse data into structure
            headers = ivis.eyetracker.IvMouse.RAWLOG_HEADERS;
            structure = cell2struct(num2cell(data, 1), headers, 2);   
        end  
    end
    
end