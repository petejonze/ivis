classdef (Sealed) IvMain < handle
    % Main (static) class for initialising and shutting down ivis.
    % Should be the first and last ivis command called in your experiment.
    %
    % IvMain Methods:
    %   * assertVersion	- Validate specified version number against the installed version of ivis.
	%   * validate      - Validate IvConfig parameters.
    %   * initialise    - Load/parse the params (if an xml file file specified), and validate the contents. Must be called prior to launch().
    %   * launch        - Open connections and ready outputs.
    %   * pause         - Pause data collection (currently disabled).
    %   * finishUp      - Shut down system and close eye-tracker connection.
    %   * totalClear 	- Clear mememory.
    %
    % See Also:
    %   none
    %
    % Example:
    %   IvMain.initialise('./IvConfig_example.xml');
    %   [dataInput, params, winhandle, InH] = IvMain.launch();
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 02/2013 : first_build\n
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    % 
    
    %% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================
    
    methods (Static, Access = public)

        function [] = checkClassPath()
            % Check for bad java class path...
            %
            % @date     29/03/13
            % @author   PRJ
            %
            tmp = javaclasspath('-dynamic');
            FlushEvents()
            AssignGetCharJava();
            if length(tmp) ~= length(javaclasspath('-dynamic'))
                % MATLAB calls the clear java command whenever you change
                % the dynamic path. This command clears the definitions of
                % all Java classes defined by files on the dynamic class
                % path, removes all variables from the base workspace, and
                % removes all compiled scripts, functions, and
                % MEX-functions from memory.
                error('nIvMain:MemoryCleared','PTB has modified the java classpath (any items in memory will have been cleared)\nWill abort, since this is highly likely to lead to errors later.\n\nTry running again, or see ''help PsychJavaTrouble'' for a more permanant solution\n\nFYI: the solution, in short is to open up the matlab classpath.txt file, and manually add the necessary locations. For example, for me I opened up:\n\n  %s\n\nand at the end of the file I added these two lines:\n\n  %s\n  %s\n\nand then I restarted Matlab\n\n\ntl;dr: try running script again (or edit classpath.txt).', 'C:\Program Files\MATLAB\R2016b\toolbox\local', 'C:\Users\petej\Dropbox\MatlabToolkits\Psychtoolbox\PsychJava', 'C:\Users\petej\Dropbox\MatlabToolkits\PsychTestRig\Utilities\memory\MatlabGarbageCollector.jar');
            end
        end
        
        function [] = assertVersion(vernum)
        	% Validate specified version number against the installed
        	% version of ivis.
            %
            % @param    vernum
            %
            % @date     29/03/13
            % @author   PRJ
            %
            if verLessThan('ivis',num2str(vernum))
                error('IvMain:InvalidInput: The version of ivis you specified in your config (%g) is greater than the currently installed version (%s).\n\n', vernum, getversion('ivis'));
            end
            if verGreaterThan('ivis',num2str(vernum))
                str = sprintf('The version of ivis you specified (%g) is less than the currently installed version (%s).\n\nThis could cause problems if any of the core functions have been modified or depreciated.\n\n', vernum, getversion('ivis'));
                if ~getLogicalInput([str 'continue (y/n)? '])
                    error('Aborted by user');
                end
            end
        end
        
        function [params] = validate(paramStructOrXmlFullFileName)    
            % Validate IvConfig parameters.
            %
            % @param    paramStructOrXmlFullFileName XML filename (including path) containing parameters, or an equivalent structure 
            % @return   params                       IvParams object
            %
            % @date     29/03/13
            % @author   PRJ
            %
            if nargin<1
                paramStructOrXmlFullFileName = [];
            end
            
            % ensure classpath has been set
            ivis.main.IvMain.checkClassPath();

            %--------------------------------------------------------------
            % init Params %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % load/parse/validate user-specified parameters
            params = ivis.main.IvParams(paramStructOrXmlFullFileName);

            % validate data input
            ivis.eyetracker.IvDataInput.validateSubclass(params.eyetracker);
        end
        
        function params = initialise(paramStructOrXmlFullFileName)    
            % Load/parse the params (if an xml file file specified), and
            % validate the contents. Must be called prior to launch().
            %
            % @param    paramStructOrXmlFullFileName XML filename (including path) containing parameters, or an equivalent structure 
            % @return   params                       IvParams object
            %
            % @date     01/10/17
            % @author   PRJ
            %
         
            % check current directory is valid
            if ~isempty(regexp(pwd(), 'Windows\\system32$', 'once'))
                error('IvMain:InvalidPath', 'Trying to run Matlab from the Windows system32 folder is not a good idea.\nChange the current working directory and try again.');
            end
            
            % initialise memory
            % clearJavaMem(); % disabled: might cause problems if initialising after a PTB window has been opened(?)
            
            % (load and) validate ivis launch parameters
            params = ivis.main.IvMain.validate(paramStructOrXmlFullFileName);

            % start logging the command window
            if params.log.diary.enable
                fn = sprintf('commandline-%s.txt', datestr(now(),30));
                fullFn = fullfile(ivisdir(), 'logs', 'diary', fn);       
                fclose(fopen(fullFn, 'wt')); % make file
                diary(fullFn); % start diary
            end
        end
        
        function [dataInput, logs, InH, winhandle, params] = launch(screennum, InH) % launch(paramStructOrXmlFullFileName, winhandle, InH)
            % Open connections and ready outputs.
            %
            % @param    screennum ######
            % @param    InH       optional existing InputHandler object
            % @return   dataInput DataInput object (eyetracker)
            % @return   logs      Raw and Data log objects
            % @return   InH       InputHandler object
            % @return   winhandle handle to PTB handle
            % @return   params    IvParam object        
            %
            % @date     29/03/13
            % @author   PRJ
            %
            
            % Import packages
            import ivis.audio.* ivis.video.* ivis.classifier.* ivis.control.* ivis.log.* ivis.eyetracker.* ivis.calibration.* ivis.graphic.* ivis.gui.* ivis.io.* ivis.main.* ivis.resources.* ivis.simulation.* ivis.test.* ivis.math.*;
            
            % Parse inputs
            if nargin < 1
                screennum = [];
            elseif Screen(screennum, 'WindowKind')
                error('a:b','invalid, screennum appears to be a handle to an already extant window? If you want to use your own window then use the screennum instead, and then call IvParams.registerScreen(winhandle) after this.\n\nThis is necessary because it is important to open up ivis before opening a PTB screen, otherwise the GUI may fail.')
            end
            if nargin < 2
                InH = [];
            end

            % get params
         	params = IvParams.getInstance();
             
            % print messsage to console
            if params.main.verbosity > 0
                fprintf('IVIS: launching...\n');
            end
                
            % init. Close figures:
%             try
%                 close all;
%                 close('all', 'hidden');
%             catch  %#ok do nothing
%             end
%             % Closing figures might fail if the CloseRequestFcn of a figure
%             % blocks the execution. Fallback:
%             AllFig = allchild(0);
%             if ~isempty(AllFig)
%                 set(AllFig, 'CloseRequestFcn', '', 'DeleteFcn', '');
%                 delete(AllFig);
%             end
            
            try
                length(javaclasspath('-dynamic'));
                % check for bad java class path..
                ivis.main.IvMain.checkClassPath();

                %--------------------------------------------------------------
                % make GUI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % create a GUI shell (will add content panels to it later)
                % n.b. moved to before screen opening to ensure that
                % figures are tiled even if a fullscreen window is open
                % (otherwise seems to struggle to set focus on the dock)
                if params.GUI.useGUI
                    IvGUI(params.GUI.screenNum);
                end
                
                %--------------------------------------------------------------
                % init Psychtoolbox, open test window %%%%%%%%%%%%%%%%%%%%%%%%%
                winhandle = [];
                if params.graphics.useScreen
                    %if ~isempty(winhandle)
                    %    warning('IvMain:InvalidInput','You have requested to use a Screen, but have passed in an already extant PTB screen handle\nWill just use that instead');
                    %else
                        % PTB-3 correctly installed and functional? Abort otherwise.
                        AssertOpenGL;

                        % !!!!required to work on slow computers!!! Use with caution!!!!!
                        Screen('Preference', 'SkipSyncTests', 2);

                        % Cache key timing functions
                        % KbCheck();
                        WaitSecs(0.0000001);

                        % Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
                        % mogl OpenGL for Matlab wrapper:
                        InitializeMatlabOpenGL(1);

                        % Open a double-buffered full-screen window on the main displays screen.
                        PsychImaging('PrepareConfiguration');
                        PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');

                        % Find the color values which correspond to white and black: Usually
                        % black is always 0 and white 255, but this rule is not true if one of
                        % the high precision framebuffer modes is enabled via the
                        % PsychImaging() commmand, so we query the true values via the
                        % functions WhiteIndex and BlackIndex:
                        white = WhiteIndex(params.graphics.testScreenNum);
                        black = BlackIndex(params.graphics.testScreenNum);

                        % Round gray to integral number, to avoid roundoff artifacts with some
                        % graphics cards:
                        gray = round((white+black)/2);

                        % This makes sure that on floating point framebuffers we still get a
                        % well defined gray. It isn't strictly neccessary in this demo:
                        if gray == white
                            gray = white/2;
                        end

                        % OPEN SCREEN!
                        winRect = [0 0 params.graphics.testScreenWidth params.graphics.testScreenHeight];
                        if all(winRect == Screen('Rect', params.graphics.testScreenNum))
                            winRect = []; % on windows at least, passing coordinates seems to assume screen 0
                        end
                        winhandle = PsychImaging('OpenWindow', params.graphics.testScreenNum, gray, winRect, [], 2);

                        % Example alternative screen Opening blurb:
                        %PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput');
                        %winhandle = PsychImaging('OpenWindow', params.graphics.testScreenNum);
                    %end
                 
                    % validate
                    maxFlipsPerSecond = 1/Screen('GetFlipInterval', winhandle);
                    if maxFlipsPerSecond < params.graphics.targFrameRate
                        if ~getLogicalInput(sprintf('Effective framerate (%1.2f) < requested Fr (%1.2f). Continue?', params.graphics.targFrameRate, maxFlipsPerSecond))
                            error('a:b','Aborted by user');
                        end
                        fprintf('\n\n\n!!!!!!WARNING: Effective framerate (%1.2f) < requested Fr (%1.2f)!!!!!!!\n\n\n', params.graphics.targFrameRate, maxFlipsPerSecond)
                    end
                    
                    % initialise text
                    Screen('TextSize', winhandle, 40);
                    Screen('TextFont', winhandle, 'Helvetica');

                    % reset focus for keyboard (which will have been set to
                    % the newly opened window)
                    if ~isempty(InH)
                        InH.updateFocus(); % to encorporate the newly opened screen
                    end
                end
                    
                if ~isempty(winhandle)
                    IvParams.registerScreen(winhandle)
                elseif ~isempty(screennum)
                    IvParams.registerScreen(screennum)
                else
                    warning('Running without a screen (N.B. if you intended to open a manual PTB screen then you should have passed the screen number in when you called launch()');
                end

                IvUnitHandler(params.graphics.monitorWidth_cm, params.graphics.testScreenWidth, params.graphics.viewDist_cm);

                
                %--------------------------------------------------------------
                % initialise audio interface %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if params.audio.isConnected
                    IvAudio(params.audio, params.main.verbosity);
                end
           
                %--------------------------------------------------------------
                % initialise video interface %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                IvVideo.init();
             
                %--------------------------------------------------------------
                % initialise video interface %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if params.webcam.enable
                    IvWebcam(params.webcam.GUIidx);
                end
                
                %--------------------------------------------------------------
                % make logs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
                logs.raw = IvRawLog(params.log.raw.dir, params.log.raw.filepattern, params.log.raw.enable); %NB: must be created before IvDataLog, because IvDataLog may need to query it on finishUp (i.e., a SingletonManager is last-in-first-out)
                logs.data = IvDataLog(params.log.data.dir, params.log.data.filepattern, params.log.data.arraySize, params.log.data.autoSaveOnClose);

              	%--------------------------------------------------------------
                % make calib %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              	IvCalibration(params.calibration);

                %--------------------------------------------------------------
                % make Data Input (e.g. connect to eye-tracker) %%%%%%%%%%%%%%%
                dataInput = [];
                if ~isempty(params.eyetracker.type)
                    dataInput = IvDataInput.init(params.eyetracker, params.saccade);
                end

                %--------------------------------------------------------------
                % initialise input (e.g., keyboard) interface %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % n.b. now placed after IvGUI to prevent functionality
                % clashes
                if isempty(InH) && ~isempty(params.keyboard.handlerClass)
                    InH = feval(params.keyboard.handlerClass, params.keyboard.isAsynchronous, params.keyboard.customQuickKeys, params.keyboard.warnUnknownInputsByDefault);
                end
                
                %----------------------------------------------------------
                % flush the keyboard input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                % Some scripts (particularly the GUI hacks, simulate
                % keystrokes, so get rid of those to avoid them lingering
                % in the buffer)
                if ~isempty(InH)
                	InH.getInput();
                end
                
                % get params anew (in case anything has been updated, e.g.
                % in terms of graphics parameters)
                params = IvParams.getInstance();
                
                % print messsage to console
                if params.main.verbosity > 0
                    fprintf('IVIS: ready to use                      [%s]\n\n', datestr(now()));
                end

            catch ME
                IvMain.finishUp();
                rethrow(ME);
            end
            
            %--------------------------------------------------------------
            % update graphics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            drawnow();
            if IsWin()
                ShowHideWinTaskbarMex(0)
            end
        end

        function pause(InH) %#ok
            % Pause data collection (currently disabled).
            %
            % @date     29/03/13
            % @author   PRJ
            %
            fprintf('IvMain: WARNING: Pause disabled\n');
        end

        function finishUp(verbosity)
            % Shut down system and close eye-tracker connection.
            %
            % @date     29/03/13
            % @author   PRJ
            %   

            import ivis.audio.* ivis.classifier.* ivis.control.* ivis.log.* ivis.eyetracker.* ivis.graphic.* ivis.gui.* ivis.io.* ivis.main.* ivis.resources.* ivis.simulation.* ivis.test.*;
                
            try                
                % Use specified verbosity (or default to 1 if unsure)
                if nargin < 1 || isempty(verbosity)
                    try % will fail if IvParams not init yet
                        verbosity = ivis.main.IvParams.getInstance().main.verbosity;
                    catch
                        verbosity = 1;
                    end
                end
                
                % Print initial finishup message
                if verbosity > 0
                    fprintf('\nIVIS: finishing up...\n');
                end
                
                %restore default gamma table(s)
                scale=2^-0;
                masterGammaTable = ((1-scale)/2:scale/255:1-(1-scale)/2)'*[1 1 1];
                for winhandle = Screen('Windows')
                    Screen('LoadNormalizedGammaTable', winhandle, masterGammaTable);
                end
              
                % make sure MS Windows taskbar is on display
                if IsWin()
                    ShowHideWinTaskbarMex(1)
                end
                
                % Shutdown/restore
                ShowCursor();
                SingletonManager.clearAll(verbosity);
                
                % ensure that GUI is closed down (not sure which is more
                % important) - otherwise trying to close the window will
                % freeze operation
                drawnow();
                FlushEvents();
                
                % close any open PTB screens
                fprintf('Closing PTB screens...\n');
                sca();
                %Screen('closeall'); % must come after SingletonManager.clearAll() to ensure IvVideo has a chance to destroy
                
                % not sure about these:
                %clear IvMain; % does anything?
                clear GetCharJava % does anything?
                clearJavaMem();
                PsychJavaSwingCleanup(); % replicates clearJavaMem
                
                % Close any resources left open n.b.
                % don't close open files, since psychtestrig may already have
                % opened a file. Don't clear java memory, since we may have
                % previously (manually) opened a screen, in which case key
                % variables such as the fliprate will be stored in java memory
                % clearJavaMem
                % Close figures:
%                 try
%                     close('all', 'hidden');
%                 catch  %#ok do nothing
%                 end
%                 % Closing figures might fail if the CloseRequestFcn of a figure
%                 % blocks the execution. Fallback:
%                 AllFig = allchild(0);
%                 if ~isempty(AllFig)
%                     set(AllFig, 'CloseRequestFcn', '', 'DeleteFcn', '');
%                     delete(AllFig);
%                 end
% ^^^ this is silly, as it will also close any figure windows opened
% manually by the user (e.g., for debugging)
                
                % Print final message
                if verbosity > 0
                    fprintf('\nIVIS: ... all done. Have a nice day!    [%s]\n\n', datestr(now()));
                end
                
                diary off
            catch ME
                diary off
                rethrow(ME);
            end
        end
        
        function [] = totalClear()
            % Clear mememory.
            %
            % @date     29/03/13
            % @author   PRJ
            %            
            close all;
            clc();
            clearJavaMem();
            clearAbsAll();
        end

    end
    
end