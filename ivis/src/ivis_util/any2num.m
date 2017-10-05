function output = any2num(varargin)
% see ANY2STR  desc.
    
    if isempty(varargin{1})
        output = [];
        return;
    end
    
    output = nan(1,length(varargin));
    for i=1:nargin
        item = varargin{i};
        if ischar(item);   num = str2double(item);
        elseif isnumeric(item);    num = item;
        elseif islogical(item);    if item; num = 1; else num = 0; end
%     	elseif iscell(item);   str = cell2str(item);
%     	elseif isstruct(item); str = struct2str(item);
%      	elseif strcmp(class(item), 'function_handle'), str= fh2str(item); 
     	else error('type conversion not supported');
        end
        
        output(i) = num;
    end

end