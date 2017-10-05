function x=column(x)
    if isvector(x)
        if size(x,2)>1
            x = x';
        end
    else
        error('a:b','invalid input (not a vector)');
    end
end