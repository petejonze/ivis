classdef (Sealed) IvEyeTribe < ivis.eyetracker.IvDataInput
    % Singleton instantiation of IvDataInput, designed not to be driven by
    % an EyeTribe eyetracker
    %
   	% IvEyeTribe Methods:
    %   * IvEyeTribe   - Constructor.
    %   * connect	- Establish a link to the eyetracking hardware.
    %   * reconnect	- Disconnect and re-establish link to eyetracker.
    %   * refresh  	- Query the eyetracker for new data; process and store.
    %   * flush   	- Query the eyetracker for new data; discard.
    %   * validate  - Validate initialisation parameters.
    %
   	% IvEyeTribe Static Methods:  
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
        NAME = 'IvEyeTribe';
    end
    properties (GetAccess = private, SetAccess = private)
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods(Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvEyeTribe()
            % IvEyeTribe Constructor.
            %
            % @return   IvEyeTribe
            %
            % @date     21/10/14
            % @author   PRJ
            %
            
            % n.b., superclass IvDataInput will already have stored all the
            % necessary parameters and commencing logging, etc., if so
            % requested

            % connect
            obj.connect();
        end
        
        function delete(obj) %#ok<INUSD>
            % IvEyeTribe Destructor.
            %
            % @date     21/10/14
            % @author   PRJ
            %
            try
                ETT_stoptracking();
            catch ME
                fprintf('FAILED TO STOP TRACKING???\n');
                disp(ME)
            end
            
            try
                ETT_disconnect();
            catch ME
                fprintf('FAILED TO DISCONNECT EYETRACKER???\n');
                disp(ME)
            end
        end
        

        %% == METHODS =====================================================
        
        function connect(obj) %  interface implementation
            
            fprintf('Connecting to EyeTribe tracker...');
            ETT_connect();
            
            % commence eye tracking
            fprintf('   commencing tracking...');
            ETT_starttracking()

            % clear any outstanding data
            fprintf('   flushing...');
            obj.flush();
            
            % ready to use
            fprintf('   tracking\n');            
        end
        
        function n = reconnect(obj) %#ok  interface implementation
            try
                ETT_stoptracking();
                ETT_disconnect();
            catch ME
                rethrow(ME)
            end
            obj.connect();
        end
        
        function n = refresh(obj, logData) %#ok  interface implementation           
            data = ETT_getdata();
            
% #####            
% parse and deal with data somehow            
%         end
%         
%         function n = flush(obj) %#ok  interface implementation              
%             data = ETT_getdata();
%             
% ######            
n = get_size_somehow
        end
    end

    
    %% ====================================================================
    %  -----PROTECTED STATIC METHODS-----
    %$ ====================================================================    
    
    methods (Static, Access = protected)
        
        function [] = validate(varargin) % interface implementation           
            % ensure that SDK installed
            if exist('ETT_connect','file')~=2
                error('ETT_connect.m not found on path. Please ensure that the EyeTribe Matlab wrapper is installed');
            end
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