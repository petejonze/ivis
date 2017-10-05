function [] = ivisDemos_runall(runFromDemoN)
% run all the demos!
% if any fail then will carry on from last failed demo, unless runall(true)

if nargin<1 || isempty(runFromDemoN)
    runFromDemoN = 1;
end

if ~ispref('ivis','demoN')
    addpref('ivis','demoN',1);
end
setpref('ivis','demoN',runFromDemoN);


while 1
    s = dir(fullfile(ivisdir,'demos','*.m'));
    demoN = getpref('ivis','demoN');
    
    if demoN > length(s)
        fprintf('No more demos left to play! Time to have a go for yourself =)\n');
        break
    end
    
    % get name
    d = s(demoN).name(1:end-2);
      
    % skip it if it is this file!
    if strcmpi(d, mfilename())
    	setpref('ivis','demoN', demoN+1)
        continue;
    end
    
    % run
    fprintf('\n=======================================================\n');
    fprintf('Demo %i: %s\n', demoN, d);
    fprintf('=======================================================\n');
    fprintf('Press any key to begin\n');
    KbWait([],2);
    fprintf('Launching "%s"...\n\n', d);
    eval(d)
    
    % iterate counter
    setpref('ivis','demoN', getpref('ivis','demoN')+1)
end

rmpref('ivis','demoN')