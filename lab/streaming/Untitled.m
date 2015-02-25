vidObj = videoinput('winvideo');
% Initialize the WebCam for live stream acquisition
triggerconfig(vidObj,'manual');
start(vidObj);

for i=1:1000 % process 1000 frames
    
    % grab a frame from the WebCam
    videoFrame = getsnapshot(vidObj);

<whatever>

end

It's the start() line that makes all the difference.

HTH,

Witek