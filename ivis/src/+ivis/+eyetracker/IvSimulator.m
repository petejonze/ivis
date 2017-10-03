classdef (Sealed) IvSimulator < ivis.eyetracker.IvDataInput
    % Singleton instantiation of IvDataInput, designed to simulate gaze
    % coordinates based on a specified probability distribution.
    %
   	% IvSimulator Methods:
    %   * IvSimulator   - Constructor.
    %   * connect       - Establish a link to the eyetracking hardware.
    %   * reconnect     - Disconnect and re-establish link to eyetracker.
    %   * refresh       - Query the eyetracker for new data; process and store.
    %   * flush         - Query the eyetracker for new data; discard.
    %   * validate      - Validate initialisation parameters.
    %   * resetClock    - Reset the clock.
    %   * setMu         - Set distribution mean (x and y).  
    %
   	% IvSimulator Static Methods:    
    %   * initialiseSDK	- Ensure toolkit is initialised (will throw an error if not).
    %   * readRawLog    - Parse data stored in a .raw binary file (hardware-brand specific format).
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
    % at some point this should be refactored, into 1 parent abstract class,
    % and 2 instances: model-based and data-based
    
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (GetAccess = public, SetAccess = private)
        % user specified parameters
        x       % ditribution mean X value, pixels    
        y       % ditribution mean Y value, pixels
        genFunc	% function handle for generating data
    end
    
    properties (GetAccess = private, SetAccess = private)
        oldSecs % last time data were generated
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvSimulator(x, y, genFunc)
            % IvSimulator Constructor.
            %
            % @param    x           ditribution mean x value, pixels
            % @param    y           ditribution mean x value, pixels
            % @param    genFunc     function handle for generating data
            % @return   obj         IvSimulator object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.x = x;
            obj.y = y;
            obj.genFunc = genFunc;
            %
            obj.resetClock();
        end

        %% == METHODS =====================================================
        
        function [] = connect(obj) %#ok  interface implementation
        end
        
        function [] = reconnect(obj) %#ok  interface implementation
        end
        
        function n = refresh(obj) % interface implementation
            n = floor(obj.getSecsElapsed()*obj.samplingRate); % Fs*t
            if n > 0
                % generate timestamps (linearly spaced from last refresh
                % time)
                t = obj.oldSecs + (1:n)./obj.samplingRate;
                obj.resetClock();
                
                % generate data
                xy = obj.genFunc.getRand(n, [obj.x obj.y]);
                
                % exclude invalid data
                idx = xy(:,1)<0 | xy(:,1)>obj.testScreenWidth | xy(:,2)<0 | xy(:,2)>obj.testScreenHeight;
                xy(idx, :) = NaN;
                
                % simulate some lag!
                % t = t - 2;
                
                % store data in buffer for later(?)
                IvDataLog.getInstance().add(xy(:,1),xy(:,2),t');
            end
        end
        
        function [] = flush(obj) %#ok  interface implementation
        end
        
        function [] = resetClock(obj)
            % Reset the clock.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.oldSecs = GetSecs();
        end
        
        function [] = setMu(obj, x, y)
            % Set distribution mean (x and y).
            %
            % @param    x
            % @param    y
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.x = x;
            obj.y = y;
        end
    end
    
    
    %% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================
    
    methods (Access = private)
        
        function secsElapsed = getSecsElapsed(obj)
            % Get the number of seconds since the last query.
            %
            % @return   secsElapsed
            %
            % @date     26/06/14
            % @author   PRJ
            %
            newSecs = GetSecs();
            secsElapsed = newSecs - obj.oldSecs;
        end
    end
    
    
 	%% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================
    
    methods (Static, Access = public)
                     
        function [] = readRawLog(fullFn)
          	error('Functionality not defined for IvSimulator');    
        end 
    end
    
end