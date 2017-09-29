function h = IvHline(y,linetype,labeltext,linecolor,labelXposition)
% function h=IvHline(y, linetype, label)
% 
% Draws a horizontal line on the current axes at the location specified by 'y'.  Optional arguments are
% 'linetype' (default is 'r:') and 'label', which applies a text label to the graph near the line.  The
% label appears in the same color as the line.
%
% The line is held on the current axes, and after plotting the line, the function returns the axes to
% its prior hold state.
%
% The HandleVisibility property of the line object is set to "off", so not only does it not appear on
% legends, but it is not findable by using findobj.  Specifying an output argument causes the function to
% return a handle to the line, so it can be manipulated or deleted.  Also, the HandleVisibility can be 
% overridden by setting the root's ShowHiddenHandles property to on.
%
% h = IvHline(42,'g','The Answer')
%
% returns a handle to a green horizontal line on the current axes at y=42, and creates a text object on
% the current axes, close to the line, which reads "The Answer".
%
% IvHline also supports vector inputs to draw multiple lines at once.  For example,
%
% IvHline([4 8 12],{'g','r','b'},{'l1','lab2','LABELC'})
%
% draws three lines with the appropriate labels and colors.
% 
% By Brandon Kuczenski for Kensington Labs.
% brandon_kuczenski@kensingtonlabs.com
% 8 November 2001
    
    % parse inputs, validate, insert defaults
    nObjs = length(y);
    c = cell(1,nObjs);
    if nargin < 2 || isempty(linetype)
        linetype = cellfun(@(x)':',c,'UniformOut',false); % cell of ':'
    end
    if nargin < 3 || isempty(labeltext)
        labeltext = cellfun(@(x)'',c,'UniformOut',false); % cell of ''
    end
    if nargin < 4 || isempty(linecolor)
        linecolor = num2cell(jet(length(y)),2);
    end
    if nargin < 5 || isempty(labelXposition)
        xlims = xlim();
        x = linspace(xlims(1),xlims(2),length(y)+1);
        x(end) = [];
        x = x+0.02*(xlims(2)-xlims(1)); % nudge right
        labelXposition = x;
    end    

    % convert scalars to cell arrays (& auto expand to number of objects)
    if ~iscell(linetype)
        linetype = cellfun(@(x)linetype,c,'UniformOut',false); % = {linetype};
    end
    if ~iscell(labeltext)
        labeltext = cellfun(@(x)labeltext,c,'UniformOut',false); % {labeltext};
    end
    if ~iscell(linecolor)
        linecolor = cellfun(@(x)linecolor,c,'UniformOut',false); % {linecolor};
    end
    
    % plot
    h = nan(nObjs, 1);
    g=ishold(gca);
    hold on
    for i = 1:nObjs
        h(i)=plotLine(y(i), linetype{i}, labeltext{i}, linecolor{i}, labelXposition(i));
    end
    if g==0
        hold off
    end
end

function h = plotLine(y, linetype, label, linecolor, labelXPos)   
    x=get(gca,'xlim');
    h = plot(x,[y y],linetype,'color',linecolor);
    if ~isempty(label)
        yy=get(gca,'ylim');
        yrange=yy(2)-yy(1);
        yunit=(y-yy(1))/yrange;
        if yunit<0.2
            text(labelXPos,y+0.02*yrange,label,'color',get(h,'color'))
        else
            text(labelXPos,y+0.02*yrange,label,'color',get(h,'color'))
            %text(labelXPos,y-0.02*yrange,label,'color',get(h,'color'))
        end
    end

    set(h,'tag','IvHline','handlevisibility','off') % this last part is so that it doesn't show up on legends
end
