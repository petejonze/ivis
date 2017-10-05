function ok=isPositiveInt(x)
    if ~isnumeric(x)
        ok = false;
        return
    end
    ok = x>0 & mod(x,1)==0;
end
