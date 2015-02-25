classdef IvGraphicCompound < IvScreenObject
	% Conglomoration of IvGraphic objects, all of which should be treated
	% as one 'unit' by the classifier.
    %
    % IvGraphicCompound Methods:
    %   * IvGraphicCompound - Constructor.
    %   * draw              - Forward the draw() command onto all constituent IvGraphic objects.
    %
    % See Also:
    %   ivis.graphic.IvGraphic
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
        % user specified parameters
        name
        graphicObjs
        nGraphicObjs
    end
    
    properties (GetAccess = public, SetAccess = public)
        plotColour = 'b'
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvGraphicCompound(name, varargin)
            % IvGraphicCompound Constructor.
            %
            % @param    name                compound graphic name
            % @param    varargin            IvGraphic object
            % @return   IvGraphicCompound   IvGraphicCompound object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % call superclass constructor
            obj@IvScreenObject(IvScreenObject.TYPE_GRAPHICCOMPOUND)
            
            % validate params
            obj.name = name;
            obj.graphicObjs = varargin;
            obj.nGraphicObjs = length(obj.graphicObjs);
        end
        
        %% == METHODS =====================================================
        
        function [] = draw(obj, winhandle, varargin)
            % Forward the draw() command onto all constituent IvGraphic
            % objects.
            %
            % @param  	winhandle   PTB screen handle
            % @param  	varargin    optional drawing parameters
            %
            % @date     26/06/14
            % @author   PRJ
            %     
            
            % parse inputs
            if nargin < 2 || isempty(winhandle)
                winhandle = [];
            end
            
            % execute
            for i = 1:obj.nGraphicObjs
                obj.graphicObjs{i}.draw(winhandle, varargin{:});
            end
        end
        
        function [] = reset(obj)
            % Forward the reset() command onto all constituent IvGraphic
            % objects.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % execute
            for i = 1:obj.nGraphicObjs
                obj.graphicObjs{i}.reset();
            end
        end
    end

end