% ivisDemo010_readingRawGazeData. Parse a raw data file and plot the results.
%
%   Using Tobii EyeX as exemplar
%
% Requires:         ivis toolbox v1.5
%
% Matlab:           v2015 onwards
%
% See also:         ivisDemo009_advancedClassifiers2.m
%                   ivisDemo011_externalConfigFiles.m
%
% Author(s):    	Pete R Jones <petejonze@gmail.com>
% 
% Version History:  1.0.1	PJ  02/08/2013    Simplified/neatened/updated.
%                   1.0.0	PJ  22/06/2013    Initial build.
%                   1.1.0	PJ  18/10/2013    General tidy up (ivis 1.4).
%                   1.2.0	PJ  28/09/2017    Ported to EyeX (ivis 1.5).
%
%
% Copyright 2017 : P R Jones <petejonze@gmail.com>
% *********************************************************************
% 

% Clear memory and set workspace
clearAbsAll();
import ivis.main.* ivis.eyetracker.*;

% Ensure running up-to-date version of the toolbox
IvMain.assertVersion(1.5);

% Pick a file
fn = fullfile(ivisdir(),'demos', 'resources', 'IvRaw-20170928T141607.raw');
fprintf('Displaying: %s\n', fn);

% Read in the data
dat = IvTobiiEyeX.readRawLog(fn);

% Read in the data
dat = IvTobiiEyeX.readRawLog(fn);
x = dat(:,1);
y = dat(:,2);

% plot the data (static)
hFig1 = figure('Units', 'centimeters','Position',[0 10 10 10]);
plot(x, y, 'o-');

% plot the data (Dynamic)
fprintf('Plotting data. Close figure window(s) to abort\n');
hFig2 = figure('Units', 'centimeters','Position',[10 10 10 10]);
title('Gaze over time');
hGaze = plot(NaN, NaN, 'x');
set(gca, 'Xlim',[min(x) max(x)], 'Ylim',[min(y) max(y)]);
try
    for i = 1:length(x)
         % quit if user closes either window!
        if ~ishandle(hFig1) || ~ishandle(hFig2)
            break;
        end
        set(hGaze, 'XData',x(i), 'YData',y(i));
        drawnow();
        WaitSecs(0.001);
    end
catch % e.g., if user closes window
end

% finish up
close all
drawnow();