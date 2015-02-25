%  Interpolates between two known points, val1 and val2
%  based on a specified function, with steps according to
%  a given duration & framerate.
% 
%  Skips val1/start point. Always ends at val2.
%  Valid functions: linear, exp, exp10, log, log10, norm
% 
%  Returns column vector(s) of points
% 
%      val1    Start value
%      val2    End value
%      d       duration (seconds, or if Framerate not specified then 'd' will assumed to be the number of frames)
%      Fr      frame rate
%      func    function type: exp, exp10, log, log10, norm, inorm, sin
%      N       ???
% 
%  EXAMPLE1:
%      start_coords = [1 4];
%      end_coords = [8 7];
%      %
%      close all
%      figure();
%      hold on
%      plot([start_coords(1) end_coords(1)],[start_coords(2) end_coords(2)],'-');
%      %
%      tween = getTween(start_coords,end_coords,1,30,'inorm');
%      plot(tween(:,1),tween(:,2),'ro');
% 
%  EXAMPLE2:
%      % shift right, spin round 4 times and fadeout
%      tween = getTween([100 10 0 0],[500 10 360*4 1],1,30,'log')
%      x = tween(:,1);
%      y = tween(:,2);
%      rot = tween(:,3);
%      alpha = tween(:,4);
%
