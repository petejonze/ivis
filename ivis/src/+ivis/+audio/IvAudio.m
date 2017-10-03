classdef (Sealed) IvAudio < Singleton
    % Singleton resposible for loading and playing audio.
    %
    % Is mainly a wrapper for PsychPortAudio, with handy methods for
    % loading files. A simple mechanism for calibration is included, but
    % for simplicity it only supports a single input-output mapping. If you
    % want to independently calibrate different ears or different
    % frequencies, you will have to modify this code.
    %
    % IvAudio Methods:
    %   * IvAudio        - Constructor.
    %   * enable         - Connect to audio device and store handle.
    %   * disable        - Close connection to audio device.
    %   * test           - Play tone pip to ensure functions are cached and everything is working.
    %   * calibrate      - Fit a calibration function to a two column matrix {rms_in, db_out}.
    %   * stop           - Stop audio stream; wrapper for PsychPortAudio('Stop').
    %   * play           - Helper/convenience function for playing a sound immediately, via PsychPortAudio.
    %   * rampOnOff 	 - Apply a Hann (raised cosine) window to the specified audio vector/matric.
    %   * setLevel       - Calibrate the specified audio vector to play at a specified level, given a pre-computed rms-db mapping.
    %   * setDefaultLevel- Set the default output level, e.g., if no level is specified when calling obj.play().
    %   * wavload        - Load audio stream from specified .wav file.    
    %   * loadAll        - Helper/convenience function for loading all sounds with a given extension, and in a given directory.
    %   * getNewSlave    - Create a new audio slave, for multitrack mixing.
    %
    % IvAudio Static Methods:
    %   * getPureTone   - Get a sine wave with a given frequency/duration.
    %   * padChannels   - Expand audio vector/matrix so that rows match N out channels (filling extra channels with zeros).
    %   * setRMS        - Set root-mean-square power to a specified value.
    %   * UnitTest   	- A simple (temporary?) test, to check that the class works.
    %
    % See Also:
    %   ivisDemo_audio.m
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 02/2013 : first_build\n
    %   1.1 PJ 06/2013 : updated documentation\n
    %
    %
    % *TODO: should probably split PsychPortAudio and MatlabBuiltIn sound
    % into seperate subclasses (i.e., rather than use of switch..case) --
    % NB: affects constructor(), destructor(), enable(), disable(), play(),
    % stop()
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (Constant)
        r2_CRITERION = 0.95;
    end
    
    properties (GetAccess = public, SetAccess = private)
        interface
        %
        isEnabled = 0   % whether or not linked to the audio device
        devID           % hardware device number (empty for best guess)
        Fs              % audio card sampling rate (e.g., 44100)
        outChans        % indices for output (e.g., [0 1] for stereo)
        runMode         % optional level of hardware priority (initialisation)
        reqlatencyclass % optional level of hardware priority (initialisation)
        latbias_secs   	% optional latency offset (initialisation)
        useCalibration  % calibration: whether to enable level calibration
        rms2db_fn       % calibration: matlab file containing raw data
        defaultLevel_db = 40 % calibration: default output level (n.b., requires an accurate calibration)
      	% simple utility sounds
        BAD_SND
        GOOD_SND
        % ####
        pahandle        % PsychPortAudio handle to audio device
    end
    
    properties (GetAccess = private, SetAccess = private)
        %pamaster
        rms2db_raw      % calibration: raw rms-db measurements (2 columns)
        db2rms_fcn      % calibration: db-rms input-output function
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvAudio(audioParams, verbosity)
            % IvAudio Constructor.
            %
            % @param    audioParams See IvParams
            % @param    verbosity   Numeric flag, passed to PsychPortAudio
            % @return   obj         IvAudio object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if nargin < 2 || isempty(verbosity)
                verbosity = 10;
            end
            
            % parse inputs
            if verbosity > 1
                dispStruct(audioParams);
            end
            
            % store params
            obj.interface       = audioParams.interface;
            obj.devID           = audioParams.devID;
            obj.Fs              = audioParams.Fs;
            obj.outChans        = audioParams.outChans;
            obj.runMode       	= audioParams.runMode;
            obj.reqlatencyclass	= audioParams.reqlatencyclass;
            obj.latbias_secs    = audioParams.latbias_secs;
            obj.useCalibration  = audioParams.useCalibration;
            if ~isempty(audioParams.defaultLevel_db)
                obj.defaultLevel_db = audioParams.defaultLevel_db;
            end
            
            switch lower(obj.interface)
                case 'psychportaudio'
                    % Initialize driver, request low-latency preinit:
                    InitializePsychSound(obj.runMode);
                    
                    % close any extant audio handles
                    PsychPortAudio('Close');
                    
                    % high verbosity
                    PsychPortAudio('Verbosity', verbosity);
                case 'matlabbuiltin'
                    % do nothing
                otherwise
                    error('Sound API not recognised: %s\nRecognised value: PsychPortAudio, MatlabBuiltIn', obj.interface);
            end
            
            % Get calibration if raw measurement specified
            if obj.useCalibration
                obj.calibrate(audioParams.rms2db_fnOrMatrix);
            end
            
            % connect and test
            if audioParams.isEnabled
                obj.enable();
                obj.test();
            end
            
            % load simple utility sounds
            obj.BAD_SND = 0.1*obj.wavload(fullfile(ivisdir(),'resources','audio','wav','bad.wav'));
            obj.GOOD_SND = 0.1*obj.wavload(fullfile(ivisdir(),'resources','audio','wav','good.wav'));
        end
        
        function [] = delete(obj)
            % IvAudio Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % fprintf('\n\n\n\n\n\nDEBUG INFO: FIRING THE IVAUDIO DESTRUCTOR\n\n\n\n\n\n');
            if obj.isEnabled
                obj.disable();
            end
            
           	% close connection, release memory
            switch lower(obj.interface)
                case 'psychportaudio'
                    PsychPortAudio('Close')
                case 'matlabbuiltin'
                    clear obj.pahandle;
                otherwise
                    warning('Sound API not recognised: %s\nRecognised value: PsychPortAudio, MatlabBuiltIn', obj.interface);
            end
        end
        
        %% == METHODS =====================================================
        
        function [] = enable(obj)
            % Connect to audio device and store handle.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % check if audio already enabled
            if obj.isEnabled || ~isempty(obj.pahandle)
                error('IvAudio:InvalidCall', 'Audio already enabled');
            end
            
            switch lower(obj.interface)
                case 'psychportaudio'
                    %pahandle = PsychPortAudio('Open' [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
                    obj.pahandle = PsychPortAudio('Open', obj.devID, [], obj.reqlatencyclass, obj.Fs, max(obj.outChans)+1,[],[],[]);
                    
                    
                    %             % by opening up the primary output device as a slave of a
                    %             % master handle, we reserve the ability to open up additional
                    %             % slave later on, for easy mixing. See getSlave().
                    %             obj.pamaster = PsychPortAudio('Open', obj.devID, [], obj.reqlatencyclass, obj.Fs, max(obj.outChans)+1,[],[],[])
                    %
                    %             % Start master immediately, wait for it to be started. We won't stop the
                    %             % master until the end of the session.
                    %             %PsychPortAudio('Start', obj.pamaster, 0, 0, 1)
                    %
                    %             % open the primary slave, that will be used for playback
                    %             % (though users can request to create new slaves if they want
                    %             % to mix tracks)
                    %             obj.pahandle = PsychPortAudio('OpenSlave', obj.pamaster, 1)
                    
                    
                    % Tell driver about hardwares inherent latency, determined via calibration
                    if ~isempty(obj.latbias_secs)
                        PsychPortAudio('LatencyBias', obj.pahandle, obj.latbias_secs);
                    end
                    
                    % runMode 1 will slightly increase the cpu load and general
                    % system load, but provide better timing and even lower sound
                    % onset latencies under certain conditions.
                    if ~isempty(obj.runMode)
                        PsychPortAudio('RunMode', obj.pahandle, obj.runMode);
                    end
                    
                    % set sample rate to default, if none was specified by user
                    if isempty(obj.Fs)
                        s = PsychPortAudio('GetStatus', obj.pahandle);
                        obj.Fs = s.SampleRate;
                    end
                case 'matlabbuiltin'
                    if ~isempty(obj.devID)
                        warning('Device ID not supported by MatlabBuiltIn sound. Ignoring specified value (%1.2f)', obj.devID);
                    end
                    if ~isempty(obj.latbias_secs)
                        warning('Latency Bias not supported by MatlabBuiltIn sound. Ignoring specified value (%1.2f)', obj.latbias_secs);
                    end
                    if ~isempty(obj.runMode)
                        warning('Run Mode not supported by MatlabBuiltIn sound. Ignoring specified value (%1.2f)', obj.runMode);
                    end
                    % set sample rate to default, if none was specified by user
                    if isempty(obj.Fs)
                        obj.Fs = 22050;
                    end
                otherwise
                    error('Sound API not recognised: %s\nRecognised value: PsychPortAudio, MatlabBuiltIn', obj.interface);
            end
            
            % store on/off flag
            obj.isEnabled = true;
        end
        
        function [] = disable(obj)
            % Close connection to audio device.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if ~obj.isEnabled || isempty(obj.pahandle)
                error('IvAudio:InvalidCall', 'Cannot disable: No audio enabled?');
            end
            
         	% fprintf('\n\n\n\n\nDEBUG INFO: DISABLING AUDIO\n\n\n\n');
            switch lower(obj.interface)
                case 'psychportaudio'
                    PsychPortAudio('Stop', obj.pahandle, 2*(obj.runMode>0));
                    PsychPortAudio('Close', obj.pahandle)
                case 'matlabbuiltin'
                    % do nothing
                otherwise
                    error('Sound API not recognised: %s\nRecognised value: PsychPortAudio, MatlabBuiltIn', obj.interface);
            end
            
            % store new values
            obj.pahandle = [];
            obj.isEnabled = false;
        end
        
        function [] = test(obj, dB)
            % Play tone pip to ensure functions are cached and everything
            % is working.
            %
            % @param    dB
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % parse inputs
            if nargin < 2
                dB = [];
            end
            
            % create 1 1kHz sound of duration d
            d = .1;           	% duration, in seconds
            testChans = obj.outChans;  	% all channels
            lvlFactor = 0.01;    % attenuate it to some arbitrarily low level to avoid blowing anybody's eardrums
            x = obj.rampOnOff(obj.padChannels(obj.getPureTone(1000,obj.Fs,d)*lvlFactor, testChans, obj.outChans));
            
            % play it
            obj.play(x, dB, false);
        end
        
        function [] = calibrate(obj, rms2db_fnOrMatrix, doPlot)
            % Fit a calibration function to a two column matrix {rms_in,
            % db_out}. The data may be passed in directly, or stored in a
            % matlab file that will be loaded in (in which case the data
            % must be stored in a variable called "data"). Fits are made
            % using a simple 1st-order polynomial, but could be improved by
            % using something more complicated, such as a spline-fit. N.b.,
            % calling this will automatically set obj.useCalibration = true
            %
            % @param    rms2db_fnOrMatrix 2-column matrix or .mat file name
            % @param    doPlot            optional. If true then graphs the fit.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % parse inputs
            if nargin < 4 || isempty(doPlot)
                doPlot = true;
            end
            
            % load raw measurements
            if ischar(rms2db_fnOrMatrix)
                if ~exist(rms2db_fnOrMatrix,'file')
                    error('IvAudio:InvalidInput', 'Specified calibration file (%s) cannot be found', rms2db_fnOrMatrix)
                end
                tmp = load(rms2db_fnOrMatrix);
                obj.rms2db_raw = tmp.data;
            else
                obj.rms2db_raw = rms2db_fnOrMatrix;
            end
            
            % make initial fit
            rms = obj.rms2db_raw(:,1);
            db = obj.rms2db_raw(:,2);
            % fit
            fitCoefs = polyfit(log10(rms),db,1);
            % compute error
            yhat = polyval(fitCoefs,log10(rms));
            c = corrcoef(db, yhat);
            r2 = c(1,end)^2; %ALT: 1 - sum((log10(rms)-yhat).^2) / sum((log10(rms)-mean(log10(rms))).^2)
            
            % plot, if so requested
            if doPlot
                figure()
                hold on
                plot(log10(rms),db,'o');
                plot(log10(rms),yhat,'-');
            end
            
            % keep refitting until sufficient variance is explained, each time
            % excluding the most outlying point (if necessary)
            while r2 < obj.r2_CRITERION
                if length(rms) <= 3 %requires 3 mininmum
                    error('calibration fit failed (fewer than 3 data points remaining)');
                end
                
                % we expect that the higher values will be more trust-worthy than the
                % lower ones, so we will weight the errors accordings
                weight = logspace(log10(1),log10(.1),length(db))';
                
                % Find the biggest/most-distal outlie
                err = abs(db-yhat); % work out RMS errors
                err = err .* weight; %weight
                % remove outlier
                rms(ismember(err,max(err))) = [];
                db(ismember(err,max(err))) = [];
                
                % refit
                fitCoefs = polyfit(log10(rms),db,1);
                % compute error
                yhat = polyval(fitCoefs,log10(rms));
                c = corrcoef(db, yhat);
                r2 = c(1,end)^2;
            end
            
            % plot, if so requested
            if doPlot
                hold on
                plot(log10(rms),db,'rx');
                plot(log10(rms),yhat,'r-');
                legend('raw (initial)', 'fitted (initial)', 'raw (robust)', 'fitted (robust)', 'Location','NorthWest')
            end
            
            % store function handle
            % obj.db2rms_fcn = @(rms)polyval(fitCoefs, rms);
            obj.db2rms_fcn = @(targLeq)exp10( (targLeq - fitCoefs(2) ) / fitCoefs(1) );
            
            % assume that we now want to enable calibration
            obj.useCalibration = true;
        end
        
        
        function [] = stop(obj)
            % Stop audio stream; wrapper for PsychPortAudio('Stop')
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            switch lower(obj.interface)
                case 'psychportaudio'
                    status = PsychPortAudio('GetStatus', obj.pahandle);
                    if status.Active == 1 % if active..
                        PsychPortAudio('Stop', obj.pahandle, 2*(obj.runMode>0)); % ..immediately stop any playing sounds
                        WaitSecs(0.05);
                        % try once more
                        status = PsychPortAudio('GetStatus', obj.pahandle);
                        if status.Active == 1 % if active..
                            PsychPortAudio('Stop', obj.pahandle, 2*(obj.runMode>0)); % ..immediately stop any playing sounds
                            WaitSecs(0.05);
                        end
                    end
                case 'matlabbuiltin'
                    if isa(obj.pahandle, 'audioplayer')
                        obj.pahandle.stop();
                    end
                otherwise
                    error('Sound API not recognised: %s\nRecognised value: PsychPortAudio, MatlabBuiltIn', obj.interface);
            end
        end
        
        
        function [] = play(obj, x, dB, blocking)
            % Helper/convenience function for playing a sound immediately,
            % via PsychPortAudio. If a target dB is specified but
            % calibration is not enabled, this parameter will be silently
            % ignored.
            %
            % @param    x           wave vector/matrix
            % @param    dB          optional. output level, in dP SPL (default = obj.defaultLevel_db)
            % @param    blocking    optional. whether or not to pause until sound is finished (default = true)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % parse inputs
            if nargin < 3 || isempty(dB)
                dB = obj.defaultLevel_db;
            end
            if nargin < 4 || isempty(pause)
                blocking = true;
            end
            
            % validate
            if ~obj.isEnabled
                warning('Cannot play sound because audio is not enabled');
                return;
            end
            
            % calibrate, if so requested
            if obj.useCalibration
                x = obj.setLevel(x, dB);
            end
            
            % play immediately
            switch lower(obj.interface)
                case 'psychportaudio'
                    % check initialized
                    if isempty(obj.pahandle)
                        error('pahandle is empty? IvAudio must be initialised first before calling play()');
                    end
                    
                    % stop if already playing
                    status = PsychPortAudio('GetStatus', obj.pahandle);
                    if status.Active == 1 % if active..
                        PsychPortAudio('Stop', obj.pahandle, 2*(obj.runMode>0)); % ..immediately stop any playing sounds
                        WaitSecs(0.05);
                        % try once more
                        status = PsychPortAudio('GetStatus', obj.pahandle);
                        if status.Active == 1 % if active..
                            PsychPortAudio('Stop', obj.pahandle, 2*(obj.runMode>0)); % ..immediately stop any playing sounds
                            WaitSecs(0.05);
                        end
                    end
                    PsychPortAudio('FillBuffer', obj.pahandle, x);   	% Fill audio buffer with data:
                    PsychPortAudio('Start', obj.pahandle, 1, 0, 1); % play
                    
                    % if in blocking mode, wait for sound to finish before
                    % continuing
                    if blocking
                        d = length(x)/obj.Fs;
                        WaitSecs(d);                             	% pause for stimulus duration (this could also be set in the call to PPA)
                        status = PsychPortAudio('GetStatus', obj.pahandle);
                        if status.Active == 1 % if active..
                            PsychPortAudio('Stop', obj.pahandle, 2*(obj.runMode>0))	% explicitly tell to stop (defensive)
                        end
                    end
                case 'matlabbuiltin'
                    obj.pahandle = audioplayer(x, obj.Fs);
                    if blocking
                        obj.pahandle.playblocking();
                    else
                        obj.pahandle.play();
                    end
                otherwise
                    error('Sound API not recognised: %s\nRecognised value: PsychPortAudio, MatlabBuiltIn', obj.interface);
            end

        end
        
        function x = rampOnOff(obj, x, wd, Fs)
            % Apply a Hann (raised cosine) window to the specified audio
            % vector/matric. Each row of x represents an audio channel.
            %
            % @param    x   sound wave, pre ramp
            % @param    wd  optional. window duration, in secs (default = 10 ms)
            % @param	Fs  optional. sampling rate, e.g., 44100 (default = obj.Fs)
            % @return	x   sound wave, post ramp
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % parse inputs
            if nargin < 3 || isempty(wd)
                wd = 0.01;
            end
            if nargin < 4 || isempty(Fs)
                Fs = obj.Fs;
            end
            
            % initialise parameters
            n = size(x,2);
            Mh = floor(Fs * wd); 	% number of samples in just the onset (/offset)
            M = Mh * 2;             % number of ramp samples
            
            % generate samples
            H = .5*(1 - cos(2*pi*(1:M)/(M+1))); 	% generate ramp
            sustain = ones(1,n-M);                  % generate sustain
            
            % construct window
            w = [H(1:Mh) sustain H(Mh+1:end)];      	% join
            
            % expand to match nChannels
            nChannels = size(x,1);
            w = repmat(w,nChannels,1);
            
            % apply
            x = x .* w;
        end
        
        function x = setLevel(obj, x, dB)
            % Calibrate the specified audio vector to play at a specified
            % level, given a pre-computed rms-db mapping.
            % (computeCalibration must have been called first).
            %
            % @param    x   sound wave, pre calibration
            % @param    dB  target level (if unspecified use default)
            % @return	x   sound wave, post calibration
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % get and set target rms
            x = obj.setRMS(x, obj.db2rms_fcn(dB));
            if any(any(abs(x)>1))
                warning('IvAudio:Clipping','some values outside the range of {-1,1}, some clipping will occur');
            end
        end
        
        function [] = setDefaultLevel(obj, dB)
            % Set the default output level, e.g., if no level is specified
            % when calling obj.play().
            %
            % @param    dB  target level (to use if unspecified)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.defaultLevel_db = dB;
        end
        
        function [x ,d_secs] = wavload(obj, fn, matchNOutChans)
            % Load audio stream from specified .wav file.
            % (helper/convenience function for loading in wav audio). Will
            % resample if not at the right sampling rate, and will
            % transpose to put it in PsychPortAudio-compatible row format.
            %
            % @param    fn              file name (incl. relative or absolute path)
            % @param    matchNOutChans  boolean - whether to replicate rows to match nOutChans
            % @return   x               wave vector/matrix
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % parse inputs
            if nargin < 3 || isempty(matchNOutChans)
                matchNOutChans = true;
            end
            
            % parse inputs
            if ~exist(fn, 'file')
                error('file not found: %s\nPwd: %s', fn, pwd());
            end

            % load data
            [x,xFs] = audioread(char(fn));
            
            % set sampling rate
            if xFs ~= obj.Fs
                x = resample(x,obj.Fs,xFs);
            end
            
            %transpose to make compatible with psychportaudio
            x = x';
            
            % replicate nRows to match nOutChans
            if matchNOutChans && size(x,1)==1
                x = repmat(x, length(obj.outChans),1);
            end
            
            % compute duration (in seconds)
            d_secs = size(x,2)/xFs;
        end
        
        function [snds, sndFullFns, d_secs] = loadAll(obj, directory, pattern, magnMod)
            % Helper/convenience function for loading all sounds with a
            % given extension, and in a given directory. Throws an error if
            % no files found N.b., it does not search recursively.
            %
            % @param    directory   directory to search in
            % @param    pattern    	optional file pattern (default: *.wav)
            % @param	magnMod     scalar to multiply the amplitude by
            % @return	snds        cell contained sound waves
            % @return	sndFullFns  cell contained source files (with path)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            if nargin < 3
                pattern = '*.wav';
            end
            if nargin < 4 || isempty(magnMod)
                magnMod = 1;
            end
            
            % get file names
            sndFiles = dir(fullfile(directory, pattern));
            if isempty(sndFiles)
                error('IvAudio:loadAll','No wav sounds found in %s', directory)
            end
            
            sndFullFns = fullfile(directory, {sndFiles.name}); % convert to cell, prepend path
            % load each file into a vector
            snds = cell(1,length(sndFullFns));
            d_secs = nan(1,length(sndFullFns));
            for i=1:length(sndFullFns)
                [snds{i}, d_secs(i)] = obj.wavload(sndFullFns{i});
                snds{i} = snds{i} * magnMod; % adjust level
            end
        end
        
        function pahandle = getNewSlave(obj)
            % Create a new audio slave, for multitrack mixing. See
            % BasicAMAndMixScheduleDemo.m for details.
            %
            % @return	pahandle  	audio slave handle
            %
            % @date     22/07/14
            % @author   PRJ
            %
            error('Not currently supported!')
            pahandle = PsychPortAudio('OpenSlave', obj.pamaster, 1);
        end
        
%         function rms = getTargRMS(obj, dB)
%             rms = obj.db2rms_fcn(dB);
%         end
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================
    
    methods (Static, Access = public)

        function x = getPureTone(hz, Fs, d)
            %  Get a sine wave with a given frequency/duration.
            %
            % @param    hz  tone carrier frequency
            % @param    Fs  sampling rate (e.g., 44100)
            % @param	d 	tone duration (seconds
            % @return	x   audio (row) vector
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % params
            n = floor(Fs * d);  % number of samples
            t = (0:(n-1)) / Fs; % time vector [sound data preparation]
            phase = 0;          % phase (Rad)
            % create
            x = sin(2 * pi * hz * t + phase); % audio vector
        end
        
        function x_padded = padChannels(x, testChans, outChans)
            % Expand audio vector/matrix so that rows match N out channels
            % (filling extra channels with zeros).
            %
            % @param	x           sound row-vector/matrix, pre padding
            % @param	testChans	vector of channel indices containing non-zeros (should match the number of rows in x)
            % @param	outChans	vector of (total) channel indices (e.g., [0 1])
            % @return	x_padded	sound row-vector/matrix, post padding
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % init
            nDataChans = size(x, 1);
            nTestChans = length(testChans);
            nOutChans = length(outChans);
            if nDataChans == 1 && nTestChans > 1 % assume want to duplicate
                x = repmat(x, nTestChans, 1);
            end
            nDataChans = size(x, 1);
            if nDataChans ~= nTestChans
                error('padChannels:invalidInput','number of test channels (%i) does''t match number of data channels (%i)',nTestChans,nDataChans);
            end
            if ~all(ismember(testChans,outChans)) % if not all of the test channels are in the output channel list
                testChans = testChans(:) %#ok
                outChans = outChans(:) %#ok
                error('padChannels:invalidInput','not all test channels contained within list of output channels');
            end
            
            % do padding
            x_padded = zeros(nOutChans, size(x, 2));
            for i = 1:nDataChans
                idx = testChans(i)+1; % +1 since matlab indexes from 1, not 0
                x_padded(idx,:) = x(i,:);
            end
        end
        
        function x = setRMS(x, rms)
            % Set root-mean-square power to a specified value.
            %
            % @param    x       sound row-vector/matrix, pre calibration
            % @param    rms    	target root-mean-square power
            % @return	x       sound row-vector/matrix, post calibration
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % init
            nChans = size(x,1); % n.b., each ROW should be an output channel
            
            % if single value given for RMS then replace with vector (identical value for each channel)
            if length(rms) == 1
                rms = repmat(rms,nChans,1);
            end
            
            % similarly the sound input (x) may be a single vector, but multiple
            % RMS values specified. In this case we'll assume that the user is
            % being lazy and wants us to split the sound into a matrix (one row
            % vector per channel)
            if size(x,1) == 1 && length(rms) > 1
                x = repmat(x,length(rms),1);
                nChans = size(x,1); % recalc number of channels
            end
            
            % ensure that RMS is a column vector (not row)
            if size(rms,1) == 1 % (might just be a single item of course, in which case this will do nothing)
                rms = rms';
            end
            
            % check that each channels has an RMS value
            if length(rms) ~= nChans
                error('IvAudio:InvalidInput','Each channel must have an RMS value (num rms = %i; num channels = %i). Input a single number to use the same value for each channel.', length(rms), nChans);
            end
            
            % set rms
            for i=1:nChans
                old_rms = sqrt(mean(x(i,:).^2));
                x(i,:) = x(i,:).*rms(i)/old_rms;
            end
        end
        
        function [] = UnitTest()
            % A simple (temporary?) test, to check that the class works.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            params = ivis.main.IvParams.getDefaultConfig();
            A = ivis.audio.IvAudio(params.audio);
            A.delete();
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