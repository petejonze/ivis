classdef (Sealed) IvManual < ivis.eyetracker.IvDataInput
    % Singleton instantiation of IvDataInput, designed to be updated manually
    % by the user
    %
    % If an input file is specified during construction then the file will
    % be parsed and entire content processed immediately.
    % Alternatively/additionally, further input can be entered at any
    % subsequent point.
    %
   	% IvManual Methods:
    %   * IvManual  - Constructor.
    %   * connect	- Establish a link to the eyetracking hardware.
    %   * reconnect	- Disconnect and re-establish link to eyetracker.
    %   * refresh  	- Query the eyetracker for new data; process and store.
    %   * flush   	- Query the eyetracker for new data; discard.
    %   * readRawLog- Parse data stored in a .raw binary file (hardware-brand specific format).
    %   * validate  - Validate initialisation parameters.
    %
   	% IvManual Static Methods:    
    %   * initialiseSDK	- ffffff.
    %   * readRawLog    - Parse data stored in a .raw binary file (hardware-brand specific format).
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
    %    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %
    
    %% ====================================================================
    %  -----PROPERTIES-----%
    %$ ====================================================================
    
    properties (Constant)
        NAME = 'IvManual';
    end
    
    properties (GetAccess = public, SetAccess = private)
        counter = 1;
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods(Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvManual(~)
            % IvManual Constructor.
            %
            % @return   obj         IvManual object
            %
            % @version  28/02/13 [PJ]
            %
        end
        
        %% == METHODS =====================================================
        
        function [] = connect(obj) %#ok  interface implementation
        end
        
        function [] = reconnect(obj) %#ok  interface implementation
        end
        
        function n = refresh(obj, x, y, t, v, p)
            % REFRESH blaaaah.
            %
            % Only the X and Y vectors are absolutely required.
            %
            % @param    x
            % @param    y
            % @param    t
            % @param    v
            % @param    p
            % @return   n
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            n = length(x);
            if nargin < 4 || isempty(t)
                t = (obj.counter:obj.counter+n-1)';
                obj.counter = obj.counter + n;
            end
            if nargin < 5 || isempty(v)
                v = nan(n,1);
            end
            if nargin < 6 || isempty(p)
                p = nan(n,1);
            end
            
            %-----------Send Data to Buffer------------------------------
            % send the data to an internal buffer which handles filtering
            % and feature extraction, and then passes the data along to the
            % central DataLog and any relevant GUI elements
            obj.processData(x,y,t,v,p);
        end
        
        function n = flush(~) % interface implementation
            n = NaN;
        end
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================
    
    methods (Static, Access = public)
        
        function [] = readRawLog(fullFn) %#ok  interface implementation
            error('Functionality not defined for IvManual');
        end
    end
    
end