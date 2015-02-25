classdef (Abstract) IvScreenObject < ivis.broadcaster.IvListener
    % Generic object that may appear on the screen (primarily an object of
    % type IvGraphic).
    %
    % IvScreenObject Methods:
    %   * IvScreenObject	- Constructor.
	%   * type              - Returns screen object code (e.g., TYPE_PRIOR, or TYPE_GRAPHIC).
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
    
    properties (Constant)
        TYPE_PRIOR = 1
        TYPE_GRAPHIC = 2
        TYPE_GRAPHICCOMPOUND = 3
    end
    
    properties (Access = private)
        TYPE
    end
    
    methods(Abstract)
        
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
        reset(obj, x, y, width, height)
        
        % Flip an associated texture onto a PTB screen 
        %
        % @return   type_code
        %
        % @date     26/06/14
        % @author   PRJ
        %
        draw(obj, winhandle, varargin)
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        function type_code = type(obj)
            % Returns screen object code (e.g., TYPE_PRIOR, or
            % TYPE_GRAPHIC).
            %
            % @return   type_code
            %
            % @date     26/06/14
            % @author   PRJ
            %
            type_code = obj.TYPE;
        end
    end
    
    
    %% ====================================================================
    %  -----PROTECTED METHODS-----
    %$ ====================================================================
    
    methods(Access = protected)
        
        function obj = IvScreenObject(type)
            % IvScreenObject Constructor.
            %
            % @return   IvScreenObject
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.TYPE = type;
        end
    end
    
end