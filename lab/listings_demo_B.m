% get basic parameters
params = IvParams.getDefaultConfig();

% for mouse (default)
params.eyetracker.type = 'mouse';

% for Tobii (id optional)
params.eyetracker.type = 'tobii';
params.eyetracker.id = 'TX120-301-22300548';

% for Eyelink (id optional)
params.eyetracker.type = 'eyelink';
params.eyetracker.id = 'EYELINK II 2.13';

% for a 'dummy' object (provides info on how
% and when methods are called) 
params.eyetracker.type = 'dummy';