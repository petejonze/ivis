%  Singleton instantiation of IvDataInput, designed to link to a Eyelink
%  eyetracker.
% 
%    Validated with Eyelink 1000
% 
%  IvEyelink Methods:
%    * IvEyelink	- Constructor.
%    * connect	- Establish a link to the eyetracking hardware.
%    * reconnect	- Disconnect and re-establish link to eyetracker.
%    * refresh  	- Query the eyetracker for new data; process and store.
%    * flush   	- Query the eyetracker for new data; discard.
%    * validate  - Validate initialisation parameters.
% 
%  IvEyelink Static Methods:    
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
%    1.0 PJ 06/2014 : first_build\n
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
% 
%
%    Reference page in Doc Center
%       doc ivis.eyetracker.IvEyelink
%
%
