% init
close all

% Pick a random file
files = dir(fullfile(ivisdir, 'logs/raw', '*.raw'));
fn = fullfile(ivisdir, 'logs/raw', files(randi(length(files))).name);
fprintf('Displaying: %s\n', fn);

% Read in the data
dat = ivis.eyetracker.IvTobii.parseRawDataLog(fn);

% plot the data
figure();
%
subplot(1,2,1);
x = dat.left_GazePoint2d_x;
y = dat.right_GazePoint2d_x;
idx = (x~=-1) & (y~=-1); % only show points where have data for both
plot(x(idx),y(idx),'o');
hold on
    alim = [min([xlim ylim]) max([xlim ylim])];
    plot(alim,alim,'k-');
hold off
axis square
xlabel('left eye (Tobii normalised units)'); ylabel('right eye');
title('X Coordinates, left-v-right eye (Tobii normalised units)');
%
subplot(1,2,2);
x = dat.left_GazePoint2d_y;
y = dat.right_GazePoint2d_y;
idx = (x~=-1) & (y~=-1); % only show points where have data for both
plot(x(idx),y(idx),'o');
hold on
    alim = [min([xlim ylim]) max([xlim ylim])];
    plot(alim,alim,'k-');
hold off
axis square
xlabel('left eye (Tobii normalised units)'); ylabel('right eye (Tobii normalised units)');
title('Y Coordinates, left-v-right eye');