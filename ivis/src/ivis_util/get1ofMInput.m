function userInput=get1ofMInput(promptText, m)
%GET1OFMINPUT command-line prompts user for 1 of M information
%
% ...
%
% Example: str2num(get1ofMInput('a: ', {'0','1','2'}))
%
% See also getBooleanInput getIntegerInput getNumericInput getStringInput

%     %----------------------------------------------------------------------
%     p = inputParser;   % Create an instance of the class.
%     p.addRequired('prompt', @ischar);
%     p.addOptional('allowQ', 0, @(x)x==0 || x==1);
%     p.FunctionName = 'GETSTRINGINPUT';
%     p.parse(promptText, varargin{:}); % Parse & validate all input args
%     allowQ = p.Results.allowQ;
%     %----------------------------------------------------------------------

   	% Open Command Window, or select it if already open
    commandwindow();
    
    while(1)
        x = input(promptText,'s'); % get user input
        if (~isempty(x)) % not empty user input
            if (any(strcmpi(x,m)))
                userInput=x;
                break % return user's choice
            elseif (x(1) == 'q') 
                error('script terminated by user') 
            end
        end 
    end 
    
end
