function y = nancumsum(x, dim)
    if nargin < 2 || isempty(dim)
        dim = 1;
    end
    
    x(isnan(x)) = 0;
    y = cumsum(x,dim);
end