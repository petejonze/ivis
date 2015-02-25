%  Video singleton for loading, playing and controlling videos.
% 
%  Videos can be made to update/play automatically on every flip, by
%  using play/pause/unpause (which registers the IvVideo object up to
%  the ivis event broadcaster). Alternatively each frame can be updated
%  manually using playFrame(). New video files can be loaded using
%  open(), which acts as a wrapper for Screen('OpenMovie'). Videos are
%  closed automatically on IvMain.finishUp().
% 
%  IvVideo Methods:
%    * IvVideo       - Constructor
%    * open          - Open movie file
%    * play          - Play movie buffer
%    * playFrame     - Play single frame from movie buffer
%    * stop          - Stop the movie and restore audio 
%    * close         - Close movie and release memory
%    * pause         - Stop the movie from updating
%    * unpause       - Restore movie updating
%    * togglePause   - Alternate between paused/unpaused state
% 
%  See Also:
%    none
% 
%  Example:
%    none
% 
%  Author:
%    Pete R Jones <petejonze@gmail.com>
% 
%  Verinfo:
%    1.0 PJ 03/2013 : first_build\n
% 
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
%  
%
