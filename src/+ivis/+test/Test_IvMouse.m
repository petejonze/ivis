classdef Test_IvMouse < TestCase
    % xUnit tests for ivis.eyetracker.IvMouse.
    %
    % See Also:
    %   ivis.log.Test_IvMouse
    %
    % Example:
    %   runtests ivis.test -verbose     % run all
    %   runtests ivis.test.Test_IvMouse % run just this
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 02/2011 : first_build\n
    %   1.1 PJ 02/2011 : used to develop commenting standards\n
    %   1.2 PJ 10/2017 : v1.5 build\n
    %
    %
    % Copyright 2017 : P R Jones <petejonze@gmail.com>
    % *********************************************************************
    % 
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods(Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function self = Test_IvMouse(name)
            % Test_Test_IvMouse constructor.
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
        
        function testDataReturned(self)
            % Dummy method.
            %            
            % @date     26/06/14                         
            % @author   PRJ
            %
            
            % basic launch
            ivis.main.IvMain.initialise(ivis.main.IvParams.getDefaultConfig('graphics.useScreen',false, 'log.diary.enable',false, 'log.raw.enable',false, 'graphics.runScreenChecks',false));
            [eyetracker, logs] = ivis.main.IvMain.launch();
            
            % check that the mouse returns data
            WaitSecs(1);
            n = eyetracker.refresh(true);
            
            % check some data were returned
            assertTrue(n > 30, 'no data returned');
            
            % check data have correct format
            xy = logs.data.getLastN(10, 1:2, false);
            assertTrue(all([size(xy)==[10 2] isnumeric(xy)]), 'returned data in wrong format');
            
            % check no NaNs when excluded
            xy = logs.data.getLastN(10, 1:2, true);
            assertTrue(~any(isnan(xy(:))), 'NaNs not excluded when requested');

            % check that requesting more elements than available doesn't
            % throw an error
            logs.data.getLastN(1000, 1:2, true);
            
            % finish up
            ivis.main.IvMain.finishUp();
        end
        
    end
end
