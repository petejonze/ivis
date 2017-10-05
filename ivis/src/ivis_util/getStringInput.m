function userInput=getStringInput(promptText, varargin)
%GETSTRINGINPUT command-line prompts user for string (text) information
%
% getStringInput(promptText, [allowQ]) returns the user's input. If blank 
% then the prompt will repeat indefinitely. If the input is 'q' then the 
% script will terminate, unless allowQ==1. AllowQ can take either the value 
% 0 or 1.
% If allowQ is not given, 0 is assumed
%
% Example: none
%
% See also getBooleanInput getIntegerInput getNumericInput

    %----------------------------------------------------------------------
    p = inputParser;   % Create an instance of the class.
    p.addRequired('prompt', @ischar);
    p.addOptional('allowNull', 0, @(x)x==0 || x==1);
    p.addOptional('allowQ', 1, @(x)x==0 || x==1); % optional abort char
    p.FunctionName = 'GETSTRINGINPUT';
    p.parse(promptText, varargin{:}); % Parse & validate all input args
    allowQ = p.Results.allowQ;
    allowNull = p.Results.allowNull;
    %----------------------------------------------------------------------

  	% Open Command Window, or select it if already open
    commandwindow();
    
    while(1)
        x = input(promptText,'s'); % get user input
        if (~isempty(x)) % not empty user input
            if (~allowQ && x(1) == 'q') 
                error('script terminated by user') 
            else
                userInput = x;
                break % return 'True'
            end
        elseif (allowNull)
            userInput = '';
            break
        end
    end 
    
end
