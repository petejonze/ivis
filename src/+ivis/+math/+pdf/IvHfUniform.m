classdef IvHfUniform < ivis.math.pdf.IvHitFunc
	% Univariate uniform probabilty distribution function for the
	% likelihood-based classifier(s).
    %
    % IvHfUniform Methods:
    %   * IvHfUniform   - Constructor.
    %   * getPDF        - Get the probability of each value, x, given the probability density function.
    %   * getRand       - Generate a column vector of n random values, given the probability density function.
    %   * plot         	- Initialise the GUI element.
    %   * updatePlot  	- update the GUI element.
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
        MIN_VAL = 0.0000000000000000001; % for the sake of IvClassifierLL 
    end
    
    properties (GetAccess = public, SetAccess = private)
        % user specified parameters
        xmin    % minimum x value, in pixels
        xmax  	% maximum x value, in pixels
        % other internal parameters
        P_unifConstant % the constant value that is returned when xmin <= x <= xmax
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvHfUniform(xmin, xmax)
            % IvHfUniform Constructor. We'll assume in the variable names
            % that the values are 'x' values, but could equally well be
            % used in the vertical domain.
            %
            % @param    xmin    minimum x value, in pixels
            % @param    xmax    maximum x value, in pixels
            % @return   obj     IvHfUniform object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % validate params [25% bigger than actual screen by default]
            % ASSUME WIDTH
            if nargin < 1 || isempty(xmin)
                w = ivis.main.IvParams.getInstance().graphics.testScreenWidth;
                xmin = -round(w*.25); % 0;
            end
            if nargin < 2 || isempty(xmax)
                w = ivis.main.IvParams.getInstance().graphics.testScreenWidth;
                xmax = w + round(w*.25); % ivis.main.IvParams.getInstance().graphics.testScreenWidth;
            end
            
            % store params
            obj.xmin = xmin;
            obj.xmax = xmax;
            
            % calc P constant
            obj.P_unifConstant = unifpdf(1, xmin, xmax);
            
            %fprintf('IvHfUniform Constructor\n')
        end
        
        %% == METHODS =====================================================
        
        function [P,x] = getPDF(obj, x, varargin) % interface implementation     
            if nargin < 2 || isempty(x) % parse inputs
                x = obj.pdf_xy;
            end
            
            if size(x,2) == 2
                x = x(:,1);
            end
            x = ceil(x); % ceil since for 0, P = 0
            
            % calc bivartiate pdf
            inRange = x<=obj.xmin & x>=obj.xmax;
            P = inRange * obj.P_unifConstant + ~inRange * obj.MIN_VAL; 
        end

        function y = getRand(obj, n) % interface implementation        
            y = unifrnd(obj.xmin, obj.xmax, [n 1]);
        end

        function h = plot(obj, ~, color) % interface implementation     
            ylims = ylim();
            h = patch([obj.xmin obj.xmin obj.xmax obj.xmax], [ylims(1) ylims(2) ylims(2) ylims(1)], color);
            set(h,'FaceAlpha',.2);
        end
        
        function [] = updatePlot(obj, mu) %#ok interface implementation (do nothing)                
        end
    end
    
end