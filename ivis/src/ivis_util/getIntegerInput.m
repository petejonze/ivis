function userInput=getIntegerInput(promptText, varargin)
%GETINTEGERINPUT command-line prompts user for integer (whole numbers, such as 0,1,2,3...) information
%
% getIntegerInput(promptText)  returns the whole number that the user inputs. The prompt will loop for
% any other input, except 'q' which will terminate the entire script.
%
% Example: none
%
% See also getBooleanInput getNumericInput getStringInput
    
    %----------------------------------------------------------------------
    p = inputParser;   % Create an instance of the class.
    p.addRequired('prompt', @ischar);
    p.addOptional('allowNull', false, @islogical);
    p.addOptional('retries', Inf, @(x)x>=0 & mod(x,1)==0);
    p.addOptional('minMax', [-inf Inf]);
    p.FunctionName = 'GETINTEGERINPUT';
    p.parse(promptText, varargin{:}); % Parse & validate all input args
    %----------------------------------------------------------------------
    allowNull=p.Results.allowNull;
    numOfRetriesAllowed=p.Results.retries;
    minMax = p.Results.minMax;
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
                if isempty(x)
                    warning('getIntegerInput:invalidEntry','Input must be numeric');
                elseif x < minMax(1) || x > minMax(2)
                    warning('getIntegerInput:invalidEntry','number must lie within %i and %i (inclusive)', minMax(1), minMax(2));
                else
                    if isempty(x) %  empty value (str2num returns empty if not a valid numeric string)
                        warning('getIntegerInput:invalidEntry','Invalid input (must be a whole number)');
                    else                  
                        if (ceil(x) == floor(x)) % is an integer
                            userInput = x;
                            return % return the integer value
                        end
                    end
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
