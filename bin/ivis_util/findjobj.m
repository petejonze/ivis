% findjobj Find java objects contained within a specified java container or Matlab GUI handle
% 
%  Syntax:
%     [handles, levels, parentIds, listing] = findjobj(container, 'PropName',PropValue(s), ...)
% 
%  Input parameters:
%     container - optional handle to java container uipanel or figure. If unsupplied then current figure will be used
%     'PropName',PropValue - optional list of property pairs (case insensitive). PropName may also be named -PropName
%          'position' - filter results based on those elements that contain the specified X,Y position or a java element
%                       Note: specify a Matlab position (X,Y = pixels from bottom left corner), not a java one
%          'size'     - filter results based on those elements that have the specified W,H (in pixels)
%          'class'    - filter results based on those elements that contain the substring  (or java class) PropValue
%                       Note1: filtering is case insensitive and relies on regexp, so you can pass wildcards etc.
%                       Note2: '-class' is an undocumented findobj PropName, but only works on Matlab (not java) classes
%          'property' - filter results based on those elements that possess the specified case-insensitive property string
%                       Note1: passing a property value is possible if the argument following 'property' is a cell in the
%                              format of {'propName','propValue'}. Example: FINDJOBJ(...,'property',{'Text','click me'})
%                       Note2: partial property names (e.g. 'Tex') are accepted, as long as they're not ambiguous
%          'depth'    - filter results based on specified depth. 0=top-level, Inf=all levels (default=Inf)
%          'flat'     - same as specifying: 'depth',0
%          'not'      - negates the following filter: 'not','class','c' returns all elements EXCEPT those with class 'c'
%          'persist'  - persist figure components information, allowing much faster results for subsequent invocations
%          'nomenu'   - skip menu processing, for "lean" list of handles & much faster processing;
%                       This option is the default for HG containers but not for figure, Java or no container
%          'print'    - display all java elements in a hierarchical list, indented appropriately
%                       Note1: optional PropValue of element index or handle to java container
%                       Note2: normally this option would be placed last, after all filtering is complete. Placing this
%                              option before some filters enables debug print-outs of interim filtering results.
%                       Note3: output is to the Matlab command window unless the 'listing' (4th) output arg is requested
%          'list'     - same as 'print'
%          'debug'    - list found component positions in the Command Window
% 
%  Output parameters:
%     handles   - list of handles to java elements
%     levels    - list of corresponding hierarchy level of the java elements (top=0)
%     parentIds - list of indexes (in unfiltered handles) of the parent container of the corresponding java element
%     listing   - results of 'print'/'list' options (empty if these options were not specified)
% 
%     Note: If no output parameter is specified, then an interactive window will be displayed with a
%     ^^^^  tree view of all container components, their properties and callbacks.
% 
%  Examples:
%     findjobj;                     % display list of all javaelements of currrent figure in an interactive GUI
%     handles = findjobj;           % get list of all java elements of current figure (inc. menus, toolbars etc.)
%     findjobj('print');            % list all java elements in current figure
%     findjobj('print',6);          % list all java elements in current figure, contained within its 6th element
%     handles = findjobj(hButton);                                     % hButton is a matlab button
%     handles = findjobj(gcf,'position',getpixelposition(hButton,1));  % same as above but also return hButton's panel
%     handles = findjobj(hButton,'persist');                           % same as above, persist info for future reuse
%     handles = findjobj('class','pushbutton');                        % get all pushbuttons in current figure
%     handles = findjobj('class','pushbutton','position',123,456);     % get all pushbuttons at the specified position
%     handles = findjobj(gcf,'class','pushbutton','size',23,15);       % get all pushbuttons with the specified size
%     handles = findjobj('property','Text','not','class','button');    % get all non-button elements with 'text' property
%     handles = findjobj('-property',{'Text','click me'});             % get all elements with 'text' property = 'click me'
% 
%  Sample usage:
%     hButton = uicontrol('string','click me');
%     jButton = findjobj(hButton,'nomenu');
%       % or: jButton = findjobj('property',{'Text','click me'});
%     jButton.setFlyOverAppearance(1);
%     jButton.setCursor(java.awt.Cursor.getPredefinedCursor(java.awt.Cursor.HAND_CURSOR));
%     set(jButton,'FocusGainedCallback',@myMatlabFunction);   % some 30 callback points available...
%     jButton.get;   % list all changeable properties...
% 
%     hEditbox = uicontrol('style','edit');
%     jEditbox = findjobj(hEditbox,'nomenu');
%     jEditbox.setCaretColor(java.awt.Color.red);
%     jEditbox.KeyTypedCallback = @myCallbackFunc;  % many more callbacks where this came from...
%     jEdit.requestFocus;
% 
%  Known issues/limitations:
%     - Cannot currently process multiple container objects - just one at a time
%     - Initial processing is a bit slow when the figure is laden with many UI components (so better use 'persist')
%     - Passing a simple container Matlab handle is currently filtered by its position+size: should find a better way to do this
%     - Matlab uipanels are not implemented as simple java panels, and so they can't be found using this utility
%     - Labels have a write-only text property in java, so they can't be found using the 'property',{'Text','string'} notation
% 
%  Warning:
%     This code heavily relies on undocumented and unsupported Matlab functionality.
%     It works on Matlab 7+, but use at your own risk!
% 
%  Bugs and suggestions:
%     Please send to Yair Altman (altmany at gmail dot com)
% 
%  Change log:
%     2012-07-25: Fixes for R2012b as well as some older Matlab releases
%     2011-12-07: Fixed 'File is empty' messages in compiled apps
%     2011-11-22: Fix suggested by Ward
%     2011-02-01: Fixes for R2011a
%     2010-06-13: Fixes for R2010b; fixed download (m-file => zip-file)
%     2010-04-21: Minor fix to support combo-boxes (aka drop-down, popup-menu) on Windows
%     2010-03-17: Important release: Fixes for R2010a, debug listing, objects not found, component containers that should be ignored etc.
%     2010-02-04: Forced an EDT redraw before processing; warned if requested handle is invisible
%     2010-01-18: Found a way to display label text next to the relevant node name
%     2009-10-28: Fixed uitreenode warning
%     2009-10-27: Fixed auto-collapse of invisible container nodes; added dynamic tree tooltips & context-menu; minor fix to version-check display
%     2009-09-30: Fix for Matlab 7.0 as suggested by Oliver W; minor GUI fix (classname font)
%     2009-08-07: Fixed edge-case of missing JIDE tables
%     2009-05-24: Added support for future Matlab versions that will not support JavaFrame
%     2009-05-15: Added sanity checks for axes items
%     2009-04-28: Added 'debug' input arg; increased size tolerance 1px => 2px
%     2009-04-23: Fixed location of popupmenus (always 20px high despite what's reported by Matlab...); fixed uiinspect processing issues; added blog link; narrower action buttons
%     2009-04-09: Automatic 'nomenu' for uicontrol inputs; significant performance improvement
%     2009-03-31: Fixed position of some Java components; fixed properties tooltip; fixed node visibility indication
%     2009-02-26: Indicated components visibility (& auto-collapse non-visible containers); auto-highlight selected component; fixes in node icons, figure title & tree refresh; improved error handling; display FindJObj version update description if available
%     2009-02-24: Fixed update check; added dedicated labels icon
%     2009-02-18: Fixed compatibility with old Matlab versions
%     2009-02-08: Callbacks table fixes; use uiinspect if available; fix update check according to new FEX website
%     2008-12-17: R2008b compatibility
%     2008-09-10: Fixed minor bug as per Johnny Smith
%     2007-11-14: Fixed edge case problem with class properties tooltip; used existing object icon if available; added checkbox option to hide standard callbacks
%     2007-08-15: Fixed object naming relative property priorities; added sanity check for illegal container arg; enabled desktop (0) container; cleaned up warnings about special class objects
%     2007-08-03: Fixed minor tagging problems with a few Java sub-classes; displayed UIClassID if text/name/tag is unavailable
%     2007-06-15: Fixed problems finding HG components found by J. Wagberg
%     2007-05-22: Added 'nomenu' option for improved performance; fixed 'export handles' bug; fixed handle-finding/display bugs; "cleaner" error handling
%     2007-04-23: HTMLized classname tooltip; returned top-level figure Frame handle for figure container; fixed callbacks table; auto-checked newer version; fixed Matlab 7.2 compatibility issue; added HG objects tree
%     2007-04-19: Fixed edge case of missing figure; displayed tree hierarchy in interactive GUI if no output args; workaround for figure sub-menus invisible unless clicked
%     2007-04-04: Improved performance; returned full listing results in 4th output arg; enabled partial property names & property values; automatically filtered out container panels if children also returned; fixed finding sub-menu items
%     2007-03-20: First version posted on the MathWorks file exchange: <a href="http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=14317">http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=14317</a>
% 
%  See also:
%     java, handle, findobj, findall, javaGetHandles, uiinspect (on the File Exchange)
%
