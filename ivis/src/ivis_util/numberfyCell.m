function [outCell,outMatrix] = numberfyCell(inCell, varargin)
%NUMBERFYCELL convert any numeric string cols to be numeric
%
%   convert string columns to numeric if appropriate. Inspired by
%   csv2struct().
%
%
% @Requires:        <blank>
%   
% @Parameters:     	<blank> 
%
% @Example:         <blank>
%
% @See also:        csv2struct()
%                   deNumberfyCell
% 
% @Author:          Pete R Jones
%
% @Creation Date:	25/08/10
% @Last Update:     25/08/10
%   
% @Todo:            allow blanks? not sure if working
%                   outsource to str2any script?
%                   should change name now, since also deals with logicals

    
    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('inCell', @iscell);
    p.addOptional('skipFirstRow', false, @islogical);
    p.FunctionName = 'NUMBERFYCELL';
    p.parse(inCell,varargin{:}); % Parse & validate all input args
    %----------------------------------------------------------------------
	skipFirstRow = p.Results.skipFirstRow; %useful if have headers
    %----------------------------------------------------------------------

    if skipFirstRow
        firstRow = 2;
    else
        firstRow = 1;
    end
    
    nRow = size(inCell,1);
    nCol = size(inCell,2);
    for c=1:nCol
        % get col
    	col = inCell(:,c);
        
        % add data (in numeric or text form)
        ColNumeric = true;
        for r = firstRow:nRow
            val = col{r};
            if ischar(val) && ~strcmpi('nan', strtrim(strtrim(val))) && isnan(str2double(val))
                if ~any(strcmpi(val,{'true','false',''})) %also allow these
                    ColNumeric = false;
                    break;
                end
            end
        end
        
        % convert values if necessary
        if ColNumeric
            for r = firstRow:nRow
                val = col{r};
                if ischar(val)
                    if strcmpi('nan', strtrim(val))
                        col{r} = NaN;
                    elseif any(strcmpi(col{r},{'true','false'}))
                        if strcmpi(col{r},'true')
                            col{r} = 1;
                        else
                            col{r} = 0;
                        end
                    else
                        col{r} = str2double(col{r});
                    end
                end
            end
            %set vals in cell
            inCell(:,c) = col;
        end
    end
    
    outCell = inCell;
    if all(cellfun(@isnumeric,outCell))
        outMatrix = cell2mat(outCell);
    else
        outMatrix = [];
    end
end