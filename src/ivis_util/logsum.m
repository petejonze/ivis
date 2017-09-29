function y = logsum(x)
% bit of a hack, but will do for now
%
% e.g.
%
% x = [10 10 10]
% logsum(x)
% log(sum(exp(x)))

%             if ndims(x)>2
%             error('a:b','Functionality not yet written');
%         end

    % 2D matrix: down columns ONLY
    y = x(1,:);

    if any(isinf(x)) % check negative infinity
        return;
    end

    for i = 2:size(x,1)
        y =  max(y, x(i,:)) + log(1 + exp( -abs(y - x(i,:)) ));
    end



%     if any(size(x)==1) % vector
%         y = x(1);
% 
%         if any(isinf(x)) % check negative infinity
%             return;
%         end
% 
%         for i = 2:length(x)
%             y =  max(y, x(i)) + log(1 + exp( -abs(y - x(i)) ));
%         end
%     else % 2D matrix
%         y = x(1,:);
% 
%         if any(isinf(x)) % check negative infinity
%             return;
%         end
% 
%         for i = 2:size(x,1)
%             y =  max(y, x(i,:)) + log(1 + exp( -abs(y - x(i,:)) ));
%         end
%     end
end
% vector only version:
% function y = logsum(x)
% % bit of a hack, but will do for now
% %
% % e.g.
% %
% % x = [10 10 10]
% % logsum(x)
% % log(sum(exp(x)))
%
%
%     y = x(1);
%
%     if any(isinf(x)) % check negative infinity
%         return;
%     end
%
%     for i = 2:length(x)
%         y =  max(y, x(i)) + log(1 + exp( -abs(y - x(i)) ));
%     end
% end
