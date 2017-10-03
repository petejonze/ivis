function [tex, rect] = tmp1(winhandle)


    w = 32;
    h = 32;
    %
    img=ones(w,h,4)*255; % make a white canvas. (useful to be a power of two)
    img(16:17,:,1:3)=0; % draw a black cross
    img(:,16:17,1:3)=0;
    img(:,:,4) = 0; % add the transparency layer
    img(16:17,    :,      4)=255;
    img(:,        16:17,  4)=255;
    tex = Screen('MakeTexture',winhandle,img); % convert image matrix to texture
    rect = [0 0 w h];
    
end