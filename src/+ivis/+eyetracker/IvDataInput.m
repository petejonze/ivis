classdef (Abstract) IvDataInput < Singleton
	% Generic data input class that must be instantiated by a subclass.
	% Handles the crucial data processing task (applying calibration
	% filtering, interpolating, classifying, sending data to logs, etc.). 
    %
    % n.b. subclasses should NOT repeated the Singleton blurb (if want to
    % be able to access generically, via DataInput.getSingleton()
    %
    % IvDataInput Abstract Methods:
    %   * connect	- Establish a link to the eyetracking hardware.
    %   * reconnect	- Disconnect and re-establish link to eyetracker.
    %   * refresh  	- Query the eyetracker for new data; process and store.
    %   * flush   	- Query the eyetracker for new data; discard.
    %   * readRawLog- Parse data stored in a .raw binary file (hardware-brand specific format).
    %   * validate  - Validate initialisation parameters.
    %
   	% IvDataInput Methods:
    %   * IvDataInput           - Constructor.
	%   * setFixationMarker     - Establish what, if anything, to use as a gaze-contingent marker.
    %   * updateDriftCorrection	- Instruct IvCalibration to update the drift correction.
    %   * getLastKnownXY        - Get the last reported xy gaze coordinate (and also the timestamp, if requested).
    %
   	% IvDataInput Static Methods:   
    %   * validateSubclass  - Check that the class name is valid, and that the parameter are congruent for this class.
    %   * init              - Initialise parameters, create GUIS, etc.
    %   * readDataLog       - Parse data stored in a .csv data file.
    %   * estimateLag       - Estimate expected lag given a specified set of parameters.
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
    % @todo discard old points (particularly useful for avoiding
    %       slowdowns/dropped-frames?
    % @todo transfer hardcoded values to IvConfig
    % @todo discard samples where only 1 eye is available? (re: Sam Wass)
    % @todo make px2deg mapping dynamic based on subject movement?
    % @todo in the long run the eyeball z data should be filtered/buffered
    %       through this class too. At the moment the logic is internal to each
    %       eyetracker, since some trackers don't return this information.
    %       But most do now, and it would be good to deal with it properly.
    %       This would allow proper retrieval (e.g., get last points since
    %       T), and should improve accuracy too (e.g., low pass filtering).
    % @todo allow setting of trackerInFrontMonitor_mm
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 
    
	%% ====================================================================
    %  -----ABSTRACT METHODS [must be implemented in all subclasses]-----
    %$ ====================================================================
    
    methods(Abstract, Access = public)
        
        % Establish a link to the eyetracking hardware.
        %
        % @date     26/06/14
        % @author   PRJ
        %
        connect(obj)
        
        % Disconnect and re-establish link to eyetracker.
        %
        % @date     26/06/14
        % @author   PRJ
        %
        reconnect(obj)
        
        % Query the eyetracker for new data; process and store.
        %
        % @date     26/06/14
        % @author   PRJ
        %
        [n,saccadeOnTime,blinkTime] = refresh(obj, logData)
        
        % Query the eyetracker for new data; discard.
        %
        % @date     26/06/14
        % @author   PRJ
        %
        n = flush(obj) 
    end
    
    methods(Abstract, Static, Access = public)
        
        % Parse data stored in a .raw binary file (hardware-brand specific
        % format).
        %
        % @param    fullFn  	log (.raw) file, including path
        %
        % @date     26/06/14
        % @author   PRJ
        %
        vargout = readRawLog(fullFn)
    end
    
    methods(Abstract, Static, Access = protected)
        
        % Validate initialisation parameters
        %
        % @date     26/06/14
        % @author   PRJ
        %
        validate()
    end
    

    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================

    properties (GetAccess = public, SetAccess = private)
        mostRecentSaccadeTime = -inf;
        mostRecentBlinkTime = -inf;
        
        % internal parameter for computing speed parameters (shouldn't
        % really be got externally, but is currently used by TrackBox)
        lastXYTV = [NaN NaN NaN NaN];
        
        % current eyeball location estimates (N.B. distance info is also
        % sotred in the main data buffer, but this record bypasses the
        % buffering process, for added speed). It only records the last
        % known location, however.
        lEyeball_xyzt = [NaN NaN NaN NaN];
        rEyeball_xyzt = [NaN NaN NaN NaN];
        % raw values for trackbox visualisation, where we are happy for
        % values to be blank/invalid (i.e., not interested in last known
        % 'good' value, but want a real time feed)
        lEyeball_xyzt_raw = [NaN NaN NaN NaN];
        rEyeball_xyzt_raw = [NaN NaN NaN NaN];
        
        % z offset (e.g., for TrackBox visualisation)
        trackerInFrontMonitor_mm = 20;
        zCalibrationOffset_mm = 0; % trueDistance_mm - currentEstimatedDistance_mm; [NB: should probably not be applied to TrackBox visualisations, in future updates]
    end

    properties (Access = protected)
        % Saccade detection params (move to IvEyeTracker?)
        doBeep
        debugMode
        saccadeCounter = 0;  % tmp?
        spatialGuiElement
        temporalGuiElement
        showFixations
        useFixationTexture % else use mouse cursor
        fixationTexture
        fixationTextureRect
        xMouseOffset; % cf. xOffset in tobiieyex
        winhandle
        testScreenWidth
        testScreenHeight
        id
        Fs
        subclass
        eyes

        % ---- TAGGING ----
        enableTagging
        includeTagsInRawOutput
        SACCADE_ON_BITPOS
        SACCADE_OFF_BITPOS
        BLINK_BITPOS
        nDataPoints
        nDataPointsPerCycle
        nCycles
        p1_ww
        p1_ww2
        p1_iw
        p1_Npre
        p1_Npost
        p2_Npre
        p2_Npost
        p2_dOffsetPost
        p2_dOffsetPrev
        distanceCriterion
        velocityCriterion
        accelCriterion
        p3_Npre
        p3_Npost
        prevSaccadeWindow
        prevBlinkWindow
        postBlinkWindow
        lagPeriod
        buffer1
        buffer2
        buffer3
        pixel_per_dg
        blinkTemporalMin_secs = 1; % 0.3;
        
        % ---- TIMING ----
        expectedLatency_sec = 0;
        
        % ---- DATA LOGGING ----
        LOG_RAW_DATA;
        RAWLOG = [];
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
    	%% == CONSTRUCTOR =================================================
            
        % *** See static init(), below ***
        
        function [] = delete(obj)
            % IvDataInput Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            if ~isempty(obj.spatialGuiElement) && ishandle(obj.spatialGuiElement)
                delete(obj.spatialGuiElement)
            end
            
            if ~isempty(obj.temporalGuiElement) && ishandle(obj.temporalGuiElement)
                delete(obj.temporalGuiElement)
            end
            
            obj.RAWLOG = [];
        end
        
        %% == METHODS =====================================================
        
        function [] = setFixationMarker(obj, fixationMarker)
            % Establish what, if anything, to use as a gaze-contingent
            % marker. Creates a OpenGL texture if so required (i.e., might
            % alternatively just use the mouse cursor). If 'none', set
            % obj.showFixations = false, and do nothing.
            %
            % @param    fixationMarker  'none', 'cursor', or the name of an arbitrary image in ./resources/images/FixationTextures
            %
            % @date     26/06/14
            % @author   PRJ
            %

            if strcmpi(fixationMarker, 'none')
                obj.showFixations = false;
                return;
            else
                obj.showFixations = true;
            end
                      
            if ~strcmpi(fixationMarker, 'cursor')
                obj.winhandle = ivis.main.IvParams.getInstance().graphics.winhandle;
                if isempty(obj.winhandle)
                    %error('IvDataInput:InvalidInput','Cannot set fixation marker, since no valid winhandle has been provided');
                    fprintf('WARNING: Fixation texture overriden. Cannot set fixation texture, since no valid winhandle has been provided. Will try to use the cursor instead\n');
                    fixationMarker = 'cursor';
                end
            end
                        
            if strcmpi(fixationMarker, 'cursor')
                if strcmpi(class(obj), 'ivis.eyetracker.IvMouse')
                	fprintf('WARNING: Fixation cursor overriden. Cannot use the cursor when using an IvMouse input\n');  
                    obj.showFixations = false;
                    return;
                end
                ShowCursor(); % needed?
                obj.useFixationTexture = false;
                
                % set x offset for drawing
                screenNum = ivis.main.IvParams.getInstance().graphics.testScreenNum;
                tmp = Screen('GlobalRect',screenNum);
                obj.xMouseOffset = tmp(1);
           
                return
            else
                obj.useFixationTexture = true;
            end
            
            toolboxHomedir = ivis.main.IvParams.getInstance().toolboxHomedir;
            texDir = fullfile(toolboxHomedir, 'resources', 'images', 'FixationTextures');
            pattern = fullfile(texDir, fixationMarker);
            d = dir([pattern '.*']);
            if isempty(d)
                error('IvDataInput:InvalidTexFile','No files found matching the pattern: %s', pattern);
            elseif length(d) > 1
                dispStruct(d);
                error('IvDataInput:InvalidTexFile','Multiple files found matching the pattern: %s', pattern);
            end
            
            [~,fn,ext] = fileparts(d(1).name);
            if strcmpi(ext,'.m')
                tmp = pwd();
                cd(texDir); % have to change to m-file location, as matlab doesn't like calling off-path functions
                [obj.fixationTexture, obj.fixationTextureRect] = feval(fn, obj.winhandle);
                cd(tmp);
            else
                % load image
                [img, ~, alpha] = imread(fullfile(texDir,d(1).name), ext(2:end));
                if strcmpi(ext,'.png')
                    img(:,:,4) = alpha(:,:); % add the transparency layer to the image (for trans. back.)
                else
                    error('IvDataInput:MissingFunctionality','Only m-file and .png fixation textures currently supported. Oops! (%s)', fn);
                    %img = cat(3, img, zeros(size(img,1),size(img,2)) );
                end
                obj.fixationTexture = Screen('MakeTexture', obj.winhandle, img);
                obj.fixationTextureRect = [0 0 size(img,2) size(img,1)];
            end
        end
        
        function [] = updateDriftCorrection(~, trueXY, estXY, maxCorrection, weight)
            % Instruct IvCalibration to update the drift correction.
            %
            % See also
            % @ref ivis.calibration.IvCalibration.updateDriftCorrection()
            %
            % @param	trueXY          the "true" xy gaze coordinate 
            % @param	estXY           the observed xy gaze coordinate
            % @param	maxCorrection	the maximum acceptable deviation 
            % @param	weight          amount of weight to give drift correction (0 to 1)    
            %
            % @todo     check that this works!
            % @todo     could weight the difference differently depending on the location on the screen?
            % @date     26/06/14
            % @author   PRJ
            %    
            if nargin < 4
                maxCorrection = [];
            end
            if nargin < 5
                weight = [];
            end
            
            ivis.calibration.IvCalibration.getInstance().updateDriftCorrection(trueXY, estXY, maxCorrection, weight);
        end
 
        function [lEyeball_xyzt, rEyeball_xyzt] = getEyeballLocations(obj)
            % Get cartesian coordinates for each eyeball, in millimeters.
            %
            % @return   lEyeball_xyzt	Cartesian coords (mm) + timestamp
         	% @return   rEyeball_xyzt   Cartesian coords (mm) + timestamp
            %
            % @date     21/07/14
            % @author   PRJ
            %
            
            lEyeball_xyzt = obj.lEyeball_xyzt;
           	rEyeball_xyzt = obj.rEyeball_xyzt;
        end
        function [lastKnownViewingDistance_mm, t] = getLastKnownViewingDistance(obj)
            % Compute last known viewing distance (averaging across
            % eyeballs).
            %            
         	% @return   lastKnownViewingDistance_cm 	distance from eyetracker to eyeball (mm)
            %
            % @date     21/07/14
            % @author   PRJ
            %
            
            % get values
            lastKnownViewingDistance_mm = nanmean([obj.lEyeball_xyzt(3) obj.rEyeball_xyzt(3)]);
            t = nanmean([obj.lEyeball_xyzt(4) obj.rEyeball_xyzt(4)]);
        end
        
        function ok = calibrateDistanceToScreen(obj, trueDistance_mm)
            
            [currentEstimatedDistance_mm, t] = obj.getLastKnownViewingDistance();
            
            % ensure that this estimate was made sufficiently recently
            if (GetSecs()-t) > 0.5
                obj.zCalibrationOffset_mm
                obj.lEyeball_xyzt
                obj.rEyeball_xyzt
                fprintf('%1.9f\n', GetSecs())
                fprintf('%1.9f\n', t)
                GetSecs()-t
                warning('IvDataFailed to set distance calibration: Last known timestamp is %1.2f seconds old\n', GetSecs()-t);
                ok = false;
                return;
            end
            
            % set zOffset value
            obj.zCalibrationOffset_mm = trueDistance_mm - currentEstimatedDistance_mm;
            ok = true;
        end
    end

    
    %% ====================================================================
    %  -----PROTECTED METHODS-----
    %$ ====================================================================
    
    methods(Access = protected)
        
        function obj = IvDataInput()
            % IvDataInput Constructor.
            %
            % @return  	obj     IvDataInput object
            %
            % @date     26/06/14
            % @author   PRJ
            %

            params = ivis.main.IvParams.getInstance();

            % init params?
            obj.testScreenWidth = params.graphics.testScreenWidth;
            obj.testScreenHeight = params.graphics.testScreenHeight;
            %
            obj.pixel_per_dg = ivis.math.IvUnitHandler.getInstance().pixel_per_dg;
            %
            obj.winhandle = params.graphics.winhandle;
            %
            obj.eyes = params.eyetracker.eyes;
            
            % init params?
            obj.doBeep = params.saccade.doBeep;

            % general params
            obj.SACCADE_ON_BITPOS   = 1; % completely arbitrary values (change later)
            obj.SACCADE_OFF_BITPOS  = 2;
            obj.BLINK_BITPOS        = 3;
            obj.nDataPoints = 150; % simulation params
            obj.nDataPointsPerCycle = 3; % n values 'returned from eyetracker' per cycle
            obj.nCycles = obj.nDataPoints/obj.nDataPointsPerCycle;
            
            % phase 1 params [smoothAndInterpolate]
            obj.p1_ww = params.eyetracker.runMeanWinWidth; % centred on current sample, e.g., 8
            obj.p1_ww2 = floor(obj.p1_ww/2);
            obj.p1_iw = params.eyetracker.interpWinWidth; % n points either side, e.g., 4
            obj.p1_Npre = max(obj.p1_ww2,1);
            obj.p1_Npost = max(obj.p1_ww2,obj.p1_iw);
            
            % phase 2 params [tagEvents]
            obj.p2_Npre = 5;
            obj.p2_Npost = 5;
            obj.p2_dOffsetPost = 5;
            obj.p2_dOffsetPrev = 5;
            obj.distanceCriterion = params.saccade.distanceCriterion_deg; % change in degrees
            obj.velocityCriterion = params.saccade.velocityCriterion_degsec; % n.b. change in degrees per second
            obj.accelCriterion = params.saccade.accelCriterion_degsec2; % n.b. change in degrees (per second per second)
            
            % phase 3 params [postHocCleanEvents]
            obj.prevSaccadeWindow = ceil(params.eyetracker.sampleRate * params.saccade.timeCriterion_secs);
            obj.prevBlinkWindow = ceil(params.eyetracker.sampleRate * params.saccade.preBlinkWindow_secs); % e.g. 10 observations at 60 Hz
            obj.postBlinkWindow = ceil(params.eyetracker.sampleRate * params.saccade.postBlinkWindow_secs);
            obj.p3_Npre = max(obj.prevSaccadeWindow, obj.prevSaccadeWindow);
            obj.p3_Npost = obj.postBlinkWindow; % 10;
            
            % calc further misc params
            obj.lagPeriod = obj.p1_Npost + obj.p2_Npost + obj.p3_Npost;
            
            % init storage
            obj.buffer1 = nan(obj.p1_Npre,13); % 13 columns by default
            obj.buffer2 = nan(obj.p2_Npre,13);
            obj.buffer3 = nan(obj.p3_Npre,13);
            % flags must be int for bitget/bitset
            obj.buffer1(:,6) = 0;
            obj.buffer2(:,6) = 0;
            obj.buffer3(:,6) = 0;

            % store params
            obj.id = params.eyetracker.id;
            obj.Fs = params.eyetracker.sampleRate;
            obj.debugMode = params.eyetracker.debugMode;
            
            % set log params
            obj.LOG_RAW_DATA = params.eyetracker.logRawData; 
            if obj.LOG_RAW_DATA
                obj.RAWLOG = ivis.log.IvRawLog.getInstance(); % get handle
                obj.RAWLOG.open();
            end
        end
        
        function [saccadeOnTime, blinkTime] = processData(obj, x, y, t, vldty, p, zL_mm,zR_mm, logData)
            % Interpolate, smooth, log the data, update the GUI and any
            % fixation marker.
            %
            % n.b. Overwrite this file in the subclass instantiation
            % if you want to customise the way data are smoothed/
            % interpolated/ tagged/ etc.
            %
            % n.b., input vectors must be columns
            %
            % @param    x       : x position (in pixels)
            % @param    y       : y position (in pixels)
            % @param    t       : timestamp (in seconds)
            % @param    vldty   : some kind of validity measure
            % @param    p       : pupil diameter
            % @param    zL_mm  	: left eyeball distance
            % @param    zR_mm  	: right eyeball distance
            % @param    logData
            % @return   saccadeOnTime
            %
            % @date     31/07/14
            % @author   PRJ
            %
            % @todo ought to update pixel_per_dg based on latest position
            % estimate(?)
            %
            % c : eye-event code (see IvEventCode)
            
                
            if nargin < 9 || isempty(logData)
                logData = true;
            end
            
          	saccadeOnTime = [];
            blinkTime = [];
            
            %-------------Get new data------------------------------------- 
            % new raw data - inlcude 4 dummy columns that will contain
            % derived values (event-code, delta, velocity, acceleration).
            % NB: eventcode 'dummy' val is 0, not NaN (i.e., as must be int
            % for bitget/bitset)
            newData = [x y t-obj.expectedLatency_sec vldty p zeros(length(x),1) nan(length(x),3) zL_mm zR_mm x y]; % x/y added again in the last two columns so that a COMPLETELY unprocessed copy of each is preserved

            % apply calibration
            newData(:,1:2) = ivis.calibration.IvCalibration.getInstance().apply(newData(:,1:2));

            % tmp
         	obj.lastXYTV = [newData(end,1:3) NaN];
                
            % smooth & interpolate
            newData = smoothAndInterpolate(obj, newData);
            
            % no point continuing if no new (processed) data
            if isempty(newData)
                return;
            end
            
            %-------------Compute temporal params--------------------------
            % compute speed parameters
            d = sqrt(sum(diff([obj.lastXYTV(1:2); newData(:,1:2)],1).^2,2)); % calc euclidean distance in points
            d = d / obj.pixel_per_dg; % ivis.math.IvUnitHandler.getInstance().px2deg(d);% convert to degrees visual angle
            dt = diff([obj.lastXYTV(3); newData(:,3)]); % calc time diff in seconds
            v = d./dt; % calc velocity (deg/sec)
            A = diff([obj.lastXYTV(4); v]); % calc acceleration (deg/sec)^2
            % store
            newData(:,7:9) = [d v A];
            obj.lastXYTV(4) = v(end);
            
            % tag events
            if obj.enableTagging
                
                if obj.includeTagsInRawOutput
                    newData = obj.postHocCleanEvents(obj.tagEvents(newData));
                    taggedData = newData;
                else
                    taggedData = obj.postHocCleanEvents(obj.tagEvents(newData));
                end
                
                if ~isempty(taggedData)
                    t = taggedData(:,3);
                    c = taggedData(:,6);

                    % check for saccades
                    idx = bitget(c, obj.SACCADE_ON_BITPOS)==1;
                    if any(idx)
                        saccadeOnTime = t(idx);
                        obj.mostRecentSaccadeTime = saccadeOnTime(end);
                        if obj.doBeep % beep if a saccde onset is detected (useful for testing/debugging)
                            sound(getPureTone(1000,22050,0.01));
                        end
                    end
                    
                    % check for blinks
                    idx =  bitget(c, obj.BLINK_BITPOS)==1;
                    if any(idx)
                        blinkTime = t(idx);
                        obj.mostRecentBlinkTime = blinkTime(end);
                        if obj.doBeep % beep if a saccde onset is detected (useful for testing/debugging)
                            sound(getPureTone(400,22050,0.01));
                        end
                    end
                end
            end

            % no point continuing if no new (processed) data
            if isempty(newData)
                return;
            end
            
            
            %-------------Get final/updated raw data-----------------------
         	% retrieve latest, post-processed, values
            xy      = newData(:,1:2);
            t       = newData(:,3);
            vldty   = newData(:,4);
            pd      = newData(:,5);
            c       = newData(:,6);
            d       = newData(:,7);
            v       = newData(:,8);
            A       = newData(:,9);
            zL_mm   = newData(:,10);
            zR_mm   = newData(:,11);
            xy_raw  = newData(:,12:13);
            
%             if any(t<360000)
%                 tmp = [xy t t<360000]
%                 xy
%                 t
%                 t = t<360000
%                 xy_raw
%                 fprintf('%1.2f\n', xy_raw(:,1));
%                 dfdfdfdf
%             end
            
            %-------------Save data----------------------------------------         
            if logData             
                ivis.log.IvDataLog.getInstance().add(xy(:,1),xy(:,2),t,vldty,pd,c,d,v,A,zL_mm,zR_mm,xy_raw(:,1),xy_raw(:,2)); % store data in buffer (could precache the singleton to speed things up)
            end

            
            %-------------Update GUI---------------------------------------
            if ~isempty(obj.spatialGuiElement)
                obj.spatialGuiElement.update(xy(end,1:2));
            end
            if ~isempty(obj.temporalGuiElement)
                obj.temporalGuiElement.update();
            end
            
            
            %-------------Give user feedback-------------------------------
            drawnow('update');

            % show current fixation estimate on screen
            if obj.showFixations
                obj.updateFixationMarker(round(xy(end,:))); % n.b. round to whole pixel value
            end
            % print text info to screen
            if obj.debugMode > 1
                %if any(obj.SACCADE_ON_CODE==c)
                if any(bitget(c, obj.SACCADE_ON_BITPOS)==1)
                    obj.saccadeCounter = obj.saccadeCounter + 1;
                end
                info = {
                    '        x: ', xy(1), '%1.2f'
                    '        y: ', xy(2), '%1.2f'
                    'N saccade: ', obj.saccadeCounter, '%i'
                    ' N Buffer: ', ivis.log.IvDataLog.getInstance().getN, '%i'
                    };
                if isempty(ivis.main.IvParams.getInstance().graphics.winhandle)
                    disp(info)
                else
                    obj.printInfoToPTBScreen(info);
                end
            end
        end
        
        function [] = setEyeballLocations(obj, lEye_xyz_mm, rEye_xyz_mm, t)
            % Set cartesian coordinates for each eyeball, in millimeters.
            %
            % @param    lEye_xyz_mm     Cartesian coordinates (mm)
            % @param    rEye_xyz_mm     Cartesian coordinates (mm)
            % @param    t               Timestamp
            %
            % @date     21/07/14
            % @author   PRJ
            %

            % apply additive calibration factor to map the estimated
            % distance from eyeball to SCREEN is correct
            lEye_xyz_mm(:,3) = lEye_xyz_mm(:,3) + obj.zCalibrationOffset_mm;
            rEye_xyz_mm(:,3) = rEye_xyz_mm(:,3) + obj.zCalibrationOffset_mm;
            
            % store left
            isvalid = (lEye_xyz_mm(:,3)>100) & (lEye_xyz_mm(:,3)<2000) & ~isnan(lEye_xyz_mm(:,3)); % distance (z) must be between 100 and 2000 mm, and non-NaN
            idx = find(isvalid,1,'last');
            if ~isempty(idx)
                obj.lEyeball_xyzt = [lEye_xyz_mm(idx, 1:3) t(idx)];
            end
            obj.lEyeball_xyzt_raw = [lEye_xyz_mm(end, 1:3) t(end)];
            
            % repeat for right
            isvalid = (rEye_xyz_mm(:,3)>100) & (rEye_xyz_mm(:,3)<2000) & ~isnan(rEye_xyz_mm(:,3)); % distance (z) must be between 100 and 2000 mm, and non-NaN
            idx = find(isvalid,1,'last');
            if ~isempty(idx)
                obj.rEyeball_xyzt = [rEye_xyz_mm(idx, 1:3) t(idx)];
            end
            obj.rEyeball_xyzt_raw = [rEye_xyz_mm(end, 1:3) t(end)];
        end 
  	end

    
    %% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================
    
    methods(Access = private)
        
        function newDataOut = smoothAndInterpolate(obj, newDataIn)
            % Use linear interpolation to fill in small amounts of missing
            % data, and then perform a running-mean filter.
            %
            % @param    newDataIn
            % @return   newDataOut
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % add data
            obj.buffer1 = [obj.buffer1; newDataIn];  
            idx = (obj.p1_Npre+1):(size(obj.buffer1,1)-obj.p1_Npost);
            nBodyContent = numel(idx);
            
            % terminate if no new body data
            if nBodyContent == 0
                newDataOut = [];
                return;
            end
            
            % for (any) content data, process
            % n.b. this could probably all be vectorised, to speed things
            % up considerably
            for i = idx
                % fill-in missing values by linear interpolation
                for xy = 1:2
                    k = 1;
                    while isnan(obj.buffer1(i,xy)) && k <= obj.p1_iw
                        obj.buffer1(i,xy) = obj.buffer1(i-1,xy)*(1-1/(k+1)) + obj.buffer1(i+k,xy)*(1/(k+1));
                        k = k+1;
                    end
                end
            end
            
            % smooth using running mean to effect a low-pass filter in
            % the time-domain
            tmp = obj.buffer1;
            m = obj.p1_ww2;
            for i = idx
                xysmoothed = mean(tmp((i-m):(i+m),1:2),1);
                if ~any(isnan(xysmoothed))
                    obj.buffer1(i,1:2) = xysmoothed;
                end
                % could also do z-smoothing at this point
            end
            
            % update data store, return any items that 'overflow' the
            % buffer
            newDataOut = obj.buffer1(idx,:);
            obj.buffer1(1:nBodyContent,:) = [];
        end
        
        function newDataOut = tagEvents(obj, newDataIn)
            % ######### blaaaah.
            %
            % @param    newDataIn
            % @return   newDataOut
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % add data
            obj.buffer2 = [obj.buffer2; newDataIn];
            idx = (obj.p2_Npre+1):(size(obj.buffer2,1)-obj.p2_Npost);
            nBodyContent = numel(idx);
            
            % terminate if no new body data
            if nBodyContent == 0
                newDataOut = [];
                return;
            end
            
            % identify saccades
            %d = obj.buffer2(:,7);   % euclidean distance in degrees visual angle
            v = obj.buffer2(:,8);	% velocity (deg/sec)
            A = obj.buffer2(:,9);  	% acceleration (deg/sec)^2
            distmetric_deg = sqrt(sum((obj.buffer2(idx-obj.p2_dOffsetPrev,1:2)-obj.buffer2(idx+obj.p2_dOffsetPost,1:2)).^2,2));
            distmetric_deg = distmetric_deg / obj.pixel_per_dg; % ivis.math.IvUnitHandler.getInstance().px2deg(distmetric_deg);% convert to degrees visual angle
            if obj.debugMode > 0
                fprintf('v=%1.2f; A=%1.2f; d=%1.2f\n', v(end), A(end), distmetric_deg(end));
            end
            
            % calculate the times when (any) saccades occured by looking
            % for changes in acceleration greater than a given cutoff (default
            % is a change in velocity > 100 degrees per second)
            isSaccadeOn = (A(idx) > obj.accelCriterion & v(idx) > obj.velocityCriterion & distmetric_deg > obj.distanceCriterion);
            isSaccadeOff = (A(idx) < -obj.accelCriterion & v(idx) > obj.velocityCriterion);
            
            % identify blink as any instance with a nan in both X and Y
            % coordinates
            % (transient missing data points will have been interpolated above) (probably a cleaner way of doing this)
            isBlink = all(isnan(obj.buffer2(idx,1:2)),2);           % Tobii
            isBlink = isBlink | any(diff(obj.buffer2(:,3)) > obj.blinkTemporalMin_secs);    % EyeX
            
            % set bit-flags
            obj.buffer2(idx,6) = 0 + isSaccadeOn*2^(obj.SACCADE_ON_BITPOS-1) + isSaccadeOff*2^(obj.SACCADE_OFF_BITPOS-1) + isBlink*2^(obj.BLINK_BITPOS-1); % ALT: bitset.m
            
            %             % tmp?, store
            obj.buffer2(idx,7) = distmetric_deg;
            obj.buffer2(idx,8) = v(idx);
            obj.buffer2(idx,9) = A(idx);
            
            % update data store
            newDataOut = obj.buffer2(idx,:);
            obj.buffer2(1:nBodyContent,:) = [];
        end
        
        function newDataOut = postHocCleanEvents(obj, newDataIn)
            % Suppress any saccades that fall within a specified proximity
            % to another saccade or a blink.
            %
            % @param    newDataIn
            % @return   newDataOut
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            %-------------PHASE 3: post-hoc reestimate eye events------------------
            % add data
            obj.buffer3 = [obj.buffer3; newDataIn];
            idx = (obj.p3_Npre+1):(size(obj.buffer3,1)-obj.p3_Npost);
            nBodyContent = numel(idx);
            
            % terminate if no new body data
            if nBodyContent == 0
                newDataOut = [];
                return;
            end
            
            % for (any) content data, process [NB: cannot be vectorized as
            % relies on sequentially updated values]
            for i = idx
                % remove any saccades that fall too close to a prior saccade,
                % or too close to a preceding/succeeding blink
                if bitget(obj.buffer3(i,6), obj.SACCADE_ON_BITPOS)==1 % change to switch if more conditions arise
                    if sum(bitget(obj.buffer3((i-obj.prevSaccadeWindow):i,6), obj.SACCADE_ON_BITPOS)==1) > 1
                        obj.buffer3(i,6) = bitset(obj.buffer3(i,6), obj.SACCADE_ON_BITPOS, 0);
                    elseif sum(bitget(obj.buffer3((i-obj.prevBlinkWindow):(i+obj.postBlinkWindow),6), obj.BLINK_BITPOS)==1) > 0
                        obj.buffer3(i,6) = bitset(obj.buffer3(i,6), obj.SACCADE_ON_BITPOS, 0);
                    end
                end
                
                % remve any blinks that fall to close to a prior blink (NB:
                % this is currently a bit of a hack, and is intended for
                % TobiiEyeX style ('callback') updating rather than Tobii
                % style polling
                if bitget(obj.buffer3(i,6), obj.BLINK_BITPOS)==1 % change to switch if more conditions arise
                    %if sum(bitget(obj.buffer3((i-obj.prevBlinkWindow):(i-1),6), obj.BLINK_BITPOS)==1) > 0
                    if sum(bitget(obj.buffer3(1:(i-1),6), obj.BLINK_BITPOS)==1) > 0 % important because if eyes closed may be accumulating #############
                        obj.buffer3(i,6) = bitset(obj.buffer3(i,6), obj.BLINK_BITPOS, 0);
                    end
                end
            end
            
            % update data store
            newDataOut = obj.buffer3(idx,:);
            obj.buffer3(1:nBodyContent,:) = [];
        end
        
        function [] = updateFixationMarker(obj, xy)
            % Draw gaze-contingent fixation marker at the specified
            % coordinates. Do nothing if either xy == NaN.
            %
            % @param    xy  1x2 integer, containing xy eye-gaze coordinates (in pixels)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            % n.b., doesn't actually flip the screen
            
            % don't do anything if we don't have a valid xy coordinate
            if any(isnan(xy))
                return
            end
            
            if obj.useFixationTexture
                Screen('DrawTexture', obj.winhandle, obj.fixationTexture, [], CenterRectOnPoint(obj.fixationTextureRect, xy(1), xy(2)));
            else
                SetMouse(obj.xMouseOffset+xy(1), xy(2));
            end
        end
        
        function [] = printInfoToPTBScreen(obj, info)
            % Convenience function to print text to a PTB OpenGL screen.
            %
            % @param    info
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % probably a cleaner/simply way to do this!
            info1 = info';
            str = sprintf('%s%s\\\\n\n',info1{[1 3],:}); % make template x: %i; y: %1.2f; etc.
            str = sprintf(str,info{:,2}); % insert values
            
            Screen('TextSize', obj.winhandle, 10);
            
            DrawFormattedText(obj.winhandle, str, 10, 10);
            
            Screen('Flip', obj.winhandle);
        end
  
    end
    
	 
 	%% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================
    
     methods (Static, Access = public)
    
         function [] = validateSubclass(params)
             % Check that the class name is valid, and that the parameter are congruent for this class.
             %
             % @param    params
             %
             % @date     26/06/14
             % @author   PRJ
             %
             
             inputTypeStr = params.type;
             
             if isempty(inputTypeStr)
                 return;
             elseif strcmpi(inputTypeStr, 'none')
                 error('use [], not "none" if you want to set your eyetracker manually');
             end
             
             % try to find appropriate class definition in the
             % ivis.eyetracker package
             files = what('ivis/eyetracker');
             % strip out any unecessary user characters (E.g., IvTobii.m =>
             % Tobii)
             inputTypeStr = regexprep(inputTypeStr, '^Iv', '');
             inputTypeStr = regexprep(inputTypeStr, '\.m$', '');
             fnpattern = sprintf('Iv%s(?=.m)', inputTypeStr);
             % perform match
             tmp = regexpi(files.m, fnpattern, 'match', 'once');
             classname = [tmp{:}];
             
             % check if any valid class name is found
             if isempty(classname)
                 error('Could not find an appropriate eyetracker class definition in ivis.eyetracker.\n\n      Detected classfiles are:\n            %s\n\n      You specified:\n            %s (raw input: %s)', sprintf('%s,',files.m{:}), fnpattern, params.type);
             end
             
             % perform common checks here
             try
                 feval(sprintf('ivis.eyetracker.%s.validate',classname), params); % e.g. ivis.eyetracker.IvTobii.validate(params)
             catch ME
                 dispStruct(params);
                 sprintf('ivis.eyetracker.%s.validate',classname)
                 rethrow(ME);
             end
         end
         
         function datIn = init(eyetracker, saccade)
             % Initialise parameters, create GUIS, etc.
             %
             % @param    eyetracker
             % @param    saccade
             % @return   datIn
             %
             % @date     26/06/14
             % @author   PRJ
             %
             
             % ensure that specified subclass function is correctly
             % formatted
             inputTypeStr = eyetracker.type;
             % ensure starts Iv...
             if isempty(regexpi(inputTypeStr,'^Iv','once'))
                 % while we are here, ensure that starts with a capital
                 inputTypeStr(1) = upper(inputTypeStr(1));
                 
                 % warning('IvDataInput:InvalidSubclass','IvDataInput subclass names should begin with Iv.\nAppending prefix %s -> Iv%s', inputTypeStr, inputTypeStr);
                 inputTypeStr = ['Iv' inputTypeStr];
             end
             % ensure package path is present
             if isempty(regexpi(inputTypeStr,'^ivis.eyetracker.','once'))
                 inputTypeStr = ['ivis.eyetracker.' inputTypeStr];
             end
             
             % check classname is valid
             classname = inputTypeStr;
             if ~exist(classname,'class')
                 error('IvDataInput:InvalidSubclass','Class not found: %s',classname);
             end
             
             % !!!Create and initialise the object!!!
             try
                 % !!create object!! e.g., ivis.eyetracker.IvManual(params)
                 %datIn = feval(classname, params);
                 datIn = feval(classname);
             catch ME
                 % in case construction failed (otherwise could get stuck in
                 % an infinite loop in Singleton Manager)
                 fprintf('\n\n\n!!!!ABORTING CREATION OF: %s....\n\n', classname);
                 SingletonManager.remove(classname);
                 rethrow(ME);
             end
             datIn.subclass = classname;
             
             % set timing parameter
             datIn.expectedLatency_sec = eyetracker.expectedLatency_ms/1000;
             
             % enable tagging if requested
             datIn.enableTagging            = saccade.enableTagging;
             datIn.includeTagsInRawOutput   = saccade.includeTagsInRawOutput;
             if datIn.enableTagging && datIn.includeTagsInRawOutput
                 warning('Currently inlcuding tags directly in raw output causes BLOCKING. Some lag will occur.')
             end
                 
             
             % initialise GUI element if figIndex specified
             if ~isempty(eyetracker.GUIidx)
                 datIn.spatialGuiElement = ivis.gui.IvGUIeyetrackSpatial(eyetracker.GUIidx);
             end
             if ~isempty(saccade.GUIidx)
                 datIn.temporalGuiElement = ivis.gui.IvGUIeyetrackTemporal(saccade.GUIidx);
             end
             
             % Create the fixation marker if one has been requested
             if ~isempty(eyetracker.fixationMarker)
                 datIn.setFixationMarker(eyetracker.fixationMarker);
             end
         end
         
         function dataStruct = readDataLog(fullFn)
             % Parse data stored in a .csv data file.
             %
             % @param    fullFn
             % @return   dataStruct
             %
             % @date     26/06/14
             % @author   PRJ
             %             
             
             % parse input
             fullFn = ivis.log.IvDataLog.validateFn(fullFn, 'data');
             
             % get data
             dataStruct = csv2struct(fullFn);
         end
         
         function lag_msec = estimateLag(params, withTagging, withGUI, Fs)
             % Estimate expected lag given a specified set of parameters.
             %
             % e.g.,
             % ivis.eyetracker.IvDataInput.computeLag(ivis.main.IvParams.getDefaultConfig(),false,true,500)*1000
             %
             % @param  	params
             % @param 	withTagging
             % @param	withGUI
             % @param 	Fs
             % @return 	lag_msec
             %
             % @todo    compute ivisOverhead empirically
             % @date   	26/06/14
             % @author 	PRJ
             %             
             
             % parse inputs
             if nargin < 2 || isempty(withTagging)
                 withTagging = true;
             end
             if nargin < 3 || isempty(withGUI)
                 withGUI = true;
             end
             if nargin >= 4 && ~isempty(Fs)
                 params.eyetracker.sampleRate = Fs;
             end
             
             % guestimate constants
             if withGUI
                 ivisOverhead = 0.0232; 
             else
                 ivisOverhead = 0.0067; 
             end
             queryTime = params.eyetracker.expectedLatency_ms;
             
             % phase 1 params [smoothAndInterpolate]
             p1_ww = 5; %#ok<*PROP>
             p1_ww2 = floor(p1_ww/2);
             p1_iw = 2;
             p1_Npost = max(p1_ww2,p1_iw);
             
             if withTagging
                 % phase 2 params [tagEvents]
                 p2_Npost = 5;
                 
                 % phase 3 params [postHocCleanEvents]
                 postBlinkWindow = ceil(params.eyetracker.sampleRate * params.saccade.postBlinkWindow_secs);
                 p3_Npost = postBlinkWindow; % 10;
             else
                 p2_Npost = 0;
                 p3_Npost = 0;
             end
             
             % calc further misc params
             N = p1_Npost + p2_Npost + p3_Npost;
             lag_msec = ivisOverhead + queryTime + (N+.5) * (1/params.eyetracker.sampleRate);
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
            obj = ivis.eyetracker.IvDataInput.getSetSingleton();
            if isempty(obj) % get standard error...
                Singleton.getInstanceSingleton(mfilename('class'));
            end     
        end
        function [] = finishUp()
            obj = ivis.eyetracker.IvDataInput.getSetSingleton();
            if isempty(obj) % get standard warning...
                Singleton.finishUpSingleton(mfilename('class'));
            else
                if isempty(obj.subclass)
                    error('a:b','Could not clear IvDataInput. No subclass set. FinishUp called before initialisation?'); % ALT could be a warning (if add else clause)
                else
                    Singleton.finishUpSingleton(obj.subclass);
                end
            end 
        end
    end
    
end