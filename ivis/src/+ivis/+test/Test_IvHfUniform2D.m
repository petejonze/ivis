classdef Test_IvHfUniform2D < TestCase
    % xUnit tests for ivis.main.IvHfUniform2D
    %
    % See Also:
    %   ivis.log.Test_IvClassifierLL
    %
    % Example:
    %   runtests ivis.test -verbose             % run all
    %   runtests ivis.test.Test_IvHfUniform2D   % run just this
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
    %  -----PROPERTIES-----
    %$ ====================================================================

    properties (GetAccess = public, SetAccess = private)
        HF
    end
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods(Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function self = Test_IvHfUniform2D(name)
            % Test_IvHfUniform2D constructor.
            %
            % @return   self TestCase
            %
            % @date     26/06/14
            % @author   PRJ
            %
            self = self@TestCase(name);
        end
        
        function setUp(obj) %#ok<*MANU>
            % Testcase setup.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            minmaxBounds_px = [0 0 640 480];
            obj.HF = ivis.math.pdf.IvHfUniform2D(minmaxBounds_px);
        end
        
        function tearDown(obj)
            % Testcase teardown.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            ivis.main.IvMain.finishUp();
        end

        %% == TEST METHODS ================================================
        
        function [] = testPdfVal1(obj)
            % Validate correct value returned (within range, 2D).
            %
            % @date     02/10/17
            % @author   PRJ
            %
            xy = [100 100];
            w = [1 1];
            y = obj.HF.getPDF(xy, w);
            assertElementsAlmostEqual(y, 0.0000032552, 'wrong value returned')
        end
        
        function [] = testPdfVal2(obj)
            % Validate correct value returned (within range, 1D).
            %
            % @date     02/10/17
            % @author   PRJ
            %
            xy = [100 100];
            w = [1 0];
            y = obj.HF.getPDF(xy, w);
            assertElementsAlmostEqual(y, 0.0015625000, 'wrong value returned')
        end
        
        function [] = testPdfVal3(obj)
            % Validate correct value returned (outside of range).
            %
            % @date     02/10/17
            % @author   PRJ
            %
            xy = [1000 1000];
            w = [1 1];
            y = obj.HF.getPDF(xy, w);
            assertEqual(y, obj.HF.MIN_VAL, 'wrong value returned')
        end
        
        function [] = testPdfVal4(obj)
            % Validate correct value returned (multiple values).
            %
            % @date     02/10/17
            % @author   PRJ
            %
            xy = [1 1; 1 2; 2 1; 2 2];
            w = [1 1];
            y = obj.HF.getPDF(xy, w);
            assertTrue(length(y)==4, 'wrong number of values returned')
        end
    end
    
end