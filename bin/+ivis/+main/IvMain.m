%  Main (static) class for initialising and shutting down ivis.
%  Should be the first and last ivis command called in your experiment.
% 
%  IvMain Methods:
%    * assertVersion	- Validate specified version number against the installed version of ivis.
%    * validate      - Validate IvConfig parameters.
%    * initialise    - Load/parse the params (if an xml file file specified), and validate the contents. Must be called prior to launch().
%    * launch        - Open connections and ready outputs.
%    * pause         - Pause data collection (currently disabled).
%    * finishUp      - Shut down system and close eye-tracker connection.
%    * totalClear 	- Clear mememory.
%    * disableScreenChecks - Prevent Ivis from checking screen parameters on launch.
% 
%  See Also:
%    none
% 
%  Example:
%    IvMain.initialise('./IvConfig_example.xml');
%    [dataInput, params, winhandle, InH] = IvMain.launch();
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
