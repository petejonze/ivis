function output = any2str(varargin)
% ANY2STR  desc.
%
% if just one value will return as char, else will return as cell
% (cellstr?)
%
% a = [1 2 3 4 5]
% num2str(a)
% ans = ['1'  '2'  '3'  '4'  '5']
% 
% a = [ 1 2 3 4 5]
% any2str(a)
% ans = '1  2  3  4  5'
% 
%
% c = {'hello','my','name',1,2,3}
% d = any2str(c{:})
% d = 'hello'    'my'    'name'    '1'    '2'    '3'
% d{1}
% ans = hello
    
    output = varargin;
    for i=1:nargin
        item = varargin{i};
        %disp(item)   %for testing
        %char(item)
        if ischar(item);   str = item; %??????????????
        elseif isnumeric(item);    str = num2str(item);
        elseif islogical(item);    str = log2str(item);
    	elseif iscell(item);
            for j=1:length(item)
                item{j} = any2str(item{j});
            end
        	str = item;
%     	elseif isstruct(item); str = struct2str(item);
%      	elseif strcmp(class(item), 'function_handle'), str= fh2str(item); 
     	else error('type conversion not supported');
        end
        
        output{i} = str;
    end

    if length(output) == 1
        output = output{1};
    end
  %return;
end