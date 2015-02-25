%  Singleton instantiation of IvDataInput, designed to be updated manually
%  by the user
% 
%  If an input file is specified during construction then the file will
%  be parsed and entire content processed immediately.
%  Alternatively/additionally, further input can be entered at any
%  subsequent point.
% 
%  IvManual Methods:
%    * IvManual  - Constructor.
%    * connect	- Establish a link to the eyetracking hardware.
%    * reconnect	- Disconnect and re-establish link to eyetracker.
%    * refresh  	- Query the eyetracker for new data; process and store.
%    * flush   	- Query the eyetracker for new data; discard.
%    * readRawLog- Parse data stored in a .raw binary file (hardware-brand specific format).
%    * validate  - Validate initialisation parameters.
% 
%  IvManual Static Methods:    
%    * initialiseSDK	- ffffff.
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
%     %
%  Copyright 2014 : P R Jones
%  *********************************************************************
% 
%
