% ivisDemo001_checkInstalled. Check that ivis is installed and uptodate.
%
%   Will throw an error if ivis or any of its dependecies are missing or
%   invalid. To run, simply type ivisDemo001_checkInstalled on the command
%   line (and press enter)
%
% See also:         ivisDemo002_keyboardHandling.m
%
% Requires:         ivis toolbox v1.4
%   
% Matlab:           v2012 onwards
%
% See also:         ivisDemo002_keyboardHandling.m
%
% Author(s):    	Pete R Jones <petejonze@gmail.com>
% 
% Version History:  1.0.0	PJ  22/06/2013    Initial build.
%                   1.1.0	PJ  18/10/2013    General tidy up (ivis 1.4).
%
%
% Copyright 2014 : P R Jones
% *********************************************************************
%
% import ivis.main.*;
% import ivis.main.IvParams;

%ivis.main.IvParams.getSimpleConfig()
ivis.main.IvParams.getSimpleConfig();

% check if toolbox can be found
if isempty(ver('ivis'))
    error('ivis toolbox not found. Try running InstallIvis.m');
end

% check version is up to date
ivis.main.IvMain.assertVersion(1.4);
% IvMain.assertVersion(1.4)

% check that the PTB dependency is present
try
    AssertOpenGL();
catch ME
    error('Psychtoolbox not found. The ivis toolbox will not work without it!');
end

% feedback
fprintf('Looks good. All done!\nWhy not try some more demos? ("help ivisDemos")\n');