function ok=isNonNegativeNum(x)
    if ~isnumeric(x)
        ok = false;
        return
    end
    ok = x>=0;
end