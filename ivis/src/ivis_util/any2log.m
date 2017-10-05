function output = any2log(varargin)
% see ANY2STR  desc.

    output = cell(1,length(varargin));
    for i=1:nargin
        item = varargin{i};
        if ischar(item);   lgcl = str2log(item);
        elseif isnumeric(item);    lgcl = min(1,abs(item))==1;
        elseif islogical(item);    lgcl = item;
            %     	elseif iscell(item);   str = cell2str(item);
            %     	elseif isstruct(item); str = struct2str(item);
            %      	elseif strcmp(class(item), 'function_handle'), str= fh2str(item);
        else error('type conversion not supported');
        end

        output{i} = lgcl;
    end
    
    if length(output) == 1
        output = output{1}; %unpack
    end
end