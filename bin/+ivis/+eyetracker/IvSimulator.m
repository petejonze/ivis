%  Singleton instantiation of IvDataInput, designed to simulate gaze
%  coordinates based on a specified probability distribution.
% 
%  IvSimulator Methods:
%    * IvSimulator   - Constructor.
%    * connect       - Establish a link to the eyetracking hardware.
%    * reconnect     - Disconnect and re-establish link to eyetracker.
%    * refresh       - Query the eyetracker for new data; process and store.
%    * flush         - Query the eyetracker for new data; discard.
%    * validate      - Validate initialisation parameters.
%    * resetClock    - Reset the clock.
%    * setMu         - Set distribution mean (x and y).  
% 
%  IvSimulator Static Methods:    
%    * initialiseSDK	- Ensure toolkit is initialised (will throw an error if not).
%    * readRawLog    - Parse data stored in a .raw binary file (hardware-brand specific format).
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
%    1.0 PJ 02/2013 : first_build\n
% 
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
% 
%  at some point this should be refactored, into 1 parent abstract class,
%  and 2 instances: model-based and data-based
%
