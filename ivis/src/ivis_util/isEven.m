function ok=isEven(x)
    if ~isnumeric(x)
        ok = false;
        return
    end
    ok = mod(x,2)==0;
end
