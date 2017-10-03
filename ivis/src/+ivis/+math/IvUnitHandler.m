classdef (Sealed) IvUnitHandler < Singleton
    % Utility singleton for converting between distances on screen (cm, px, dg)
    %
    % Note that these conversions require setup-specific info, regarding the
    % dimensions of the monitor, the screen resolution, and the distance of the
    % observer to the screen. The singleton object should be informed about
    % these things upon initialisation.
    %
    % IvUnitHandler Methods:
	%   * IvUnitHandler	- Constructor.
    %   * px2cm         - Convert pixels to cm.
    %   * px2deg        - Convert pixels to degrees visual angle.
    %   * deg2px        - Convert degrees visual angle to pixels.
    %   * cm2px        	- Convert cm to pixels.
    %   * cm2deg       	- Convert cm to degrees visual angle.
    %   * deg2cm       	- Convert degrees visual angle to cm.    
    %
    % See Also:
    %   ivis.math.IvUnitHandler
    %
    % Example:
    %   runtests infantvision.tests -verbose
    %
    %   IvUH = ivis.math.IvUnitHandler(59.7, 2560, 60);
    %   IvUH.cm2deg(0.11,60) 
    %   IvUH.deg2px(3) 
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.1 PJ 02/2011 : used to develop commenting standards\n
    %   1.0 PJ 02/2011 : first_build
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
        screenWidth_px  % info
        screenWidth_cm  % djfksdhfajk
        viewingDist_cm  % dfdfdf
        
        % other internal parameters
        pixel_per_cm    % dfdfdf
        screenWidth_dg  % dfdfdf
        pixel_per_dg    % dfdfdf
        maxFreq_cpd     % dfdfdf
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
        
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvUnitHandler(screenWidth_cm, screenWidth_px, viewingDist_cm)
            % IvUnitHandler Constructor.
            %
            % @param    screenWidth_cm  monitor screen width, in cm
            % @param    screenWidth_px  monitor screen width, in px
            % @param    viewingDist_cm  distance from eye to monitor, in cm
            % @return   obj             IvUnitHandler object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.screenWidth_cm = screenWidth_cm;
            obj.screenWidth_px = screenWidth_px;
            obj.viewingDist_cm = viewingDist_cm;
            
            obj.pixel_per_cm = obj.screenWidth_px/obj.screenWidth_cm;
            obj.screenWidth_dg = 2*rad2deg(atan(obj.screenWidth_cm/(2*obj.viewingDist_cm)));
            obj.pixel_per_dg = obj.screenWidth_px/obj.screenWidth_dg;
            obj.maxFreq_cpd = obj.pixel_per_dg/2; % cycles per degree
        end
        
        %% == METHODS =====================================================
        
        function y = px2cm(obj, x_px)
            % Convert pixels to cm.
            %
            % @param    x_px
            % @return   y
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            y = x_px / obj.pixel_per_cm;
        end
                
        function y_px = cm2px(obj, x_cm)
            % Convert cm to pixels.
            %
            % @param    x_cm
            % @return   y_deg
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            y_px = x_cm * obj.pixel_per_cm;
        end
        
        function y = px2deg(obj, x_px, viewingDist_cm)
            % Convert pixels to degrees visual angle.
            %
            % @param    x_px
            % @param    viewingDist_cm
            % @return   y
            %
            % @date     26/06/14
            % @author   PRJ
            % 
            if nargin < 3 || isempty(viewingDist_cm)
                pixel_per_dg = obj.pixel_per_dg;  %#ok<*PROP>
            else
                screenWidth_dg = 2*rad2deg(atan(obj.screenWidth_cm/(2*viewingDist_cm)));
                pixel_per_dg = obj.screenWidth_px/screenWidth_dg;
            end
            
            y = x_px / pixel_per_dg;
        end
        
        function y = deg2px(obj, x_deg, viewingDist_cm)
            % Convert degrees visual angle to pixels.
            %
            % @param    x_deg
            % @param    viewingDist_cm
            % @return   y
            %
            % @date     26/06/14
            % @author   PRJ
            %    
            if nargin < 3 || isempty(viewingDist_cm)
                pixel_per_dg = obj.pixel_per_dg;
            else
                screenWidth_dg = 2*rad2deg(atan(obj.screenWidth_cm/(2*viewingDist_cm)));
                pixel_per_dg = obj.screenWidth_px/screenWidth_dg;
            end
            
            y = x_deg * pixel_per_dg;
        end
        
        function y_cm = deg2cm(obj, x_deg, viewingDist_cm)
            % Convert degrees visual angle to cm.
            %
            % @param    x_deg
            % @param    viewingDist_cm
            % @return   y_cm
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            if nargin < 3 || isempty(viewingDist_cm)
                viewingDist_cm = obj.viewingDist_cm;
            end
            
            y_cm = tan(deg2rad(x_deg/2)) * viewingDist_cm * 2;
        end
        
        function y_deg = cm2deg(obj, x_cm, viewingDist_cm)
            % Convert cm to degrees visual angle.
            %
            % @param    x_cm
            % @param    viewingDist_cm
            % @return   y_deg
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            if nargin < 3 || isempty(viewingDist_cm)
                viewingDist_cm = obj.viewingDist_cm;
            end
            
            y_deg = rad2deg(2*atan(x_cm/(viewingDist_cm*2)));
        end
    end
 

  	%% ====================================================================
    %  -----SINGLETON BLURB-----
    %$ ====================================================================

    methods (Static, Access = ?Singleton)
        function obj = getSetSingleton(obj)
            persistent singleObj
            if nargin > 0, singleObj = obj; end
            obj = singleObj;
        end
    end
    methods (Static, Access = public)
        function obj = getInstance()
            obj = Singleton.getInstanceSingleton(mfilename('class'));
        end
        function [] = finishUp()
            Singleton.finishUpSingleton(mfilename('class'));
        end
    end
    
end