%  Generic data input class that must be instantiated by a subclass.
%  Handles the crucial data processing task (applying calibration
%  filtering, interpolating, classifying, sending data to logs, etc.). 
% 
%  n.b. subclasses should NOT repeated the Singleton blurb (if want to
%  be able to access generically, via DataInput.getSingleton()
% 
%  IvDataInput Abstract Methods:
%    * connect	- Establish a link to the eyetracking hardware.
%    * reconnect	- Disconnect and re-establish link to eyetracker.
%    * refresh  	- Query the eyetracker for new data; process and store.
%    * flush   	- Query the eyetracker for new data; discard.
%    * readRawLog- Parse data stored in a .raw binary file (hardware-brand specific format).
%    * validate  - Validate initialisation parameters.
% 
%  IvDataInput Methods:
%    * IvDataInput           - Constructor.
%    * setFixationMarker     - Establish what, if anything, to use as a gaze-contingent marker.
%    * updateDriftCorrection	- Instruct IvCalibration to update the drift correction.
%    * getLastKnownXY        - Get the last reported xy gaze coordinate (and also the timestamp, if requested).
% 
%  IvDataInput Static Methods:   
%    * validateSubclass  - Check that the class name is valid, and that the parameter are congruent for this class.
%    * init              - Initialise parameters, create GUIS, etc.
%    * readDataLog       - Parse data stored in a .csv data file.
%    * estimateLag       - Estimate expected lag given a specified set of parameters.
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
%  @todo discard old points (particularly useful for avoiding
%        slowdowns/dropped-frames?
%  @todo transfer hardcoded values to IvConfig
%  @todo discard samples where only 1 eye is available? (re: Sam Wass)
%  @todo make px2deg mapping dynamic based on subject movement?
%  @todo in the long run the eyeball z data should be filtered/buffered
%        through this class too. At the moment the logic is internal to each
%        eyetracker, since some trackers don't return this information.
%        But most do now, and it would be good to deal with it properly.
%        This would allow proper retrieval (e.g., get last points since
%        T), and should improve accuracy too (e.g., low pass filtering).
%  @todo allow setting of trackerInFrontMonitor_mm
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
%  
%
%    Reference page in Doc Center
%       doc ivis.eyetracker.IvDataInput
%
%
