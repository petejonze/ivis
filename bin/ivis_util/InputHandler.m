%  Responsible for polling the keyboard and mouse, and mapping any
%  events to predefined numeric codes.
% 
%      if isAsychronous is true then uses the slow but steady GetChar,
%      otherwise uses the faster KbWait (but at the risk that keystrokes
%      may start & end before the keyboard has been polled. See help
%      KbDemo)
% 
%      could break up into seperate synchronous and asynchronous subclasses. But for now will just leave as one
%      ctrl, alt, shift, escape not detectable async/with-getchar on the mac?
% 
%  MyInputHandler Methods:
%    * MyInputHandler      	 - Constructor.
%    * getInput               - Check for any inputs, return as numeric codes, along with timestamp, and any mouse xy coordinates.
%    * mapKeyboardInputToCode - Take one or more keyboard key (and mouse clicks also), and return the appropriate input code (INPT_MISC if not recognised).
%    * mapCodeToInputObj    	 - Take one or more specified codes, and return the appropriate input code (INPT_MISC if not recognised).
%    * waitForInput           - Block Matlab until a specified input code is registered.
%    * waitForKeystroke       - Block Matlab until a key is pressed (a specific key if one is specified).
%    * removeFocus            - Stop monopolisation of the keyboard.
%    * updateFocus            - Commence monopolisation of the keyboard (prevents key presses being registered by the wider operating system).  
% 
%  MyInputHandler Static Methods:
%    * test - Check that the class is working.
% 
%  See Also:
%    none
% 
%  Example:
%    none
% 
%  Author:
%    Pete R Jones <petejonze@gmail.com>
% 
%  Verinfo:
%    1.0 PJ 07/2013 : first_build\n
% 
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
% 
%
%    Reference page in Doc Center
%       doc InputHandler
%
%
