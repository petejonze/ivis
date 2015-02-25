classdef Test_IvMain < TestCase
    % xUnit tests for ivis.main.IvMain.
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
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods(Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function self = Test_IvMain(name)
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
            % Validate cycle overhead.
            %
            % @date     26/06/14
            % @author   PRJ
            %
        	N = 100;
            cfg = ivis.main.IvParams.getDefaultConfig();
            
            % ####
            ivis.main.IvMain.initialise(cfg);
            eyetracker = ivis.main.IvMain.launch;
            timeElapsed = nan(N,1);
            myClassifier = ivis.classifier.IvClassifierVector([-70 0 70 200]);
            myClassifier.start();
            
            for i =1:N
                tic();
                eyetracker.refresh();
                myClassifier.update();
                timeElapsed(i) = toc();
                WaitSecs(1/60);
            end
            timeElapsed(1:3) = [];
            fprintf('\n > mean = %1.2f, std = %1.2f, min = %1.2f, max = %1.2f\n', mean(timeElapsed)*1000, std(timeElapsed)* 1000, min(timeElapsed)*1000, max(timeElapsed)*1000)
            ivis.main.IvMain.finishUp();
            
            % ####
            cfg.GUI.useGUI = false;
            ivis.main.IvMain.initialise(cfg);
            eyetracker = ivis.main.IvMain.launch;
            timeElapsed = nan(N,1);
            myClassifier = ivis.classifier.IvClassifierVector([-70 0 70 200]);
            myClassifier.start();
            
            for i =1:N
                tic();
                eyetracker.refresh();
                myClassifier.update();
                timeElapsed(i) = toc();
                WaitSecs(1/60);
            end
            timeElapsed(1:3) = [];
            fprintf('\n > mean = %1.2f, std = %1.2f, min = %1.2f, max = %1.2f\n', mean(timeElapsed)*1000, std(timeElapsed)* 1000, min(timeElapsed)*1000, max(timeElapsed)*1000)
            ivis.main.IvMain.finishUp();  
        end
    end
    
end