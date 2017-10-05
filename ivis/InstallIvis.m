% v0.1 PJ 02/05/2012  largely taken from SetupPsychtoolbox.m
% v1.5 PJ 03/10/2017  Better dependency checks

% Check dependencies
fprintf('Preliminaries: Checking that required dependencies are present\n');
ok = true;

% get version info
x = ver();

% Check that MATLAB is sufficiently up to date
v = str2double(x(strcmpi('MATLAB',{x.Name})).Version);
if v < 8.5
  	ok = false;
    warning('InstallIvis:missingDependencies','MATALB version older than 8.5 (2015) detected. The ivis toolbox does not work on older platforms (e.g., due to the use of OOP syntax)');
end

% Check that MATLAB stats toolbox is installed
if ~ismember('Statistics and Machine Learning Toolbox', {x.Name})
  	ok = false;
    warning('InstallIvis:missingDependencies','Statistics Toolbox not found. The ivis toolbox will not work without it!');
else
    % try running example command
    try
        makedist('Uniform', 0, 100);
    catch ME
        ok = false;
        warning('InstallIvis:missingDependencies','Statistics Toolbox function "makedist()" failed to execute. The ivis toolbox will not work without a working version of Statistics Toolbox!');
    end
end

% Check that Psychtoolbox is installed (since the following is dependent on
% it)
if ~ismember('Psychtoolbox', {x.Name})
 	ok = false;
    warning('InstallIvis:missingDependencies','Psychtoolbox not found. The ivis toolbox will not work without it!');
else
    % try running example command
    try
        AssertOpenGL();
    catch ME
        ok = false;
        warning('InstallIvis:missingDependencies','Psychtoolbox function "AssertOpenGL()" failed to execute. The ivis toolbox will not work without a working version of Psychtoolbox!');
    end
end

% throw error if any requirements not met
if ~ok
    error('One or more requirements not met. See warnings above for details.');
end

% Locate ourselves:
targetdirectory=fileparts(mfilename('fullpath'));

% Begin
fprintf('Will setup working copy of the ivis folder inside: %s\n\n',targetdirectory);

% Remove any previous from path:
searchpattern = sprintf('[^%s]*%sivis+[^%s]*%s',pathsep,filesep,pathsep,pathsep);
searchpattern = regexprep(searchpattern,'\\','\\\\'); % escape any backslashes
while any(regexp(path, searchpattern))
    fprintf('Your old ivis appears in the MATLAB/OCTAVE path:\n');
    paths=regexp(path, searchpattern, 'match');
    fprintf('Your old ivis appears %d times in the MATLAB/OCTAVE path.\n',numel(paths));
    % Old and wrong, counts too many instances: fprintf('Your old Psychtoolbox appears %d times in the MATLAB/OCTAVE path.\n',length(paths));
    answer=input('Before you decide to delete the paths, do you want to see them (y or n)? ','s');
    if ~strcmp(answer,'y')
        fprintf('You didn''t say "yes", so I''m taking it as no.\n');
    else
        for p=paths
            s=char(p);
            if any(regexp(s,searchpattern))
                fprintf('%s\n',s);
            end
        end
    end
    answer=input('Shall I delete all those instances from the MATLAB/OCTAVE path (y or n)? ','s');
    if ~strcmp(answer,'y')
        fprintf('You didn''t say yes, so I cannot proceed.\n');
        fprintf('Please use the MATLAB "File:Set Path" command or its Octave equivalent to remove all instances of "ivis" from the path.\n');
        error('Please remove ivis from MATLAB/OCTAVE path.');
    end
    for p=paths
        s=char(p);
        %fprintf('rmpath(''%s'')\n',s);
        rmpath(s);
    end
    if exist('savepath') %#ok<EXIST>
       savepath;
    else
       path2rc;
    end

    fprintf('Success!\n\n');
end

% Add ivis to MATLAB/OCTAVE path
fprintf('Now adding the new ivis folder (and all the necessary subfolders) to your MATLAB/OCTAVE path.\n');
addpath(targetdirectory);
% use genpath to find appropriate subdirectories also
addpath(genpath(fullfile(targetdirectory,'src'))); % addpath(genpath(fullfile(targetdirectory,'bin')));
addpath(fullfile(targetdirectory,'demos'));
addpath(fullfile(targetdirectory,'demos','resources'));

if exist('savepath') %#ok<EXIST>
   err=savepath;
else
   err=path2rc;
end

if err
    fprintf('SAVEPATH failed. ivis is now already installed and configured for use on your Computer,\n');
    fprintf('but i could not save the updated Matlab/Octave path, probably due to insufficient permissions.\n');
    fprintf('You will either need to fix this manually via use of the path-browser (Menu: File -> Set Path),\n');
    fprintf('or by manual invocation of the savepath command (See help savepath). The third option is, of course,\n');
    fprintf('to add the path to the Psychtoolbox folder and all of its subfolders whenever you restart Matlab.\n\n\n');
else 
    fprintf('Add to path success.\n\n');
end

% create necessary additional subdirectories if required
% (NB: these may have been lost during the upload/download to GitHub, as
% Git has no concept of empty directories)
fullFn = fullfile(ivisdir(), 'logs');
if ~exist(fullFn, 'dir')
    fprintf('Directory not found (%s), creating..\n', fullFn);
    mkdir(fullFn);
end
fullFn = fullfile(ivisdir(), 'logs', 'data');
if ~exist(fullFn, 'dir')
    fprintf('Directory not found (%s), creating..\n', fullFn);
    mkdir(fullFn);
end
fullFn = fullfile(ivisdir(), 'logs', 'raw');
if ~exist(fullFn, 'dir')
    fprintf('Directory not found (%s), creating..\n', fullFn);
    mkdir(fullFn);
end
fullFn = fullfile(ivisdir(), 'logs', 'diary');
if ~exist(fullFn, 'dir')
    fprintf('Directory not found (%s), creating..\n', fullFn);
    mkdir(fullFn);
end

% finish up
fprintf('\n\nivis has been successfully installed. Enjoy!\n-------------------\n\n');
fprintf('New to ivis? Try running some of the demos in "help demos".\n');