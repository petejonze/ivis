function [] = clearJavaMem()
% A wrapper for jheapl, by Davide Tabarelli
% http://www.mathworks.co.uk/matlabcentral/fileexchange/36757-java-heap-cleaner

    %%%%%%%
    %% 1 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Ensure that MatlabGarbageCollector.jar is located on the Dynamic Java
    % Path (n.b., can't simply add to the static path, since classpath.txt
    % is not writable for many users. Could simply replace all of the below
    % with: javaaddpath(which('MatlabGarbageCollector.jar')). However
    % javaaddpath automatically clears the java memory, which can have some
    % unfortunate knock on consequences if this is called within another
    % script)
    % This way it is possible to safely call clearJavaMem anywhere in the
    % script, as long as it was first called at least once at the start

        % locate the jar file
        jheapclJar = which('MatlabGarbageCollector.jar');
        if isempty(jheapclJar)
            error('MatlabGarbageCollector.jar not found?!');
        end

        % if not already on the dynamic path..
        oldpath = javaclasspath('-all');
        if ~ismember(jheapclJar, oldpath)
            % .. add to path
            warning('clearJavaMem is modifying the dynamic class path. This will clear the java memory. In the process all [Global] variables will be removed from the base workspace, and all compiled scripts, functions, and  MEX-functions will be cleared from memory.');
            javaaddpath(jheapclJar);
        else
            % do nothing
        end

    %%%%%%%
    %% 2 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Clear java memory %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        jheapcl();
    
end