%  function X = TruncatedGaussian(sigma, range)
%           X = TruncatedGaussian(sigma, range, n)
% 
%  Purpose: generate a pseudo-random vector X of size n, X are drawn from
%  the truncated Gaussian distribution in a RANGE braket; and satisfies
%  std(X)=sigma.
%  RANGE is of the form [left,right] defining the braket where X belongs.
%  For a scalar input RANGE, the braket is [-RANGE,RANGE].
% 
%  X = TruncatedGaussian(..., 'double') or
%  X = TruncatedGaussian(..., 'single') return an array X of of the
%     specified class.
% 
%  If input SIGMA is negative, X will be forced to have the same "shape" of
%  distribution function than the unbounded Gaussian with standard deviation
%  -SIGMA: N(0,-SIGMA). It is similar to calling RANDN and throw away values
%  ouside RANGE. In this case, the standard deviation of the truncated
%  Gaussian will be different than -SIGMA. The *effective* mean and
%  the effective standard deviation can be obtained by calling:
%    [X meaneffective sigmaeffective] = TruncatedGaussian(...)
% 
%  Example:
%  
%  sigma=2;
%  range=[-3 5]
%  
%  [X meaneff sigmaeff] = TruncatedGaussian(sigma, range, [1 1e6]);
%  
%  stdX=std(X);
%  fprintf('mean(X)=%g, estimated=%g\n',meaneff, mean(X))
%  fprintf('sigma=%g, effective=%g, estimated=%g\n', sigma, sigmaeff, stdX)
%  hist(X,64)
% 
%  Author: Bruno Luong <brunoluong@yahoo.com>
%  Last update: 19/April/2009
%               12-Aug-2010, use asymptotic formula for unbalanced
%                            range to avoid round-off error issue
%
