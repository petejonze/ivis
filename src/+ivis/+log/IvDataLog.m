classdef (Sealed) IvDataLog < ivis.log.IvLog
	% Responsible for buffering and saving processed data.
    %
    % IvDataLog Methods:
    %   * IvDataLog  - Constructor.
	%   * add        - Add data to the buffer.
    %   * getLastN	 - Retrieve last N samples from the buffer.
    %   * getSinceT	 - Retrieve all samples from the buffer since time T.
    %   * getTmpBuff - Get all samples that were added on the last cycle.
    %   * save    	 - Dump the buffer to an external file; prompt IvGraphic objects to do likewise.
    %   * reset  	 - Clear the buffer.
    %   * getN    	 - Get the N samples held in the buffer.
    %   * getLastKnownXY     - Convenience wrapper for getLastN, that extracts the last N [xy,t] values (raw or processed, with or without NaNs).      
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

    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (GetAccess = public, SetAccess = private)
        % other internal parameters
        buffer % CExpandableBuffer. Currently 11 columns: x,y,t,v,p,s,d,v,a,X,Y
            % x : x position (in pixels)
            % y : y position (in pixels)
            % t : timestamp (in seconds)
            % v : some kind of validity measure
            % p : pupil diameter
            % c : eye-event code (see IvEventCode)
            % d,v,A
            % X : x position, without processing (in pixels)
            % Y : y position, without processing (in pixels)
        tmpBuff % just stores the last inserted sample(s)     
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvDataLog(homeDir, fnPattern, arraySize)
            % IvDataLog Constructor.
            %
            % @param    homeDir
            % @param    fnPattern
            % @param    arraySize
            % @return   obj         IvDataLog object
            %
            % @date     26/06/14
            % @author   PRJ
            %             
            
            obj.homeDir = regexprep(homeDir, '\$iv', escape(ivis.main.IvParams.getInstance().toolboxHomedir), 'ignorecase');
            obj.fnPattern = fnPattern;
obj.homeDir = 'D:\Dropbox\MatlabToolkits\ivis\logs\data'
            % try to open/create example log. Will immediately close & delete afterwards,
            % but this is just to see if disk-access is permitted
            if ~exist(obj.homeDir, 'dir')
                error('IvDataLog:FailedToInit','Specified data directory could not be found: %s ', obj.homeDir);
            end
            fullFn = fullfile(obj.homeDir, 'tmp');
            fid = fopen(fullFn,'w+');
            if fid == -1
                error('IvDataLog:FailedToInit','Could not open file: %s  [No write access?]', fullFn);
            end
            fclose(fid);
            delete(fullFn);
            
            obj.buffer = CExpandableBuffer(arraySize, 11);
        end
        
        function [] = delete(obj)
            % IvDataLog Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %       
            
            % release buffer:
            if ~isempty(obj.buffer)
                delete(obj.buffer);
                obj.buffer = [];
            end
        end

        %% == METHODS =====================================================
        
        function [] = add(obj, x, y, t, vldty, p, c, d, v, A, X, Y)
            % Add data to the buffer.
            %
            % @param    x       gaze x position (pixels)
            % @param    y       gaze y position (pixels)
            % @param    t       gaze timestamp (seconds)
            % @param    vldty   validity code
            % @param    p       pupil diamter (mm)
            % @param    c       eye-event code (see IvEventCode)
            % @param    d       distance
            % @param    v       velocity
            % @param    A       acceleration
            % @param    X
            % @param    Y
            %
            % @date     26/06/14
            % @author   PRJ
            %          
            obj.tmpBuff = [x, y, t, vldty, p, c, d, v, A, X, Y];
            obj.buffer.put(obj.tmpBuff);
        end
        
        function data = getLastN(obj, n, c, excludeRowsWithNaNs)
            % Retrieve last N samples from the buffer.
            % e.g., xy = getLastN(10, 1:2)            
            %
            % @param    n                       number of gaze samples
            % @param    c                       column indices
            % @param    excludeRowsWithNaNs     optional boolean (default=false)
            % @return   data                    data row(s) (or subsets if specific indices specified)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if nargin < 3
                c = []; % select all columns
            end
            if nargin < 4 || isempty(excludeRowsWithNaNs)
                excludeRowsWithNaNs = false;
            end
            
            data = obj.buffer.getLastN(min(obj.buffer.nrows,n), c); % hack??
            
            % remove any rows containing 1+ NaN values (if specifically
            % requested)
            if nargin >= 4 && excludeRowsWithNaNs
                data(any(isnan(data),2),:) = [];
            end
        end
        
        function [xy, t] = getLastKnownXY(obj, n, useRaw, allowNan)
            % Convenience wrapper for getLastN, that extracts the last N
            % [xy,t] values (raw or processed, with or without NaNs).
            %
            % @todo currently exlcuding NaNs will reduce the N items
            % returned - might be nice to return a constant number of
            % non-NaN elements(?).
            %
            % @param    n
            % @param    c
            % @param    excludeRowsWithNaNs
            % @return   xy
            % @return   t            
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if nargin < 2 || isempty(n)
                n = 1;
            end
            if nargin < 3 || isempty(useRaw)
                useRaw = false;
            end
            if nargin < 4 || isempty(allowNan)
                allowNan = true;
            end
            
            if useRaw
                columns = [10 11 3];
            else
                % use processed (e.g., calibrated, smoothed, interpolated) values
                columns = [1 2 3];
            end
            
            if allowNan
                maxN = obj.buffer.nrows();
            else
                maxN = obj.buffer.computeNnonNaN(columns);
            end
            if n > maxN 
                warning('IvDataLog.getLastKnownXY: n reduced (%i -> %i) to avoid index out-of-bounds', n, maxN);
                n = maxN;
            end
            if n == 0
                warning('IvDataLog.getLastKnownXY: no data stored - returning blank');
                xy = [];
                t = [];
                return
            end
            
            % get data
            if allowNan
                data = obj.buffer.getLastN(n, columns);
            else
                data = obj.buffer.getLastNnonNaN(n, columns);
            end
            
            % defensive - check that no NaNs comehow crept in (if
            % specifically prohibited)
            if ~allowNan && any(any(isnan(data),2))
                disp(data)
                error('data contains NaNs?')
            end
            
            % return values
            xy = data(:,1:2);
            t = data(:,3);
        end
        
        function data = getSinceT(obj, t, c)
            % Retrieve all samples from the buffer since time T.
            %
            % @param    t    	times (seconds)
            % @param    c     	column indices
            % @return   data    data row(s) (or subsets if specific indices specified)
            %
            % @date     26/06/14
            % @author   PRJ
            %            
            if nargin < 3
                c = []; % select all columns
            end
            data = obj.buffer.getAfterX(t,3,c);
        end
        
        function data = getTmpBuff(obj, c)
            % Get all samples that were added on the last cycle.
            %
            % @param    c   	column indices
            % @return   data    data row(s) (or subsets if specific indices specified)
            %
            % @date     26/06/14
            % @author   PRJ
            %            
            if nargin < 2
                data = obj.tmpBuff;
            else
                %if max(c) > size(obj.tmpBuff,2)
                if isempty(obj.tmpBuff)
                    data = [];
                else
                    data = obj.tmpBuff(:,c);
                end
            end
        end
        
        function [fn, fullFn] = save(obj, fn, saveGraphics)
            % Dump the buffer to an external file; prompt IvGraphic objects
            % to do likewise.
            %
            % @param    fn
            % @param    saveGraphics
            % @return   fn
            % @return   fullFn
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % parse
            if nargin < 3 || isempty(saveGraphics)
                saveGraphics = true;
            end
            
            % save to file
            headerInfo={'x','y','t','vldty','p','c','d','v','A','x_raw','y_raw', 'IvRawLog'};
            
            if nargin < 2 || isempty(fn)
                fn = obj.fnPattern;
            end
            fn=regexprep(fn, '\$time', datestr(now,30), 'ignorecase');
            fn =  regexprep(fn, '.csv$', '', 'once'); % strip off any '.csv' suffix
            
            % append IvRawLog file reference, and (re)add .csv suffix
            rawFullFn = ivis.log.IvRawLog.getInstance().fullFn;
            rawFn = ivis.log.IvRawLog.getInstance().fn;
            if ~isempty(rawFn)
                rawFn = regexprep(rawFn, '.raw$', '', 'once'); % strip off any '.raw' suffix
                fn = sprintf('%s__%s.csv', fn, rawFn);
            else % if no raw log extant
               fn = [fn '.csv'];
            end

            % add path
            fullFn = fullfile(obj.homeDir, fn);

            % create/open file
            fid = fopen(fullFn,'w+');
            if fid == -1
                warning('IvDataLog:FailedToOpenFile','Could not open file: %s', fullFn);
            else
                try
                    fprintf(fid, '%s', strjoin(',',headerInfo{:}));
                    % write data (1st line - also includes IvRawLog file ref)
                    fprintf(fid, '\n%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%s,',obj.buffer.get(1)',rawFullFn);
                    % write data (the rest)
                    if obj.buffer.nrows > 1
                        fprintf(fid, '\n%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,,',obj.buffer.get(2:obj.buffer.nrows)');
                    end
                    %fprintf(fid, '\n%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f,%1.2f',obj.buffer.get()');
                    fclose(fid);
                    fprintf('SAVED => %s\n',fullFn);
                catch ME
                    %fclose(fid);
                    fclose all;
                    rethrow(ME);
                end
            end
            
            % reset log
            obj.reset();
            
            % notify other (e.g., IvGraphic) objects to export their data
            % too
            if saveGraphics
                ivis.broadcaster.IvBroadcaster.getInstance().notify('SaveData', ivis.broadcaster.IvEventData(fullFn) );
            end
        end
        
        function [] = reset(obj)
            % Clear the buffer.
            %
            % @date     26/06/14
            % @author   PRJ
            %            
            obj.buffer.clear();
        end
        
        function n = getN(obj)
            % Get the N samples held in the buffer.
            %
            % @return   n   number of data rows in log
            %
            % @date     26/06/14
            % @author   PRJ
            %            
            n = obj.buffer.nrows();
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