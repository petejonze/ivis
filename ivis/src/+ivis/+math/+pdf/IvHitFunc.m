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

    properties (Constant)
        MIN_VAL = 0.0000000000000000001; % for the sake of IvClassifierLL
    end
    
    properties(GetAccess = public, SetAccess = protected)
        % (optinally) user specified parameters
        xmin_px    % minimum x value, in pixels
        ymin_px    % minimum y value, in pixels        
        xmax_px  	% maximum x value, in pixels
        ymax_px  	% maximum y value, in pixels   

        % key internal params
        probdistr_x	% as returned by makedist.m
        probdistr_y	% as returned by makedist.m
        pedestalMix_p = 0 % pedestal magnitude (0<=x<=1)
        pedestalConstants_xy = [0 0]
        hPlot      	% handle to GUI plot, as returned by figure.m
    end
    
    
    %% ====================================================================
    %  -----ABSTRACT METHODS-----
    %$ ====================================================================
          
    methods(Abstract)
                
     	% Initialise the GUI element.
        %
        % @param    color 	plot color
        % @return   h       plot handle
        %
        % @todo     change mu to be stored internally?
        % @date     26/06/14
      	% @author   PRJ
        %
        h = plot(obj, color)
        
        % Update the model params & GUI element.
        %
        % @param    mu_px	any bias in the distribution
        % @todo     change mu to be stored internally?
        %
        % @date     26/06/14
      	% @author   PRJ
        %
        update(obj, mu_px)
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)

        function [P,xy] = getPDF(obj, xy, w)
            % Get the probability of each value, x, given the probability
            % density function.
            %
            % @param    xy 	vector of values to evaluate PDF at
            % @param    w  	two-element vector specifying weights (0<=x<=1)
            %               for x/y distributions
            %               e.g., [1 1]
            % @return   y  	probability density values
            %
            % @date     26/06/14
            % @author   PRJ
            %

            % parse/check inputs
            if nargin<3 || isempty(w)
                w = [1 1];
            end
            if size(xy,2)~=2
                error('IvHitFunc:InvalidInput', 'xy must be a 2 column matrix')
            end
            
            % ensure largest relative weight == 1
            w = w./max(w);
            
            % calc bivartiate pdf
            if obj.pedestalMix_p > 0 % not actually necessary, but easier to follow this way
                inRange = (xy(:,1)<=obj.xmax_px & xy(:,1)>=obj.xmin_px & xy(:,2)<=obj.ymax_px & xy(:,2)>=obj.ymin_px);
                P = (obj.pedestalMix_p*inRange*obj.pedestalConstants_xy(1) + (1-obj.pedestalMix_p)*obj.probdistr_x.pdf(xy(:,1))).^w(1) ...
                    .*                                                                                                           ...
                    (obj.pedestalMix_p*inRange*obj.pedestalConstants_xy(2) + (1-obj.pedestalMix_p)*obj.probdistr_y.pdf(xy(:,2))).^w(2);
            else
                P = obj.probdistr_x.pdf(xy(:,1)).^w(1) .* obj.probdistr_y.pdf(xy(:,2)).^w(2);
            end
            
            % replace (e.g., out of range) values with min val
            P = max(obj.MIN_VAL, P);
        end

    end
    
    
    %% ====================================================================
    %  -----PROTECTED METHODS-----
    %$ ====================================================================
  
    methods (Access = protected)
        
     	%% == CONSTRUCTOR =================================================

        function obj = IvHitFunc(minmaxBounds_px, pedestalMix_p)
            % IvHitFunc Constructor.
            %
            % @param    minmaxBounds_px     4 element vector specifying min/max bounds [xmix_px ymin_px xmax_px ymax_px]
            % @param    pedestalMix_p     	[0<=x<=1] uniform pedestal to mix with main distribution
            % @return   obj                 IvHitFunc object
            %
            % @date     26/06/14
            % @author   PRJ
            %    
            
            % set bounds: substitute defaults, and store vals [extent 15% bigger than actual screen by default]
            if isempty(minmaxBounds_px)
                w = ivis.main.IvParams.getInstance().graphics.testScreenWidth;
                h = ivis.main.IvParams.getInstance().graphics.testScreenHeight;
                obj.xmin_px = -round(w * .15);
                obj.ymin_px = -round(h * .15);
                obj.xmax_px = w + round(w * .15);
                obj.ymax_px = h + round(h*.15);
            else
                if length(minmaxBounds_px) ~= 4
                    error('minmaxBounds_px should be a 4 elemebt vector')
                end
                obj.xmin_px = minmaxBounds_px(1);
                obj.ymin_px = minmaxBounds_px(2);
                obj.xmax_px = minmaxBounds_px(3);
                obj.ymax_px = minmaxBounds_px(4);
            end
            
            % set pedestal
            if pedestalMix_p > 0
                % compute pedestal constant PDF values
                tmp_probdistr_x = makedist('Uniform', obj.xmin_px, obj.xmax_px);
                tmp_probdistr_y = makedist('Uniform', obj.ymin_px, obj.ymax_px);
                x = tmp_probdistr_x.pdf(mean([obj.xmin_px obj.xmax_px]));
                y = tmp_probdistr_y.pdf(mean([obj.ymin_px obj.ymax_px]));
                
                % store
                obj.pedestalConstants_xy = [x y];
                obj.pedestalMix_p      = pedestalMix_p;
            end
            
        end
    end
    
end