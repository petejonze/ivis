classdef InputHandler < Singleton
    % Responsible for polling the keyboard and mouse, and mapping any
    % events to predefined numeric codes.
    %
    %     if isAsychronous is true then uses the slow but steady GetChar,
    %     otherwise uses the faster KbWait (but at the risk that keystrokes
    %     may start & end before the keyboard has been polled. See help
    %     KbDemo)
    %
    %     could break up into seperate synchronous and asynchronous subclasses. But for now will just leave as one
    %     ctrl, alt, shift, escape not detectable async/with-getchar on the mac?
    %
    % MyInputHandler Methods:
    %   * MyInputHandler      	 - Constructor.
    %   * getInput               - Check for any inputs, return as numeric codes, along with timestamp, and any mouse xy coordinates.
    %   * mapKeyboardInputToCode - Take one or more keyboard key (and mouse clicks also), and return the appropriate input code (INPT_MISC if not recognised).
    %   * mapCodeToInputObj    	 - Take one or more specified codes, and return the appropriate input code (INPT_MISC if not recognised).
    %   * waitForInput           - Block Matlab until a specified input code is registered.
    %   * waitForKeystroke       - Block Matlab until a key is pressed (a specific key if one is specified).
    %   * removeFocus            - Stop monopolisation of the keyboard.
	%   * updateFocus            - Commence monopolisation of the keyboard (prevents key presses being registered by the wider operating system).  
    %
    % MyInputHandler Static Methods:
    %   * test - Check that the class is working.
    %
    % See Also:
    %   none
    %
    % Example:
    %   none
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 07/2013 : first_build\n
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %

    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (Constant)
        INPT_NULL = struct('key',[], 'code',-1)
        INPT_MISC = struct('key',[], 'code',-2)
        INPT_CLICK = struct('key','leftclick', 'code',-3)
        INPT_RIGHTCLICK = struct('key','rightclick', 'code',-4)
        INPT_PAUSE = struct('key','p', 'code',-5)
        INPT_QUIT = struct('key','escape', 'code',-99)
        INPT_SPACE = struct('key','space', 'code',-6) % useful to have 1 key
        INPT_RETURN = struct('key','Return', 'code',-7) % useful to have a 2nd key
        INPT_RECONNECT = struct('key','o', 'code',-8)
    end
    
    properties (GetAccess = public, SetAccess = private)
        % user defined
        winhandle = [];
        isAsynchronous = true;
        warnUnknownInputsByDefault = true;
        % other
        isPaused = 0;
    end
    
    properties (GetAccess = private, SetAccess = private)
        buttonsPrior = [0 0 0]; % init buttons
        keysPrior = {};
        
        map_keyCell
        map_codeArray
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================    

    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================

        function obj = InputHandler(isAsynchronous, customQuickKeys, warnUnknownInputsByDefault, winhandle)
            % InputHandler Constructor.
            %
            % @param   isAsynchronous
            % @param   customQuickKeys
            % @param   warnUnknownInputsByDefault
            % @param   winhandle
            % @return  obj
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if nargin < 1 || isempty(isAsynchronous)
                isAsynchronous = obj.isAsynchronous;
            end
            if nargin < 2
                customQuickKeys = {};
            end
            if nargin < 3 || isempty(warnUnknownInputsByDefault)
                warnUnknownInputsByDefault = obj.warnUnknownInputsByDefault;
            end
            if nargin < 4 || isempty(winhandle)
                winhandle = obj.winhandle;
            end
 
            % store vars
            obj.isAsynchronous = isAsynchronous;
            obj.warnUnknownInputsByDefault = warnUnknownInputsByDefault;
            obj.winhandle = winhandle;
            
            %intercept input of keypresses to Matlab. !!!use with care!!!!!!
            %if the program gets stuck you might end up with a dead keyboard
            %if this happens, press CTRL-C to reenable keyboard handling -- it is
            %the only key still recognized.
            ListenChar(2);            
            
            if ~isAsynchronous
                
                % Enable unified mode of KbName, so KbName accepts identical
                % key names on all operating systems
                KbName('UnifyKeyNames');
                
                % Precache functions (first calls always have lag)
                KbCheck();
            end
            
            % make maps
            mc = metaclass(obj);
            idx = ~cellfun(@isempty, regexp({mc.PropertyList.Name},'INPT_\w'));
            inpts = {mc.PropertyList(idx).Name};
            %
            obj.map_keyCell = {};
            obj.map_codeArray = [];
            for i = 1:length(inpts)
                key = lower(eval(['obj.' inpts{i} '.key']));
                code = eval(['obj.' inpts{i} '.code']);
                obj.addKeyCode(key, code);
            end
            
            % add any custom quick-keys (i.e., specified in IvConfig file)
            if ~iscell(customQuickKeys)
                customQuickKeys = {customQuickKeys};
            end
            for i = 1:length(customQuickKeys)
                obj.addKeyCode(customQuickKeys{i}, i);
            end

            % clear buffer and ensure fully cached
            obj.getInput();
        end
        
     	function [] = delete(~)
         	% InputHandler Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            ListenChar(0);               
        end
        
        %% == METHODS =====================================================        
        
        function [usrInput, timeInSecs, x, y] = getInput(obj, newOnly, warnUnknownInputs, suppressQuit)
            % Check for any inputs, return as numeric codes, along with
            % timestamp, and any mouse xy coordinates.
            %
            % @param    newOnly
            % @param    warnUnknownInputs
            % @param    suppressQuit
            % @return   usrInput
            % @return   timeInSecs
            % @return   x
            % @return   y
            %
            % @date     26/06/14
            % @author   PRJ
            %            
            if nargin < 2 || isempty(newOnly)
                newOnly = true;
            end
            if nargin < 3 || isempty(warnUnknownInputs)
                warnUnknownInputs = true;
            end
            if nargin < 4 || isempty(suppressQuit)
                suppressQuit = false;
            end
            
            % Check for activity
            timeInSecs = [];
            responseKey = {};
            if obj.isAsynchronous
                % ASYNC / GETCHAR -----------------------------------------
                while CharAvail
                    keyName = [];
                    [keyCode,info]=GetChar(true,true);
                    if keyCode < 33 || keyCode == 127
                        % http://www.google.co.uk/imgres?imgurl=http://www.asciitable.com/index/asciifull.gif&imgrefurl=http://www.asciitable.com/&h=488&w=715&sz=28&tbnid=2U31hF4tTw886M:&tbnh=90&tbnw=132&zoom=1&usg=__QKvmFTxkkNLdnI4XSnlKseHqfJw=&docid=JMtOixefP_tDJM&sa=X&ei=YAkIUeu2B-iG0AXn_oGgBA&ved=0CEYQ9QEwAg&dur=694
                        % names should match those from KbName
                        switch keyCode
                            case 8, keyName = 'BackSpace';
                            case 9, keyName = 'tab';
                            case 10, keyName = 'Return';
                           	case 13, keyName = 'Return'; % windows?
                            case 27, keyName = 'Escape';
                            case 32, keyName = 'space';
                            case 127, keyName = 'DELETE';
                            otherwise, fprintf('character not currently recognised. Add to list?\n');
                        end
                    else
                        keyName = char(keyCode);
                    end
                    % store
                    if ~isempty(keyName)
                        responseKey{end+1} = keyName; %#ok
                        timeInSecs(end+1) = info.secs; %#ok
                    end
                end
              	FlushEvents();
            else
                % SYHNC / KbCHECK -----------------------------------------
                % Poll keyboard device for activity
                [~, timeInSecs, keyCode] = KbCheck(-1);
                responseKey=KbName(keyCode);  %find out which key was pressed & translate code into letter (string, or strcell)
                if isempty(responseKey)
                    obj.keysPrior = {}; % nothing press. No action except to clear any history.
                else
                    
                    % if only a single instance was returned it is a string not
                    % a cell. Pack into a strcell so that can be processed in
                    % the same way as when multiple keys
                    if ~iscell(responseKey)
                        responseKey = {responseKey}; %ALT? cellstr(responseKey)
                    end
                    
                    prevPressed = ismember(responseKey, obj.keysPrior); % calc if any are held down from previously
                    obj.keysPrior = responseKey; % store
                    
                    if newOnly % ignore any prev pressed (i.e. only detect onPress)
                        if all(prevPressed==1)
                            responseKey = {}; % x = {[]} is invalid syntax, so catch any such instances and set manually to empty
                        else
                            responseKey = responseKey{~prevPressed}; % get all new
                        end
                    end
                end
            end

            % Poll mouse device for activity
            try
                [x,y,buttons] = GetMouse();
                prevPressed = obj.buttonsPrior; % check if any are held down from previously
                obj.buttonsPrior = buttons; % store
                if newOnly % ignore any prev pressed (i.e. only detect onPress)
                    buttons = buttons .* (1-prevPressed);
                end
            catch %#ok
                buttons = [0 0 0]; % assume default state (all off)
                fprintf('WARNING:  InputHandler failed to get mouse\n');
            end

            % map and return
            usrInput = obj.mapKeyboardInputToCode(responseKey, buttons, warnUnknownInputs, suppressQuit);
        end
        
        function usrInput = mapKeyboardInputToCode(obj, keyboardInput, mouseInput, warnUnknownInputs, suppressQuit)
            % Take one or more keyboard key (and mouse clicks also), and
            % return the appropriate input code (INPT_MISC if not
            % recognised).
            %
            % @param   keyboardInput
            % @param   mouseInput
            % @param   warnUnknownInputs
            % @param   suppressQuit
            % @return  usrInput
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % would be nice to also return the input objects, not just a
            % vector of codes
            
            % if no mouse input provided substitute a zero value
            if nargin<3 || isempty(mouseInput);
                mouseInput=0;
            end
            if nargin < 4 || isempty(warnUnknownInputs)
                warnUnknownInputs = obj.warnUnknownInputsByDefault;
            end

            usrInput = InputHandler.INPT_NULL.code;
            if sum(mouseInput)==0 && isempty(keyboardInput)
                return;
            end
            
            % if ascii code was given convert to a character
            if isnumeric(keyboardInput)
                % weird characters sometimes seem to be returned by odd keyboards. Here we shall ignore such characters
                if keyboardInput<27;
                    return; % ignore
                elseif keyboardInput==27
                    usrInput = obj.INPT_QUIT;
                    if ~suppressQuit                     
                        obj.processQuit();
                    end
                    return;
                end
            else% convert
                if ~isempty(keyboardInput)
                    %keyboardInput={char(keyboardInput)};
                    keyboardInput=cellstr(char(keyboardInput)); % superior to above, since might have an [N 1] char array if using Async handling
                end
            end
            
            % dfdsf
            if mouseInput(1)==1
                keyboardInput{end+1} = 'leftclick';
            elseif mouseInput(2)==1
                keyboardInput{end+1} = 'rightclick';
            elseif isempty(keyboardInput)
                return;
            end
            
            % Performing mappings
            [isKnown, idx] = ismember(lower(keyboardInput), obj.map_keyCell);
            usrInput = repmat(obj.INPT_MISC.code, 1, numel(idx));
         	usrInput(isKnown) = obj.map_codeArray(idx(isKnown));
            
            % warn about any unknown (if so requested)
            if any(~isKnown) && warnUnknownInputs
                if obj.isAsynchronous
                    fprintf('Unknown Input: %s\n', strjoin1(', ', keyboardInput{~isKnown}) );
                else
                    fprintf('Unknown Input: %s\n', strjoin1(', ', keyboardInput{~isKnown}) );
                end
            end
            
            % handle quit
            if any(usrInput == obj.INPT_QUIT.code) && ~suppressQuit
                obj.processQuit();
            end
            
            % HACKY--------------------------------------------------------
            % check for pause
            if any(usrInput == obj.INPT_PAUSE.code)
                obj.isPaused = ~obj.isPaused;
                if obj.isPaused
                    ivis.main.IvMain.pause(obj);
                end
            end
            
            % check for reconnect
            if any(usrInput == obj.INPT_RECONNECT.code)
                ivis.eyetracker.IvDataInput.getInstance().reconnect();
            end
            % -------------------------------------------------------------
                
        end
        
        function inputObjs = mapCodeToInputObj(obj, codes)
            % Take one or more specified codes, and return the appropriate
            % input code (INPT_MISC if not recognised).
            %
            % @param   codes
            % @return  inputObjs
            %
            % @todo     depreciate this method?
            % @date     26/06/14
            % @author   PRJ
            %
            
            % validate that potential inputs are all recognised
            if ~all(ismember(codes, obj.map_codeArray))
                idx = ismember(codes, obj.map_codeArray);
                error('InputHandler:BadInput','The following keycodes are not recognised: %s', sprintf('%i ', codes(~idx)))
            end
            
            % get keys info, and store in a structure with each code
            idx = ismember(obj.map_codeArray, codes);
            inputObjs = struct('key',obj.map_keyCell(idx), 'code',num2cell(obj.map_codeArray(idx)) );
        end
        
        function [usrInputCode, timeInSecs, x, y] = waitForInput(obj, specificInputCodes, promptText, warnUnknownInputs)
         	% Block Matlab until a specified input code is registered.
         	% Provide a text prompt if one is specified, and warn if input
         	% is unknown if so requested.
            %
            % @param   specificInputCodes
            % @param   promptText
            % @param   warnUnknownInputs
            % @return  usrInputCode
            % @return  timeInSecs
            % @return  x
            % @return  y
            %
            % @date     26/06/14
            % @author   PRJ
            %  
            
            % parse inputs and substitute default values where required
            if nargin < 2
                specificInputCodes = [];
            end
            if nargin < 3 || isempty(promptText)
                promptText = '';
            end
            if nargin < 4 || isempty(warnUnknownInputs)
                warnUnknownInputs = true;
            end
            
            % attempt to end up with a vector of potential numeric codes
            if isempty(specificInputCodes)
                specificInputCodes = obj.map_codeArray; % all possible codes (including misc, so any key)
            else
                if isstruct(specificInputCodes)
                    specificInputCodes = [specificInputCodes.code];
                elseif iscell(specificInputCodes)
                    specificInputCodes = cellfun(@(c)c.code, specificInputCodes);
                end
            end

            % validate that potential inputs are all recognised
            if ~all(ismember(specificInputCodes, obj.map_codeArray))
                idx = ismember(specificInputCodes, obj.map_codeArray);
                error('InputHandler:BadInput','The following keycodes are not recognised: %s', sprintf('%i ', specificInputCodes(~idx)))
            end

            % print prompt text (if any)
            fprintf(promptText);
            
            % loop until desired input is reached
            while 1
                [usrInputCode, timeInSecs, x, y] = obj.getInput(true, warnUnknownInputs);
                
                if any(ismember(usrInputCode, specificInputCodes))
                    break
                end
                
                WaitSecs(.02);
            end
        end
        
        function [keyCode, timeInSecs] = waitForKeystroke(~, specificKey)
            % Block Matlab until a key is pressed (a specific key if one
            % is specified).
            %
            % @param   isAsynchronous
            % @param   customQuickKeys
            % @param   warnUnknownInputsByDefault
            % @param   winhandle
            % @return  obj
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            if nargin < 2
                specificKey = [];
            end
           
            while 1
                [timeInSecs, keyCode] = KbWait([], 2);
                if isempty(specificKey) || ismember({lower(specificKey)}, KbName(keyCode))
                    break
                end
            end
        end
        
        function [] = removeFocus(~)    
            % Stop monopolisation of the keyboard.
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            ListenChar(0);
        end
        
        function [] = updateFocus(~)    
            % Commence monopolisation of the keyboard (prevents key presses
            % being registered by the wider operating system).
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            ListenChar(2);
        end

    end
    

    %% ====================================================================
    %  -----PRIVATE METHODS-----
    %$ ====================================================================    
    
    methods(Access = private)
        
        function [] = addKeyCode(obj, key, code)
            % Add mapping of key->code
            %
            % @param   key
            % @param   code
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            if ~isempty(key)
                prevKeys = obj.map_keyCell(~cellfun(@isempty,obj.map_keyCell));
                if ismember(key, prevKeys)
                    error('InputHandler:InvalidInput', 'Cannot map: %s => %i\nKey ''%s'' has already been mapped.\n', key, code, key)
                end
                if any(code == obj.map_codeArray)
                    error('InputHandler:InvalidInput', 'Cannot map: %s => %i\nCode ''%i'' has already been mapped.\n', key, code, code)
                end
                obj.map_keyCell{end+1} = key;
                obj.map_codeArray(end+1) = code;
            end
        end

        function [] = processQuit(~)
            % Throw an error in response to pressing quit. Overwrite to
            % suppress.
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            error('InputHandler:processQuit','!!Aborted by user!!');
        end
    end
    
    
	%% ====================================================================
    %  -----STATIC (public)-----
    %$ ====================================================================
    
    methods (Static, Access = public)
        
        function [] = test()
            % Check that the class is working. Also provides a handy way to
            % see key mappings.
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            InH = InputHandler(false);
            fprintf('Press escape to quit\n');
            try
                while 1
                    InH.getInput();
                    WaitSecs(0.01);
                end
            catch %#ok
                delete(InH);
                fprintf('done\n');
            end
        end
    end
    
    
	%% ====================================================================
    %  -----SINGLETON BLURB-----
    %$ ====================================================================

    methods (Static, Access = ?Singleton)
        function obj = getSetSingleton(obj)
            persistent singleObj
            if nargin > 0, singleObj = obj; end
            obj = singleObj;
        end
    end
    methods (Static, Access = public)
        function obj = getInstance()
            obj = Singleton.getInstanceSingleton(mfilename('class'));
        end
        function [] = finishUp()
            Singleton.finishUpSingleton(mfilename('class'));
        end
    end
end