%  Screenobject responsible for remembering the position of an image at
%  each point in time. The associated PTB texture can be drawn by
%  invoking the draw() method. The classifier can request the location
%  of the image at any point in time, using the getXY() and getX0Y0()
%  methods.
% 
%  IvGraphic Methods:
%    * IvGraphic     - Constructor.
%    * draw          - Convenience wrapper for DrawTexture; if used should be called *immediately* after set().
%    * setXY         - Log mean XY position(s) at specified timepoint(s).
%    * nudge        	- Increment current XY position
%    * reset       	- Sets XY, and resets the history (n.b., may want to save the buffer history first?).
%    * getXY        	- Get mean xy position (in pixels) prior to each time specified timepoint (or the most recent point if no time specified).
%    * getX0Y0     	- Get top-left xy position (in pixels) prior to each time specified timepoint (or the most recent point if no time specified).
%    * getX          - Get current mean X position (in pixels).
%    * getY          - Get current mean Y position (in pixels).
%    * saveBuffer 	- Output xyt log to an external CSV file, linked in name to the appropriate IvDataLog file.
% 
%  IvGraphic Static Methods:   
%    * loadAll      	- convert all image files from a given directory into textures
% 
%  See Also:
%    none
% 
%  Example:
%    none
% 
%  Author:
%    Pete R Jones <petejonze@gmail.com>
% 
%  Verinfo:
%    1.0 PJ 02/2013 : first_build\n
% 
%  @todo: check getX0Y0
%  @todo: delete setXY and reinitXY
% 
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
% 
%
