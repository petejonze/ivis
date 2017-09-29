function y = logadd(x1,x2)
% [x1 + x2]
% http://stackoverflow.com/questions/778047/we-know-log-add-but-how-to-do-log-subtract
%
% e.g.
%
% x1 = 10
% x2 = 10
% logadd(x1,x2)
% log(exp(x1)+exp(x2)) % for comaprison

    if isinf(x1) % check negative infinity
        y = x2;
        return;
    end
    if isinf(x2)
        y =  x1;
        return
    end
    y =  max(x1, x2) + log(1 + exp( -abs(x1 - x2) ));
end
