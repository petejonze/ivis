classdef IvPrior < ivis.graphic.IvScreenObject
	% Degenerate graphic object that doesn't move or resize.
    %
    % IvPrior Methods:
    %   * IvPrior   - Constructor.
	%   * getXY     - Dummy method; does nothing.
    %   * getX      - Dummy method; does nothing.
    %   * getY      - Dummy method; does nothing.
    %   * reset     - Dummy method; does nothing.
    %   * draw      - Dummy method; does nothing.
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
    % @todo     with the introduction of the stationary flag in the IvGraphic class, this is rapidly becoming redundant. Maybe should subclass IvGraphic?
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
        name = 'prior'
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================

        function obj = IvPrior()
            % IvPrior Constructor.
            %
            % @return   obj         IvPrior object
            %
            % @date     26/06/14
            % @author   PRJ
            %   
            
            % call superclass constructor
            obj@ivis.graphic.IvScreenObject(ivis.graphic.IvScreenObject.TYPE_PRIOR);
            
            % validate params
            % none
        end
        
        %% == METHODS =====================================================
        
        function xy = getXY(~, ~) % interface implementation
            % Dummy method; does nothing
            %
            % @return   xy  empty array
            %
            % @date     26/06/14
            % @author   PRJ
            %               
            xy = [];
        end
        
        function x = getX(~, ~) % interface implementation
            % Dummy method; does nothing
            %
            % @return   xy  empty array
            %
            % @date     26/06/14
            % @author   PRJ
            %               
            x = [];
        end
        
        function y = getY(~, ~) % interface implementation
            % Dummy method; does nothing
            %
            % @return   xy  empty array
            %
            % @date     26/06/14
            % @author   PRJ
            %               
            y = [];
        end
        
        function [] = reset(~, ~, ~, ~, ~) % interface implementation
            % Dummy method; does nothing
            %
            % @date     26/06/14
            % @author   PRJ
            %              
        end  
        
        function [] = draw(~, varargin) % interface implementation
            % Dummy method; does nothing
            %
            % @date     26/06/14
            % @author   PRJ
            %         
        end
    end
    
end