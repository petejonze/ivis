classdef Test_IvClassifierLL < TestCase
    % xUnit tests for ivis.classifier.IvClassifierLL.
    %
    % See Also:
    %   ivis.log.Test_IvClassifierLL
    %
    % Example:
    %   runtests ivis.test -verbose
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.1 PJ 02/2011 : used to develop commenting standards\n
    %   1.0 PJ 02/2011 : first_build\n
    %
    % @todo write me
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties
        eyetracker
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods(Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function self = Test_IvClassifierLL(name)
            % Test_Test_IvClassifierLL constructor.
            %
            % @return   self TestCase
            %
            % @date     26/06/14
            % @author   PRJ
            %
            self = self@TestCase(name);
        end
        
        function setUp(self) %#ok<*MANU>
            % Testcase setup.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            ivis.main.IvMain.finishUp(0);
            self.eyetracker = ivis.main.IvMain.initialise(ivis.main.IvParams.getDefaultConfig());
        end
        
        function tearDown(self)
            % Testcase teardown.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            ivis.main.IvMain.finishUp();
        end
        
        
        %% == TEST METHODS ================================================
        
        function [] = testTiming(self)
            % Dummy method.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            assertEqual(1,1);
        end
        
        function myClassifier = testInit(self)
            % Dummy method.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            assertEqual(1,1);
        end
    end
    
end