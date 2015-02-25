%  A pseudo-singleton class pattern for Matlab
% 
%  Note that the constructor of any class that inherets from this should be
%  hidden thus:
% 
%      methods (Access = ?Singleton)
%          function obj=MyClass()
%        end
%      end
% 
%  And the following blurb pasted in (e.g., at the end of the class):
% 
%      %% ====================================================================
%      %  -----SINGLETON BLURB----- %$
%      ====================================================================
% 
%      methods (Static, Access = ?Singleton)
%          function obj = getSetSingleton(obj)
%              persistent singleObj if nargin > 0, singleObj = obj; end obj = singleObj;
%          end
%      end
%      methods (Static, Access = public)
%          function obj = init()
%              obj = Singleton.initialise(mfilename('class'));
%          end function obj = getInstance()
%              obj = Singleton.getInstanceSingleton(mfilename('class'));
%          end function [] = finishUp()
%              Singleton.finishUpSingleton(mfilename('class'));
%          end
%      end
% 
%  In this way the only initialisation point is via MyClass.init()
% 
%  Note that the blurb would not be necessary if Matlab provided:
%    a) Static variables
%    b) Any means of determining the name of a class calling a static parent
%       method
% 
%  Author:
%    Pete R Jones <petejonze@gmail.com>
% 
%  Verinfo:
%    1.0 PJ 02/2013 : first_build\n
%    1.1 PJ 06/2013 : updated documentation\n
% 
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
% 
%
