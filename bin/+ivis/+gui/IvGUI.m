%  Singleton responsible for maintaining the overall frame, in which
%  individual Java windows may be embedded.
% 
%      clear all
%      import ivis.gui.*;
%      IvGUI.init(1,1)
%      IvGUI.getInstance().addFigurePanel(2,'blah')
%      IvGUI.getInstance()
%      IvGUI.finishUp
%      IvGUI.init(1,3)    
% 
%  IvGUI Methods:
%    * IvGUI             - Constructor.
%    * addFigurePanel  	- Create a new java window and at it to the GUI frame, at the specified index location..
%    * addFigureToPanel	- Add an existing java window to the GUI frame, at the specified index location.
% 
%  See Also:
%    none
% 
%  Example:
%    none
% 
%  Author:
%    Pete R Jones <petejonze@gmail.com>
% 
%  Verinfo:
%    1.0 PJ 02/2013 : first_build\n
% 
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
%  
%
%    Reference page in Doc Center
%       doc ivis.gui.IvGUI
%
%
