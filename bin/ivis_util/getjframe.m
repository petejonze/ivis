%  getjframe Retrieves the underlying Java frame for a figure
% 
%  Syntax:
%     jframe = getjframe(hFig)
% 
%  Description:
%     GETJFRAME retrieves the current figure (gcf)'s underlying Java frame,
%     thus enabling access to all 35 figure callbacks that are not exposed
%     by Matlab's figure.
% 
%     Notable callbacks include: FocusGainedCallback, FocusLostCallback, 
%     KeyPressedCallback, KeyReleasedCallback, MouseEnteredCallback, 
%     MouseExitedCallback, MousePressedCallback, MouseReleasedCallback,
%     WindowActivatedCallback, WindowClosedCallback, WindowClosingCallback,
%     WindowOpenedCallback, WindowStateChangedCallback and 22 others.
% 
%     The returned jframe object also allows access to other useful window
%     features: 'AlwaysOnTop', 'CloseOnEscapeEnabled', 'Resizable',
%     'Enabled', 'HWnd' (for those interested in Windows integration) etc.
%     Type "get(jframe)" to see the full list of properties.
% 
%     GETJFRAME(hFig) retrieves a specific figure's underlying Java frame.
%     hFig is a Matlab handle, or a list of handles (not necesarily figure
%     handle(s) - the handles' containing figure is used).
% 
%  Examples:
%     see original doc
% 
%  Bugs and suggestions:
%     Please send to Yair Altman (altmany at gmail dot com)
% 
%  Change log:
%     2007-08-05: First version posted on <a href="http://www.mathworks.com/matlabcentral/fileexchange/loadAuthor.do?objectType=author&mfx=1&objectId=1096533#">MathWorks File Exchange</a>
%     2007-08-11: Added Matlab figure handle property; improved responsiveness handling; added support for array of handles; added sanity checks for illegal handles
%     2011-10-14: Fix for R2011b
% 
%  See also:
%     gcf, findjobj (on the File Exchange)
%
