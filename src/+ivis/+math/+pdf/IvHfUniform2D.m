classdef IvHfUniform2D < ivis.math.pdf.IvHitFunc
	% Bivariate uniform probabilty distribution function for the
	% likelihood-based classifier(s).
    %
    % IvHfUniform2D Methods:
    %   * IvHfUniform2D - Constructor.
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
        ymin    % minimum y value, in pixels        
        xmax  	% maximum x value, in pixels
        ymax  	% maximum y value, in pixels        
        % other internal parameters
        P_unifConstant % the constant value that is returned when xmin <= x <= xmax
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvHfUniform2D(xmin, ymin, xmax, ymax)
            % IvHfUniform2D Constructor.
            %
            % @param    xmin  minimum x value, in pixels
            % @param    ymin  minimum y value, in pixels
            % @param    xmax  maximum x value, in pixels
            % @param    ymax  maximum y value, in pixels
            % @return   obj   IvHfUniform2D object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % validate params [25% bigger than actual screen by default]
            if nargin < 1 || isempty(xmin)
                w = ivis.main.IvParams.getInstance().graphics.testScreenWidth;
                xmin = -round(w*.25); % 0;
            end
            if nargin < 2 || isempty(ymin)
                h = ivis.main.IvParams.getInstance().graphics.testScreenHeight;
                ymin = -round(h*.25); % 0;
            end
            if nargin < 3 || isempty(xmax)
                w = ivis.main.IvParams.getInstance().graphics.testScreenWidth;
                xmax = w + round(w*.25); % ivis.main.IvParams.getInstance().graphics.testScreenWidth;
            end
            if nargin < 4 || isempty(ymax)
                h = ivis.main.IvParams.getInstance().graphics.testScreenHeight;
                ymax = h + round(h*.25); % ivis.main.IvParams.getInstance().graphics.testScreenHeight;
            end
            
            % store params
            obj.xmin = xmin;
            obj.ymin = ymin;
            obj.xmax = xmax;
            obj.ymax = ymax;
            
            % calc P constant
            obj.P_unifConstant = pdf('unid', 1, xmax, xmin) * pdf('unid', 1, ymax, ymin);
        end
        
        %% == METHODS =====================================================
        
        function [P,xy] = getPDF(obj, xy, varargin) % interface implementation
            if nargin < 2 || isempty(xy) % parse inputs
                xy = obj.pdf_xy;
            end
            xy = ceil(xy); % ceil since for 0, P = 0
            
            % calc bivartiate pdf
            inRange = (xy(:,1)<=obj.xmax & xy(:,1)>=obj.xmin & xy(:,2)<=obj.ymax & xy(:,2)>=obj.ymin);
            P = inRange * obj.P_unifConstant + ~inRange * obj.MIN_VAL;
        end

        function xy = getRand(obj, n) % interface implementation
            xy = [unifrnd(obj.xmin, obj.xmax, [n 1]) unifrnd(obj.ymin, obj.ymax, [n 1])];
        end
        
        function h = plot(obj, ~, color) % interface implementation
            h = patch([obj.xmin obj.xmin obj.xmax obj.xmax], [obj.ymin obj.ymax obj.ymax obj.ymin], color);
            set(h,'FaceAlpha',.2);
        end
        
        function [] = updatePlot(obj, mu) %#ok interface implementation (do nothing)
        end
    end
    
end