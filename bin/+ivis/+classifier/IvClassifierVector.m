%  Singleton instantiation of IvClassifier, in which the decision
%  variable is the additive movement vector, with a direction that must
%  lie within some prescribed bin, and a magnitude that must exceed some
%  arbitrary threshold.
% 
%  IvClassifierVector Methods:
%    * IvClassifierVector	- Constructor.
%    * start         - Start accruing evidence towards each alternative.
%    * update        - Update evidence.
%    * getStatus     - Get current status code.
%    * isUndecided   - Convenience wrapper for: obj.status == obj.STATUS_UNDECIDED.
%    * interogate    - Make an (optionally forced) response, based on current level of evidence (if unforced may return obj.NULL_OBJ).
%    * draw          - Visualise classifier on a PTB OpenGL screen.
%    * show          - Enable automatic PTB screen texture drawing, allowing the observer to see the classification area(s).
%    * hide          - Disable automatic PTB screen texture drawing.
% 
%  See Also:
%    IvClassifierBox, IvClassifierGrid, IvClassifierLL
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
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
% 
%  if no graphicObjs specified, just test for most likely polygon area (quadrant)
%  (currently the latter will crash, due to some crude hacks [simple fixes])
%  n.b. '0' is due north in the deg form
%
%    Reference page in Doc Center
%       doc ivis.classifier.IvClassifierVector
%
%
