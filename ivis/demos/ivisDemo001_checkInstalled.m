% ivisDemo001_checkInstalled. Check that ivis is installed and uptodate.
%
%   Will throw an error if ivis or any of its dependecies are missing or
%   invalid. To run, simply type ivisDemo001_checkInstalled on the command
%   line (and press enter)
%
% See also:         ivisDemo002_keyboardHandling.m
%
% Requires:         ivis toolbox v1.5
%   
% Matlab:           v2015 onwards
%
% See also:         ivisDemo002_keyboardHandling.m
%
% Author(s):    	Pete R Jones <petejonze@gmail.com>
% 
% Version History:  1.0.0	PJ  22/06/2013    Initial build
%                   1.1.0	PJ  18/10/2013    General tidy up (ivis 1.4)
%                   1.2.0	PJ  29/09/2017    Additional checks (ivis 1.5)
%
%
% Copyright 2017 : P R Jones <petejonze@gmail.com>
% *********************************************************************
% 

% check if toolbox can be found
if isempty(ver('ivis'))
    error('ivis toolbox not found. Try running InstallIvis.m');
end

% check version is up to date
ivis.main.IvMain.assertVersion(1.5);

% check that the PTB dependency is present
try
    AssertOpenGL();
catch ME
    error('Psychtoolbox not found. The ivis toolbox will not work without it!');
end

% check all the necessary directories are on the path
pathCell = regexp(path, pathsep, 'split');
if ~exist('ivis.main.IvMain','class')
    error('Could not find example class: ivis.main.IvMain');
end
if ~exist('SingletonManager','file')
    error('Could not find example utility function: SingletonManager.m');
end
if ~ismember(fullfile(ivisdir(),'demos'), pathCell)
    error('Could not find ivis/demos subdirectory on the path');
end
if ~ismember(fullfile(ivisdir(),'demos','resources'), pathCell)
    error('Could not find ivis/demos/resources subdirectory on the path');
end
if ~exist(fullfile(ivisdir(),'resources'), 'dir')
    error('Could not detect ivis/resources subdirectory');
end

% feedback
fprintf('Looks good. All done!\nWhy not try some more demos? ("help demos")\n');