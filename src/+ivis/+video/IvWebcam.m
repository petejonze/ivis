classdef (Sealed) IvWebcam < Singleton & ivis.broadcaster.IvListener
	% Webcam singleton for displaying webcam feed in a GUI.
    %
    % IvWebcam Methods:
	%   * IvWebcam	- Constructor.    
	%   * draw   	- Retrieve the latest image from the video input buffer, and draw it onto the GUI.
    %
    % IvWebcam Static Methods:
    %   * listDevices - Wrapper for Screen('VideoCaptureDevices')
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
    %   1.0 PJ 07/2013 : first_build\n
    %
    % @todo: check if specified deviceId is valid
    % @todo: handle device detection
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================

    properties (GetAccess = public, SetAccess = private)
        winhandle       % handle to PTB screen
        videoGrabber 	% handle to webcam interface
        resolution      % webcam resolution [w h] pixels
        guiElement      % handle to Ivis GUI element
    end


    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvWebcam(GUIidx, deviceId)
            % IvWebcam Constructor.
            %
            % @param    GUIidx      Ivis GUI element index
            % @param    deviceId    Optional id of the webcam hardware
            % @return   obj         IvWebcam object
            %             
            % @date     26/06/14                          
            % @author   PRJ
            %  
            fprintf('IVIS: initialising webcam...\n');
                
            if nargin < 2 || isempty(deviceId)
                deviceId = [];
            end 
            
            % Open connection to device
            obj.winhandle = ivis.main.IvParams.getInstance().graphics.winhandle;
            obj.videoGrabber = Screen('OpenVideoCapture', obj.winhandle, deviceId);
            
            % Get a frame to calculate image resolution 
            tex = 0;
            startTime = GetSecs();
            while tex == 0
                tex=Screen('GetCapturedImage', obj.winhandle, obj.videoGrabber, 1);
                if (tex>0)
                    texrect = Screen('Rect', tex);
                    obj.resolution = texrect(3:4);
                    break
                end
                if (GetSecs()-startTime) > 5
                    error('timeout');
                end
            end
            
            if ~isempty(GUIidx)
                obj.guiElement = ivis.gui.IvGUIwebcam(GUIidx, obj.resolution);
            end

            Screen('StartVideoCapture', obj.videoGrabber, 24, 1);
            obj.start();
        end
        
        function [] = delete(obj)
            Screen('CloseVideoCapture', obj.videoGrabber);
        end
        
        %% == METHODS =====================================================
          
        function [] = draw(obj,~,~)
            % Retrieve the latest image from the video input buffer, and
            % draw it onto the GUI.
            %           
            % @date     26/06/14                          
            % @author   PRJ
            %     
            tex = Screen('GetCapturedImage', obj.winhandle, obj.videoGrabber, 1);
            if (tex>0)
                obj.guiElement.update(tex);
                Screen('Close', tex); % release texture to prevent clogging up the system memory
            end
        end
    end
    
    
  	%% ====================================================================
    %  -----STATIC METHODS-----
    %$ ====================================================================
    
    methods (Static, Access = public)
        
        function [] = listDevices()
            % Wrapper for Screen('VideoCaptureDevices').
            %
            % @date     26/06/14                          
            % @author   PRJ
            %  
            d = Screen('VideoCaptureDevices');
            dispStruct(d);
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