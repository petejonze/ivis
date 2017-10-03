function [tex, rect] = whitedot(winhandle)


    w = 3;
    h = 3;
    img=ones(w,h,4)*255; % white square
    tex = Screen('MakeTexture',winhandle,img); % convert image matrix to texture
    rect = [0 0 w h];
    
end