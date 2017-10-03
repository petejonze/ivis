classdef Test_IvClassifierVector < TestCase
    % xUnit tests for ivis.classifier.IvClassifierGrid.
    %
    % See Also:
    %   ivis.log.Test_IvClassifierLL
    %
    % Example:
    %   runtests ivis.test -verbose                 % run all
    %   runtests ivis.test.Test_IvClassifierVector  % run just this
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
    
    properties (Constant)
        USE_GUI = false;
    end
    
    properties (GetAccess = public, SetAccess = private)
        params
        eyetracker
        InH
        myGraphic
        myGraphic2
        myClassifier
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods(Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function self = Test_IvClassifierVector(name)
            % Test_IvClassifierVector constructor.
            %
            % @return   self TestCase
            %
            % @date     26/06/14
            % @author   PRJ
            %
            self = self@TestCase(name);
        end
        
        function setUp(obj)
            % Testcase setup.
            %
            % @date     26/06/14
            % @author   PRJ
            %

            import ivis.classifier.* ivis.main.* ivis.graphic.*; 

            % launch ivis
            IvMain.assertVersion(1.5);
            obj.params = IvMain.initialise(IvParams.getDefaultConfig('GUI.useGUI',obj.USE_GUI, 'graphics.useScreen',false, 'eyetracker.type','mouse', 'log.raw.enable',false, 'log.diary.enable',false));
            [obj.eyetracker, ~, obj.InH] = IvMain.launch();

            % prepare a classifier
            timeout_secs = 4;
            obj.myClassifier = IvClassifierVector([90 180 270 0], [], [], timeout_secs);
        end
        
        function tearDown(~)
            % Testcase teardown.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            ivis.main.IvMain.finishUp();
            clearJavaMem();
        end
        
        
        %% == TEST METHODS ================================================
        
        function [] = testInit(obj)
            % Test basic object initialisation
            %
            % @date     02/10/17
            % @author   PRJ
            %
            
            % check correctly returned
            assertTrue(isa(obj.myClassifier,'ivis.classifier.IvClassifierVector'), 'Failed to initialise IvClassifierVector correctly');
        end

        function [] = testEndToEnd_hit1(obj)
            % Test can correctly classify when the user is fixating 1 of M targets
            %
            % @date     02/10/17
            % @author   PRJ
            %

            % *******Set mouse position*******
            %  - set it in arbitrary location and then move rightwards (below)
            x = 1000;
            SetMouse(x, 500, obj.params.graphics.testScreenNum);
            
            % flush eyetracker
            obj.eyetracker.refresh(false);
            
            % start classifier
            obj.myClassifier.start();
            
            % run
            while obj.myClassifier.getStatus() == obj.myClassifier.STATUS_UNDECIDED
                % move rightwards
                x = x + 10;
                SetMouse(x, 500, obj.params.graphics.testScreenNum);
                
                % poll peripheral devices for valid user inputs
                obj.InH.getInput();
                
                % poll eyetracker & update classifier
                [n, saccadeOnTime, blinkTime] = obj.eyetracker.refresh(); %#ok
                obj.myClassifier.update();
                
                % in case want to track progress:
                [~,propComplete] = obj.myClassifier.interogate(); %#ok
                
                % pause before proceeding
                WaitSecs(1/50);
            end
            
            % compute whether was a hit
            whatLookingAt = obj.myClassifier.interogate();
            
            % check correct
            assertEqual(whatLookingAt.name(), '90', 'failed to register rightward movement');
        end

        function [] = testEndToEnd_hit2(obj)
            % Test can correctly classify when the user is fixating another of M targets
            %
            % @date     02/10/17
            % @author   PRJ
            %
            
            % *******Set mouse position*******
            %  - set it in arbitrary location and then move leftwards (below)
            x = 1000;
            SetMouse(x, 500, obj.params.graphics.testScreenNum);
            
            % flush eyetracker
            obj.eyetracker.refresh(false);
            
            % start classifier
            obj.myClassifier.start();
            
            % run
            while obj.myClassifier.getStatus() == obj.myClassifier.STATUS_UNDECIDED
                
                % move leftwards
                x = x - 10;
                SetMouse(x, 500, obj.params.graphics.testScreenNum);
                
                % poll peripheral devices for valid user inputs
                obj.InH.getInput();
                
                % poll eyetracker & update classifier
                [n, saccadeOnTime, blinkTime] = obj.eyetracker.refresh(); %#ok
                obj.myClassifier.update();
                
                % in case want to track progress:
                [~,propComplete] = obj.myClassifier.interogate(); %#ok
                
                % pause before proceeding
                WaitSecs(1/50);
            end

            % compute whether was a hit
            whatLookingAt = obj.myClassifier.interogate();
            
            % check correct
            assertEqual(whatLookingAt.name(), '270', 'failed to register leftward movement');
        end

        function [] = testEndToEnd_miss(obj)
            % Test can correctly classify when the user is fixating neither
            % of 2 targets
            %
            % @date     02/10/17
            % @author   PRJ
            %
            
            % *******Set mouse position*******
            %  - do nothing, so the classifier should timeout
            SetMouse(0, 0, obj.params.graphics.testScreenNum);
            
            % flush eyetracker
            obj.eyetracker.refresh(false);
            
            % start classifier
            obj.myClassifier.start();
            
            % run
            while obj.myClassifier.getStatus() == obj.myClassifier.STATUS_UNDECIDED
                % poll peripheral devices for valid user inputs
                obj.InH.getInput();
                
                % poll eyetracker & update classifier
                [n, saccadeOnTime, blinkTime] = obj.eyetracker.refresh(); %#ok
                obj.myClassifier.update();
                % in case want to track progress:
                [~,propComplete] = obj.myClassifier.interogate(); %#ok
                
                % pause before proceeding
                WaitSecs(1/50);
            end

            % compute whether was a hit
            whatLookingAt = obj.myClassifier.interogate();
            
            % check correct
            assertEqual(whatLookingAt.name(), 'timeout', 'failed to register miss');
        end
    end
    
end