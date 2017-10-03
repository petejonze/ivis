function y = logsubtract(x1,x2)
% substract x2 from x1  [x1 - x2]
% http://stackoverflow.com/questions/778047/we-know-log-add-but-how-to-do-log-subtract
%
% e.g.
%
% x1 = 10
% x2 = 5
% logsubtract(x1,x2)
% log(exp(x1)-exp(x2)) % for comaprison

    if(x1 <= x2)
        y = x2;
        return
        %error('logsubtract:invalidInput', 'computing the log of a negative number')
    end
    if isinf(x2)
        y = x1;
        return
    end

    y = x1 + log(1-exp(x2-x1));

end
