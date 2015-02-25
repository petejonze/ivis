classdef (Sealed) IvTobii < ivis.eyetracker.IvDataInput
    % Singleton instantiation of IvDataInput, designed to link to a Tobii
    % eyetracker.
    %
    %   long_description
    %
    % IvTobii Methods:
    %   * connect	- Establish a link to the eyetracking hardware.
    %   * reconnect	- Disconnect and re-establish link to eyetracker.
    %   * refresh  	- Query the eyetracker for new data; process and store.
    %   * flush   	- Query the eyetracker for new data; discard.
    %   * validate  - Validate initialisation parameters.
    %   * getEyeballLocations - Get cartesian coordinates for each eyeball, in millimeters.
    %   * getLastKnownViewingDistance - Compute last known viewing distance (averaging across eyeballs)
    %
    % IvTobii Static Methods:
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
        NAME = 'IvTobii';
        RAWLOG_PRECISION = 'single'; % 'double'
        RAWLOG_NCOLS = 28; % 27 + CPUtime
        RAWLOG_HEADERS = {
            'left_EyePosition3d_x', 'left_EyePosition3d_y', 'left_EyePosition3d_z', 'left_EyePosition3dRelative_x', 'left_EyePosition3dRelative_y', 'left_EyePosition3dRelative_z' ...
            , 'left_GazePoint2d_x', 'left_GazePoint2d_y' ...
            , 'left_GazePoint3d_x', 'left_GazePoint3d_y', 'left_GazePoint3d_z', 'left_PupilDiameter', 'left_Validity' ...
            , 'right_EyePosition3d_x', 'right_EyePosition3d_y', 'right_EyePosition3d_z', 'right_EyePosition3dRelative_x', 'right_EyePosition3dRelative_y', 'right_EyePosition3dRelative_z' ...
            , 'right_GazePoint2d_x', 'right_GazePoint2d_y' ...
            , 'right_GazePoint3d_x', 'right_GazePoint3d_y', 'right_GazePoint3d_z', 'right_PupilDiameter', 'right_Validity' ...
            , 'Timestamp', 'CPUtime'
            }; % from pp.61-62 of the Tobii SDK 3.0 handbook
        DISABLE_ID_VALIDATE = false; % set to true if the 'browsing for available trackers' is taking forever, and you want to skip that step (e.g., as on my macbook pro) (will use first specified id)
    end
    
    properties (GetAccess = public, SetAccess = private)
        leyeSpatialPosition = [NaN NaN NaN];
        reyeSpatialPosition = [NaN NaN NaN];
        leyeSpatialPosition_nonNaN = [-inf -inf -inf];
        reyeSpatialPosition_nonNaN = [-inf -inf -inf];
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvTobii()
            % IvTobii Constructor.
            %
            % @return   IvTobii
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % n.b., the SDK must already have been initialized by this
            % point. By default, this will already have happened due to
            % ivis.main.IvMain (indirectly) calling the validate() subclass
            
            % n.b., superclass IvDataInput will already have stored all the
            % necessary parameters and commencing logging, etc., if so
            % requested
            
            % validate params and connect to tracker
            if ~isempty(obj.id)
                obj.connect();
            else
                fprintf('\n\n!!!!IvTobii: id not set. You must explicitly (re)call IvTobii.connect(id) before attempting to gather data!!!!!!!!\n\n');
            end
        end
        
        function delete(obj) %#ok<INUSD>
            % IvTobii Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            try
                tetio_stopTracking();
            catch ME
                fprintf('FAILED TO STOP TRACKING???\n');
                disp(ME)
            end
            
            try
                tetio_disconnectTracker();
            catch ME
                fprintf('FAILED TO DISCONNECT EYETRACKER???\n');
                disp(ME)
            end
            
            try
                tetio_cleanUp();
            catch ME
                fprintf('FAILED TO CLEANUP EYETRACKER SDK???\n');
                disp(ME)
            end
            
        end
        
        %% == METHODS =====================================================
        
        function [] = connect(obj) % interface implementation
            if ~regexp(obj.id, 'TX120-\d{3}-\d{8}') % validate (otherwise could get nasty faults
                error('IvTobii:Invalid_Connect_Param', 'id must be of the form TX120-###-######## (%s).', obj.id);
            end
            if ~ismember(obj.Fs, [60 120])
                error('IvTobii:Invalid_Connect_Param', 'Sampling rate must be either 60 or 120 (%1.2f).', obj.Fs);
            end
            
            % connect to eyetracker
            fprintf('Connecting to tracker "%s"...', obj.id);
            try
                tetio_connectTracker(obj.id)
            catch ME
                if regexp(ME.message, 'Host not found') % grrr, TObii haven't bothered to identify their errors, so manually check here
                    fprintf('\n\nTracker not reachable. Available trackers are:\n');
                    ivis.eyetracker.IvTobii.enumerateTrackers();
                    fprintf('Press any key to continue (will quit)\n');
                    KbWait([],2);
                end
                rethrow(ME)
            end
            
            % set the specified framerate
            tetio_setFrameRate(obj.Fs);
            
            % commence eye tracking
            fprintf('   commencing tracking...');
            tetio_startTracking()
            
            % sync clock
            %obj.sync();
            
            fprintf('   tracking\n');
        end
        
        function [] = reconnect(obj) % interface implementation
            try
                tetio_stopTracking();
                tetio_disconnectTracker()
            catch ME
                rethrow(ME)
            end
            obj.connect();
        end
        
        function [n,saccadeOnTime] = refresh(obj, logData, lefteye,righteye,timestamp) % interface implementation
            if nargin < 2
                logData = true;
            end
            
            %-----------Extract Raw Data---------------------------------
            timeReceived = GetSecs();
            if nargin < 3
                % get data from hardware
                [lefteye, righteye, timestamp] = tetio_readGazeData;
            end
            
            % check if any data returned (if not, no point continuing)
            n = size(timestamp,1);
            saccadeOnTime = [];
            if n == 0
                return;
            end
            
            % tmp (for trackbox)
            obj.leyeSpatialPosition = lefteye(end, 1:3);
            obj.reyeSpatialPosition = righteye(end, 1:3);
            %   
            obj.leyeSpatialPosition(all(obj.leyeSpatialPosition==0,2),:) = NaN; % replace any rows of all 0's, with NaNs
            obj.reyeSpatialPosition(all(obj.reyeSpatialPosition==0,2),:) = NaN; % replace any rows of all 0's, with NaNs
            %
            %idx = find(~all(lefteye(:,1:3)==0,2),1,'last');
            idx = find(lefteye(:,3)<1000 & lefteye(:,3)>600,1,'last'); % distance (z) must be between 600 and 1000mm

            if ~isempty(idx)
                obj.leyeSpatialPosition_nonNaN = lefteye(idx, 1:3);
                obj.reyeSpatialPosition_nonNaN = righteye(idx, 1:3);
            end
            
            % map itrack timestamp to matlab's clock
            itime = double(timestamp)/1000000; % microseconds to seconds (since GetSecs is in seconds)
            %offset = itime - timeReceived;
            %t = itime - offset;
            CPUtime = itime - (itime(end) - timeReceived); % effectively just substituting the current time for the last sampled time
            
            % extract relevant gaze data
            xy1 = lefteye(:,7:8); % see ParseGazeData
            xy2 = righteye(:,7:8);
            % additional
            p1 = lefteye(:,12); % pupil diameter
            v1 = lefteye(:,13); % validity
            p2 = righteye(:,12);
            v2 = righteye(:,13);
            
            % exclude any erroneous points (which Tobii marks as -1(?)), by
            % setting to NaN
            xy1(xy1==-1) = NaN;
            xy2(xy2==-1) = NaN;
            
            % combine data across eyes (or select from one only)
            switch obj.eyes
                case 0 % left eye only
                    xy = xy1;
                    vldty = v1;
                    pd = p1;
                case 1 % right eye only
                    xy = xy2;
                    vldty = v2;
                    pd = p2;
                case 2 % mean of both
                    xy = nanmean(cat(3,xy1,xy2),3);
                    vldty = v1*10 + v2;
                    pd = nanmean(cat(3,p1,p2),3);
                otherwise
                    error('unknown eye code: %1.2f', obj.eyes);
            end
            
            % convert to monitor position (pixels)
            xy = xy .* repmat([obj.testScreenWidth obj.testScreenHeight], n, 1);
            
            %-----------Send Data to Buffer------------------------------
            % send the data to an internal buffer which handles filtering
            % and feature extraction, and then passes the data along to the
            % central DataLog and any relevant GUI elements
            saccadeOnTime = obj.processData(xy(:,1),xy(:,2),CPUtime,vldty,pd, logData);
            
            % log data if requested in launch params (and not countermanded
            % by user's refresh call)
            if obj.LOG_RAW_DATA && logData
                obj.RAWLOG.write([lefteye righteye itime CPUtime], obj.RAWLOG_PRECISION);
            end
        end
        
        function n = flush(obj) % interface implementation
            [lefteye] = tetio_readGazeData;
            n = size(lefteye,1); % compute n data points received
            obj.refresh(false);
        end
        
        function [left_xyz_mm, right_xyz_mm] = getEyeballLocations(obj, allowNaN)
            % Get cartesian coordinates for each eyeball, in millimeters.
            % If allowNaN==false then will return most recent valid
            % measurement (or minus infinity if no valid location has ever
            % been recorded).
            %
            % @param    allowNaN        Boolean (default=false)
            % @return   left_xyz_mm     Cartesian coordinates (mm)
         	% @return   right_xyz_mm    Cartesian coordinates (mm)
            %
            % @date     21/07/14
            % @author   PRJ
            %
            
            if nargin < 2 || isempty(allowNaN)
                allowNaN = true;
            end
            
            if allowNaN
                left_xyz_mm = obj.leyeSpatialPosition;
                right_xyz_mm = obj.reyeSpatialPosition;
            else
                left_xyz_mm = obj.leyeSpatialPosition_nonNaN;
                right_xyz_mm = obj.reyeSpatialPosition_nonNaN;
            end
            
        end
        
        function [lastKnownViewingDistance_cm] = getLastKnownViewingDistance(obj)
            % Compute last known viewing distance (averaging across
            % eyeballs). Will return NaN if no valid location has ever been
            % recorded.
            %
         	% @return   lastKnownViewingDistance_cm    distance from Tobii to mean eyeball location (cm)
            %
            % @date     21/07/14
            % @author   PRJ
            %
            
            % get values
            [left_xyz_mm, right_xyz_mm] = getEyeballLocations(obj, false);
            
            
            % compute
            mean_xyz_mm = nanmean([left_xyz_mm; right_xyz_mm]);
            lastKnownViewingDistance_cm = mean_xyz_mm(3)/10;
            
            % validation
            if isnan(lastKnownViewingDistance_cm)
                error('Internal ivis error');
            end
            
            % replace '-1' with 'NaN'
            if lastKnownViewingDistance_cm == -1
                lastKnownViewingDistance_cm = NaN;
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
            
            % Ensure that SDK installed
            if exist('tetio_init','file')~=2
                error('tetio_init.m not found on path. Please ensure that the Tobii SDK 3.0 Matlab wrapper is installed');
            end
            
            % tetio doesn't provide a way to query if the SDK is already
            % initialised, and it will crash if one tries to initialise it
            % twice. So we'll try to close it, just in case it is already
            % open, before trying to open it afresh.
            try tetio_cleanUp(); catch, end %#ok
            
            tetio_init();
        end
        
        function [structure, lefteye, righteye, timestamp, CPUtime, headers] = readRawLog(fullFn)
            % Parse data stored in a .raw binary file (hardware-brand
            % specific format).
            %
            %     e.g.,
            %     [lefteye, righteye, timestamp] = ivis.eyetracker.IvTobii.readRawLog('D:/Dropbox/MatlabToolkits/infantVision/code/v0.0.8/infantVision/logs/tobii-20130228T194814.raw');
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
            data = ivis.log.IvRawLog.read(fullFn, ivis.eyetracker.IvTobii.RAWLOG_PRECISION, ivis.eyetracker.IvTobii.RAWLOG_NCOLS);
            
            % parse data in submatrices
            lefteye = data(:, 1:13);
            righteye = data(:, 14:26);
            timestamp = data(:, 27);
            CPUtime = data(:, 28);
            
            % parse data into structure
            headers = ivis.eyetracker.IvTobii.RAWLOG_HEADERS;
            structure = cell2struct(num2cell(data, 1), headers, 2);
        end
        
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS (protected)-----
    %$ ====================================================================
    
    methods (Static, Access = protected)
        
        function [] = validate(params)
            ivis.eyetracker.IvTobii.initialiseSDK(); % ensure toolkit is initialised (will throw an error if not)
            
            % For now we'll insist on valid Tobii X120 params
            if ~ismember(params.sampleRate, [60 120])
                error('Error: Sampling rate must be either 60 or 120 (%1.2f).', params.sampleRate);
            end
            
            % if id is empty give user option to choose from a list, but
            % allow empty id for now, since may want to explicitly/manually
            % connect later
            if isempty(params.id)
                trackeraddresses = ivis.eyetracker.IvTobii.enumerateTrackers();
                
                fprintf('\nIvTobii: Enter tracker number, or leave blank to manually specify later (n.b., not recommended - will skip validation)\n');
                n = getIntegerInput('Tracker number: ', 'minMax',[1 length(trackeraddresses)], 'allowNull',true);
                if isempty(n)
                    return
                else
                    params.id = trackeraddresses{n};
                end
            end
            
            % convert to cell if currently a string
            if ~iscell(params.id)
                params.id = {params.id}; % allow for a cell of possible address, which will attempt to work through, in order
            end
            
            % remove the '.local' suffix if/where present
            id = regexp(params.id,'(.*?)(?=\.|$)','match','once');
            
            % display
            fprintf('Specified Tracker(s):\n');
            fprintf('    %s\n', id{:})
            
            % get available trackers and print addresses to screen
            if ~ivis.eyetracker.IvTobii.DISABLE_ID_VALIDATE
                if ~exist('trackeraddresses','var') % may have already been retrieved
                    trackeraddresses = ivis.eyetracker.IvTobii.enumerateTrackers();
                end
                
                valididx = ismember(id, trackeraddresses);
                if ~any(valididx)
                    fprintf('Specified tracker ID(s) (%s) does not match any of the available trackers (%s)\n', strjoin(',',id{:}), strjoin(',',trackeraddresses{:}) );
                    if getLogicalInput(sprintf('Temporarily replace with %s? (Not recommended): ', trackeraddresses{1}) )
                        id = trackeraddresses{1};
                    else
                        error('IvTobii:FailedInit','Specified tracker ID (%s) does not match any of the available trackers (%s)\nEdit the XML config file and try again.', strjoin(',',id{:}), strjoin(',',trackeraddresses{:}));
                    end
                else
                    % select the first valid tracker
                    id = id{find(valididx,1)};
                end
            else
                fprintf('IVIS: skipping tracker address validation, as requested by the flag DISABLE_ID_VALIDATE in IvTobii.m (will use first specified id)\n');
                id = id{1}; % select the first specified tracker (no way of knowing if valid)
            end
            
            % Inform user which id using (i.e., in case multiple
            % possibilities were specified (useful when using the same
            % scripts on multiple machines)
            fprintf('Using eyetracker ID: %s\n\n', id);
            
            % set id (i.e., if one wasn't specified by the user)
            pObj = ivis.main.IvParams.getInstance();
            pObj.eyetracker.id = id; % ???
        end
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS (private)-----
    %$ ====================================================================
    
    methods (Static, Access = private)
        function trackeraddresses = enumerateTrackers()
            fprintf('Browsing for trackers...');
            trackerinfo = tetio_getTrackers();  % For debuggin: trackerinfo = struct('ProductId', {'TX120-203-81900130', '1312121212'});
            if ~isempty(trackerinfo)
                trackeraddresses = {trackerinfo.ProductId};
                fprintf(' Available Trackers:\n');
                x = [num2cell(1:length(trackeraddresses)); trackeraddresses];
                fprintf('    [%i] %s\n', x{:})
            else
                fprintf(' No trackers found\n');
                error('IvTobii:FailedInit','No eyetrackers detected. Check turned on?');
            end
        end
    end
        
end