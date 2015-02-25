classdef IvHfGUmix < ivis.math.pdf.IvHitFunc
	% Mixture of a univariate-Gaussian and uniform probabilty distribution
	% function for the likelihood-based classifier(s).
    %
    % A uniform pedestal can be useful for avoiding very small probability
    % values as gaze moves away from the mean.
    %
    % IvHfGUmix Methods:
    %   * IvHfGUmix     - Constructor.
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
          
    properties (GetAccess = public, SetAccess = private)
        % user specified parameters
        gaussRatio          % ratio of Gaussian/uniform (1 = full Gaussian)
        % other internal parameters
        hf_uniform          % handle to uniform distribution
    	hf_Gaussian         % handle to Gaussian distribution
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvHfGUmix(muOffset, sigma, gaussRatio, minVal, maxVal)
            % IvHfGUmix Constructor. This is a weighted additive mixture of
            % a truncated gaussian and uniform.
            %
            % @param    muOffset    additive offset of gaussian (pixels)
            % @param    sigma       standard deviation of gaussian (pixels)
            % @param    gaussRatio  ratio of gaussian PDF to uniform PDF
            % @param    minVal    	minimum uniform value, in pixels
            % @param    maxVal     	maximum uniform value, in pixels
            % @return   obj         IvHfGUmix object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % validate params
            if nargin < 5
                minVal = []; maxVal = [];
            end
            
            % construct individual pdf objects
            obj.hf_uniform = ivis.math.pdf.IvHfUniform(minVal, maxVal);
            obj.hf_Gaussian = ivis.math.pdf.IvHfGauss(muOffset, sigma);
            
            % store params
            obj.gaussRatio = gaussRatio;
        end
        
        %% == METHODS =====================================================
        
        function [P,xy] = getPDF(obj, xy, mu) % interface implementation
            P_uniform = obj.hf_uniform.getPDF(xy);
            P_Gaussian = obj.hf_Gaussian.getPDF(xy, mu);
            P = P_Gaussian*obj.gaussRatio + P_uniform*(1-obj.gaussRatio); % returns as a column
        end

        function xy = getRand(obj, n) %#ok interface implementation       
            error('Functionality not yet written');
            % calculate the cdf, invert it, and send in a uniform distribution.
            % http://en.wikipedia.org/wiki/Inverse_transform_sampling
            % http://www.mathworks.co.uk/matlabcentral/newsreader/view_thread/39887
        end
        
        function h = plot(obj, mu, color) % interface implementation
            h = obj.hf_Gaussian.plot(mu, color);
        end
        
        function [] = updatePlot(obj, mu) % interface implementation
            obj.hf_Gaussian.updatePlot(mu);
        end
    end
    
end