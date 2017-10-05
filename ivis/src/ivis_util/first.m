function y = first(x,dim)
%FIRST   first value.

% if nargin==1, 
%   % Determine which dimension SUM will use
%   dim = min(find(size(x)~=1));
%   if isempty(dim), dim = 1; end
% 
%   y = sum(x)/size(x,dim);
% else
%   y = sum(x,dim)/size(x,dim);
% end
if iscell(x)
    y = x{1};
else
    y = x(1);
end