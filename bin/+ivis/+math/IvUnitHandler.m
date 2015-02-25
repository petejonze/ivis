%  Utility singleton for converting between distances on screen (cm, px, dg)
% 
%  Note that these conversions require setup-specific info, regarding the
%  dimensions of the monitor, the screen resolution, and the distance of the
%  observer to the screen. The singleton object should be informed about
%  these things upon initialisation.
% 
%  IvUnitHandler Methods:
%    * IvUnitHandler	- Constructor.
%    * px2cm         - Convert pixels to cm.
%    * px2deg        - Convert pixels to degrees visual angle.
%    * deg2px        - Convert degrees visual angle to pixels.
%    * cm2px        	- Convert cm to pixels.
%    * cm2deg       	- Convert cm to degrees visual angle.
%    * deg2cm       	- Convert degrees visual angle to cm.    
% 
%  See Also:
%    ivis.math.IvUnitHandler
% 
%  Example:
%    runtests infantvision.tests -verbose
% 
%  Author:
%    Pete R Jones <petejonze@gmail.com>
% 
%  Verinfo:
%    1.1 PJ 02/2011 : used to develop commenting standards\n
%    1.0 PJ 02/2011 : first_build
% 
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
% 
%
