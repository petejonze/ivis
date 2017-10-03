classdef (Sealed) IvDummy < ivis.eyetracker.IvDataInput
    % Singleton instantiation of IvDataInput, designed not to be driven by
    % anything, but to flag up when/by-what methods are called.
    %
    %   Can be useful when trying to understand how Ivis works.
    %
   	% IvDummy Methods:
    %   * IvDummy   - Constructor.
    %   * connect	- Establish a link to the eyetracking hardware.
    %   * reconnect	- Disconnect and re-establish link to eyetracker.
    %   * refresh  	- Query the eyetracker for new data; process and store.
    %   * flush   	- Query the eyetracker for new data; discard.
    %   * validate  - Validate initialisation parameters.
    %
   	% IvDummy Static Methods:  
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
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (Constant)
        NAME = 'IvDummy';
        RAWLOG_PRECISION = 'single'; % 'double'
        RAWLOG_NCOLS = 3 % 2 + CPUtime
        RAWLOG_HEADERS = {'x','y','CPUtime'};    
    end
    properties (GetAccess = private, SetAccess = private)
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods(Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvDummy()
            dbs = dbstack();
            fprintf('\n\n    **this is where you would construct/initialise a (Singleton) instance of your eyetracker object**\n    |\n    |- Calling history: ')
            fprintf('%s <- ', dbs.name)
            fprintf('\n\n');
        end

        %% == METHODS =====================================================
        
        function connect(obj) %#ok  interface implementation
            dbs = dbstack();
            fprintf('\n\n    **this is where you would attempt to connect to the tracker**\n    |\n    |- Calling history: ')
            fprintf('%s <- ', dbs.name)
            fprintf('\n\n');
        end
        
        function n = reconnect(obj) %#ok  interface implementation       
            dbs = dbstack();
            fprintf('\n\n    **this is where you would attempt to disconnect/reconnect to the tracker**\n    |\n    |- Calling history: ')
            fprintf('%s <- ', dbs.name)
            fprintf('\n\n');
        end
        
        function n = refresh(obj, logData) %#ok  interface implementation           
            dbs = dbstack();
            fprintf('\n\n    **this is where you would query the hardware for (and return any) gaze coordinates (etc.). Set logData to false to prevent the new data being logged**\n    |\n    |- Calling history: ')
            fprintf('%s <- ', dbs.name)
            fprintf('\n\n');
        end
        
        function n = flush(obj) %#ok  interface implementation              
            dbs = dbstack();
            fprintf('\n\n    **this is where you would clear any buffered data**\n    |\n    |- Calling history: ')
            fprintf('%s <- ', dbs.name)
            fprintf('\n\n');
        end
    end

    
    %% ====================================================================
    %  -----PROTECTED STATIC METHODS-----
    %$ ====================================================================    
    
    methods (Static, Access = protected)
        
        function [] = validate(varargin) % interface implementation           
            dbs = dbstack();
            fprintf('\n\n    **this is where you would validate the eyetracker parameter inputs**\n    |\n    |- Calling history: ')
            fprintf('%s <- ', dbs.name)
            fprintf('\n\n');
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