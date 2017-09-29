%  Bivariate uniform probabilty distribution function for the
%  likelihood-based classifier(s).
% 
%  IvHfUniform2D Methods:
%    * IvHfUniform2D - Constructor.
%    * getPDF        - Get the probability of each value, x, given the probability density function.
%    * getRand       - Generate a column vector of n random values, given the probability density function.
%    * plot         	- Initialise the GUI element.
%    * updatePlot  	- update the GUI element.
%    
%  See Also:
%    none
% 
%  Example:
%    clearAbsAll; x = ivis.math.pdf.IvHfUniform2D([0 0], [100 100]), x.getPDF([-9991 -9991]), x.getPDF([-1 -1])
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
%    Reference page in Doc Center
%       doc ivis.math.pdf.IvHfUniform2D
%
%
