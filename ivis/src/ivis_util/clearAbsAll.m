% Clear command window:
% clc;

% Close figures:
try
  close('all', 'hidden');
catch  %#ok do nothing
end

% Closing figures might fail if the CloseRequestFcn of a figure
% blocks the execution. Fallback:
AllFig = allchild(0);
if ~isempty(AllFig)
   set(AllFig, 'CloseRequestFcn', '', 'DeleteFcn', '');
   delete(AllFig);
end

% Clear loaded functions:
clear all;
clear('functions');
clear('classes');
clear('global');
% clear('import');  % Not from inside a function!
clear('variables');
clear('java');

% Stop and delete timers:
AllTimer = timerfindall;
if ~isempty(AllTimer)  % EDITED: added check
   stop(AllTimer);
   delete(AllTimer);
end

% Unlock M-files:
LoadedM = inmem;
for iLoadedM = 1:length(LoadedM)
   % EDITED: Use STRTOK to consider OO methods:
   aLoadedM = strtok(LoadedM{iLoadedM}, '.'); 
   try
    munlock(aLoadedM);
   catch, end
   clear(aLoadedM);
end   

% Close open files:
fclose('all');

% final pass
clear all;
clear('functions');
clear('classes');
clear('global');
clear('variables');
clear('java');