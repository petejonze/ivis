%  Singleton instantiation of IvDataInput, designed not to be driven by
%  anything, but to flag up when/by-what methods are called.
% 
%    Can be useful when trying to understand how Ivis works.
% 
%  IvDummy Methods:
%    * IvDummy   - Constructor.
%    * connect	- Establish a link to the eyetracking hardware.
%    * reconnect	- Disconnect and re-establish link to eyetracker.
%    * refresh  	- Query the eyetracker for new data; process and store.
%    * flush   	- Query the eyetracker for new data; discard.
%    * validate  - Validate initialisation parameters.
% 
%  IvDummy Static Methods:  
%    * readRawLog- Parse data stored in a .raw binary file (hardware-brand specific format).
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
%
%    Reference page in Doc Center
%       doc ivis.eyetracker.IvDummy
%
%
