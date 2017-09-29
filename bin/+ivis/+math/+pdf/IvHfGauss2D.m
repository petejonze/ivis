%  Bivariate Gaussian probabilty distribution function for the
%  likelihood-based classifier(s).
% 
%  IvHfGauss2D Methods:
%    * IvHfGauss2D  	- Constructor.
%    * getPDF        - Get the probability of each value, x, given the probability density function.
%    * getRand       - Generate a column vector of n random values, given the probability density function.
%    * plot         	- Initialise the GUI element.
%    * updatePlot  	- update the GUI element.
% 
%  See Also:
%    none
% 
%  Example:
%    clearAbsAll; x = ivis.math.pdf.IvHfGauss2D([0 0], [100 100]), x.getPDF([-9991 -9991]), x.getPDF([-1 -1])
%   
%  Example:
%    ivisDemo011_advancedClassifiers_noScreen()
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
%  TODO: truncate
%
%    Reference page in Doc Center
%       doc ivis.math.pdf.IvHfGauss2D
%
%
