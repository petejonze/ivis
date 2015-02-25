%  Display Tobii eyetracker box schema and current eyeball info.
% 
%  Utility function that displays a scale wireframe model of the display
%  screen and Tobii x120 trackbox. Estimated eyeball and fixation
%  positions are displayed, or the wireframe is turned red if no input
%  is detected. The screen parameters are taken from IvParams. However,
%  the track box dimensions are guestimated and hardcoded, since they
%  cannot be extracted from the Tobii given the current matlab SDK
%  bindings.
% 
%  TrackBox Methods:
%    * draw      - Draw trackbox, and keep updating until stopped
%    * stop      - Stop drawing trackbox and release memory
%    * toggle	- Alternate between start/stop states
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
%    1.0 PJ 03/2013 : first_build\n
% 
%  @ todo: Should probably be refactored to be part of a Tobii-specific package (or even inside the Tobii class itself)
% 
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
% 
%
