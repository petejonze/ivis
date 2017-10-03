classdef (Sealed) IvVideo < Singleton & ivis.broadcaster.IvListener
	% Video singleton for loading, playing and controlling videos.
    %
    % Videos can be made to update/play automatically on every flip, by
    % using play/pause/unpause (which registers the IvVideo object up to
    % the ivis event broadcaster). Alternatively each frame can be updated
    % manually using playFrame(). New video files can be loaded using
    % open(), which acts as a wrapper for Screen('OpenMovie'). Videos are
    % closed automatically on IvMain.finishUp().
    %
    % IvVideo Methods:
    %   * IvVideo       - Constructor
    %   * open          - Open movie file
    %   * play          - Play movie buffer
    %   * playFrame     - Play single frame from movie buffer
    %   * stop          - Stop the movie and restore audio 
    %   * close         - Close movie and release memory
    %   * pause         - Stop the movie from updating
    %   * unpause       - Restore movie updating
    %   * togglePause   - Alternate between paused/unpaused state
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
    %   1.0 PJ 03/2013 : first_build\n
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================

    properties (Constant)
        WAIT_PERIOD = .005;   % ######
    end
    
    properties (GetAccess = public, SetAccess = private)
        defaultVidDir   % path to default video directory
        defaultVidFns   % default video filenames
        nVidFns         % number of video files
        moviePtr        % handle to PTB movie
        movieFn         % name of current movie
        playRate = 1    % 0==stop; -1==backwards; 1=forwards
        frameCount = 0; % current frame in movie
        
        winhandle       % handle to PTB screen texture
        
        fullscreen = false; % whether to play the movie fullscreen
        dstRect = [];       % rectangle to draw into
        
        tex                     % OpenGL texture
        wasAudioEnabled = false % boolean
        
        background = [128, 128, 128]; % screen background RGB (max 255)
        blocking = 1;       % Use blocking wait for new frames by default
        preloadsecs = 1;    % defaults to 1second
        pixelFormat = 4;    % 4 is the default for colour, 5 or 6 may provide significantly improved playback performance on modern GPUs.
        maxThreads = [];    % a setting of zero asks to auto-select an optimum number of threads for a given computer
        shader = [];        % OpenGL texture shader
        volume = .35;       % scalar to multiple audio vector by
        
        isPaused = false;   % boolean
    end


    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvVideo()
            % IvVideo Constructor.
            %
            % @return   obj     IvVideo object
            %
            % @date     26/06/14             
            % @author   PRJ
            %
            toolboxHomedir = ivis.main.IvParams.getInstance().toolboxHomedir;
            obj.defaultVidDir = fullfile(toolboxHomedir,'./resources/videos');
            d = dir(obj.defaultVidDir);
            defaultVidFiles = d(~[d.isdir]); % exclude directories
            defaultVidFiles(strncmp({defaultVidFiles.name}, '.', 1)) = []; % exclude files begining with '.' (e.g., hidden files such as .DS_Store, .svn)
            obj.defaultVidFns = fullfile(obj.defaultVidDir, {defaultVidFiles.name});
            
            obj.nVidFns = length(obj.defaultVidFns);    
        end
        
        function [] = delete(obj)
            % IvVideo destructor.
            %
            % @date     26/06/14             
            % @author   PRJ
            %  
            obj.close();
            obj.winhandle = [];
        end
        
        %% == METHODS =====================================================
          
        function movPtr = open(obj, movieFn)
            % Open a movie file.
            %
            % @param    movieFn     file name (incl. relative or absolute path - or will otherwise assume it is in the present working directory)
            % @return   movPtr      PTB movie handle
            %
            % @date     26/06/14             
            % @author   PRJ
            %         
            
            if ~isempty(obj.moviePtr)
                error('IvVideo:FailedToOpen','Movie already open?');
            end
            
            if ~exist(movieFn, 'file')
                error('IvVideo:FailedToOpen','Movie file not found: %s\n pwd: %s', movieFn, pwd());
            end
            
obj.winhandle = ivis.main.IvParams.getInstance().graphics.winhandle;
                        
            % convert to absolute path if necessary
            if strcmpi(movieFn(1), '.')
                movieFn = fullfile(pwd(), movieFn);
            end
            
            [movPtr movieduration fps imgw imgh] = Screen('OpenMovie', obj.winhandle, movieFn, [], obj.preloadsecs, [], obj.pixelFormat, obj.maxThreads); %#ok
             
            % check if the movie actually has a video track (imgw and imgh > 0):
            if (imgw<=0) || (imgh<=0)
                error('a:b','c');
            end
            
            % store
            obj.movieFn = movieFn;
            obj.moviePtr = movPtr;
            obj.frameCount = 0;
        end
                
        
        function [] = play(obj, fullscreen, updateAutomatically)
            % Start the movie playing; sign up to the PreFlip broadcaster
            % to ensure that the movie keeps playing after every user call
            % to Screen('Flip') [n.b., requires that the user has called
            % import.broadcaster.*]
            %
            % @param	fullscreen          #####
            % @param    updateAutomatically	#####
            %
            % @date     26/06/14             
            % @author   PRJ
            %         
            
            if nargin < 2 || isempty(fullscreen)
                fullscreen = false;
            end
            if nargin < 3 || isempty(updateAutomatically)
                updateAutomatically = true;
            end
            
            obj.fullscreen = fullscreen;
            obj.dstRect = []; % will be calc'd at first cycle
                
%             obj.wasAudioEnabled = false;
%             audio = [];
%             try
%                 audio = ivis.audio.IvAudio.getInstance();
%             catch ME
%                 fprintf('IvVideo: Failed to retrieve audio object?\n');
%             end
%             if ~isempty(audio)
%                 obj.wasAudioEnabled = audio.isEnabled;
%                 if obj.wasAudioEnabled
%                     audio.disable();
%                 end
%             end
            
            Screen('PlayMovie', obj.moviePtr, obj.playRate, 1, obj.volume);

            if updateAutomatically
                obj.startListening('PreFlip', @obj.playFrame);
            end  
            
            obj.isPaused = false;
        end
        
        function tex = playFrame(obj, ~, ~)
            % Draw the single, current frame onto the screen, and iterate
            % the frame counter.
            %
            % @return   tex  PTB texture handle
            %
            % @date     26/06/14             
            % @author   PRJ
            %
            % tex empty if eof
            
            % disp('playing frame')
            
            if ~obj.isPaused
                % Release any prev texture: (PJ: Is this necessary?)
                if ~isempty(obj.tex)
                    Screen('Close', obj.tex);
                end
                
                % Return next frame in movie, in sync with current playback
                % time and sound.
                % tex is either the positive texture handle or zero if no
                % new frame is ready yet in non-blocking mode (blocking == 0).
                % It is -1 if something went wrong and playback needs to be stopped:
                obj.tex = Screen('GetMovieImage', obj.winhandle, obj.moviePtr, obj.blocking);
                tex = obj.tex;
                if obj.tex < 0
                    obj.frameCount = obj.frameCount + 1;
                end
            end
            
            if obj.tex < 0 % || ~ishandle(obj.tex)% Valid texture returned?
                fprintf('IvVideo: Aborting playback loop\n');
                return  % Abort playback loop:
            end
            
            if obj.fullscreen && isempty(obj.dstRect)
                obj.dstRect = CenterRect(ScaleRect(Screen('Rect', obj.tex),3,3 ) , Screen('Rect', obj.winhandle));
            end
            
            [sourceFactorOld, destinationFactorOld, colorMaskOld]= Screen('BlendFunction', obj.winhandle, GL_ONE , GL_ONE_MINUS_SRC_ALPHA );
            
            % Draw the new texture immediately to screen:
            Screen('DrawTexture', obj.winhandle, obj.tex, [], obj.dstRect, [], [], [], [], obj.shader);
            
            Screen('BlendFunction', obj.winhandle, sourceFactorOld, destinationFactorOld, colorMaskOld);
            
        end
        
        function [] = stop(obj)
            % Pause the movie and stop any audio (n.b., memory will not be
            % released until obj.close() is called)
            %
            % @date     26/06/14             
            % @author   PRJ
            %  
            
            obj.pause(false);
            
%             if obj.wasAudioEnabled
%                 audio = ivis.audio.IvAudio.getInstance();
%                 audio.enable();
%             end
        end
        
        function [] = close(obj)
            % Close the movie, and release memory.
            %
            % @date     26/06/14             
            % @author   PRJ
            %  

            obj.stopListening('PreFlip');
            
            % Release any prev texture:
            if ~isempty(obj.tex) && ishandle(obj.tex)
                Screen('Close', obj.tex);
            end
            obj.frameCount = 0;
            
            if ~isempty(obj.moviePtr) && ishandle(obj.moviePtr)
                % stop the movie
                Screen('PlayMovie', obj.moviePtr, 0);
                
                %fprintf('Closing the movie...\n');
                % Close movie object:
                Screen('CloseMovie', obj.moviePtr);
            end
            obj.moviePtr = [];
        end
        
        function [] = pause(obj, keepDisplaying)
            % Pause the movie, optionally leaving the last frame displayed
            % on the screen
            %
            % @param    keepDisplaying  whether to leave the last frame on the screen (default=true)
            %
            % @date     26/06/14             
            % @author   PRJ
            %   
            if nargin < 2 || isempty(keepDisplaying)
                keepDisplaying = true;
            end
            
            % fprintf('pausing..\n');            
            obj.isPaused = true;
            Screen('PlayMovie', obj.moviePtr, 0, 1, obj.volume);

            if ~keepDisplaying
                obj.stopListening('PreFlip');
            end
        end
        
        function [] = unpause(obj)
            % Resume playing the movie (following a call to obj.pause)
            %
            % @date     26/06/14             
            % @author   PRJ
            %            
            
            % fprintf('unpausing..\n');            
            obj.isPaused = false;
            Screen('PlayMovie', obj.moviePtr, obj.playRate, 1, obj.volume);
            
            obj.startListening('PreFlip', @obj.playFrame);
        end
        
        function [] = togglePause(obj, keepDisplaying)
            % Pause the movie is currently playing (otherwise unpause).
            %
            % @param    keepDisplaying  whether to keep displaying the movie (if calling obj.pause())
            %
            % @date     26/06/14             
            % @author   PRJ
            %     
            
            if nargin < 2 || isempty(keepDisplaying)
                keepDisplaying = true;
            end

            if obj.isPaused
                obj.unpause();
            else
                obj.pause(keepDisplaying);
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
        function obj = init()
            obj = Singleton.initialise(mfilename('class'));
        end
        function obj = getInstance()
            obj = Singleton.getInstanceSingleton(mfilename('class'));
        end
        function [] = finishUp()
            Singleton.finishUpSingleton(mfilename('class'));
        end
    end
    
end