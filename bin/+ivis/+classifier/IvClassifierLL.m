%  Singleton instantiation of IvClassifier, in which the decision
%  variable is weighted cumulative-loglikelihood proportions, computed
%  using some specified underlying probability-density-function(s).
% 
%  When using a log-likelihood classifier (IvClassifierLL), the
%  likelihoods are calculated in the Update method (and then stored
%  for future use). Except to be precise it is actually the relative
%  proportions of the log-likelihoods that is important, and it is
%  the cumulative sum of the log-likelihoods. So the key variable is
%  wcllp (the weighted-cumulative-log-likelihhood-proportions). This
%  method queries the eyetracker for data, queries the graphics
%  objects for their positions at each data timepoint, and
%  calculates the log-likelihoods accordingly. It is given all the
%  necessary handles on initialisation, so that it knows where/what
%  to ask for the data.
% 
%  n.b., currently 1D classifier will always use the x-axis only
% 
%  http://www-structmed.cimr.cam.ac.uk/Course/Likelihood/likelihood.html
% 
%  IvClassifierLL Methods:
%    * IvClassifierLL	- Constructor.
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
%    IvClassifierBox, IvClassifierGrid, IvClassifierVector
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
%
