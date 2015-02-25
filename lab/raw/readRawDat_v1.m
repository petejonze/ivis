%% Specify the file name
% fn = 'D:\Dropbox\MatlabToolkits\infantvision\logs\raw\IvRaw-acuity-100-1-20130502T144952.raw';
% fn = 'D:\Dropbox\MatlabToolkits\infantvision\logs\raw\IvRaw-acuity-999-1-20130419T163415.raw';
fn = 'D:\Dropbox\MatlabToolkits\infantvision\logs\raw\IvRaw-acuity-999-1-20130419T171015.raw';
% fn = 'IvRaw-acuity-1-1-20130417T164256.raw';

%% read in the data
fid = fopen(fn);
A = fread(fid,'double');
fclose(fid);

%% extra the information
B = reshape(A,27,[])';
leye = B(:,1:13);
reye = B(:,14:26);
time = B(:,27);

%% plot the data
datacolumn = 7; % column 4 should be GazePoint2d.x (see page 62 of the Tobii SDK 3.0 handbook)
x1 = leye(:,datacolumn);
x2 = reye(:,datacolumn);
idx = (x1~=-1) & (x2~=-1); % only show points where have data for both
close all;
figure();
plot(x1(idx),x2(idx),'o',[0 1],[0 1],'k-');
xlabel('left eye (Tobii normalised units)'); ylabel('right eye');
