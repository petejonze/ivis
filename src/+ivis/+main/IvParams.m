classdef (Sealed) IvParams < Singleton
	% Responsible for loading, parsing and validating inputs stored in
    % Config.xml, and storing the system variables so that other aspects of
    % ivis may query them.
    %
    % IvParams Static Methods:
	%   * registerScreen        - Update graphic parameters based on the specified PTB screen.
    %   * getDefaultConfig      - Return the default parameter structure.
    %   * getSimpleConfig       - Return a simple parameter structure.
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
    % @todo: http://www.mathworks.co.uk/help/matlab/matlab_oop/listening-for-changes-to-property-values.html
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 

    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
      
    properties (GetAccess = public, SetAccess = private)
        toolboxHomedir
        %
        main
        graphics
        GUI
        keyboard
        webcam
        saccade
        classifier
        calibration
        log
        audio
        adapt       
    end
    properties (GetAccess = public, SetAccess = ?ivis.eyetracker.IvDataInput)
        eyetracker
    end

    
    %% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================

    methods (Static, Access = public)

        function [] = registerScreen(winhandle)
            % Update graphic parameters based on the specified PTB screen.
            %
            % @param    winhandle
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % Compute graphic params
            obj = ivis.main.IvParams.getInstance();
            
            % only set these values if winhandle is a PTB texture.
            % Otherwise, if it is simply the screen number then set the
            % spatial variables only (this function will have to be called
            % again later, once the texture handle is available)           
            if Screen(winhandle, 'WindowKind')
                obj.graphics.winhandle = winhandle;
                obj.graphics.testScreenNum=Screen('WindowScreenNumber', winhandle);
                
                [obj.graphics.monitorWidth,obj.graphics.monitorHeight] = Screen('WindowSize',obj.graphics.testScreenNum);
                
                % Preparing the motion parameters. Adapted From: DriftDemo2
                obj.graphics.ifi=Screen('GetFlipInterval', obj.graphics.winhandle); % Query duration of one monitor refresh interval
                obj.graphics.maxFlipsPerSecond = 1/obj.graphics.ifi; % Take the reciprocal
                obj.graphics.Fr = obj.graphics.maxFlipsPerSecond; % alias
                
                % used by myFlip in: calib(?)
                obj.graphics.waitframes = obj.graphics.maxFlipsPerSecond/obj.graphics.targFrameRate; % waitframes = 1 means: Redraw every monitor refresh. If your GPU is not fast enough to do this, you can increment this to only redraw every n'th refresh.
                obj.graphics.effFrameRate = obj.graphics.maxFlipsPerSecond / obj.graphics.waitframes; % effective framerate
                obj.graphics.waitDuration = (obj.graphics.waitframes - 0.5) * obj.graphics.ifi;
                
                % if an eyetracker exists (and this window was registered
                % manually after ivis has already launched) then it may be
                % necessary for the eyetracker to update its fixation
                % marker [bit of a kludge!]
                eyeObj = [];
                try
                    eyeObj = ivis.eyetracker.IvDataInput.getInstance();
                catch %#ok
                end
                if ~isempty(eyeObj) && isvalid(eyeObj) %isvalid to check not deleted
                    eyeObj.setFixationMarker(obj.eyetracker.fixationMarker)
                end
            end
            
            % Preparing the spatial parameters
            obj.graphics.winrect = Screen('Rect', winhandle);
            [obj.graphics.mx, obj.graphics.my] = RectCenter(obj.graphics.winrect); %get the midpoint (mx, my) of this window, x and y
            [obj.graphics.testScreenWidth, obj.graphics.testScreenHeight] = RectSize(obj.graphics.winrect);
            
            % Find the color values which correspond to white and black: Usually
            % black is always 0 and white 255, but this rule is not true if one of
            % the high precision framebuffer modes is enabled via the
            % PsychImaging() commmand, so we query the true values via the
            % functions WhiteIndex and BlackIndex:
            obj.graphics.white=WhiteIndex(winhandle);
            obj.graphics.black=BlackIndex(winhandle);
            % Round gray to integral number, to avoid roundoff artifacts with some
            % graphics cards:
            obj.graphics.gray=round((obj.graphics.white+obj.graphics.black)/2);
            % This makes sure that on floating point framebuffers we still get a
            % well defined gray. It isn't strictly neccessary in this demo:
            if obj.graphics.gray == obj.graphics.white
                obj.graphics.gray= obj.graphics.white / 2;
            end
        end

        function params = getDefaultConfig(varargin)
            % Return the default parameter structure. Individual paramters
            % can be overwritten by specifying pairs of the form:
            % "name",value. E.g., getDefaultConfig('main.verbosity',10).
            %
            % @param    varargin    Any over
            % @return   params
            %
            %     % @date     26/06/14
            % @author   PRJ
            %            
            params = struct();
            
            tmp = ver('ivis');
            params.main.ivVersion = str2double(tmp.Version);
            params.main.verbosity = 1;
            
            params.graphics.useScreen = true;
            params.graphics.targFrameRate = 30;
            params.graphics.testScreenNum = max(Screen('Screens'));
            params.graphics.fullScreen = true;
            params.graphics.testScreenWidth = [];
            params.graphics.testScreenHeight = [];
            params.graphics.monitorWidth_cm = 33.1724; % macbook pro 15'' (guess)
            params.graphics.monitorHeight_cm = 33.1724; % macbook pro 15'' (guess)
            params.graphics.viewDist_cm = 60;
            
            params.GUI.useGUI = true;
            params.GUI.screenNum = []; % max(0,params.graphics.testScreenNum-1); % min(Screen('Screens'));
            params.GUI.dockFlag = 1;
            
            params.keyboard.handlerClass = [];
            params.keyboard.isAsynchronous = false;
            params.keyboard.customQuickKeys = [];
            params.keyboard.warnUnknownInputsByDefault = [];
            
            params.webcam.enable = false;
            params.webcam.GUIidx = 4;
            params.webcam.deviceId = [];
            
            params.eyetracker.type = 'mouse';
            params.eyetracker.id = [];
            params.eyetracker.sampleRate = 60;
            params.eyetracker.GUIidx = 2;
            params.eyetracker.runMeanWinWidth = 8; % n samples (change to msecs?)
            params.eyetracker.interpWinWidth = 4;
            params.eyetracker.showLastNPoints = 30;
            params.eyetracker.debugMode = 0;
           	params.eyetracker.fixationMarker = 'whitedot'; % none, cursor, or the name of any m-file in ivis\resources\images\FixationTextures\
            params.eyetracker.logRawData = true;
            params.eyetracker.expectedLatency_ms = 10;
            params.eyetracker.eyes = 2; %0==left, 1==right, 2==both
            
            params.saccade.enableTagging = false;
            params.saccade.distanceCriterion_deg = 7;
            params.saccade.velocityCriterion_degsec = 250;
            params.saccade.accelCriterion_degsec2 = 75;
            params.saccade.timeCriterion_secs = .3;
            params.saccade.doBeep = false;
            params.saccade.GUIidx = []; % 3;
            params.saccade.preBlinkWindow_secs = 0.17;
            params.saccade.postBlinkWindow_secs = 0.17;

          	params.classifier.nsecs = 5;
            params.classifier.bufferLength = 100;
            params.classifier.onsetRampStart = 0.4;
            params.classifier.onsetRampDuration = 0.4;
            params.classifier.GUIidx = 1;
            params.classifier.loglikelihood.lMagThresh = 200;
            params.classifier.box.margin_deg = 2;
            params.classifier.box.npoints = 50;
            params.classifier.grid.npoints = 50;
            params.classifier.vector.bufferLength = 90;
            params.classifier.vector.margin_deg = 15;
            params.classifier.vector.rqdMagnitude = 500; %??consistency
            params.classifier.vector.nsecs = 15; %??redundant

            params.calibration.targCoordinates = [0.1,0.1;.1,.5;.1,.9; 0.5,0.1;.5,.5;.5,.9; 0.9,0.1;.9,.5;.9,.9]; % with [0 0] == top-left
            params.calibration.presentationFcn = 'ivis.calibration.measurePoint';
            params.calibration.nRecursions = 1;
            params.calibration.outlierThresh_px = 100;
            params.calibration.GUIidx = []; % 4;
            params.calibration.drift.maxDriftCorrection_deg = 6;
            params.calibration.drift.driftWeight = 1;

            params.log.raw.dir = '$iv/logs/raw';
            params.log.raw.filepattern = 'IvRaw-$time.raw';
            params.log.data.dir = '$iv/logs/data';
            params.log.data.filepattern = 'IvData-$time.csv';
            params.log.data.arraySize = 10000; % also used for any graphics
            params.log.data.expansionFactor = 2;
            
            params.audio.isConnected = true;
            params.audio.isEnabled = true;
            params.audio.devID = [];
            params.audio.Fs = 44100;
            params.audio.outChans = [0 1];
            params.audio.runMode = [];
            params.audio.reqlatencyclass = [];
            params.audio.latbias_secs = [];
            params.audio.useCalibration = false;
            params.audio.rms2db_fnOrMatrix = [];
            params.audio.defaultLevel_db = [];

            % Manually override defaults with user specified parameters
            if nargin > 0
                % ensure pairs of 2
                if mod(nargin,2) ~= 0
                    error('must be in pairs');
                end
                % set
                for i=1:2:(nargin-1)
                    % check exists
                    eval(['tmp = params.' varargin{i} ';']);
                  	% set value
                    eval(['params.' varargin{i} ' = varargin{i+1};']);
                end
            end
        end
        
        function params = getSimpleConfig(varargin)  
            % Return a simple parameter structure, with PTB no screen or
            % GUI. See getDefaultConfig() for details.
            %
            % @param    varargin    Any over
            % @return   params
            %
            %     % @date     26/06/14
            % @author   PRJ
            %                 
            params = ivis.main.IvParams.getDefaultConfig();
            
            % override defaults
            params.graphics.useScreen = false;
            params.GUI.useGUI = false;
            params.eyetracker.fixationMarker = 'none';
            params.audio.isConnected = false;
            params.calibration.calibFcn = [];
            
            params.webcam.GUIidx = [];
            params.eyetracker.GUIidx = [];
            params.saccade.GUIidx = [];
            params.classifier.GUIidx = [];
            params.calibration.GUIidx = [];
            
            % Manually override defaults with user specified parameters
            if nargin > 0
                % ensure pairs of 2
                if mod(nargin,2) ~= 0
                    error('must be in pairs');
                end
                % set
                for i=1:2:(nargin-1)
                    % check exists
                    eval(['tmp = params.' varargin{i} ';']);
                    % set value
                    eval(['params.' varargin{i} ' = varargin{i+1};']);
                end
            end
        end
    end

    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================

        function obj = IvParams(paramStructOrXmlFullFileName, verbosity)
            % IvParams Constructor.
            %
            % @param    paramStructOrXmlFullFileName
            % @param    verbosity
            % @return   IvParams
            %
            %     % @date     26/06/14
            % @author   PRJ
            %
            
            % init
            if nargin < 1 || isempty(paramStructOrXmlFullFileName)
                [path,~,~] = fileparts(which('ivis'));
                paramStructOrXmlFullFileName = fullfile(path, 'IvConfig.xml');
            end
            if nargin < 2
                verbosity = [];
            end
            
            % Check if screen checks have been disabled (and warn if so)
            disableScreenChecks = false;
            if isfield(getpref('ivis'),'disableScreenChecks')
                disableScreenChecks = getfield(getpref('ivis'),'disableScreenChecks'); %#ok
                setpref('ivis','disableScreenChecks',false); % reset to false. This way the user will always have to explicitly disable the checks every time, prior to use
            end
            if disableScreenChecks
                fprintf('\n\n\n\n!!!WARNING!!! Screen checks have been disabled! Use with caution\n\n\n\n');
            end
            
            % load params from XML file
            if isstruct(paramStructOrXmlFullFileName)
                params = paramStructOrXmlFullFileName;
            else
                if ~exist(paramStructOrXmlFullFileName, 'file')
                    error('IvParams:LoadFail','Config file not found: %s', paramStructOrXmlFullFileName);
                end
                try
                    params = xmlRead(paramStructOrXmlFullFileName);
                catch ME
                    fprintf('IvParams: Failed to load from %s\n', paramStructOrXmlFullFileName);
                    rethrow(ME)
                end
            end
            
            if isempty(verbosity)
                verbosity = params.main.verbosity;
            end
            
            % print message to console
            if verbosity > 0
                fprintf('IVIS: loading parameters...             [%s]\n', datestr(now()));
            end
            
            if verbosity > 1
                dispStruct(params);
            end
            
            % check version
            ivis.main.IvMain.assertVersion(params.main.ivVersion);
            % store toolbox name
            tmp = ver('ivis');
            params.main.ivName = tmp.Name;
            
            % Insert defaults(?) could do with doing properly
            %             if ~isfield(params, 'graphics')
            %                 params.graphics.useScreen = false;
            %             end
            if ~isfield(params, 'audio')
                params.audio.isConnected = false;
            end
            if ~isfield(params, 'adapt')
                params.adapt = [];
            end
            
            % If using a screen, check the specified values are valid
            if params.graphics.useScreen
                % validate
                try
                    x = Screen('Rect', params.graphics.testScreenNum);
                catch ME
                    % enumerate displays
                    screens =  Screen('Screens');
                    for i = 1:length(screens)
                        dims = Screen('Rect', screens(i));
                        fprintf('Screen %i: %i x %i\n', screens(i), dims(3), dims(4));
                    end
                    error('IvMain:invalidConfig','Invalid Screen index (%i) specified in config',params.graphics.testScreenNum);
                end
                
                % Check that the specified physical dimensions are correct.
                % The absolute values reported by Screen('DisplaySize') do
                % not appear reliable, but we can at least check that the
                % display size ratio is approximately correct
                [detectedWidth, detectedHeight]=Screen('DisplaySize', params.graphics.testScreenNum);
                detectedWidth = detectedWidth/10; % convert to cm
                detectedHeight = detectedHeight/10;
                aspectRatio_detected = detectedWidth/detectedHeight;
                aspectRatio_specified = params.graphics.monitorWidth_cm/params.graphics.monitorHeight_cm;
                if abs(aspectRatio_detected-aspectRatio_specified) > 0.1
                    fprintf('Specified screen ratio (%1.2f :: %1.2f x %1.2f) does not match detected screen ratio (%1.2f :: %1.2f x %1.2f)\n   n.b., screen checks can be toggled using the command: setpref(''ivis'',''disableScreenChecks'',true/false)\n', aspectRatio_specified, params.graphics.monitorWidth_cm, params.graphics.monitorHeight_cm, aspectRatio_detected, detectedWidth, detectedHeight);
                    if disableScreenChecks || getLogicalInput('Temporarily use suggested values? (not recommended): ')
                        params.graphics.monitorWidth_cm =  detectedWidth;
                        params.graphics.monitorHeight_cm = detectedHeight;
                    else
                        error('IvMain:invalidConfig','Specified screen ratio (%1.2f :: %1.2f x %1.2f) does not match detected screen ratio (%1.2f :: %1.2f x %1.2f)\n', aspectRatio_specified, params.graphics.monitorWidth_cm, params.graphics.monitorHeight_cm, aspectRatio_detected, width, height);
                    end
                end
                
                % If fullscreen is specified, check that the detected screen
                % rectangle is the same as the specified dimensions
                if params.graphics.fullScreen
                    if isempty(params.graphics.testScreenWidth)
                        params.graphics.testScreenWidth = 0;
                    end
                    if isempty(params.graphics.testScreenHeight)
                        params.graphics.testScreenHeight = 0;
                    end
                    if ~all(x == [0 0 params.graphics.testScreenWidth, params.graphics.testScreenHeight])
                        % enumerate displays
                        screens =  Screen('Screens');
                        for i = 1:length(screens)
                            dims = Screen('Rect', screens(i));
                            fprintf('Screen %i: %i x %i\n', screens(i), dims(3), dims(4));
                        end
                        fprintf('Specified screen dimensions (%i x %i) do not match those detected (%i x %i) for display %i\n', params.graphics.testScreenWidth, params.graphics.testScreenHeight, x(3),x(4), params.graphics.testScreenNum);
                        if disableScreenChecks || getLogicalInput('Temporarily use suggested values? (not recommended): ')
                            params.graphics.testScreenWidth =  x(3);
                            params.graphics.testScreenHeight = x(4);
                        else
                            %oldRes = Screen('Resolution', params.graphics.testScreenNum, x(3), x(4)) % attempt to set resolution
                            error('IvMain:invalidConfig','Specified screen dimensions (%i x %i) do not match those detected (%i x %i) for display %i\n', params.graphics.testScreenWidth, params.graphics.testScreenHeight, x(3),x(4), params.graphics.testScreenNum);
                        end
                    end
                end
            else
                % insert defaults
                params.graphics.useScreen = false;
                % still have a go at detecting likely screen dimensions,
                % since may still want to represent screen dimensions in
                % various GUIs
                if params.graphics.testScreenNum > max(Screen('Screens'))
                    params.graphics.testScreenNum = max(Screen('Screens'));
                end
                [params.graphics.testScreenWidth, params.graphics.testScreenHeight] = Screen('WindowSize', max(Screen('Screens')));
                
            end

            % input
            if ~isfield(params, 'keyboard')
                params.keyboard = [];
            elseif isfield(params, 'keyboard') && isfield(params.keyboard, 'handlerClass') && isempty(params.keyboard.handlerClass)
                params.keyboard.handlerClass = 'InputHandler';
            end
                    
            % if not using a GUI, suppress any specified element
            if ~params.GUI.useGUI
                if ~isempty(params.saccade.GUIidx)
                    fprintf('WARNING: GUI not active. Overriding specified value of params.saccade.GUIidx\n');
                    params.saccade.GUIidx = [];
                end
                if ~isempty(params.classifier.GUIidx)
                    fprintf('WARNING: GUI not active. Overriding specified value of params.classifier.GUIidx\n');
                    params.classifier.GUIidx = [];
                end
                if ~isempty(params.eyetracker.GUIidx)
                    fprintf('WARNING: GUI not active. Overriding specified value of params.eyetracker.GUIidx\n');
                    params.eyetracker.GUIidx = [];
                end
                if ~isempty(params.calibration.GUIidx)
                    fprintf('WARNING: GUI not active. Overriding specified value of params.calibration.GUIidx\n');
                    params.calibration.GUIidx = [];
                end
            else
                if ~isfield(params.GUI,'screenNum') || isempty(params.GUI.screenNum)
                    fprintf('No GUI screen specified. Attempting to guess an appropriate screen\n');
                    params.GUI.screenNum = max(1,min(Screen('Screens')));
                    if (params.GUI.screenNum == params.graphics.testScreenNum) && params.GUI.screenNum > 0 % if multiple screens available and picked the same one
                        screens = Screen('Screens');
                        params.GUI.screenNum = screens(find(params.graphics.testScreenNum~=screens,1,'last')); % find greatest not equal                
                    end
                end
                if ~isfield(params.GUI,'dockFlag') || isempty(params.GUI.dockFlag)
                    fprintf('No dockFlag specified. Reverting to default (1)\n');
                    params.GUI.dockFlag = 1; % recommended
                end   
            end
                    
            % store ------------------------------------
            % todo: automate this?
            obj.main = params.main;
            obj.graphics = params.graphics;
            obj.GUI = params.GUI;
            obj.keyboard = params.keyboard;
            obj.webcam = params.webcam;
            obj.eyetracker = params.eyetracker;
            obj.saccade = params.saccade;
            obj.classifier = params.classifier;
            obj.calibration = params.calibration;
           	obj.log = params.log;
            obj.audio = params.audio;
            obj.adapt = params.adapt;
            
            % init additional params
            obj.graphics.winhandle = [];
            tmp=what('ivis');
            obj.toolboxHomedir = tmp(end).path;
        end
        
        %% == METHODS =====================================================
        
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
        function isIn = isInit()
            o = ivis.main.IvParams.getSingleton(false);
            isIn = ~(isempty(o) || ~isvalid(o));
        end
    end
    
end