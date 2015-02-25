classdef Test_IvUnitHandler < TestCase
    % xUnit tests for ivis.math.IvUnitHandler.
    %
    % See Also:
    %   ivis.math.IvUnitHandler
    %
    % Example:
    %   runtests infantvision.tests -verbose
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.1 PJ 02/2011 : used to develop commenting standards\n
    %   1.0 PJ 02/2011 : first_build\n
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods(Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function self = Test_IvUnitHandler(name)
            % Test_IvUnitHandler constructor.
            %
            % @return   self TestCase
            %
            % @date     26/06/14
            % @author   PRJ
            %
            self = self@TestCase(name);
        end
        
        function [] = setUp(self) %#ok<*MANU>
            % Testcase setup.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            SingletonManager.clearAll(0); % in case any previous crashed
            screenWidth_cm = 59.5;
            screenWidth_px = 1280;
            viewingDist_cm = 60;
            ivis.math.IvUnitHandler(screenWidth_cm, screenWidth_px, viewingDist_cm);
        end
        
        function [] = tearDown(self)
            % Testcase teardown.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            ivis.math.IvUnitHandler.finishUp;
        end
        
        %% == TEST METHODS ================================================
        
        function testDeg2cm(self)
            % Validate degrees-to-cm conversion (to 4 dp).
            %
            % @date     26/06/14
            % @author   PRJ
            %
            assertElementsAlmostEqual(ivis.math.IvUnitHandler.getInstance().deg2cm(6), 6.2889, 'relative', 1.0000e-05)
        end
        
        function testCm2deg(self)
            % Validate cm-to-degree conversion (to 4 dp).
            %
            % @date     26/06/14
            % @author   PRJ
            %
            assertElementsAlmostEqual(ivis.math.IvUnitHandler.getInstance().cm2deg(20), 18.9246, 'relative', 1.0000e-05)
        end
        
        function testNotInitialised(self)
            % Validate that IvUnitHandler must be initialised before
            % requesting a singleton object.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            ivis.math.IvUnitHandler.finishUp();
            assertExceptionThrown(@ivis.math.IvUnitHandler.getInstance, 'IvUnitHandler:FailedToGetSingleton_notInitialised')
        end
    end
    
end