function z=truncnormrnd(N,mu,sig,xlo,xhi)
% truncnormrnd: truncated normal deviate generator
% usage:z=truncnormrnd(N,mu,sig,xlo,xhi)
%
% (assumes the statistics toolbox, its easy
%  to do without that toolbox though)
%
% arguments: (input)
%  N   - size of the resulting array of deviates
%        (note, if N is a scalar, then the result will be NxN.)
%  mu  - scalar - Mean of underlying normal distribution
%  sig - scalar - Standard deviation of underlying normal distribution
%  xlo - scalar - Low truncation point, if any
%  xhi - scalar - High truncation point, if any
%
% arguments: (output)
%  z   - array of truncated normal deviates, size(z)==N

% defaults
if (nargin<2)||isempty(mu)
  mu=0;
end

if (nargin<3)||isempty(sig)
  sig=0;
end

if (nargin<4)||isempty(xlo)
  xlo=-inf;
  plo=0;
else
  plo=normcdf((xlo-mu)/sig);
end

if (nargin<5)||isempty(xhi)
  xhi=inf;
  phi=1;
else
  phi=normcdf((xhi-mu)/sig);
end

% test if trunation points are reversed
if xlo>xhi
  error 'Must have xlo <= xhi if both provided'
end

% generate uniform [0,1] random deviates
r=rand(N);

% scale to [plo,phi]
r=plo+(phi-plo)*r;

% Invert through standard normal
z=norminv(r);

% apply shift and scale
z=mu+z*sig;
