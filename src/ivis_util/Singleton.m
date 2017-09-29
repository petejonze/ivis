classdef (Abstract) Singleton < handle
 	% A pseudo-singleton class pattern for Matlab
    %
    % Note that the constructor of any class that inherets from this should be
    % hidden thus:
    %
    %     methods (Access = ?Singleton)
    %         function obj=MyClass()
    %       end
    %     end
    %
    % And the following blurb pasted in (e.g., at the end of the class):
    %
    %     %% ====================================================================
    %     %  -----SINGLETON BLURB----- %$
    %     ====================================================================
    %
    %     methods (Static, Access = ?Singleton)
    %         function obj = getSetSingleton(obj)
    %             persistent singleObj if nargin > 0, singleObj = obj; end obj = singleObj;
    %         end
    %     end
    %     methods (Static, Access = public)
    %         function obj = init()
    %             obj = Singleton.initialise(mfilename('class'));
    %         end function obj = getInstance()
    %             obj = Singleton.getInstanceSingleton(mfilename('class'));
    %         end function [] = finishUp()
    %             Singleton.finishUpSingleton(mfilename('class'));
    %         end
    %     end
    %
    % In this way the only initialisation point is via MyClass.init()
    %
    % Note that the blurb would not be necessary if Matlab provided:
    %   a) Static variables
    %   b) Any means of determining the name of a class calling a static parent
    %      method
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 02/2013 : first_build\n
    %   1.1 PJ 06/2013 : updated documentation\n
    %
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %

    %% ====================================================================
    %  -----PROTECTED METHODS-----
    %$ ====================================================================    
    
    methods (Access = protected)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = Singleton()
            % The internal singleton reference (bit of a hack, thanks to
            % Matlab not having static properties).
            %         
            % @date     26/06/14                          
            % @author   PRJ
            %             
            SingletonManager.add(class(obj));
            singleObj = eval(sprintf('%s.getSetSingleton()', class(obj)));
            if ~isempty(singleObj) && ishandle(singleObj) % ishandle correct?
                error('Singleton:FailedToSet','Could not set new Singleton object of type %s, since one already extant', class(singleObj) );
            end
            eval(sprintf('%s.getSetSingleton(obj);', class(obj)));
        end 
    end
    
    
    %% ====================================================================
    %  -----ABSTRACT METHODS-----
    %$ ====================================================================    
    
    methods (Abstract, Static, Access = ?Singleton)
        
        % ######.
        %
        % @date     26/06/14
        % @author   PRJ
        %
        obj = getSetSingleton(obj)
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS (protected)-----
    %$ ====================================================================    
    % the protected access methods (called via public access methods stored
    % in the instance class)
    
    methods (Static, Access = protected)

        function obj = initialise(classname, varargin)
            % Initialise the Singleton.
            %
            % @param    classname   String containing child class name
            % @param    varargin    Misc
            % @return   obj         Singleton object
            %
            % @date     26/06/14
            % @author   PRJ
            % 
            if Singleton.isinit(classname)
                classnameNoPkg = regexp(classname, '\w+$', 'match', 'once'); % discard pacakge info. 'once' to ensure char not cell
                errorId = sprintf('%s:FailedToInitSingleton_alreadyInitialised',classnameNoPkg);
                error(errorId, 'Could not initialise Singleton object of type %s, since has already been initialised.\nSee help for info.', classname);
            else
                obj = eval([classname '(varargin{:})']);
            end
        end
        
        
        function init = isinit(classname)
            % Confirm whether the Singleton has been initialised.
            %
            % @param    classname   String containing child class name
            % @return   init        Boolean
            %         
            % @date     26/06/14                          
            % @author   PRJ
            %              
            obj = eval(sprintf('%s.getSetSingleton()', classname));
            if ~isempty(obj) && isvalid(obj) % isvalid to check for deleted
                init = true;
            else
                init = false;
            end
        end
        
        function obj = getInstanceSingleton(classname, varargin)
            % Get object (only 1 can exist).
            %
            % @param    classname   String containing child class name
            % @param    varargin    Misc
            % @return   obj         Singleton object
            %
            % @date     26/06/14
            % @author   PRJ
            %         
            
          	% disable warnings refering to implicit class references, of
            % the type:
            %       ivis.broadcaster.IvBroadcaster.getInstance().delete() 
            % NB: otherwise would have to type:
            %       tmp = ivis.broadcaster.IvBroadcaster.getInstance()
            %       tmp.delete() 
            warning('off', 'MATLAB:subscripting:noSubscriptsSpecified')
            
            obj = eval(sprintf('%s.getSetSingleton()', classname));
            if isempty(obj) || ~isvalid(obj) % isvalid to check for deleted
                if  ismember('ALLOW_IMPLICIT_CONSTRUCTION', properties(classname)) && eval(sprintf('%s.ALLOW_IMPLICIT_CONSTRUCTION', classname))
                    %if nargin(sprintf('%s>%s.%s',classname,classname,classname)) == 0
                    obj = eval([classname '(varargin{:})']);
                else
                    classnameNoPkg = regexp(classname, '\w+$', 'match', 'once'); % discard pacakge info. 'once' to ensure char not cell
                    errorId = sprintf('%s:FailedToGetSingleton_notInitialised',classnameNoPkg);
                    error(errorId, 'Could not get Singleton object of type %s, since one has not yet been constructed.\nIf you wish to enable auto-construct you can include a true ALLOW_IMPLICIT_CONSTRUCTION constant. See help for info.', classname);
                end
            end
        end
        
        function [] = finishUpSingleton(classname)
            % Delete object.
            %
            % @param    classname   String containing child class name
            %
            % @date     26/06/14
            % @author   PRJ
            %             
            SingletonManager.remove(classname);          
            obj = eval(sprintf('%s.getSetSingleton()', classname));
            if ~isempty(obj)% && ishandle(obj) <-- no
                delete(obj);
                warning('off','MATLAB:lang:cannotClearExecutingFunction');
                clear(class(obj));
                warning('on','MATLAB:lang:cannotClearExecutingFunction');
            else
                fprintf('WARNING: No object of type %s to clear\n', classname);
            end
%             clear Singleton
        end
    end

end