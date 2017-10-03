classdef IvEventData < event.EventData
 	% Simple Event object wrapper specifying what properties an event
 	% should store (currently just a generic parameter called obj.Data).
    %
    % IvEventData Methods:
	%   * IvEventData - Constructor.
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
    
    properties (Access = public)
        Data % Event data
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvEventData(data)
           	% IvEventData Constructor.
            %
            % @param    data        info to be stored in obj.Data
            % @return   obj         IvEventData object 
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.Data = data;
        end
    end
    
end