function userInput=getLogicalInput(promptText)
%GETLOGICALINPUT command-line prompts user for boolean (yes/no) information
%
% getBooleanInput(promptText) returns 1 if the user indicates 'y', 't' or
% '1', or 0 if the user indicates 'n', 'f' or '0'. The prompt will loop for
% any other input, except 'q' which will terminate the entire script.
%
% Example: none
%
% See also getIntegerInput getNumericInput getStringInput

    %----------------------------------------------------------------------
    p = inputParser;   % Create an instance of the class.
    p.addRequired('prompt', @ischar);
    p.FunctionName = 'GETBOOLEANINPUT';
    p.parse(promptText); % Parse & validate all input args
    %----------------------------------------------------------------------
    
    % Open Command Window, or select it if already open
    commandwindow();
    
    while(1)
        x = input(promptText,'s'); % get user input
        if (~isempty(x)) % not empty user input
            if (x(1) == 'q') 
                error('script terminated by user') 
            else
                if ((x(1) == 'y') || (x(1) == 't') || (x(1) == '1'))
                    userInput = true;
                    break % return 'True'
                elseif ((x(1) == 'n') || (x(1) == 'f') || (x(1) == '0'))
                    userInput = false;
                    break % return 'False'
                end
            end
        end 
    end 
    
end
