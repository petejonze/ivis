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
    %   clearAbsAll; x = ivis.math.pdf.IvHfUniform2D([0 0], [100 100]), x.getPDF([-9991 -9991]), x.getPDF([-1 -1])
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
        % other internal parameters
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvHfUniform2D(minmaxBounds_px)
            % IvHfUniform2D Constructor.
            %
            % @param    minmaxBounds_px  4 element vector specifying min/max bounds [xmix_px ymin_px xmax_px ymax_px]
            % @return   obj   IvHfUniform2D object
            %
            % @date     26/06/14
            % @author   PRJ
            %

            % explicitly invoke superclass constructor. This will cause any
            % min/max values not stated explicitly to default to their
            % preset values (e.g., screen width +/- a margin of X%)
            if nargin < 1, minmaxBounds_px = []; end
            obj@ivis.math.pdf.IvHitFunc(minmaxBounds_px, 0);

            % create Probability Distribution objects (independent for x
            % and y domain)
            obj.probdistr_x = makedist('Uniform', obj.xmin_px, obj.xmax_px);
            obj.probdistr_y = makedist('Uniform', obj.ymin_px, obj.ymax_px);
        end
        
        %% == METHODS =====================================================

        function h = plot(obj, color) % interface implementation
            h = patch([obj.xmin_px obj.xmin_px obj.xmax_px obj.xmax_px], [obj.ymin_px obj.ymax_px obj.ymax_px obj.ymin_px], color);
            set(h,'FaceAlpha',.2);
        end
        
        function [] = update(obj, ~) %#ok interface implementation (do nothing)
        end
    end
    
end