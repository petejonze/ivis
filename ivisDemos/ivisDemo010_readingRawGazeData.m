% ivisDemo010_readingRawGazeData. Parse a raw (Tobii) data file and plot the results.
%
%   ffffff
%
% Requires:         ivis toolbox v1.3
%
% Matlab:           v2012 onwards
%
% See also:         ivisDemo009_streamingWebcams.m
%                   ivisDemo011_advancedClassifiers.m
%
% Author(s):    	Pete R Jones <petejonze@gmail.com>
% 
% Version History:  1.0.1	PJ  02/08/2013    Simplified/neatened/updated.
%                   1.0.0	PJ  22/06/2013    Initial build.
%                   1.1.0	PJ  18/10/2013    General tidy up (ivis 1.4).
%
%
% Copyright 2014 : P R Jones
% *********************************************************************
% 

% Clear memory and set workspace
clearAbsAll();
import ivis.main.* ivis.eyetracker.*;

% % Pick a random file
% files = dir(fullfile(ivisdir, 'logs/raw', '*.raw'));
% fn = fullfile(ivisdir, 'logs/raw', files(randi(length(files))).name);
fn = fullfile(ivisdir(),'ivisDemos', 'demoResources', 'IvRaw-acuity-8-2-20130628T140719.raw');
fprintf('Displaying: %s\n', fn);

% Read in the data
dat = IvTobii.parseRawLog(fn);

% plot the data
figure('Units', 'centimeters','Position',[10 10 30 10]);
% how do the x-coordinates compare across eyes?
subplot(1,3,1);
x = dat.left_GazePoint2d_x;
y = dat.right_GazePoint2d_x;
idx = (x~=-1) & (y~=-1); % only show points where have data for both
alim = [min([x(idx);y(idx)]) max([x(idx);y(idx)])];
plot(x(idx),y(idx),'o',alim,alim,'k-');
xlim(alim); ylim(alim);
axis square
xlabel('left eye (Tobii normalised units)'); ylabel('right eye (Tobii normalised units)');
title('X Coordinates');
% how do the y-coordinates compare across eyes?
subplot(1,3,2);
x = dat.left_GazePoint2d_y;
y = dat.right_GazePoint2d_y;
idx = (x~=-1) & (y~=-1); % only show points where have data for both
alim = [min([x(idx);y(idx)]) max([x(idx);y(idx)])];
plot(x(idx),y(idx),'o',alim,alim,'k-');
xlim(alim); ylim(alim);
axis square
xlabel('left eye (Tobii normalised units)'); ylabel('right eye (Tobii normalised units)');
title('Y Coordinates');
% next: show the result in time
subplot(1,3,3);
hGaze = plot(NaN, NaN, 'ko',  NaN, NaN, 'ro');
xlim(alim); ylim(alim);
axis square
xlabel('X'); ylabel('Y');
title('Gaze over time');
try
    for i = 1:length(x)
        set(hGaze(1), 'XData',dat.left_GazePoint2d_x(i), 'YData',dat.left_GazePoint2d_y(i));
        set(hGaze(2), 'XData',dat.right_GazePoint2d_x(i), 'YData',dat.right_GazePoint2d_y(i));
        drawnow();
        WaitSecs(0.001);
    end
catch %#ok e.g., if user closes window
end

% finish up
close all
drawnow();