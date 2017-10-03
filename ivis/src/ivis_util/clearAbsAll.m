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
warning off
clear all;
clear('functions');
clear('classes');
clear('global');
clear('variables');
clear('java');
warning on

% Stop and delete timers:
AllTimer = timerfindall;
if ~isempty(AllTimer)
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
    warning off
   clear(aLoadedM);
    warning on
end   

% Close open files:
fclose('all');

% final pass
warning off
clear all;
clear('functions');
clear('classes');
clear('global');
clear('variables');
clear('java');
warning on