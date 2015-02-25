%  blurFigure blurs and prevents interaction on a figure window
% 
%  Syntax:
%     hFigBlur = blurFigure(hFig, state)
% 
%  Description:
%     blurFigure(hFig) blurs figure hFig and prevents interaction with it.
%     The only interaction possible is with user-created controls on the
%     blurring panel (see below).
% 
%     hFigBlur = blurFigure(hFig) returns the overlaid blurred figure pane.
%     This is useful to present a progress bar or other GUI controls, for
%     user interaction during the blur phase.
% 
%     blurFigure(hFig,STATE) sets the blur status of figure hFig to STATE,
%     where state is 'on','off',true or false (default='on'/true).
% 
%     blurFigure(hFig,'on') or blurFigure(hFig,true) is the same as:
%     blurFigure(hFig).
% 
%     blurFigure(hFig,'off') or blurFigure(hFig,false) is the same as:
%     close(hFigBlur).
% 
%     blurFigure('demo') displays a simple demo of the blurring
% 
%  Input parameters:  (all parameters are optional)
% 
%     hFig -  (default=gcf) Handle(s) of the modified figure(s).
%             If component handle(s) is/are specified, then the containing
%             figure(s) will be inferred and used.
% 
%     state - (default='on'/true) blurring flag: 'on','off',true or false
% 
%  Examples:
%     hFigBlur = blurFigure(hFig);       % blur hFig (alternative #1)
%     hFigBlur = blurFigure(hFig,true);  % blur hFig (alternative #2)
% 
%     blurFigure(hFig,false);       % un-blur hFig (alternative #1)
%     blurFigure(hFig,'off');       % un-blur hFig (alternative #2)
%     close(hFigBlur);              % un-blur hFig (alternative #3)
%     delete(hFigBlur);             % un-blur hFig (alternative #4)
% 
%     blurFigure('demo');           % blur demo with progress bar etc.
% 
%     hFigBlur = blurFigure(hFig);  % add a blur with a cancel button
%     uicontrol('parent',hFigBlur, 'string','Cancel', 'Callback','close(gcbf)');
% 
%  Technical Description:
%     http://UndocumentedMatlab.com/blog/blurred-matlab-figure-window
% 
%  Bugs and suggestions:
%     Please send to Yair Altman (altmany at gmail dot com)
% 
%  Warning:
%     This code heavily relies on undocumented and unsupported Matlab functionality.
%     It works on Matlab 7.9 (R2009b) and higher, but use at your own risk!
% 
%  Change log:
%     2011-03-07: First version posted on Matlab's File Exchange: <a href="http://www.mathworks.com/matlabcentral/fileexchange/?term=authorid%3A27420">http://www.mathworks.com/matlabcentral/fileexchange/?term=authorid%3A27420</a>
%     2011-03-08: Minor fix to the demo
%     2011-10-14: Fix for R2011b
% 
%  See also:
%     enableDisableFig, setFigTransparency, getJFrame (all of them on the File Exchange)
%
