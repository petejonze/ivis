classdef IvHfGauss < ivis.math.pdf.IvHitFunc    
	% Univariate Gaussian probabilty distribution function for the
	% likelihood-based classifier(s).
    %
    % IvHfGauss Methods:
    %   * IvHfGauss     - Constructor.
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
    % @todo truncate
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 

    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================      
    
    properties (GetAccess = public, SetAccess = private)
        % user specified parameters
        muOffset = 0;   % additive bias in the distribution mean
        sigma           % distribution standard deviation
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvHfGauss(muOffset, sigma)
            % IvHfGauss Constructor.
            %
            % @param    muOffset    additive offset of gaussian (pixels)
            % @param    sigma       standard deviation of gaussian (pixels)
            % @return   obj         IvHfGauss object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            % validate params
            if length(muOffset) ~= 1
                error('IvHfGauss:invalidInitParam','mu must contain 1 element');
            end
            if length(muOffset) ~= length(sigma)
                error('IvHfGauss:invalidInitParam','mu dimensions must match sigma dimensions');
            end
            
            % store params
            obj.muOffset = muOffset;
            obj.sigma = sigma;
        end
        
        %% == METHODS =====================================================
        
        function [P,x] = getPDF(obj, x, mu) % interface implementation
            if nargin < 2 || isempty(x) % parse inputs
                x = obj.pdf_xy;
            end
            
            % validate
            if size(x,2) == 2
                x = x(:,1);
                warning('IvHfGauss:invalidGetPDFParam','x must only contain 1 column (discarding additional values)');
            end
            if size(mu,2) == 2
                mu = mu(:,1);
                warning('IvHfGauss:invalidGetPDFParam','mu must only contain 1 element (discarding additional values)');
            end
            
            P = normpdf(x, mu+obj.muOffset, obj.sigma);
        end
        
        function y = getRand(obj, n, mu) % interface implementation     
            mu = mu + obj.muOffset;
            y = normrnd(x, mu+obj.muOffset, obj.sigma, [n 1]);
        end

        function h = plot(obj, mu, color) % interface implementation
            if length(mu) == 2; % validate
                mu = mu(1);
                warning('IvHfGauss:invalidGetPDFParam','mu must only contain 1 element (discarding additional values)');
            end

            % draw vertical lines at z-unit intervals
            mu = mu + obj.muOffset;
            sd = [-8,-4,-1, 1,4,8] * obj.sigma; % [-2.2,-1.33,-0.55, 0.55,1.33,2.2]
            h = vline(mu+sd,color);

            % store
            obj.hPlot = h;
        end
        
        function [] = updatePlot(obj,mu)  % inhereted
            if length(mu) == 2; % validate
                mu = mu(1);
                warning('IvHfGauss:invalidGetPDFParam','mu must contain only 1 element (discarding additional values)');
            end
            
            % update lines
            mu = mu + obj.muOffset;
            sd = [-8,-4,-1, 1,4,8] * obj.sigma; % [-2.2,-1.33,-0.55, 0.55,1.33,2.2]
            for i=1:length(obj.hPlot)
                set(obj.hPlot(i), 'XData', [sd(i) sd(i)]+mu);
            end
        end
    end
    
end