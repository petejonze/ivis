%% 02/05/2012, largely taken from SetupPsychtoolbox.m

% Locate ourselves:
targetdirectory=fileparts(mfilename('fullpath'));

% Begin
fprintf('Will setup working copy of the ivis folder inside: %s\n',targetdirectory);
fprintf('\n');

% Check that Psychtoolbox is installed (since the following is dependent on
% it)
try
    AssertOpenGL();
catch ME
    error('Installivis:missingDependencies','Psychtoolbox not found. The ivis toolbox will not work without it!');
end

% Check that PsychTestRig is installed (since is dependent on it)
try
    PsychTestRig();
catch ME
    error('Installivis:missingDependencies','PsychTestRig not found. The ivis toolbox will not work without it!');
end

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
fprintf('Now adding the new ivis folder (and all the /bin subfolders) to your MATLAB/OCTAVE path.\n');
addpath(targetdirectory);
% use genpath to find appropriate subdirectories also
addpath(genpath(fullfile(targetdirectory,'src'))); % addpath(genpath(fullfile(targetdirectory,'bin')));
addpath(fullfile(targetdirectory,'ivisdemos'));
addpath(fullfile(targetdirectory,'ivisdemos','demoResources'));

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

fprintf('\n\nivis has been successfully installed. Enjoy!\n-------------------\n\n');
fprintf('New to ivis? Try running some of the demos in "help ivisDemos".\n');