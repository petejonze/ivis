function output = any2cellstr(varargin)
   
    output = varargin;
    for i=1:nargin
        item = varargin{i};
        %disp(item)   %for testing
        %char(item)
        if ischar(item);   str = item; %??????????????
        elseif isnumeric(item);    str = num2cellstr(item);
    	elseif iscell(item);
            str = item;
%             for j=1:length(item)
%                 item{j} = any2cellstr(item{j});
%             end
%         	str = item;
     	else error('type conversion not supported');
        end
        
        output{i} = str;
    end

    if length(output) == 1
        output = output{1};
    end
  %return;
end