%  Singleton instantiation of IvDataInput, designed not to be driven by
%  an SMI eyetracker
% 
%    Uses the official SMI iView SDK
%      
%      
%          myStruct:-|
%                |-  timestamp: '4265056496'
%                |-    leftEye:-|
%                               |-       gazeX: '385.258'
%                               |-       gazeY: '803.163'
%                               |-        diam: '4.62'
%                               |-eyePositionX: '-33.468'
%                               |-eyePositionY: '7.187'
%                               |-eyePositionZ: '597.324'
%                |-   rightEye:-|
%                               |-       gazeX: '385.258'
%                               |-       gazeY: '803.163'
%                               |-        diam: '4.82'
%                               |-eyePositionX: '25.139'
%                               |-eyePositionY: '9.285'
%                               |-eyePositionZ: '598.138'
%                |-planeNumber: '-1'
% 
%  IvSmi Methods:
%    * IvSmi     - Constructor.
%    * connect	- Establish a link to the eyetracking hardware.
%    * reconnect	- Disconnect and re-establish link to eyetracker.
%    * refresh  	- Query the eyetracker for new data; process and store.
%    * flush   	- Query the eyetracker for new data; discard.
%    * validate  - Validate initialisation parameters.
% 
%  IvSmi Static Methods:  
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
%       doc ivis.eyetracker.IvSmi
%
%
