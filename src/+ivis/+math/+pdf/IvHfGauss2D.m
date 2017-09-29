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
    %   clearAbsAll; x = ivis.math.pdf.IvHfGauss2D([0 0], [100 100]), x.getPDF([-9991 -9991]), x.getPDF([-1 -1])
    %  
    % Example:
    %   ivisDemo011_advancedClassifiers_noScreen()
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
        mu_px           % distribution location [x, y]
        sigma_px    	% distribution standard deviations [x, y]
        pedestal_p    	% 0<=x<=1 uniform pedestal to mix
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
          
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvHfGauss2D(mu_px, sigma_px, minmaxBounds_px, pedestalMix_p)
            % IvHfGauss2D Constructor.
            %
            % @param    mu_px               additive offset of gaussian (pixels) -- NB: this should usually be [0 0] to centre the distribution on the target
            % @param    sigma_px            standard deviation of gaussian (pixels)
            % @param    minmaxBounds_px     4 element vector specifying min/max bounds [xmix_px ymin_px xmax_px ymax_px]
            % @param    pedestalMix_p     	[0<=x<=1] uniform pedestal to mix with main distribution
            % @return   obj                 IvHfGauss2D object
            %
            % @date     26/06/14
            % @author   PRJ
            %

            % validate params
            if length(mu_px) ~= 2
                error('IvHfGauss2D:invalidInitParam','mu must contain 2 elements');
            end
            if length(mu_px) ~= length(sigma_px)
                error('IvHfGauss2D:invalidInitParam','mu dimensions must match sigma dimensions');
            end
            
         	% explicitly invoke superclass constructor. This will cause any
            % min/max values not stated explicitly to default to their
            % preset values (e.g., screen width +/- a margin of X%)
            if nargin < 3, minmaxBounds_px = []; end
            if nargin < 4 || isempty(pedestalMix_p), pedestalMix_p = 0.1; end
            obj@ivis.math.pdf.IvHitFunc(minmaxBounds_px, pedestalMix_p);

            % check for pedestal
            if obj.pedestalMix_p == 0
                warning('Not including a pedestal with a Gaussian is not recommended');
            end
            
            % create main Probability Distribution objects (independent for x
            % and y domain)
            obj.probdistr_x = truncate(makedist('Normal', mu_px(1), sigma_px(1)), obj.xmin_px, obj.xmax_px);
            obj.probdistr_y = truncate(makedist('Normal', mu_px(2), sigma_px(2)), obj.ymin_px, obj.ymax_px);
            
            % store params
            obj.mu_px = mu_px;
            obj.sigma_px = sigma_px;
            
        end
        
        %% == METHODS =====================================================
        
        function h = plot(obj, color) % interface implementation
            % plot
            mu = obj.mu_px;
            sd = [0.5 1 2]' * obj.sigma_px;
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
        
        function [] = update(obj, mu_px) % interface implementation
            if ~all([obj.probdistr_x.mu obj.probdistr_y.mu] == mu_px) % if anything has changed
                
                % update model params
                obj.probdistr_x.mu = mu_px(1);
                obj.probdistr_y.mu = mu_px(2);
                
                % update plot
                sd = [0.5 1 2]' * obj.sigma_px;
                [~,x,y] = ellipse(sd(:,1), sd(:,2), 0, mu_px(1), mu_px(2), 'r', 50, false);
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
    
end