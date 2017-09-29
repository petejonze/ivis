function [y,n] = getTween(val1,val2,d,Fr,func, N)
% Interpolates between two known points, val1 and val2 based on a specified
% function, with steps according to a given duration & framerate.
%
% Skips val1/start point. Always ends at val2.
% Valid functions: linear, exp, exp10, log, log10, norm
%
% Returns column vector(s) of points
%
%     val1    Start value
%     val2    End value
%     d       duration (seconds, or if Framerate not specified then 'd' will assumed to be the number of frames)
%     Fr      frame rate
%     func    function type: exp, exp10, log, log10, norm, inorm, sin
%     N       ???
%
% EXAMPLE1:
%     start_coords = [1 4];
%     end_coords = [8 7];
%     %
%     close all
%     figure();
%     hold on
%     plot([start_coords(1) end_coords(1)],[start_coords(2) end_coords(2)],'-');
%     %
%     tween = getTween(start_coords,end_coords,1,30,'inorm');
%     plot(tween(:,1),tween(:,2),'ro');
%
% EXAMPLE2:
%     % shift right, spin round 4 times and fadeout
%     tween = getTween([100 10 0 0],[500 10 360*4 1],1,30,'log')
%     x = tween(:,1);
%     y = tween(:,2);
%     rot = tween(:,3);
%     alpha = tween(:,4);
%
% Copyright 2014 : P R Jones
% *********************************************************************
%

    %% 1 Parse inputs
    % check for equal row-vectors
    if size(val1,1) > 1
        val1 = val1';
        val2 = val2';
    end
    if ~all(size(val1) == size(val2))
        error('getTween:invalidInput','val1 and val2 must have common dimensions');
    end
    
    if nargin < 4 || isempty(Fr) % if Framerate not specified then 'd' will assumed to be the number of frames
        n = d;
    else
        n = floor(Fr * d);
    end
    if n < 1
        error('getTween:invalidInput','n must be > 0');
    end
    
    if nargin < 5 || isempty(func)
        func = 'linear';
    end
    
    %% 2 Get interpolation index
    startPoint = min(.0001,1/n);
    endPoint = 1;

    switch lower(func)
        case 'linear'
            i = linspace(startPoint,endPoint,n+1);
        case 'exp'
            i = exp(linspace(log(startPoint),log(endPoint),n+1));
        case 'exp10'
            i  = exp10(linspace(log10(startPoint),log10(endPoint),n+1));
        case 'log'
            i  = log(linspace(exp(startPoint),exp(endPoint),n+1));
     	case 'log10' % more pronounced
            i  = log10(linspace(exp10(startPoint),exp10(endPoint),n+1));
        case 'norm'  
            i = normcdf(linspace(norminv(startPoint),norminv(endPoint-startPoint),n+1),0,1);
        case 'inorm'  
            tmp = norminv(linspace(startPoint,endPoint-startPoint,n+1),0,1);
            i = (tmp + max(tmp)) / (max(tmp)*2);         
        case 'sin'  
            t = (0:n) / Fr;    	% time vector [sound data preparation]
            cf = N;             % frequency
            i = sin(2 * pi * cf * t + 0);
        otherwise
            error('getTween:UnknownMethod','%s is an invalid function.\nFunction type must be one of: %s',func,strjoin1(', ','linear','exp','exp10','log','log10','norm','inorm'));
    end
    
    % remove first and ensure converges at 1 (e.g. for continuous
    % distributions such as norm)
    i(1) = [];
    i(end) = 1;
    
    %% 3 Apply interpolation
    if strcmpi(func,'sin')
        y = (val2+val1)/2 + i'*diff([val1,val2])/2; % works a bit differently to others. oscillates between val1 and val2, N times per second
    else
        i = repmat(i',1,size(val1,2));
        val1 = repmat(val1,n,1);
        val2 = repmat(val2,n,1);
        y = val1.*(1-i) + val2.*i;
    end
    
    n = length(y);
    
end