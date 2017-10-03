classdef Test_IvHfGauss2D < TestCase
    % xUnit tests for ivis.main.IvHfUniform2D
    %
    % Example:
    %   runtests ivis.test -verbose             % run all
    %   runtests ivis.test.Test_IvHfGauss2D     % run just this
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
        
        function self = Test_IvHfGauss2D(name)
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
            % @date     03/10/17
            % @author   PRJ
            %
            
            % basic init (load params)
            ivis.main.IvMain.initialise(ivis.main.IvParams.getSimpleConfig());
            
            % init pdf object
            mu_px = [500 500];
            sigma_px = [30 30];
            minmaxBounds_px = [0 0 1200 1000];
            pedestalMix_p = 0.05;
            obj.HF = ivis.math.pdf.IvHfGauss2D(mu_px, sigma_px, minmaxBounds_px, pedestalMix_p);
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
            assertElementsAlmostEqual(y, 2.0833e-09, 'wrong value returned')
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
            assertElementsAlmostEqual(y, 4.1667e-05, 'wrong value returned')
        end
        
        function [] = testPdfVal3(obj)
            % Validate correct value returned (outside of range).
            %
            % @date     02/10/17
            % @author   PRJ
            %
            xy = [2000 2000];
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
        
        function [] = testPdfVal5(obj)
            % Validate error checking (should only accept column-wise input matrix)
            %
            % @date     02/10/17
            % @author   PRJ
            %
            xy = [1 1; 1 2; 2 1; 2 2]'; % NB: convert to rows
            w = [1 1];
            assertExceptionThrown(@()obj.HF.getPDF(xy, w), 'IvHitFunc:InvalidInput')    
        end
        
    end
    
end