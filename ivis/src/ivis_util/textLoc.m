function [H]=textLoc(varargin)
% function [H]=textLoc('string',location[,parameter,value,...])
%
% Puts string onto the current axes with location similar to legend locations.
% Passes all parameter, value pairs to text. textLoc works with semilog and 
% loglog plots.
% 
% H is the handle from the text command after modifications by textLoc.
%
% location can also be a 1x2 cell array containing {location,buffer} where
%   buffer is a spacing buffer (in normalized units) for distance from the axes.
%   buffer default is 1/50
%
% location can be any of:
%        'North'                   inside plot box near top
%        'South'                   inside bottom
%        'East'                    inside right
%        'West'                    inside left
%        'Center'                  centered on plot
%        'NorthEast'               inside top right (default)
%        'NorthWest'                inside top left
%        'SouthEast'               inside bottom right
%        'SouthWest'               inside bottom left
%        'NorthOutside'            outside plot box near top
%        'SouthOutside'            outside bottom
%        'EastOutside'             outside right
%        'WestOutside'             outside left
%        'NorthEastOutside'        outside top right
%        'NorthWestOutside'        outside top left
%        'SouthEastOutside'        outside bottom right
%        'SouthWestOutside'        outside bottom left
%        'NorthEastOutsideAbove'   outside top right (above)
%        'NorthWestOutsideAbove'   outside top left (above)
%        'SouthEastOutsideBelow'   outside bottom right (below)
%        'SouthWestOutsideBelow'   outside bottom left (below)
%        'Random'                  Random placement inside axes
% or
%       1 = Upper right-hand corner (default)
%       2 = Upper left-hand corner
%       3 = Lower left-hand corner
%       4 = Lower right-hand corner
%      -1 = To the right of the plot
%
% EXAMPLES:
%  figure(1); x=0:.1:10; y=sin(x); plot(x,y);
%  t=textLoc('North','North')
%  t=textLoc('southeastoutside',{'southeastoutside',1/20},'rotation',90)
%  t=textLoc('SouthEast',4)
%  t=textLoc('West',{'west',.1})
%  t=textLoc('northwest',{2,.3},'Color','red')
%  t=textLoc({'\downarrow','south'},'south')
%  t=textLoc('SWRot',{3},'rotation',45)
%  t=textLoc('NEOAbove',{'NorthEastOutsideAbove',0},'FontSize',8)
%  t=textLoc('textLoc','center','edgecolor','black','fontsize',20)

%testall={'North','South','East','West','Center','NorthEast','NorthWest','SouthEast','SouthWest','NorthOutside','SouthOutside','EastOutside','WestOutside','NorthEastOutside','NorthWestOutside','SouthEastOutside','SouthWestOutside','NorthEastOutsideAbove','NorthWestOutsideAbove','SouthEastOutsideBelow','SouthWestOutsideBelow','Random'};for i=1:length(testall),textLoc(testall{i},testall{i}); end

% Author: Ben Barrowes, barrowes@alum.mit.edu


if nargin<2
 varargin{2}=1;
end

% send all but 2nd arg to text
tArg=true(1,length(varargin)); tArg(2)=false;
H=text(0,0,varargin{tArg});

%locationing and 2nd arg handling
loc=varargin{2};
buffer=1/50;
if iscell(loc)
 if length(loc)==0
  loc=1;
 elseif length(loc)==1
  loc=loc{1};
 elseif length(loc)>1
  buffer=loc{2};
  loc=loc{1};
 end
end
if isnumeric(loc)
 loc=num2str(loc);
end


% HACK!
if strcmpi('latex',get(0,'defaulttextinterpreter'))
    buffer = buffer*5;
end

% set the text position
set(H,'units','normalized');
switch lower(loc)
  case 'north' %              inside plot box near top
    set(H,'Position',[.5,1-buffer]);
    set(H,'HorizontalAlignment','Center');
    set(H,'VerticalAlignment','Top');
  case 'south' %              inside bottom
    set(H,'Position',[.5,  buffer]);
    set(H,'HorizontalAlignment','Center');
    set(H,'VerticalAlignment','Bottom');
  case 'east' %               inside right
    set(H,'Position',[1-buffer,.5]);
    set(H,'HorizontalAlignment','Right');
    set(H,'VerticalAlignment','Middle');
  case 'west' %               inside left
    set(H,'Position',[  buffer,.5]);
    set(H,'HorizontalAlignment','Left');
    set(H,'VerticalAlignment','Middle');
  case 'center' %               inside left
    set(H,'Position',[.5,.5]);
    set(H,'HorizontalAlignment','Center');
    set(H,'VerticalAlignment','Middle');
  case {'northeast','1'} %          inside top right (default)
    set(H,'Position',[1-buffer,1-buffer]);
    set(H,'HorizontalAlignment','Right');
    set(H,'VerticalAlignment','Top');
  case {'northwest','2'} %           inside top left
    set(H,'Position',[  buffer,1-buffer]);
    set(H,'HorizontalAlignment','Left');
    set(H,'VerticalAlignment','Top');
  case {'southeast','4'} %          inside bottom right
    set(H,'Position',[1-buffer,  buffer]);
    set(H,'HorizontalAlignment','Right');
    set(H,'VerticalAlignment','Bottom');
  case {'southwest','3'} %          inside bottom left
    set(H,'Position',[  buffer,  buffer]);
    set(H,'HorizontalAlignment','Left');
    set(H,'VerticalAlignment','Bottom');
  case 'northoutside' %       outside plot box near top
    set(H,'Position',[.5,1+buffer]);
    set(H,'HorizontalAlignment','Center');
    set(H,'VerticalAlignment','Bottom');
  case 'southoutside' %       outside bottom
    set(H,'Position',[.5, -buffer]);
    set(H,'HorizontalAlignment','Center');
    set(H,'VerticalAlignment','Top');
  case 'eastoutside' %        outside right
    set(H,'Position',[1+buffer,.5]);
    set(H,'HorizontalAlignment','Left');
    set(H,'VerticalAlignment','Middle');
  case 'westoutside' %        outside left
    set(H,'Position',[ -buffer,.5]);
    set(H,'HorizontalAlignment','Right');
    set(H,'VerticalAlignment','Middle');
  case {'northeastoutside','-1'} %   outside top right
    set(H,'Position',[1+buffer,1]);
    set(H,'HorizontalAlignment','Left');
    set(H,'VerticalAlignment','Top');
  case 'northwestoutside' %   outside top left
    set(H,'Position',[ -buffer,1]);
    set(H,'HorizontalAlignment','Right');
    set(H,'VerticalAlignment','Top');
  case 'southeastoutside' %   outside bottom right
    set(H,'Position',[1+buffer,0]);
    set(H,'HorizontalAlignment','Left');
    set(H,'VerticalAlignment','Bottom');
  case 'southwestoutside' %   outside bottom left
    set(H,'Position',[ -buffer,0]);
    set(H,'HorizontalAlignment','Right');
    set(H,'VerticalAlignment','Bottom');
  case 'northeastoutsideabove' %   outside top right (above)
    set(H,'Position',[1,1+buffer]);
    set(H,'HorizontalAlignment','Right');
    set(H,'VerticalAlignment','Bottom');
  case 'northwestoutsideabove' %   outside top left (above)
    set(H,'Position',[0,1+buffer]);
    set(H,'HorizontalAlignment','Left');
    set(H,'VerticalAlignment','Bottom');
  case 'southeastoutsidebelow' %   outside bottom right (below)
    set(H,'Position',[1, -buffer]);
    set(H,'HorizontalAlignment','Right');
    set(H,'VerticalAlignment','Top');
  case 'southwestoutsidebelow' %   outside bottom left (below)
    set(H,'Position',[0, -buffer]);
    set(H,'HorizontalAlignment','Left');
    set(H,'VerticalAlignment','Top');
  case 'random' % random placement
    set(H,'Position',[rand(1,2)]);
    set(H,'HorizontalAlignment','Center');
    set(H,'VerticalAlignment','Middle');
  otherwise
    error('location (4th argument) not recognized by textLoc')
end
