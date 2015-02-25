classdef (Sealed) IvTobiieyex < ivis.eyetracker.IvDataInput
    % Singleton instantiation of IvDataInput, designed to link to a Tobii
    % eyetracker.
    %
    %   long_description
    %
    % IvTobiieyex Methods:
    %   * connect	- Establish a link to the eyetracking hardware.
    %   * reconnect	- Disconnect and re-establish link to eyetracker.
    %   * refresh  	- Query the eyetracker for new data; process and store.
    %   * flush   	- Query the eyetracker for new data; discard.
    %   * validate  - Validate initialisation parameters.
    %
    % IvTobiieyex Static Methods:
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
    %   1.1 PJ 02/2013 : Added support for raw data logging and trackbox visualisation\n
    %   1.0 PJ 02/2013 : first_build\n
    %
    % @todo switch to single precision?
    % @todo protect constructor?
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %
    
    %% ====================================================================
    %  -----PROPERTIES-----%
    %$ ====================================================================
    
    properties (Constant)
        NAME = 'IvTobiieyex';
        RAWLOG_PRECISION = 'single'; % 'double'
        RAWLOG_NCOLS = 5; % 4 + CPUtime
        RAWLOG_HEADERS = {
            'x', 'y', 'tobiistamp', 'winstamp', 'CPUtime'
            }; % from "Matlab EyeX Wrapper Guide.docx"
    end
    
    properties (GetAccess = public, SetAccess = private)
        xOffset = 0;
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvTobiieyex()
            % IvTobiieyex Constructor.
            %
            % @return   IvTobiieyex
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % n.b., the SDK must already have been initialized by this
            % point. With the Tobii EyeX this must be done manually
            % (outside of Matlab)
            
            % n.b., superclass IvDataInput will already have stored all the
            % necessary parameters and commencing logging, etc., if so
            % requested
            
            screenNum = ivis.main.IvParams.getInstance().graphics.testScreenNum;
            tmp = Screen('GlobalRect',screenNum);
            obj.xOffset = -tmp(1);

            % connect
            obj.connect();
        end
        
        function delete(obj) %#ok<INUSD>
            % IvTobiieyex Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            try
                eyex_stop();
            catch ME
                fprintf('FAILED TO STOP TRACKING???\n');
                disp(ME)
            end
        end
        
        %% == METHODS =====================================================
        
        function [] = connect(obj) % interface implementation
            % commence eye tracking (n.b. we will do all the logging within
            % ivis itself, so will not call eyex_double_log)
            fprintf('   commencing tracking...');
            eyex_init();
            eyex_collect();
            obj.flush();
        end
        
        function [] = reconnect(obj) % interface implementation
            try
                %stop tracking
                eyex_stop();
            catch ME
                rethrow(ME)
            end
            obj.connect();
        end
        
        function [n,saccadeOnTime] = refresh(obj, logData, xy,tobiistamp,winstamp) % interface implementation
            if nargin < 2
                logData = true;
            end
            
            %-----------Extract Raw Data---------------------------------

            timeReceived = GetSecs();
            if nargin < 3
                % get data from hardware (xy in pixels)
                [xy, tobiistamp, winstamp] = eyex_last_data_series();
            end
            
            % check if any data returned (if not, no point continuing)
            n = size(xy,1);
            saccadeOnTime = [];
            if n == 0
                return;
            end        
            
            % apply any requisite horizontal offset if using multiple
            % sceens (i.e., map from global to local screen origin)
            xy(:,1) = xy(:,1) + obj.xOffset;

            % map itrack timestamp to matlab's clock
            itime = double(tobiistamp)/1000000000000; % ??? to seconds (since GetSecs is in seconds)
%             fprintf('--------------------\n')
%             fprintf('%1.3f\n', itime);
%             itime2 = double(winstamp)/1000000000;
%             fprintf('=======================\n')
%             fprintf('%1.3f\n', itime2);
            CPUtime = itime - (itime(end) - timeReceived); % effectively just substituting the current time for the last sampled time

%             % exclude any erroneous points (which Tobii marks as -1(?)), by
%             % setting to NaN
%             xy(xy==-1) = NaN;
            
            % invent some placeholder validity and pupil data
            vldty = nan(size(tobiistamp));
            pd = vldty;
             
            %-----------Send Data to Buffer------------------------------
            % send the data to an internal buffer which handles filtering
            % and feature extraction, and then passes the data along to the
            % central DataLog and any relevant GUI elements
            saccadeOnTime = obj.processData(xy(:,1),xy(:,2),CPUtime,vldty,pd, logData);
            
            % for debugging:
            % fprintf('%1.3f  [%1.3f]    %1.3f\n', xy(1,1), xy(1,1)-obj.xOffset, xy(1,2));

            % log data if requested in launch params (and not countermanded
            % by user's refresh call)
            if obj.LOG_RAW_DATA && logData
                obj.RAWLOG.write([xy tobiistamp winstamp CPUtime], obj.RAWLOG_PRECISION);
            end
        end
        
        function n = flush(obj) %#ok interface implementation
            xy = eyex_last_data_series();
            n = size(xy,1); % compute n data points received
%             obj.refresh(false);
        end
        
        function lastKnownViewingDistance_cm = getLastKnownViewingDistance(obj)
            % Compute last known viewing distance (averaging across
            % eyeballs). Will return NaN if no valid location has ever been
            % recorded.
            %
         	% @return   lastKnownViewingDistance_cm    distance from Tobii to mean eyeball location (cm)
            %
            % @date     21/07/14
            % @author   PRJ
            %
            
            lastKnownViewingDistance_cm = 65; 
        end
        
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================
    
    methods (Static, Access = public)
        
        function [structure, xy, tobiistamp, winstamp, CPUtime, headers] = readRawLog(fullFn)
            % Parse data stored in a .raw binary file (hardware-brand
            % specific format).
            %
            %     e.g.,
            %     [lefteye, righteye, timestamp] = ivis.eyetracker.IvTobiieyex.readRawLog('D:/Dropbox/MatlabToolkits/infantVision/code/v0.0.8/infantVision/logs/tobii-20130228T194814.raw');
            %
            % @param	fullFn  	log (.raw) file, including path
            % @return   structure   structure, containing all data
            % @return   lefteye
            % @return   righteye
            % @return   timestamp
            % @return   CPUtime
            % @return   headers
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % get data matrix
            data = ivis.log.IvRawLog.read(fullFn, ivis.eyetracker.IvTobiieyex.RAWLOG_PRECISION, ivis.eyetracker.IvTobiieyex.RAWLOG_NCOLS);
            
            % parse data in submatrices
            xy = data(:, 1:2);
            tobiistamp = data(:, 3);
            winstamp = data(:, 4);
            CPUtime = data(:, 5);
            
            % parse data into structure
            headers = ivis.eyetracker.IvTobiieyex.RAWLOG_HEADERS;
            structure = cell2struct(num2cell(data, 1), headers, 2);
        end
        
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS (protected)-----
    %$ ====================================================================
    
    methods (Static, Access = protected)
        
        function [] = validate(~) % interface implementation
            
            % ensure that SDK installed
            if exist('eyex_init','file')~=2
                error('eyex_init.m not found on path. Please ensure that the EyeX Matlab wrapper is installed');
            end
        end
        
    end
        
end