function [tex, rect] = dot(winhandle)


    w = 3;
    h = 3;
    img=ones(w,h,4)*128; % grey square
    tex = Screen('MakeTexture',winhandle,img); % convert image matrix to texture
    rect = [0 0 w h];
    
end