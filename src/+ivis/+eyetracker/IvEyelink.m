classdef (Sealed) IvEyelink < ivis.eyetracker.IvDataInput
    % Singleton instantiation of IvDataInput, designed to link to a Eyelink
    % eyetracker.
    %
    %   Validated with Eyelink 1000
    %
   	% IvEyelink Methods:
    %   * IvEyelink	- Constructor.
    %   * connect	- Establish a link to the eyetracking hardware.
    %   * reconnect	- Disconnect and re-establish link to eyetracker.
    %   * refresh  	- Query the eyetracker for new data; process and store.
    %   * flush   	- Query the eyetracker for new data; discard.
    %   * validate  - Validate initialisation parameters.
    %
   	% IvEyelink Static Methods:    
    %   * initialiseSDK	- Ensure toolkit is initialised (will throw an error if not).
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
    %   1.0 PJ 06/2014 : first_build\n
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %
    
    %% ====================================================================
    %  -----PROPERTIES-----%
    %$ ====================================================================
    
    properties (Constant)
        NAME = 'IvEyelink';
        RAWLOG_PRECISION = 'single'; % 'double'
        RAWLOG_NCOLS = 32; % 31 + CPUtime
        RAWLOG_HEADERS = {
              'time_ms', 'type', 'flags' ...
            , 'left_pupil_x_cam', 'right_pupil_x_cam', 'left_pupil_y_cam', 'right_pupil_y_cam' ...
            , 'left_headref_x_gaze', 'right_headref_x_gaze', 'left_headref_y_gaze', 'right_headref_y_gaze' ...
            , 'left_pupilsize_arb', 'right_pupilsize_arb' ...
            , 'left_gaze_x_px', 'right_gaze_x_px', 'left_gaze_y_px', 'right_gaze_y_px' ...
            , 'resolution_x', 'resolution_y' ...
            , 'status', 'input_port', 'input_button' ...
            , 'tracker_data_type', 'tracker_data_1', 'tracker_data_2', 'tracker_data_3', 'tracker_data_4', 'tracker_data_5', 'tracker_data_6', 'tracker_data_7', 'tracker_data_8' ...
            , 'CPUtime'
            }; % from Eyelink Matlab Toolbox ("Eyelink GetQueuedData?")
    end
    
    properties (GetAccess = public, SetAccess = private)
        leyeSpatialPosition = [NaN NaN NaN];
        reyeSpatialPosition = [NaN NaN NaN];
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvEyelink()
            % IvEyelink Constructor.
            %
            % @return   obj     IvEyelink object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % n.b., the SDK must already have been initialized by this
            % point. By default, his will already have happened due to
            % ivis.main.IvMain (indirectly) calling the validate() subclass
            
            % n.b., superclass IvDataInput will already have stored all the
            % necessary parameters and commencing logging, etc., if so
            % requested
            
            % connect to eyetracker (alt: can also do it manually later)
            obj.connect();
        end
        
        function delete(obj) %#ok<INUSD>
            % IvEyelink Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %

            try
                Eyelink('StopRecording');
            catch ME
                fprintf('FAILED TO STOP TRACKING???\n');
                disp(ME.message);
                disp(ME)
            end
            
            try
                Eyelink('Shutdown')
            catch ME
                fprintf('FAILED TO DISCONNECT EYETRACKER???\n');
                disp(ME.message);
                disp(ME)
            end
            
        end
        
        %% == METHODS =====================================================
        
        function [] = connect(obj) %#ok  interface implementation
            fprintf('   commencing tracking...');
            Eyelink('Command', 'set_idle_mode');
            WaitSecs(0.05);
            Eyelink('StartRecording'); % start tracking
            
            % sync clock
            %obj.sync();
            
            fprintf('   tracking\n');
        end
        
        function [] = reconnect(obj) %#ok  interface implementation
            Eyelink('StopRecording');
            WaitSecs(0.02);
            
            Eyelink('Shutdown')
            WaitSecs(0.02);
            
            Eyelink('Initialize')
            WaitSecs(0.02);
            
            Eyelink('Command', 'set_idle_mode');
            WaitSecs(0.02);
            
            Eyelink('StartRecording');
        end
        
        function connect_status = isconnected(obj) %#ok  interface implementation
            connect_status = Eyelink('IsConnected');
        end
        
        function [n,saccadeOnTime] = refresh(obj, logData, samples)
            if nargin < 2
                logData = true;
            end
            
            %-----------Extract Raw Data---------------------------------
            timeReceived = GetSecs();
            if nargin < 3
                if Eyelink( 'NewFloatSampleAvailable')
                    % get data from hardware
                    samples = Eyelink('GetQueuedData'); % each new sample is a column
                    
                    %ALT:
                    % drained = 0;
                    % while ~drained
                    %     [samples, events, drained] = Eyelink('GetQueuedData'); % each new sample is a column
                    % end
                    
                    samples = samples'; % transpose so that each column is a variable, each row is a timeseries sample
                else
                    samples = [];
                end
            end
            
            % check if any data returned (if not, no point continuing)
            n = size(samples,1);
            saccadeOnTime = [];
            if n == 0
                return;
            end
            
            % tmp (for trackbox)
            obj.leyeSpatialPosition = samples(end,[4 6]); 
            obj.reyeSpatialPosition = samples(end,[5 7]);
            
            % map itrack timestamp to matlab's clock
            timestamp = samples(:,1);
            itime = double(timestamp)/1000000; % microseconds to seconds (since GetSecs is in seconds)
            t = itime - (itime(end) - timeReceived); % effectively just substituting the current time for the last sampled time
            
            % extract relevant gaze data (already in pixel coordinates)
            xy1 = samples(:,[14 16]);
            xy2 = samples(:,[15 17]);
            % additional
            p1 = nan(n,1); % lefteye(:,12); % pupil diameter
            v1 = nan(n,1); % lefteye(:,13); % validity
            p2 = nan(n,1); % righteye(:,12);
            v2 = nan(n,1); % righteye(:,13);
            
            % exclude any erroneous points, by setting to NaN
            xy1(xy1<-10000) = NaN;
            xy2(xy2<-10000) = NaN;
            
            % combine data across eyes
            xy = nanmean(cat(3,xy1,xy2),3); % mean
            vldty = v1*10 + v2; % mean
            pd = nanmean(cat(3,p1,p2),3); % combine
            
         	% invent some placeholder depth data (tmp hack)
            zL_mm = nan(size(vldty));
            zR_mm = nan(size(vldty));
            
            %-----------Send Data to Buffer------------------------------
            % send the data to an internal buffer which handles filtering
            % and feature extraction, and then passes the data along to the
            % central DataLog and any relevant GUI elements
            saccadeOnTime = obj.processData(xy(:,1),xy(:,2),t,vldty,pd, zL_mm,zR_mm, logData);
            
            % log data if requested in launch params (and not countermanded
            % by user's refresh call)
            if obj.LOG_RAW_DATA && logData
                obj.RAWLOG.write([samples itime], obj.RAWLOG_PRECISION);
            end
        end
        
        function n = flush(~)
            n = 0; % init
            
            % clear the hardware buffer
            if Eyelink( 'NewFloatSampleAvailable')
                drained = 0;
                while ~drained
                    [samples, ~, drained] = Eyelink('GetQueuedData');
                    n = n + size(samples,2);
                end
            end
        end
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================
    
    methods (Static, Access = public)
        
        function [] = initialiseSDK()
            % Ensure toolkit is initialised (will throw an error if not).
            %
            % @date     26/06/14
            % @author   PRJ
            %            
            status = Eyelink('Initialize');
            if status ~= 0
                error('Failed to initialise the Eyelink (Error: %i)', status);
            end
        end
                       
        function [structure, samples, CPUtime, headers] = readRawLog(fullFn)
            % Parse data stored in a .raw binary file (hardware-brand specific format).
            %
            % n.b., returned with each row as an observation (transposed
            % from original eyelink format)
            %
            % @param    fullFn
            % @return   structure
            % @return   samples
            % @return   CPUtime
            % @return   headers
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % get data matrix
            data = ivis.log.IvRawLog.read(fullFn, ivis.eyetracker.IvEyelink.RAWLOG_PRECISION, ivis.eyetracker.IvEyelink.RAWLOG_NCOLS);
            
            % parse data in submatrices
            samples = data(:, 1:end-1);
            CPUtime = data(:, end);

            % parse data into structure
            headers = ivis.eyetracker.IvEyelink.RAWLOG_HEADERS;
            structure = cell2struct(num2cell(data, 1), headers, 2);      
        end 
    end

    
    %% ====================================================================
    %  -----STATIC METHODS (protected)-----
    %$ ====================================================================
        
    methods (Static, Access = protected)
        
        function [] = validate(params) % interface implementation  
            ivis.eyetracker.IvEyelink.initialiseSDK(); % ensure toolkit is initialised (will throw an error if not)

            % verify version (if specified)
            [~, versionString]  = Eyelink('GetTrackerVersion'); % e.g., [2, 'EYELINK II x.xx']
            if ~isempty(params.id) && ~strcmpi(versionString, params.id)
                error('Specified Eyelink id (%s) does not match the detection version (%s)', params.id, versionString);
            end            

            % set id (i.e., if one wasn't specified by the user)
            pObj = ivis.main.IvParams.getInstance();
            pObj.eyetracker.id = versionString;
        end
    end

end