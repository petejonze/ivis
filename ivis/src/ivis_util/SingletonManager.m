classdef SingletonManager
 	% Singleton manager class that maintains references to each Singleton
 	% object (and provides a mechanism to find and/or delete all
 	% Singletons).
    %
    % Singleton Static Methods:
    %   * add    	- Register specified Singleton.
    %   * remove  	- Delete specified Singleton.
    %   * clearAll 	- Delete all Singletons.
    %   * listAll  	- Print the names of all extant singletons to the console.   
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 02/2013 : first_build\n
    %   1.1 PJ 06/2013 : updated documentation\n
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %

    %% ====================================================================
    %  -----STATIC METHODS (private)-----
    %$ ====================================================================    

    methods  (Static, Access = private)
        
        function getSetIndex(addFlag, classname, verbosity)
            % ########.
            %
            % @param    addFlag
            % @param    classname
            % @param    verbosity
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            persistent index;

            if nargin == 0
                for i = 1:length(index)
                    fprintf('%s\n', index{i});
                end
                return;
            end
            
            if isempty(addFlag)
                while ~isempty(index)
                    l = length(index);
                    if verbosity > 0
                        fprintf('SingletonManager: Close All: %35s', index{end});
                    end
                    eval(sprintf('%s.finishUp()', index{end}));
                    % no need to explicitly remove, since will happen
                    % anyway via .remove.
                    % however, just in case:
                    if length(index) == l
                        %error('a:b','Failed to remove %s???', index{end});
                        index(end) = [];
                        if verbosity > 0
                            fprintf('	[FAILED]\n');
                        end
                    else
                        if verbosity > 0
                            fprintf('    [SUCCEEDED]\n');
                        end
                    end
                end
                index = {};
            elseif addFlag
                index{end+1} = classname;
            else
                index(strcmpi(index, classname)) = [];
            end
        end   
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================    
    
    methods  (Static, Access = public)
        
        function add(classname)
            % Register specified Singleton.
            %
            % @param    classname   String containing child class name
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            SingletonManager.getSetIndex(1, classname);
        end

        function remove(classname)
            % Delete specified Singleton.
            %
            % @param    classname   String containing child class name
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            SingletonManager.getSetIndex(0, classname);
        end
        
        function clearAll(verbosity)
            % Delete all Singletons. Print info to the console.
            %
            % @param    verbosity   Numeric verbosity flag
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            if nargin < 1
                verbosity = 1;
            end
            SingletonManager.getSetIndex([], [], verbosity);
        end
        
        function listAll()
            % Print the names of all extant Singletons to the console.
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            SingletonManager.getSetIndex();
        end  
    end
    
end