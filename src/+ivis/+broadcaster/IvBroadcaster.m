classdef (Sealed) IvBroadcaster < Singleton
	% Responsible for broadcasting event message to ivis components.
    %
    % Objects can subscribe to this class to be informed of updates,
    % containing an event code, and any message content.
    %
    % IvBroadcaster Methods:
	%   * IvBroadcaster - Constructor.
    %
    % Possible Events:
	%   * PreFlip   - Instruction to carry out any graphical updates, prior to Screen('Flip').
    %   * SaveData  - Instruction to logs to save any remaining data left in the buffer.
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
    %   1.0 PJ 03/2013 : first_build\n
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================

    properties (Constant)
        ALLOW_IMPLICIT_CONSTRUCTION = true; % whether getInstance() can be called prior to init()
    end


    %% ====================================================================
    %  -----EVENTS-----
    %$ ====================================================================
    
    events
        PreFlip     % Instruction to carry out any graphical updates, prior to Screen('Flip').
        SaveData    % Instruction to logs to save any remaining data left in the buffer.
    end
    

    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj=IvBroadcaster()
            % IvBroadcaster constructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %     
        end
        
        function [] = delete(obj) %#ok
            % Object destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %     
            clear IvBroadcaster
        end
        
        %% == METHODS =====================================================

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