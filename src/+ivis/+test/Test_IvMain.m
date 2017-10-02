classdef Test_IvMain < TestCase
    % xUnit tests for ivis.main.IvMain.
    %
    % See Also:
    %   ivis.log.Test_IvClassifierLL
    %
    % Example:
    %   runtests ivis.test -verbose     % run all
    %   runtests ivis.test.Test_IvMain  % run just this
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
            cfg = ivis.main.IvParams.getDefaultConfig('log.diary.enable',false, 'log.raw.enable',false, 'graphics.runScreenChecks',false);
            
            % ####
            ivis.main.IvMain.initialise(cfg);
            eyetracker = ivis.main.IvMain.launch();
            timeElapsed = nan(N,1);
            myClassifier = ivis.classifier.IvClassifierVector([-70 0 70 200]);
            % ALT:
            %myGraphic = ivis.graphic.IvGraphic('targ', [], 0, 0, 100, 100);
        	%myClassifier = ivis.classifier.IvClassifierLL({ivis.graphic.IvPrior(), myGraphic}, [inf 300], 360, [], [], [], false);  
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
            % ALT:
            %myGraphic = ivis.graphic.IvGraphic('targ', [], 0, 0, 100, 100);
        	%myClassifier = ivis.classifier.IvClassifierLL({ivis.graphic.IvPrior(), myGraphic}, [inf 300], 360, [], [], [], false);  
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