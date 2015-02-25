%  enableDisableFig enable or disable an entire figure window
% 
%  Syntax:
%     currentState = enableDisableFig(hFig, newState)
% 
%  Description:
%     enableDisableFig sets the figure hFig's enable/disable state, which
%     is otherwise supported by Matlab only for specific components but not
%     figures. Using this function, the entire figure window, including all
%     internal menus, toolbars and components, is enabled/disabled in a
%     single call. Valid values for newState are true, false, 'on' & 'off'
%     (case insensitive). hFig may be a list of figure handles.
% 
%     Note 1: when the state is enabled, internal figure components may
%     remain disabled if their personal 'enabled' property is 'off'.
% 
%     Note 2: in disabled state, a figure cannot be moved, resized, closed
%     or accessed. None of its menues, toolbars, buttons etc. are clickable.
% 
%     enableDisableFig(newState) sets the state of the current figure (gcf).
%     Note 3: this syntax (without hFig) might cause unexpected results if
%     newState is a numeric value (interpreted as a figure handle), instead
%     of a string or logical value.
% 
%     state = enableDisableFig(hFig) returns the current enabled/disabled
%     state of figure hFig, or of the current figure (gcf) if hFig is not
%     supplied. The returned state is either 'on' or 'off'.
% 
%  Examples:
%     state = enableDisableFig;
%     state = enableDisableFig(hFig);
%     oldState = enableDisableFig(hFig, 'on');
%     oldState = enableDisableFig(hFig, result>0);
%     oldState = enableDisableFig(true);  % on current figure (Note 3 above)
% 
%  Technical description:
%     http://UndocumentedMatlab.com/blog/disable-entire-figure-window
% 
%  Bugs and suggestions:
%     Please send to Yair Altman (altmany at gmail dot com)
% 
%  Warning:
%     This code heavily relies on undocumented and unsupported Matlab
%     functionality. It works on Matlab 7+, but use at your own risk!
% 
%  Change log:
%     2007-08-10: First version posted on <a href="http://www.mathworks.com/matlabcentral/fileexchange/loadAuthor.do?objectType=author&mfx=1&objectId=1096533#">MathWorks File Exchange</a>
%     2007-08-11: Fixed sanity checks for illegal list of figure handles
%     2011-02-18: Remove Java warnings in modern Matlab releases
%     2011-10-14: Fix for R2011b
% 
%  See also:
%     gcf, findjobj, getJFrame (last two on the File Exchange)
%
