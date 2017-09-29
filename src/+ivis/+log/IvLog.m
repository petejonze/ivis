classdef (Abstract) IvLog < Singleton
	% Abstract interface for data storage.
    %
    % IvLog Methods:
	%   none
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
    %   1.0 PJ 06/2014 : first_build\n
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================

    properties (GetAccess = public, SetAccess = protected)
        homeDir
        fnPattern
    end
    
        
    %% ====================================================================
    %  -----STATIC METHODS (protected)-----
    %$ ====================================================================
    
    methods (Static, Access = public)
        
        function fullFn = validateFn(fullFn, logType)
            % Confirm whether file can be found, and append path if
            % necessary. If not initially found based on the specified file
            % name, will search again inside the default logs directory
            % (i.e., in case user omited to supply the path).
            %
            % @param    fullFn      the file name, either including the path, or will search in the appropriate ivis/logs subdirectory
            % @param    logType     'raw' or 'data'
            % @return   fullFn      the file name, including the path
            %
            % @date     26/06/14
            % @author   PRJ
            %            
            if ~exist(fullFn, 'file')
                % try to fix by prepending default log path
                fullerFn = fullfile(ivisdir(), 'logs', logType, fullFn);
                if ~exist(fullerFn, 'file')
                    error('file not found: %s\nNor could we find: %s', fullFn, fullerFn);
                else
                    fullFn = fullerFn;
                end
            end
        end
    end

end