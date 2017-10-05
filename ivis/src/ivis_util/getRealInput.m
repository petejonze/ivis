function userInput=getRealInput(promptText, varargin)
%GETREALINPUT command-line prompts user for double (any number, e.g. 0.1, 3.1...) information
%
% getRealInput(promptText)  returns the number that the user inputs. The prompt will loop for
% any other input, except 'q' which will terminate the entire script.
%
% Example: none
%
% See also getBooleanInput getNumericInput getStringInput getIntegerInput
    
    %----------------------------------------------------------------------
    p = inputParser;   % Create an instance of the class.
    p.addRequired('prompt', @ischar);
    p.addOptional('allowNull', false, @islogical);
    p.addOptional('retries', Inf, @(x)x>=0 & mod(x,1)==0);
    p.FunctionName = 'GETINTEGERINPUT';
    p.parse(promptText, varargin{:}); % Parse & validate all input args
    %----------------------------------------------------------------------
    allowNull=p.Results.allowNull;
    numOfRetriesAllowed=p.Results.retries;
	%----------------------------------------------------------------------   

    % Open Command Window, or select it if already open
    commandwindow();
    
    % Intialise local variables
    retries = 0;
    
    while(retries <= numOfRetriesAllowed) 
        x = input(promptText,'s'); % get user input
        if (~isempty(x)) % not empty user input
            if (x(1) == 'q') 
                error('script terminated by user') 
            else   
                x = str2num(x);
                if isempty(x) %  empty value (str2num returns empty if not a valid numeric string)
                    warning('getRealInput:invalidEntry','Invalid input (must be a number)');
                else                  
                    userInput = x;
                    return % return the value
                end
            end
        else
            if allowNull
                break
            end
        end
        retries = retries+1;
    end
    
    % If we get to here then the max number of retries has been exceeded
    % without a valid entry
    userInput = [];
    
end
