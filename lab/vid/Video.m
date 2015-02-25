classdef Video < handle
	% 
    % My example Video class
    %
    % IvVideo Methods:
    %   * ###### - 
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
    %   1.0 PJ 05/2013 : first_build\n
    %
    % Todo:
    %   none
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================

    properties (Constant)
        PRELOAD_SECS = 1
        PIXEL_FORMAT =  6
        MAX_THREADS = []
        KEEP_DISPLAYING_WHEN_PAUSED = true
    end
    
    properties (GetAccess = public, SetAccess = private)
        fn
        winhandle
        tex
        frameCount = 0
        fullscreen
        dstRect
        isPaused = false
        
        volume
        
        moviePtr
        movieduration
        fps
        imgw
        imgh
    end


    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj=Video(fn, winhandle)
            % IvVideo dfdfdf.
            %
            % @param    InH
            % @return   IvVideo
            % @version  25/03/13 [PJ]
            %    
            
            % open movie
            % If a relative file path, convert to absolute
            if strcmpi(fn(1),'.')
                fn = fullfile(pwd(), fn);
            end
            % Check file exists
            if ~exist(fn, 'file')
                error('Video:FailedToOpen','Movie file not found: %s\n', fn);
            end
            % Attempt to open movie
            [obj.moviePtr, obj.movieduration, obj.fps, obj.imgw, obj.imgh] = Screen('OpenMovie', winhandle, fn, [], Video.PRELOAD_SECS); % , [], Video.PIXEL_FORMAT, Video.MAX_THREADS); %#ok
            % check if the movie actually has a video track (imgw and imgh > 0):
            if (obj.imgw<=0) || (obj.imgh<=0)
                error('Video:FailedToOpen','Movie has no video track?');
            end
            
            % store
            obj.fn = fn;
            obj.winhandle = winhandle;
        end
        
        function [] = delete(obj)
            % Object destructor.
            %
            % @version  25/03/13 [PJ]
            %    

            % Release any prev texture:
            if ~isempty(obj.tex) && ishandle(obj.tex)
                Screen('Close', obj.tex);
            end
            
            
            try
                % Close movie object:
                Screen('CloseMovie', obj.moviePtr);
            catch %#ok
                fprintf('\nFailed to close movie???\n\n');
            end
            
        end
        
        %% == METHODS =====================================================
          
        function [] = start(obj, fullscreen, playRate, volume)
            % Start playback of movie. This will start
            % the realtime playback clock and playback of audio tracks, if any.
            % Play 'movie', at a playbackrate = 1, with endless loop=1 and
            % 1.0 == 100% audio volume.
            
           	% parse inputs
            if nargin < 2 || isempty(fullscreen)
                fullscreen = true;
            end 
            if nargin < 3 || isempty(playRate)
                playRate = 1.0;
            end 
            if nargin < 4 || isempty(fullscreen)
                volume = 1.0;
            end 
            
            % store
            obj.fullscreen = fullscreen;
            obj.volume = volume;
                
            % ####
            Screen('PlayMovie', obj.moviePtr, playRate, 1, volume);
        end
        function tex = playFrame(obj)
            % playFrame dfdfdf.
            %
            % @param    movieFnOrPtr
            % @param    maxSecs
            % @param    isLooped
            % @return   eof
            % @version  25/03/13 [PJ]
            %
            
          	tex = obj.tex;
            if ~obj.isPaused
                % Release any prev texture:
                if ~isempty(obj.tex)
                    Screen('Close', obj.tex);
                end
                
                % Return next frame in movie, in sync with current playback
                % time and sound.
                % tex is either the positive texture handle or zero if no
                % new frame is ready yet in non-blocking mode (blocking == 0).
                % It is -1 if something went wrong and playback needs to be stopped:
                obj.tex = Screen('GetMovieImage', obj.winhandle, obj.moviePtr, 1);
                tex = obj.tex;
                if obj.tex < 0
                	obj.frameCount = obj.frameCount + 1;
                end
            elseif ~Video.KEEP_DISPLAYING_WHEN_PAUSED
                return;
            end
            
            % returns -1 if end of file reached
            if obj.tex < 0
                warning('Video:NoTextureFound', 'No texture found. EOF?');
            end
  
            % Stretch rectangle to make fullscreen if so requested
            if obj.fullscreen && isempty(obj.dstRect)
                obj.dstRect = CenterRect(ScaleRect(Screen('Rect', obj.tex),3,3 ) , Screen('Rect', obj.winhandle));
            end
            
            % ensure appropriate blend function in operation
            [sourceFactorOld, destinationFactorOld, colorMaskOld]= Screen('BlendFunction', obj.winhandle, GL_ONE , GL_ONE_MINUS_SRC_ALPHA );
                                
            % Draw the new texture immediately to screen:
            Screen('DrawTexture', obj.winhandle, obj.tex, [], obj.dstRect);
            
            % restore previous blend function
            Screen('BlendFunction', obj.winhandle, sourceFactorOld, destinationFactorOld, colorMaskOld);
        end
        
        function [] = togglePause(obj)
            obj.isPaused = ~obj.isPaused;
            Screen('PlayMovie', obj.moviePtr, 1-obj.isPaused, 1, obj.volume);
        end   
    end
    
end