classdef IvHfGauss2D < ivis.math.pdf.IvHitFunc    
	% Bivariate Gaussian probabilty distribution function for the
	% likelihood-based classifier(s).
    %
    % IvHfGauss2D Methods:
    %   * IvHfGauss2D  	- Constructor.
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
% TODO: truncate
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================      
    
    properties (GetAccess = public, SetAccess = private)
        % user specified parameters
        muOffset = [0 0];   % additive bias in the distribution mean [x, y]
        sigma               % distribution standard deviations [x, y]
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvHfGauss2D(muOffset, sigma)
            % IvHfGauss2D Constructor.
            %
            % @param    muOffset    additive offset of gaussian (pixels)
            % @param    sigma       standard deviation of gaussian (pixels)
            % @return   obj         hiQualGUI object
            %
            % @date     26/06/14
            % @author   PRJ
            %

            % validate params
            if length(muOffset) ~= 2
                error('IvHfGauss2D:invalidInitParam','mu must contain 2 elements');
            end
            if length(muOffset) ~= length(sigma)
                error('IvHfGauss2D:invalidInitParam','mu dimensions must match sigma dimensions');
            end
            
            % store params
            obj.muOffset = muOffset;
            obj.sigma = sigma;
        end
        
        %% == METHODS =====================================================
        
        function [P,xy] = getPDF(obj, xy, mu) % interface implementation
            if nargin < 2 || isempty(xy) % parse inputs
                xy = obj.pdf_xy;
            end
            if size(mu,2) ~= 2
                error('IvHfGauss2D:invalidGetPDFParam','mu must contain 2 columns');
            end

            % calc bivartiate pdf
            P = mvnpdf(xy, bsxfun(@plus, mu, obj.muOffset), obj.sigma.^2);
        end

        function xy = getRand(obj, n, mu) % interface implementation          
            mu = mu + obj.muOffset;
            xy = mvnrnd(mu, obj.sigma.^2, n);
        end

        function h = plot(obj, mu, color, ~) % interface implementation
            if length(mu) ~= 2
                error('IvHfGauss2D:invalidGetPDFParam','mu must contain 2 elements');
            end

            % plot
            mu = mu + obj.muOffset;
            sd = [0.55 1.33 2.2]' * obj.sigma;
            h = ellipse(sd(:,1), sd(:,2), 0, mu(1), mu(2), color, 50, true);
            
            % ALT: higher quality (but slower) (?)
            % [P,xy] = obj.getPDF([],mu);
            % if isempty(minP)
            %     minP = min(P);
            % end
            % V = linspace(minP,max(P),7);
            % [~,h] = contourf(reshape(xy(:,1),IvHitFunc.N,IvHitFunc.N),reshape(xy(:,2),IvHitFunc.N,IvHitFunc.N),reshape(P,IvHitFunc.N,IvHitFunc.N), V);
            % ch = get(h,'child'); alpha(ch,0.2);
            % set(h, 'linecolor',color);
            
            % store
            obj.hPlot = h;
        end
        
        function [] = updatePlot(obj, mu) % interface implementation
                mu = mu + obj.muOffset;
                sd = [0.55 1.33 2.2]' * obj.sigma;
                [~,x,y] = ellipse(sd(:,1), sd(:,2), 0, mu(1), mu(2), 'r', 50, false);
                for i=1:length(obj.hPlot)
                    set(obj.hPlot(i), 'XData',x(:,i), 'YData',y(:,i));
                end
                
                % ALT: higher quality (but slower) (?)
                % [P,xy] = obj.getPDF([],mu);
                % set(obj.hPlot, 'ZData',reshape(P,IvHitFunc.N,IvHitFunc.N));
                % ch = get(obj.hPlot,'child'); alpha(ch,0.2)
        end
    end
    
end