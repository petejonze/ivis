function resp = measurePoint(x, y)
% Dummy method simulating noisy (and sometimes biased) gaze measurements at
% a given x/y coordinate. 
%
% Parameters:             
%
%     	x       float	target coordinate, x location (pixels)
%                           	
%     	y       float	target coordinate, y location (pixels)
%                           	
% Returns:  
%
%    	resp	[n,2]  	gaze location observations
%
% Usage:            resp = measurePoint(x, y)
% Example:          resp = measurePoint(100, 200)
%
% Requires:         none
%   
% See also:         none
%
% Matlab:           v2008 onwards
%
% Author(s):    	Pete R Jones
%
% Version History:  v1.0.0	18/06/14    Initial build.
%
%
% Copyright 2014 : P R Jones
% *********************************************************************
% 

    fprintf('measuring point {%i,%i}', x, y);
    WaitSecs(0.1); fprintf(' .');
    WaitSecs(0.1); fprintf(' .');
    WaitSecs(0.1); fprintf(' .\n');
    
    mu = [x y];
    noise = [100 100];
    nSamples = 60;
    
    if rand()<.25
       mu = mu + [100 100];
    end

    resp = mvnrnd(mu, noise, nSamples);
end