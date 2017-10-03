classdef Test_IvClassifierBox < TestCase
    % xUnit tests for ivis.classifier.IvClassifierBox.
    %
    % See Also:
    %   ivis.log.Test_IvClassifierLL
    %
    % Example:
    %   runtests ivis.test -verbose                 % run all
    %   runtests ivis.test.Test_IvClassifierBox     % run just this
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
        
        function self = Test_IvClassifierBox(name)
            % Test_IvClassifierBox constructor.
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

            % prepare graphic
            obj.myGraphic = IvGraphic('targ1', [], 300, 600, 200, 200);
            obj.myGraphic2 = IvGraphic('targ2', [], 1000, 600, 200, 200);
            
            % prepare a classifier
            timeout_secs = 4;
            obj.myClassifier = IvClassifierBox({obj.myGraphic, obj.myGraphic2}, [], [], timeout_secs);
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
            assertTrue(isa(obj.myClassifier,'ivis.classifier.IvClassifierBox'), 'Failed to initialise IvClassifierBox correctly');
        end

        function [] = testEndToEnd_hit1(obj)
            % Test can correctly classify when the user is fixating 1 of M targets
            %
            % @date     02/10/17
            % @author   PRJ
            %

            % *******Set mouse position*******
            %  - set it directly over Target 1, so should register 'targ1'
            SetMouse(obj.myGraphic.getX(), obj.myGraphic.getY(), obj.params.graphics.testScreenNum);
            
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
            assertEqual(whatLookingAt.name(), obj.myGraphic.name, 'failed to register looking at target A');
        end

        function [] = testEndToEnd_hit2(obj)
            % Test can correctly classify when the user is fixating another of M targets
            %
            % @date     02/10/17
            % @author   PRJ
            %
            
            % *******Set mouse position*******
            %  - set it directly over Target 2, so should register 'targ2'
            SetMouse(obj.myGraphic2.getX(), obj.myGraphic2.getY(), obj.params.graphics.testScreenNum);
            
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
            assertEqual(whatLookingAt.name(), obj.myGraphic2.name, 'failed to register looking at target B');
        end

        function [] = testEndToEnd_miss(obj)
            % Test can correctly classify when the user is fixating neither
            % of 2 targets
            %
            % @date     02/10/17
            % @author   PRJ
            %
            
            % *******Set mouse position*******
            %  - set it in the corner, so the classifier should timeout
            %  (NB: prior criterion set to Inf)
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
        
        function [] = testEndToEnd_hit1moving(obj)
            % Test can correctly classify when the user is fixating 1 of M
            % targets, when the target is moving
            %
            % @date     02/10/17
            % @author   PRJ
            %
            
            % *******Set mouse position*******
            %  - set it directly BELOW Target 1, but will set the
            %  y-weighting to 0, so should still register 'targ1'
            SetMouse(obj.myGraphic.getX(), 0, obj.params.graphics.testScreenNum);

            % flush eyetracker
            obj.eyetracker.refresh(false);
            
            % start classifier
            obj.myClassifier.start();
            
            % run
            while obj.myClassifier.getStatus() == obj.myClassifier.STATUS_UNDECIDED
                % poll peripheral devices for valid user inputs
                obj.InH.getInput();
                
               	% update graphics
                if obj.myGraphic.getY() < 1000
                   obj.myGraphic.nudge(0, 10);
                end
                %obj.myGraphic.setXY(randi(1000), randi(1000))
                
                % update mouse to follow target (lag slightly behind)
                SetMouse(obj.myGraphic.getX(), obj.myGraphic.getY()-100, obj.params.graphics.testScreenNum);
            
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
            assertEqual(whatLookingAt.name(), obj.myGraphic.name, 'failed to register looking at moving Target 1');
        end    
    end
    
end