function varargout = Screen(varargin)
%SCREEN wrapper for PTB's Screen command.
%
%  	Intercepts Screen command and inserts a PreFlip broadcast event before
%  	any 'Flip' commands
%
%   Note, because further objects may be drawn just prior to the final
%   'Flip', it is important NOT to use: Screen('DrawingFinished',
%   winhandle) in your script!
%
% Parameters:             
%
%     	varargin   whatever PTB's Screen() requires
%
% Returns:  
%
%    	varargout   whatever PTB's Screen() returns
%
%
% Requires:        none
%   
% See also:        none
%
% Matlab:          v2008 onwards
%
% Author(s):    	Pete R Jones
%
% Version History: v1.0.0	18/06/14    Initial build.
%                   v1.0.1	20/01/11    ######
%
%
% Copyright 2014 : P R Jones
% *********************************************************************
% 
    if strcmpi(varargin{1},'flip')
       	% update graphics as appropriate
      	ivis.broadcaster.IvBroadcaster.getInstance().notify('PreFlip', ivis.broadcaster.IvEventData(GetSecs()) ) % e.g., update classifier, TrackBox, etc.
    end
    
    % forward onwards
    [varargout{1:nargout}] = Screen( varargin{:} ); 
end