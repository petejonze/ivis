function escapedStr=escape(str)
%ESCAPE description. ???? IS THERE A BUILT IN METHOD TO DO THIS?? SURELY??
%
% desc
%
% Example: none
%
% See also
% 
% @Author: Pete R Jones
% @Date: 22/01/10

    %----------------------------------------------------------------------
    p = inputParser;
    p.addRequired('str', @(x)ischar(x) | iscellstr(x));
    p.FunctionName = 'ESCAPE';
    p.parse(str); % Parse & validate all input args
    %----------------------------------------------------------------------
    
    %escapedStr = regexprep(str,'\\','\\\\');
    escapedStr = regexprep(str, '(?<!\\)\\(?!\\)', '\\\\'); % only do for single strokes
    
end