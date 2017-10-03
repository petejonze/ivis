classdef Test_IvDataInput < TestCase
    % xUnit tests for ivis.eyetracker.IvDataInput.
    %
    % See Also:
    %   ivis.log.IvDataInput
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
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods(Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function self = Test_IvDataInput(name)
            % Test_IvDataInput constructor.
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
            ivis.main.IvMain.initialise(ivis.main.IvParams.getDefaultConfig());
        end
        
        function tearDown(self)
            % Testcase teardown.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            ivis.main.IvParams.finishUp;
        end

        %% == TEST METHODS ================================================
        
        function [] = testDummy(self)
            % Dummy method.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            assertEqual(1,1);
        end
        
        function [] = testDummy2(self)
            % Dummy method.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            assertEqual(1,1);
        end
    end
    
end