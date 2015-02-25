classdef IvGraphic < ivis.graphic.IvScreenObject
    % Screenobject responsible for remembering the position of an image at
    % each point in time. The associated PTB texture can be drawn by
    % invoking the draw() method. The classifier can request the location
    % of the image at any point in time, using the getXY() and getX0Y0()
    % methods.
    %
    % IvGraphic Methods:
    %   * IvGraphic     - Constructor.
    %   * draw          - Convenience wrapper for DrawTexture; if used should be called *immediately* after set().
    %   * setXY         - Log mean XY position(s) at specified timepoint(s).
    %   * nudge        	- Increment current XY position
    %   * reset       	- Sets XY, and resets the history (n.b., may want to save the buffer history first?).
    %   * getXY        	- Get mean xy position (in pixels) prior to each time specified timepoint (or the most recent point if no time specified).
    %   * getX0Y0     	- Get top-left xy position (in pixels) prior to each time specified timepoint (or the most recent point if no time specified).
    %   * getX          - Get current mean X position (in pixels).
    %   * getY          - Get current mean Y position (in pixels).
    %   * saveBuffer 	- Output xyt log to an external CSV file, linked in name to the appropriate IvDataLog file.
    %
   	% IvGraphic Static Methods:   
    %   * loadAll      	- convert all image files from a given directory into textures
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
    % @todo: check getX0Y0
    % @todo: delete setXY and reinitXY
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (GetAccess = public, SetAccess = private, SetObservable)
        nullrect
    end
    
    properties (GetAccess = public, SetAccess = private)
        % user specified parameters
        name
        texture
        winhandle
        srcrect
        width
        height
        auxParameters % to pass to Screen('DrawTexture') - i.e., see procedural gabor demo
        isStationary = true
        % other internal parameters
        xyt % an Nx3 CExpandableBuffer with starting N as specified in params
    end
    
    properties (GetAccess = public, SetAccess = public)
        plotColour = 'b'
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvGraphic(name, texture, x, y, width, height, winhandle, auxParameters)
            % IvGraphic Constructor.
            %
            % @param    name            String specifying the name of the graphical object
            % @param    texture         A PTB-3 texture handle
            % @param    x               The centre position, in pixels, along the horizontal axis [0 == left]
            % @param    y               The centre position, in pixels, along the vertical axis [0 == top]
            % @param    width           The width of the graphic, in pixels
            % @param    height          The height of the graphic, in pixels
            % @param    winhandle       PTB-3 screen handle
            % @param    auxParameters   Cell of optional aditional parameters passed to PTB's Screen('DrawTexture'...). E.g., for procedural texture generation
            % @return   IvGraphic       IvGraphic handle
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % call superclass constructor
            obj@ivis.graphic.IvScreenObject(ivis.graphic.IvScreenObject.TYPE_GRAPHIC);
            
            % parse/validate params
            if nargin < 8
                winhandle = [];
            end
            if nargin < 9
                auxParameters = {};
            end
            
            if ~isempty(texture) && isempty(winhandle)
                winhandle = ivis.main.IvParams.getInstance().graphics.winhandle;
            end
            
            % X initialise circular buffer
            % initialise total buffer (borrow params from DataLog)
            obj.xyt = CExpandableBuffer(ivis.main.IvParams.getInstance().log.data.arraySize, 3, ivis.main.IvParams.getInstance().log.data.expansionFactor);
            
            % sign up to the broadcast manager, which will notify this
            % object if it needs to save it's buffer to an external file
            % (called by IvDataLog)
            obj.startListening('SaveData', @obj.saveBuffer);

            % store params
            obj.name = name;
            obj.texture = texture;
            obj.winhandle = winhandle;
            obj.width = width;
            obj.height = height;
            obj.srcrect = round([0 0 width height]);
            obj.nullrect = round([-width -height width height]/2);
            obj.xyt.put([x y -inf]);
            obj.auxParameters = auxParameters;
        end
        
        function [] = delete(obj)
            % IvGraphic Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % Release texture:
            if ishandle(obj.texture)
                Screen('Close', obj.texture);
            end
            
            % release buffer:
            if ~isempty(obj.xyt)
                delete(obj.xyt);
                obj.xyt = [];
            end
            
            % stop listening
            obj.stopListening('SaveData');
        end
        
        %% == METHODS =====================================================
        
        function [] = draw(obj, winhandle, varargin)
            % Convenience wrapper for DrawTexture; if used should be called
            % *immediately* after set().
            %
            % @param  	winhandle   handle to PTB-3 screen, onto which the texture will be drawn
            % @param  	varargin    Optional aditional parameters passed to PTB's Screen('DrawTexture'...). E.g., for procedural texture generation. If blank, will use any auxParameters specified during construction
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            if nargin < 2 || isempty(winhandle)
                winhandle = obj.winhandle;
            end
            if nargin < 3
                varargin = obj.auxParameters;
            end
            
            % get position
            xy = obj.xyt.getLastN(1,1:2);
            
            % draw
            dstRect = obj.nullrect + [xy xy];
            Screen('DrawTexture', winhandle, obj.texture, [], dstRect, varargin{:})
        end
        
        function [] = setXY(obj, x, y, t)
            % Log mean XY position(s) at specified timepoint(s). If no presentation time is specified, will
            % assume the current time. If xy has changed since previous,
            % turns stationarity off.
            %
            % @param    x           The centre position, in pixels, along the horizontal axis [0 == left]. If empty, will repeat previous.
            % @param  	y           The centre position, in pixels, along the vertical axis [0 == top]. If empty, will repeat previous.
            % @param  	t           The expected presentation time. If empty, will use the current time, under the assumption that the graphic is going to be presented (i.e. Flipped) ASAP
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % get prior
            xy = obj.xyt.getLastN(1,1:2);
            
            if nargin < 2 || isempty(x)
                % assume we just want to leave the graphic in the same
                % place, in which case we can reduplicate the last position
                x = xy(1);
            end
            if nargin < 3 || isempty(y)
                % ditto
                y = xy(2);
            end
            if nargin < 4 || isempty(t)
                % assume that the graphic is going to be flipped onto the
                % screen immediately
                t = GetSecs();
            end
            
            % turn off stationarity if it has moved
            if any(xy ~= [x y])
                obj.isStationary = false;
                fprintf('!!!!IvGraphic: Switching off stationarity - timings may be affected!\n');
            end 
                
            % update
            obj.xyt.put([x y t]);
        end
        
        function [] = nudge(obj,x,y)
            % Increment current x and y positions.
            %
            % @param    x	Num pixels to incremement X position by
            % @param    y	Num pixels to incremement X position by
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            if obj.isStationary
                obj.isStationary = false;
                fprintf('!!!!IvGraphic: Switching off stationarity - timings may be affected!\n')
            end
            xy = obj.xyt.getLastN(1,1:2) + [x, y];
            obj.xyt.put([xy GetSecs()]);
        end
        
        function [] = reset(obj, x, y, width, height)
            % Sets XY, and resets the history (n.b., may want to save the
            % buffer history first?). If no values specified, will return
            % to whereever it started.
            %
            % @param    x       The centre position, in pixels, along the horizontal axis [0 == left]
            % @param    y       The centre position, in pixels, along the vertical axis [0 == top]
            % @param    width	The width of the graphic, in pixels
            % @param    height 	The height of the graphic, in pixels
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if nargin < 2 || isempty(x)
                x = obj.xyt.get(1,1); % get initial x point
            end
            if nargin < 3 || isempty(y)
                y = obj.xyt.get(1,2); % get initial y point
            end
            
            if nargin > 3 && ~isempty(width)
                obj.width = width;
            end
            if nargin > 4 && ~isempty(height)
                obj.height = height;
            end
            obj.srcrect = round([0 0 obj.width obj.height]);
            obj.nullrect = round([-obj.width -obj.height obj.width obj.height]/2);
            
            %obj.xyt = CExpandableBuffer(ivis.main.IvParams.getInstance().log.data.arraySize, 3, ivis.main.IvParams.getInstance().log.data.expansionFactor);
            %obj.xyt.put(starting_xyt);
            obj.xyt.clear();
            obj.xyt.put([x y -inf]);
        end
        
        function [] = setSize(obj, width, height)
            % Sets width and/or height. May trigger updates in
            % classifier(s).
            %
            % @param    width	The width of the graphic, in pixels
            % @param    height 	The height of the graphic, in pixels
            %
            % @date     26/06/14
            % @author   PRJ
            %

            % set
            if nargin > 1 && ~isempty(width)
                obj.width = width;
            end
            if nargin > 2 && ~isempty(height)
                obj.height = height;
            end
            
            % update rectangles
            obj.srcrect = round([0 0 obj.width obj.height]);
            obj.nullrect = round([-obj.width -obj.height obj.width obj.height]/2);
            
        end
        
        function xy = getXY(obj, t)
            % Get mean xy position (in pixels) prior to each time specified
            % timepoint (or the most recent point if no time specified).
            %
            % @param  	t   Optional vector of times. The XY position immediately prior to each time will be returned. If empty, will return the current XY.
            % @return   xy  2D vector, giving x and y coordinates (from top-left of screen, to middle of object)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if nargin < 2 || isempty(t)
                xy = obj.xyt.getLastN(1,1:2);
                return
            end
            
            if obj.isStationary
                xy = repmat(obj.xyt.getLastN(1,1:2), length(t), 1);
            else
                xy = obj.xyt.getBeforeEach(t,3,1:2);
            end
        end
        
        function xy = getX0Y0(obj, t)
            % Get top-left xy position (in pixels) prior to each time
            % specified timepoint (or the most recent point if no time
            % specified).
            %
            % @param  	t   Optional vector of times. The XY position immediately prior to each time will be returned. If empty, will return the current XY.
            % @return   xy  2D vector, giving x and y coordinates (from top-left of screen, to top-left of object)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if nargin < 2
                t = [];
            end
            xy = bsxfun(@minus, obj.getXY(t), [obj.width obj.height]/2); % n.b., should this be to BOTTOM-left of object???
        end
        
        function x = getX(obj, t)
            % Get current mean X position (in pixels).
            %
            % @param  	t   Optional vector of times. The XY position immediately prior to each time will be returned. If empty, will return the current XY.
            % @return   x   New centre position, in pixels, along the horizontal axis [0 == left].
            %
            % @date     26/06/14
            % @author   PRJ
            %

            if nargin < 2 || isempty(t)
                x = obj.xyt.getLastN(1,1);
                return
            end
            
            if obj.isStationary
                x = repmat(obj.xyt.getLastN(1,1), length(t), 1);
            else
                x = obj.xyt.getBeforeEach(t,3,1);
            end 
        end
        
        function y = getY(obj)
            % Get current mean Y position (in pixels).
            %
            % @return   y   New centre position, in pixels, along the vertical axis [0 == top].
            %
            % @date     26/06/14
            % @author   PRJ
            %
            y = obj.xyt.getLastN(1,2);
        end
        
        function [] = saveBuffer(obj, src, evnt) %#ok
            % Output xyt log to an external CSV file, linked in name to the
            % appropriate IvDataLog file.
            %
            % @param    src
            % @param    evnt
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % get filename
            datalogFullFn = evnt.Data;
            [fdir,fn] = fileparts(datalogFullFn);
            fn = sprintf('%s__gfc-%s.csv', fn, char(java.util.UUID.randomUUID()));
            fullFn = fullfile(fdir, fn);
            
            % save to file
            headerInfo={'x','y','t','IvDataLog'};
            
            % create/open file
            fid = fopen(fullFn,'w+');
            if fid == -1
                warning('IvGraphic:FailedToCreateFile','Could not open file: %s. Data will not be saved', fullFn);
            else
                try
                    fprintf(fid, '%s', strjoin(',',headerInfo{:}));
                    % write data (1st line - also includes IvDataLog file ref)
                    fprintf(fid, '\n%1.2f,%1.2f,%1.2f,%s,',obj.xyt.get(1)',datalogFullFn );
                    % write data (the rest)
                    if obj.xyt.nrows > 1
                        fprintf(fid, '\n%1.2f,%1.2f,%1.2f,,',obj.xyt.get(2:obj.xyt.nrows)');
                    end
                    fclose(fid);
                    fprintf('SAVED => %s\n',fullFn);
                catch ME
                    %fclose(fid);
                    fclose all;
                    rethrow(ME);
                end
            end
        end
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS-----
    %$ ====================================================================
    
    methods (Static, Access = public)
        
        function [texs, rects, imgs] = loadAll(directory, ext, winhandle)
            % loadAll helper/convenience function for loading all image
            % files (with a given file extension) from a specified
            % directory (returns the texture handles)
            %
            % @param    directory	relative or absolute path to folder containing images
            % @param    ext         file extension (e.g., 'png')
            % @param    winhandle 	PTB-3 screen handle, with which textures will be created
            % @return   texs      	cell of texture handles
            % @return   rects      	cell of image dimensions [0 0 width height]
            % @return   imgs        cell of RGBA matrices
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if nargin < 2 || isempty(ext)
                ext = 'png';
            end
            
            % get file names
            imgFiles = dir(fullfile(directory, sprintf('*.%s',ext)) );
            if isempty(imgFiles)
                error('IvGraphic:loadAll','No png images found in %s', directory)
            end
            
            imgFullFns = fullfile(directory, {imgFiles.name}); % convert to cell, prepend path
            % load each file into a vector
            n = length(imgFullFns);
            texs = cell(1,n);
            rects = cell(1,n);
            imgs = cell(1,n);
            for i=1:n
                [imgs{i}, ~, alpha] = imread(imgFullFns{i}, ext);
                imgs{i}(:,:,4) = alpha(:,:); % add the transparency layer to the image (for trans. back.)
                texs{i} = Screen('MakeTexture', winhandle, imgs{i});
                rects{i} = [0 0 size(imgs{i},1) size(imgs{i},2)];
            end
        end
    end
    
end