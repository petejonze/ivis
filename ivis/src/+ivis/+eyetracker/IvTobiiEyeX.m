classdef (Sealed) IvTobiiEyeX < ivis.eyetracker.IvDataInput
    % Singleton instantiation of IvDataInput, designed to link to a Tobii
    % eyetracker.
    %
    %   long_description
    %
    % IvTobiiEyeX Methods:
    %   * connect	- Establish a link to the eyetracking hardware.
    %   * reconnect	- Disconnect and re-establish link to eyetracker.
    %   * refresh  	- Query the eyetracker for new data; process and store.
    %   * flush   	- Query the eyetracker for new data; discard.
    %   * validate  - Validate initialisation parameters.
    %
    % IvTobiiEyeX Static Methods:
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
        NAME = 'IvTobiiEyeX';
        RAWLOG_PRECISION = 'single'; % 'double'
        RAWLOG_NCOLS = 13;
        RAWLOG_HEADERS = {
            'Fixation X (px)', 'Fixation Y (px)', 'EyeGazeTimestamp (microseconds)' ...
            ,'HasLeftEyePosition (0 or 1)', 'HasRightEyePosition (0 or 1)' ...
            ,'LeftEyeX (mm)', 'LeftEyeY (mm)', 'LeftEyeZ (mm)' ...
            ,'RightEyeX (mm)', 'RightEyeY (mm)', 'RightEyeZ (mm)' ...
            ,'EyePosTimestamp (microseconds)' ...
            ,'CPUtime'
            }; % from "Matlab EyeX Wrapper Guide.docx"
        PREFERRED_VIEWING_DISTANCE_MM = 500;
        TRACKBOX_SIZE_MM = 300;
    end
    
    properties (GetAccess = public, SetAccess = private)
        xOffset = 0;
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvTobiiEyeX()
            % IvTobiiEyeX Constructor.
            %
            % @return   IvTobiiEyeX
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
            % IvTobiiEyeX Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            try
                myex('disconnect');
                WaitSecs(0.01);
            catch ME
                fprintf('FAILED TO STOP TRACKING???\n');
                disp(ME)
            end
        end
        
        %% == METHODS =====================================================
        
        function [] = connect(obj) % interface implementation
            % commence eye tracking (n.b. we will do all the logging within
            % ivis itself)
            fprintf('   commencing tracking...');
            myex('connect');
            WaitSecs(.01); 
            obj.flush();
        end
        
        function [] = reconnect(obj) % interface implementation
            try
                %stop tracking
                myex('disconnect');
            catch ME
                rethrow(ME)
            end
            WaitSecs(0.01);
            obj.connect();
            WaitSecs(.01); 
        end
        
        function [n,saccadeOnTime,blinkTime] = refresh(obj, logData, samples) % interface implementation
            if nargin < 2
                logData = true;
            end
            
            %-----------Extract Raw Data---------------------------------

            timeReceived = GetSecs();
            
            if nargin < 3
                % get data from hardware
                samples = myex('getdata');
            end
            
            % check if any data returned (if not, no point continuing)
            n = size(samples,1);
            saccadeOnTime = [];
            blinkTime = [];
            if n == 0
                % force display to show no-longer receiving tracking data
                % (i.e., since, unlike the Tobii X120, the EyeX does not
                % return 'NaN' values for missing data points (just returns
                % nothing)
                if ~isempty(obj.spatialGuiElement)
                    obj.spatialGuiElement.update([NaN NaN]);
                    drawnow();
                end
                
                % after 150+ milliseconds with no input, set the
                % eyeball location to be NaNs. This will ensure, for
                % example, that trackbox.m is aware we are no longer
                % receiving data
                if timeReceived > (obj.lastXYTV(3) + 0.15)
                    obj.setEyeballLocations(nan(1,3), nan(1,3), timeReceived);
                end
            
                % exit the refresh/update code
                return;
            end        

            % map itrack timestamp to matlab's clock
            tobiistamp = samples(:,3);
            itime = double(tobiistamp)/1000; % ??? to seconds (since GetSecs is in seconds)
            CPUtime = itime - (itime(end) - timeReceived); % effectively just substituting the current time for the last sampled time, and extrapolating backwards

        	% extract relevant gaze data (already in pixel coordinates, and
        	% already averaging between eyes if so specified using the
        	% external Tobii EyeX engine controller)
            xy = samples(:,[1 2]);
            
            % apply any requisite horizontal offset if using multiple
            % sceens (i.e., map from global to local screen origin)
            xy(:,1) = xy(:,1) + obj.xOffset;
            
            % exclude any erroneous points (which some versions of the eyex
            % engine seem to mark as 0), bysetting to NaN
            z_mm = samples(:,[8 11]);
            isvalid = samples(:,[4 5])==1 ;
            isvalid = isvalid | (z_mm~=0); % (i.e., not possible that eyeball is 0mm from device) - defensive
            isvalid = isvalid & xy~=0 & CPUtime>1;
            isvalid = mean(isvalid,2);
            xy(isvalid==0,:) = NaN; % treat only points with data from *neither* eye as invalid
            CPUtime(isvalid==0) = NaN;
            
            % get distance data (also exlude if invalid)
            zL_mm = samples(:,8);
            zL_mm(zL_mm<100 | zL_mm>1000) = NaN;
            zR_mm = samples(:,11);
            zR_mm(zR_mm<100 | zR_mm>1000) = NaN;
            
            % invent some placeholder pupil data
            pd = nan(size(tobiistamp));
            
            %-----------Send Data to Buffer--------------------------------
          	% set eyeball locations in physical space (e.g., for trackbox)
            obj.setEyeballLocations(samples(:,6:8), samples(:,9:11), samples(:,12)); % note timestamp not the same as the gaze data(!)
            
            % send the data to an internal buffer which handles filtering
            % and feature extraction, and then passes the data along to the
            % central DataLog and any relevant GUI elements
            [saccadeOnTime, blinkTime] = obj.processData(xy(:,1),xy(:,2),CPUtime,isvalid,pd, zL_mm,zR_mm, logData);
            
            % for debugging:
            % fprintf('%1.3f  [%1.3f]    %1.3f\n', xy(1,1), xy(1,1)-obj.xOffset, xy(1,2));

            % log data if requested in launch params (and not countermanded
            % by user's refresh call)
            if logData
                obj.RAWLOG.write([samples CPUtime], obj.RAWLOG_PRECISION);
            end
        end
        
        function n = flush(obj) % interface implementation
            xy = myex('getdata');
            n = size(xy,1); % compute n data points received
            obj.refresh(false);
        end
        
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================
    
    methods (Static, Access = public)
        
%         function [structure, xy, tobiistamp, winstamp, CPUtime, headers] = readRawLog(fullFn)
        function [data] = readRawLog(fullFn)
            % Parse data stored in a .raw binary file (hardware-brand
            % specific format).
            %
            %     e.g.,
            %     [lefteye, righteye, timestamp] = ivis.eyetracker.IvTobiiEyeX.readRawLog('D:/Dropbox/MatlabToolkits/infantVision/code/v0.0.8/infantVision/logs/tobii-20130228T194814.raw');
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
            data = ivis.log.IvRawLog.read(fullFn, ivis.eyetracker.IvTobiiEyeX.RAWLOG_PRECISION, ivis.eyetracker.IvTobiiEyeX.RAWLOG_NCOLS);

            
%             functionality_not_yet_written
%             % parse data in submatrices
%             xy = data(:, 1:2);
%             tobiistamp = data(:, 3);
%             winstamp = data(:, 4);
%             CPUtime = data(:, 5);
%             
%             % parse data into structure
%             headers = ivis.eyetracker.IvTobiiEyeX.RAWLOG_HEADERS;
%             structure = cell2struct(num2cell(data, 1), headers, 2);
        end
        
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS (protected)-----
    %$ ====================================================================
    
    methods (Static, Access = protected)
        
        function [] = validate(~) % interface implementation
            
            % ensure that SDK installed
            if exist('myex','file')~=3
                error('myex mex file (i.e., ''myex.mexw32'', ''myex.mexw64'') not found on path. Please ensure that the EyeX Matlab wrapper is installed');
            end
        end
        
    end
        
end