%  Singleton for displaying calibration interactive panel and fit
%  results.
% 
%      Click individual swing icons to trigger calibration, right click
%      on the background to trigger a calibration computation.
% 
%  IvGUIcalibration Methods:
%    * IvGUIcalibration      - Constructor.
%    * callbackMeasurePoint	- Method to execute once an intruction to measure a specific coordinate is recorded; start data gathering and log the results.
%    * callbackMouseClick	- Method to execute once a mouse click occurs; if a right click, proceed to compute a new calibration given all existing measurements..
%    * showMeasurements  	- Visualise raw measurements in the GUI.
%    * showButtons           - Visualise measurement-trigger-buttons in the GUI.. 
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
%    1.1 PJ 02/2013 : converted to Singleton\n    
%    1.0 PJ 02/2013 : first_build\n
% 
%  £todo     add 'clear calib' button?
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
%  
%
