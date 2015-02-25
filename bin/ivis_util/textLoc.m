%  function [H]=textLoc('string',location[,parameter,value,...])
% 
%  Puts string onto the current axes with location similar to legend locations.
%  Passes all parameter, value pairs to text. textLoc works with semilog and 
%  loglog plots.
%  
%  H is the handle from the text command after modifications by textLoc.
% 
%  location can also be a 1x2 cell array containing {location,buffer} where
%    buffer is a spacing buffer (in normalized units) for distance from the axes.
%    buffer default is 1/50
% 
%  location can be any of:
%         'North'                   inside plot box near top
%         'South'                   inside bottom
%         'East'                    inside right
%         'West'                    inside left
%         'Center'                  centered on plot
%         'NorthEast'               inside top right (default)
%         'NorthWest'                inside top left
%         'SouthEast'               inside bottom right
%         'SouthWest'               inside bottom left
%         'NorthOutside'            outside plot box near top
%         'SouthOutside'            outside bottom
%         'EastOutside'             outside right
%         'WestOutside'             outside left
%         'NorthEastOutside'        outside top right
%         'NorthWestOutside'        outside top left
%         'SouthEastOutside'        outside bottom right
%         'SouthWestOutside'        outside bottom left
%         'NorthEastOutsideAbove'   outside top right (above)
%         'NorthWestOutsideAbove'   outside top left (above)
%         'SouthEastOutsideBelow'   outside bottom right (below)
%         'SouthWestOutsideBelow'   outside bottom left (below)
%         'Random'                  Random placement inside axes
%  or
%        1 = Upper right-hand corner (default)
%        2 = Upper left-hand corner
%        3 = Lower left-hand corner
%        4 = Lower right-hand corner
%       -1 = To the right of the plot
% 
%  EXAMPLES:
%   figure(1); x=0:.1:10; y=sin(x); plot(x,y);
%   t=textLoc('North','North')
%   t=textLoc('southeastoutside',{'southeastoutside',1/20},'rotation',90)
%   t=textLoc('SouthEast',4)
%   t=textLoc('West',{'west',.1})
%   t=textLoc('northwest',{2,.3},'Color','red')
%   t=textLoc({'\downarrow','south'},'south')
%   t=textLoc('SWRot',{3},'rotation',45)
%   t=textLoc('NEOAbove',{'NorthEastOutsideAbove',0},'FontSize',8)
%   t=textLoc('textLoc','center','edgecolor','black','fontsize',20)
%
