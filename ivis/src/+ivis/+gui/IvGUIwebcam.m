classdef (Sealed) IvGUIwebcam < ivis.gui.IvGUIelement
	% Singleton for displaying webcam feed in a GUI.
    %
    % IvGUIwebcam Methods:
    %   * IvGUIwebcam   - Constructor.
	%   * update        - Update figure window.
    %
    % See Also:
    %   ivis.video.IvWebcam
    %
    % Example:
    %   none
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 07/2013 : first_build\n
    %
    % @todo add pausetoggle button(s)
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================

    properties (Constant)
        FIG_NAME = 'IvGUIwebcam';
    end
    
    properties (GetAccess = public, SetAccess = private)
        hImage
    end


    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvGUIwebcam(GUIidx, resolution)
            % IvWebcam Constructor.
            %
            % @param    GUIidx      GUI frame index
            % @param    resolution  expected image size (pixels)
            % @return   obj         IvVideo object
            %
            % @date     26/06/14             
            % @author   PRJ
            %  
            obj.init(GUIidx, resolution);
            
            obj.hImage = image( nan(resolution(2),resolution(1)) );
            set(gca, 'XTick', [], 'YTick', []);
        end
        
        %% == METHODS =====================================================
          
        function [] = update(obj, tex)
            % Update figure window.
            %
            % @param    tex     image texture
            %
            % @date     26/06/14             
            % @author   PRJ
            %    
            set(obj.hImage, 'CData', Screen('GetImage', tex));
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