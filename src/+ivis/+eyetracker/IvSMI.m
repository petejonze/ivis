classdef (Sealed) IvSmi < ivis.eyetracker.IvDataInput
    % Singleton instantiation of IvDataInput, designed not to be driven by
    % an SMI eyetracker
    %
    %   Uses the official SMI iView SDK
    %     
    %     
    %         myStruct:-|
    %               |-  timestamp: '4265056496'
    %               |-    leftEye:-|
    %                              |-       gazeX: '385.258'
    %                              |-       gazeY: '803.163'
    %                              |-        diam: '4.62'
    %                              |-eyePositionX: '-33.468'
    %                              |-eyePositionY: '7.187'
    %                              |-eyePositionZ: '597.324'
    %               |-   rightEye:-|
    %                              |-       gazeX: '385.258'
    %                              |-       gazeY: '803.163'
    %                              |-        diam: '4.82'
    %                              |-eyePositionX: '25.139'
    %                              |-eyePositionY: '9.285'
    %                              |-eyePositionZ: '598.138'
    %               |-planeNumber: '-1'
    %
   	% IvSmi Methods:
    %   * IvSmi     - Constructor.
    %   * connect	- Establish a link to the eyetracking hardware.
    %   * reconnect	- Disconnect and re-establish link to eyetracker.
    %   * refresh  	- Query the eyetracker for new data; process and store.
    %   * flush   	- Query the eyetracker for new data; discard.
    %   * validate  - Validate initialisation parameters.
    %
   	% IvSmi Static Methods:  
    %   * readRawLog- Parse data stored in a .raw binary file (hardware-brand specific format).
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
    
%@todo: allow use-specified parameters   
%@todo: add calibration support
%@todo: maybe allow user to extract an 'ivx' style data structure, if they
%want to 'manually' interact with the iViewX toolbox
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (Constant)
        NAME = 'IvSmi';
        RAWLOG_PRECISION = 'single'; % 'double'
        RAWLOG_NCOLS = 14; % 4 + CPUtime
        RAWLOG_HEADERS = {
            'timestamp' ...
            , 'lgazeX', 'lgazeY', 'ldiam', 'leyePositionX', 'leyePositionY', 'leyePositionZ' ...
            , 'rgazeX', 'rgazeY', 'rdiam', 'reyePositionX', 'reyePositionY', 'reyePositionZ' ...
            , 'planeNumber'
            }; % from SMI data structure
    end
    properties (GetAccess = public, SetAccess = private)
        pSystemInfoData
        pSampleData
        pEventData
        pAccuracyData
        CalibrationData
        pCalibrationData
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods(Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvSmi()
            % IvSmi Constructor.
            %
            % @return   IvSmi
            %
            % @date     21/10/14
            % @author   PRJ
            %
            
         	% n.b., the iView server must already have been initialized by
         	% this point.This must be done manually (outside of Matlab)
            
            % n.b., superclass IvDataInput will already have stored all the
            % necessary parameters and commencing logging, etc., if so
            % requested

            % load the iViewX API library
            loadlibrary('iViewXAPI.dll', 'iViewXAPI.h');
            
            % connect
            obj.connect();
        end
        
        function delete(obj)
            % IvSmi Destructor.
            %
            % @date     21/10/14
            % @author   PRJ
            %

            try
                % disconnect from iViewX
                calllib('iViewXAPI', 'iV_Disconnect');
            catch ME
                fprintf('FAILED TO DISCONNECT EYETRACKER???\n');
                disp(ME.message);
                disp(ME)
            end

            pause(0.01);

            
            obj.pSystemInfoData = [];
            obj.pSampleData = [];
            obj.pEventData = [];
            obj.pAccuracyData = [];
            obj.CalibrationData = [];
            obj.pCalibrationData = [];
        
            try
                % unload iViewX API libraray
                unloadlibrary('iViewXAPI');
            catch ME
                fprintf('FAILED TO UNLOAD SMI LIBRARY???\n');
                disp(ME.message);
                disp(ME)
            end
        end

        %% == METHODS =====================================================
        
        function connect(obj) % interface implementation
            fprintf('Connecting to SMI tracker...');         
            [obj.pSystemInfoData, obj.pSampleData, obj.pEventData, obj.pAccuracyData, obj.CalibrationData] = InitiViewXAPI();

% set a load of calibration params?!?!?!
            obj.CalibrationData.method = int32(5);
            obj.CalibrationData.visualization = int32(1);
            obj.CalibrationData.displayDevice = int32(0);
            obj.CalibrationData.speed = int32(0);
            obj.CalibrationData.autoAccept = int32(1);
            obj.CalibrationData.foregroundBrightness = int32(250);
            obj.CalibrationData.backgroundBrightness = int32(230);
            obj.CalibrationData.targetShape = int32(2);
            obj.CalibrationData.targetSize = int32(20);
            obj.CalibrationData.targetFilename = int8('');
            obj.pCalibrationData = libpointer('CalibrationStruct', obj.CalibrationData);

%             fprintf('SMI: Defining Logger...\n')
% warning('so what is this doing?')            
%             calllib('iViewXAPI', 'iV_SetLogger', int32(1), 'iViewXSDK_Matlab_GazeContingent_Demo.txt');

            fprintf('SMI: Connecting to iViewX...\n')
            status = calllib('iViewXAPI', 'iV_Connect', '127.0.0.1', int32(4444), '127.0.0.1', int32(5555));
            switch status
                case 1
                    % connected ok, do nothing and continue
                case 104
                    error('Could not establish connection. Check if Eye Tracker is running');
                case 105
                    error('Could not establish connection. Check the communication Ports');
                case 123
                    error('Could not establish connection. Another Process is blocking the communication Ports');
                case 200
                    error('Could not establish connection. Check if Eye Tracker is installed and running');
                otherwise
                    error('Could not establish connection');
            end
            
            
            fprintf('Get System Info Data...\n')
            calllib('iViewXAPI', 'iV_GetSystemInfo', obj.pSystemInfoData)
            get(obj.pSystemInfoData, 'Value');

% 	disp('Calibrate iViewX')
% 	calllib('iViewXAPI', 'iV_SetupCalibration', pCalibrationData)
% 	calllib('iViewXAPI', 'iV_Calibrate')
% 
% 
% 	disp('Validate Calibration')
% 	calllib('iViewXAPI', 'iV_Validate')
% 
% 
% 	disp('Show Accuracy')
% 	calllib('iViewXAPI', 'iV_GetAccuracy', pAccuracyData, int32(0))
% 	get(pAccuracyData,'Value')

            % ready to use
            fprintf('   tracking\n');          
        end
        
        function n = reconnect(obj) %#ok  interface implementation
%             try
%                 ETT_stoptracking();
%                 ETT_disconnects();
%             catch ME
%                 rethrow(ME)
%             end
%             obj.connect();
            error('functionality not yet written');
        end
        
        function n = refresh(obj, logData) %#ok  interface implementation    
            if nargin < 2
                logData = true;
            end
            
            %-----------Extract Raw Data---------------------------------

         	timeReceived = GetSecs();
            if nargin < 3
 % for now we'll just get the one (most recent?) available point(??!?!?)       
 % in future looks like may have to call some kind of callback handle(??)
                if calllib('iViewXAPI', 'iV_GetSample', obj.pSampleData)
                    % get data from hardware
                    sample = libstruct('SampleStruct', obj.pSampleData);
                    timestamp = sample.timestamp;
                else
                    sample = [];
                end
            end
            
            % check if any data returned (if not, no point continuing)
            n = size(sample,1);
            saccadeOnTime = [];
            if n == 0
                return;
            end
            
            
            
            % map itrack timestamp to matlab's clock
            itime = double(timestamp)/1000000; % microseconds to seconds (since GetSecs is in seconds)
            %offset = itime - timeReceived;
            %t = itime - offset;
            CPUtime = itime - (itime(end) - timeReceived); % effectively just substituting the current time for the last sampled time

            % combine data across eyes (or select from one only)
            switch obj.eyes
                case 0 % left eye only
                    xy = [sample.leftEye.gazeX sample.leftEye.gazeY];
                    pd = sample.leftEye.diam;
                case 1 % right eye only
                    xy = [sample.rightEye.gazeX sample.rightEye.gazeY];
                    pd = sample.rightEye.diam;
                case 2 % mean of both
                    xy = ([sample.rightEye.gazeX sample.rightEye.gazeY] + [sample.leftEye.gazeX sample.leftEye.gazeY])/2;
                    pd = (sample.leftEye.diam + sample.rightEye.diam)/2;
                otherwise
                    error('unknown eye code: %1.2f', obj.eyes);
            end
            
         	% exclude any erroneous points (which SMI marks as 0), by
            % setting to NaN
            xy(xy==0) = NaN;
            
            % map itrack timestamp to matlab's clock
            itime = double(timestamp)/1000000000000; % ??? to seconds (since GetSecs is in seconds)
            CPUtime = itime - (itime(end) - timeReceived); % effectively just substituting the current time for the last sampled time

            % invent some placeholder validity data
            vldty = nan(size(itime));
             
            % invent some placeholder depth data (tmp hack)
            zL_mm = nan(size(vldty));
            zR_mm = nan(size(vldty));
            
         	%-----------Send Data to Buffer------------------------------
            % send the data to an internal buffer which handles filtering
            % and feature extraction, and then passes the data along to the
            % central DataLog and any relevant GUI elements
            saccadeOnTime = obj.processData(xy(:,1),xy(:,2),CPUtime,vldty,pd, zL_mm,zR_mm, logData);
            
            % log data if requested in launch params (and not countermanded
            % by user's refresh call)
            if obj.LOG_RAW_DATA && logData
                obj.RAWLOG.write([sample.timestamp ...
                                  sample.leftEye.gazeX sample.leftEye.gazeY sample.leftEye.diam sample.leftEye.eyePositionX sample.leftEye.eyePositionY sample.leftEye.eyePositionZ ...
                                  sample.rightEye.gazeX sample.rightEye.gazeY sample.rightEye.diam sample.rightEye.eyePositionX sample.rightEye.eyePositionY sample.rightEye.eyePositionZ ...
                                  sample.planeNumber], obj.RAWLOG_PRECISION);
            end    
        end
        
        function n = flush(obj) %#ok  interface implementation        
            error('functionality not yet written');
        end
    end

    %% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================    
    
    methods (Access = private)
        
        
    end
        
    
    
    


    %% ====================================================================
    %  -----PROTECTED STATIC METHODS-----
    %$ ====================================================================    
    
    methods (Static, Access = protected)
        
        function [] = validate(varargin) % interface implementation           
            % ensure that SDK installed
            if exist('InitiViewXAPI.m','file')~=2
                error('InitiViewXAPI.m not found on path. Please ensure that the SMI Matlab wrapper is installed');
            end
        end
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================
    
    methods (Static, Access = public)

        function outputs = readRawLog(fullFn) %#ok interface implementation              
            fprintf('\n\n    **this is used to interface with IvRawLog in order to parse raw binary files**\n\n')  
            outputs = [];
        end  
    end
    
end