%  function h=IvHline(y, linetype, label)
%  
%  Draws a horizontal line on the current axes at the location specified by 'y'.  Optional arguments are
%  'linetype' (default is 'r:') and 'label', which applies a text label to the graph near the line.  The
%  label appears in the same color as the line.
% 
%  The line is held on the current axes, and after plotting the line, the function returns the axes to
%  its prior hold state.
% 
%  The HandleVisibility property of the line object is set to "off", so not only does it not appear on
%  legends, but it is not findable by using findobj.  Specifying an output argument causes the function to
%  return a handle to the line, so it can be manipulated or deleted.  Also, the HandleVisibility can be 
%  overridden by setting the root's ShowHiddenHandles property to on.
% 
%  h = IvHline(42,'g','The Answer')
% 
%  returns a handle to a green horizontal line on the current axes at y=42, and creates a text object on
%  the current axes, close to the line, which reads "The Answer".
% 
%  IvHline also supports vector inputs to draw multiple lines at once.  For example,
% 
%  IvHline([4 8 12],{'g','r','b'},{'l1','lab2','LABELC'})
% 
%  draws three lines with the appropriate labels and colors.
%  
%  By Brandon Kuczenski for Kensington Labs.
%  brandon_kuczenski@kensingtonlabs.com
%  8 November 2001
%
