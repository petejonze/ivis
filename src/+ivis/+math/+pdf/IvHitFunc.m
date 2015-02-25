classdef (Abstract) IvHitFunc < handle
	% Probabilty distribution functions for the likelihood-based
	% classifier(s).
    %
    % IvHitFunc Methods:
	%   * IvHitFunc - Constructor.
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

    properties(Access = protected)
        N = 20  % number of points used to compute pdf_xy with
        pdf_xy  % precache an evaluation of the PDF at some set values, for easy visualisation
        hPlot   % handle to GUI plot
    end
    
    
    %% ====================================================================
    %  -----ABSTRACT METHODS-----
    %$ ====================================================================
          
    methods(Abstract)
        
        % Get the probability of each value, x, given the probability
        % density function.
        %
        % @param    x           vector of values to evaluate PDF at
        % @param    varargin    any additional values the subclass requires
        % @return   y           probability density values
        %
      	% @date     26/06/14
      	% @author   PRJ
        %
        P = getPDF(obj, x, varargin)

        % Generate a column vector of n random values, given the probability
        % density function.
        %
        % @param    n   number of random values of generate (integer)
        % @return   xy  random values [n by 1], or [n by 2], in size
        %
        % @date     26/06/14
     	% @author   PRJ
        %
        xy = getRand(obj, n)
        
     	% Initialise the GUI element.
        %
        % @param    mu      any bias in the distribution
        % @param    color 	plot color
        % @return   h       plot handle
        %
        % @todo     change mu to be stored internally?
        % @date     26/06/14
      	% @author   PRJ
        %
        h = plot(obj, mu, color)
        
        % Update the GUI element.
        %
        % @param    mu      any bias in the distribution
        % @todo     change mu to be stored internally?
        %
        % @date     26/06/14
      	% @author   PRJ
        %
        updatePlot(obj, mu)
    end
    
    
    %% ====================================================================
    %  -----PROTECTED METHODS-----
    %$ ====================================================================
  
    methods (Access = protected)
        
     	%% == CONSTRUCTOR =================================================

        function obj = IvHitFunc()
            % IvHitFunc Constructor.
            %
            % @return   obj  IvHitFunc object
            %
            % @date     26/06/14
            % @author   PRJ
            %    
            params = ivis.main.IvParams.getInstance();
            [X1,X2] = meshgrid(linspace(1, params.graphics.testScreenWidth, obj.N)', linspace(1, params.graphics.testScreenHeight, obj.N)');
            obj.pdf_xy = [X1(:) X2(:)];
        end
    end
    
end