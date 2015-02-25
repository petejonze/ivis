classdef MyDemoInputHandler < InputHandler
    % Example InputHandler subclass, with added mappings for the "a" and
    % "b" key
    %
    % MyDemoInputHandler Methods:
    %   * MyDemoInputHandler - Constructor.
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
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (Constant)
        INPT_A = struct('key','a', 'code',2)
        INPT_B = struct('key','b', 'code',3)
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = MyDemoInputHandler(isAsynchronous, customQuickKeys, warnUnknownInputsByDefault, winhandle)
            if nargin < 1, isAsynchronous = []; end
            if nargin < 2, customQuickKeys = []; end
            if nargin < 3, warnUnknownInputsByDefault = []; end
            if nargin < 4, winhandle = []; end
            obj = obj@InputHandler(isAsynchronous, customQuickKeys, warnUnknownInputsByDefault, winhandle);
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