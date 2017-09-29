%  Singleton instantiation of IvDataInput, designed to link to a Tobii
%  eyetracker.
% 
%    long_description
% 
%  IvTobii Methods:
%    * connect	- Establish a link to the eyetracking hardware.
%    * reconnect	- Disconnect and re-establish link to eyetracker.
%    * refresh  	- Query the eyetracker for new data; process and store.
%    * flush   	- Query the eyetracker for new data; discard.
%    * validate  - Validate initialisation parameters.
%    * getEyeballLocations - Get cartesian coordinates for each eyeball, in millimeters.
%    * getLastKnownViewingDistance - Compute last known viewing distance (averaging across eyeballs)
% 
%  IvTobii Static Methods:
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
%    1.1 PJ 02/2013 : Added support for raw data logging and trackbox visualisation\n
%    1.0 PJ 02/2013 : first_build\n
% 
%  @todo switch to single precision?
%  @todo protect constructor?
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
% 
%
%    Reference page in Doc Center
%       doc ivis.eyetracker.IvTobii
%
%
