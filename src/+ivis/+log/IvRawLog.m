classdef (Sealed) IvRawLog < ivis.log.IvLog
	% Responsibile for outputting raw eye-tracking data to a binary (.raw).
    % file
    %
    % IvRawLog Methods:
    %   * IvRawLog  - Constructor.
	%   * open      - Open a new output stream (writes directly to disc).
    %   * write     - Write new samples to the output (.raw) file.
    %   * close     - Close the output (.raw) file.
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
        fid
        fn
        fullFn
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvRawLog(homeDir, fnPattern)
            % IvRawLog Constructor.
            %
            % @param    homeDir
            % @param    fnPattern
            % @return   obj         IvDataLog object
            %
            % @date     26/06/14
            % @author   PRJ
            %             

            obj.homeDir = regexprep(homeDir, '\$iv', escape(ivis.main.IvParams.getInstance().toolboxHomedir), 'ignorecase');
% obj.homeDir = 'D:\Dropbox\MatlabToolkits\ivis\logs\raw'      
            % check that raw log dir exists
            if ~exist(obj.homeDir, 'dir')
                error('IvRawLog:FailedToInit','Specified raw log directory could not be found: %s ', obj.homeDir);
            end
            
            obj.fnPattern = fnPattern;
        end
        
        function [] = delete(obj)
            % IvRawLog Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %    
            
            % end log if file currently open
            try
                if ~isempty(obj.fid)
                    obj.close();
                end
            catch ME
                disp(ME)
            end
        end

        %% == METHODS =====================================================
        
        function [fid, fullFn] = open(obj, fdir, fn)
            % Open a new output stream (writes directly to disc).
            %
            % @param    fdir
            % @param    fn
            % @return   fid
            % @return   fullFn
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % ensure no log already extant
            if ~isempty(obj.fid)
                error('IvRawLog:FailedToStartLog','Could not open new log, since one is already extant. Please use close() before open()')
            end
            
            % parse inputs
            if nargin < 2 || isempty(fdir)
                fdir = obj.homeDir;
            end
            if nargin < 3 || isempty(fn)
                fn = regexprep(obj.fnPattern, '\$time', datestr(now,30), 'ignorecase');
            end
            
        	% replace any wild-cards, as appropriate
            fn = regexprep(fn, '\$time', datestr(now,30), 'ignorecase');
            
            % ensure '.raw' extension exists (if not, add suffix)
            fn =  regexprep(fn, '.raw$', '', 'once'); % strip off any '.csv' suffix
            fn = [fn '.raw'];
            
            % append path to filename
            fullFn = fullfile(fdir, fn);
            
            % open file
            fid = fopen(fullFn, 'W'); % W rather than w (perhaps marginally faster?)
            
            if fid == -1
                error('IvRawLog:FailedToStartLog','Failed to create log (%s)', fullfile(fdir, fn))
            end
            
            % store
            obj.fid = fid; 
            obj.fn = fn;
            obj.fullFn = fullFn;
        end
        
        function [] = write(obj, dat, precision)
            % Write new samples to the output (.raw) file.
            %
            % @param    dat
            % @param    precision
            %
            % @date     26/06/14
            % @author   PRJ
            %
            fwrite(obj.fid, dat', precision);
        end
        
        function [] = close(obj)
            % Close the output (.raw) file.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if isempty(obj.fid)
                error('IvRawLog:FailedToCloseLog','Could not close raw log, since none currently open. Please use open() before close()')
            end
            
            % fprintf('Closing raw log..\n');
            fclose(obj.fid);
            
            % delete file if empty
            fileInfo = dir(obj.fullFn);
            if fileInfo.bytes == 0
                delete(obj.fullFn);
            end
            
            % remove handle reference
            obj.fid = [];
            obj.fn = [];
            obj.fullFn = [];
        end

    end

    
    %% ====================================================================
    %  -----STATIC METHODS (?IvDataInput)-----
    %$ ====================================================================
    
    methods (Static, Access = ?ivis.eyetracker.IvDataInput)
        
        function data = read(fullFn, precision, expectedNCols)
            % Load in binary data from a .raw file; this should be called
            % from the appropriate IvDataInput class, which will be
            % required to parse the data stream.
            %
            % @param    fullFn          .raw file name, including path
            % @param    precision       level of numeric precision (e.g., 'single')
            % @param    expectedNCols   number of columns per data row
            % @return   data            the data matrix
            %
            % @date     26/06/14
            % @author   PRJ
            %            
            
            % validate file name (and append suffix if necessary)
            fullFn = ivis.log.IvLog.validateFn(fullFn, 'raw');
            
            % open the file
            ffid = fopen(fullFn, 'r' );
            if ffid == -1
                error('IvRawLog:IOError','Failed to open log file (%s)', fullFn)
            end
            
            % read the data
            try
                data = fread(ffid, precision);
            catch ME % ensure graceful fail
                fclose(ffid);
                rethrow(ME);
            end
            
            % close file normally
            fclose(ffid);
            
            % validate data
            nRows = numel(data)/expectedNCols;
            if mod(nRows,1)~=0
                error('IvRawLog:InvalidLogFormat', 'nRows (%1.2f) must be an integer. Data not stored in correct format?\n\n   file: %s\n   Expected nCols: %1.2f', nRows, fullFn, expectedNCols);
            end
            
            % reshape data into a matrix
            data = reshape(data, expectedNCols, nRows)';
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