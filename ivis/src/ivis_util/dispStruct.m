function dispStruct(thestruct, varargin)
%DISPSTRUCT shortdescr.
%
% added some functionality for structarrays (e.g. myStruct(2).blah...)
%
% Example: none
%
% See also
%
% for multi items structs
% 
% @Author: Pete R Jones
% @Date: 22/01/10

% changed size to length for numElements to allow for Mx1 structures as
% well as 1xN
% still won't work for MxN though!

% problem #00002: doesn't expand out the top level structure if it contains 
% more than 1 element?
%
% todo: allow user to specify how many levels to display

    %----------------------------------------------------------------------
    % Parse & validate all input args
    p = inputParser;
    p.addRequired('thestruct', @isstruct);
    p.addParamValue('indent', 4, @(x)x>=0 && mod(x,1)==0); %4 = disp()
    p.addParamValue('showNames', true, @islogical);
    p.addParamValue('showVals', true, @islogical);
    p.addParamValue('offshoot', false, @islogical);
    p.addParamValue('trailingBlank', true, @islogical);
    p.addParamValue('nStructElements', 1, @(x)x>=0 && mod(x,1)==0);
    p.FunctionName = 'DISPSTRUCT';
    p.parse(thestruct, varargin{:});
    indentNum = p.Results.indent;
    showNames = p.Results.showNames;
    showVals = p.Results.showVals;
    isOffshoot = p.Results.offshoot;
    isTrailingBlankLine = p.Results.trailingBlank;
    nStructElements = p.Results.nStructElements;
    %----------------------------------------------------------------------

    % attempt to fix problem #00002
    if ~isOffshoot
        % try to work out the name of the structure from the name of the
        % variable sent to the function call
        name = inputname(1);
        
    	% if there was no name (e.g. if it was created using cell2struct)
        % then assign a default name   
        if strcmpi(name,'')
            name = 'myStruct';
        end
        
        tmp.(name) = thestruct;
        thestruct = tmp;
    end
    
    %initialise local variables
    longestWordLength = 0;
    if (showNames && showVals)
        sepStr = ': ';
    else
        sepStr = '';
    end
    
    
    FNs = fieldnames(thestruct); %get field names
    FVs = struct2cell(thestruct); %get values
    
    for i=1:size(FNs,1)
        val = FVs{i};
        if isstruct(val)
            %nSubStructElements = size(val,2);
            nSubStructElements = length(val);
            if nSubStructElements > 1
                FNs{i} = sprintf('%s(%i)',FNs{i},nSubStructElements);
            end
        end
    end

    %display results
    for i=1:size(FNs,1)
        name = sub_getName(FNs,i);
        val = FVs{i};

        if isstruct(val)
            %nSubStructElements = size(val,2);
            nSubStructElements = length(val);
            
            for jj=1:nSubStructElements

                substruct = val(jj);
                dispname = '';
                if showNames
                    % buffer
                    substr = str(regexp(str,'('):end); %get from first parenthesis onwards
                    nDigits = length(regexp(substr,'\d'));
                    newNDigits = length(num2str(jj));
                    padding = blanks(nDigits-newNDigits);
                    dispname = regexprep(name,'\([\d]+\)',['(' padding num2str(jj) ')']);
                    if showVals %crude
                        dispname = regexprep(dispname,': ',':-|');
                    else
                        dispname = [dispname ' -|'];
                    end

                    disp(dispname)
                end
                dispStruct(substruct, 'indent',(length(dispname)-1),'showNames',showNames,'showVals',showVals,'offshoot',true,'nStructElements',nSubStructElements);
            end
        elseif ischar(val)
            valStr = sub_getCharVal(val);
            disp([name valStr])
        elseif isnumeric(val)
            valStr = sub_getNumVal(val);
            if isscalar(valStr)
                disp([name valStr])
            else
                disp([name mat2str(valStr)])
            end
     	elseif islogical(val)
            valStr = log2str(val);
            disp([name valStr])
        else
            valStr = sub_getCellVals(val);
            disp([name valStr])
            %error(['Sorry, unsupported item class: ' class(val)])
        end
    end

        
    %print blank line at end - like disp(struct)
    if ~isOffshoot
        if isTrailingBlankLine
            disp(' ')
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%
    %%% SUB FUNCTIONS %%%
    %%%%%%%%%%%%%%%%%%%%%
    function nameStr=sub_getName(strCell,i)
        if showNames
            longestWordLength = max(cellfun(@length,strCell));
            str = strCell{i};
            if isOffshoot
                strBuff = [blanks(indentNum) '|-' blanks(longestWordLength - length(str))]; %+5 to account for "|-" and ":-|"
            else
                strBuff = blanks(longestWordLength - length(str) + indentNum);
            end
            nameStr = [strBuff str sepStr];
        else
            nameStr = '';
        end
    end
    function valStr=sub_getCharVal(val)
        if showVals
            valStr = ['''' val '''']; %wrap in quote marks, e.g. foo => 'foo'
        else
            valStr = '';
        end
    end
    function valStr=sub_getNumVal(val) %convert class(numeric) => class(char)
        if showVals
            valStr = num2str(val);
        else
            valStr = '';
        end
    end
    function valStr=sub_getCellVals(val)
        if showVals
            vals = any2str(val{:});
            if iscell(vals) %may actually be a char if cell only contained one value
                valStr = ['{' strjoin1(', ',vals{:}) '}'];
            else
                valStr = vals;
            end
        else
            valStr = '';
        end
    end    
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% LOCAL FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%



