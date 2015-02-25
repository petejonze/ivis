% requires Image Acquisition Toolbox


% Create a video input object.
vid = videoinput('winvideo');

% Create a figure window. This example turns off the default
% toolbar, menubar, and figure numbering.

figure('Toolbar','none',...
    'Menubar', 'none',...
    'NumberTitle','Off',...
    'Name','My Preview Window');

% Create the image object in which you want to display
% the video preview data. Make the size of the image
% object match the dimensions of the video frames.

vidRes = get(vid, 'VideoResolution');
nBands = get(vid, 'NumberOfBands');
hImage = image( zeros(vidRes(2), vidRes(1), nBands) );

% Display the video data in your GUI.

preview(vid, hImage);


KbWait([],2);

close all
stop(vid)
delete(vid)

%%


cam1=videoinput('winvideo'); % we connect to a Windows web camera under name cam1
preview(cam1)

%%

camobj=videoinput('winvideo'); % we connect to a Windows web camera under name cam1


% Create a customized GUI.
figure('Name', 'My Custom Preview Window');

% Create an image object for previewing.
vidRes = get(camobj, 'VideoResolution');
nBands = get(camobj, 'NumberOfBands');
hImage = image( zeros(vidRes(2), vidRes(1), nBands) );
preview(camobj, hImage);

%%

camobj=videoinput('winvideo'); % we connect to a Windows web camera under name cam1


% Create a customized GUI.
figure('Name', 'My Custom Preview Window');

% Create an image object for previewing.
vidRes = get(camobj, 'VideoResolution');
nBands = get(camobj, 'NumberOfBands');
hImage = image( zeros(vidRes(2), vidRes(1), nBands) );
%preview(camobj, hImage);
t = [];
while 1
    if KbCheck()
        break
    end
    tic();
    frame = getsnapshot(camobj);
    t(end+1) = toc();
    image(frame);
    
    WaitSecs(0.05);
end

close all
stop(camobj)
delete(camobj)


%%

obj = videoinput('winvideo');

frame = getsnapshot(obj);
image(frame);

delete(obj); 
