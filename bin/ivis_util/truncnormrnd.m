%  truncnormrnd: truncated normal deviate generator
%  usage:z=truncnormrnd(N,mu,sig,xlo,xhi)
% 
%  (assumes the statistics toolbox, its easy
%   to do without that toolbox though)
% 
%  arguments: (input)
%   N   - size of the resulting array of deviates
%         (note, if N is a scalar, then the result will be NxN.)
%   mu  - scalar - Mean of underlying normal distribution
%   sig - scalar - Standard deviation of underlying normal distribution
%   xlo - scalar - Low truncation point, if any
%   xhi - scalar - High truncation point, if any
% 
%  arguments: (output)
%   z   - array of truncated normal deviates, size(z)==N
%
