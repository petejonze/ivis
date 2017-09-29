%  Responsible for buffering and saving processed data.
% 
%  IvDataLog Methods:
%    * IvDataLog  - Constructor.
%    * add        - Add data to the buffer.
%    * getLastN	 - Retrieve last N samples from the buffer.
%    * getSinceT	 - Retrieve all samples from the buffer since time T.
%    * getTmpBuff - Get all samples that were added on the last cycle.
%    * save    	 - Dump the buffer to an external file; prompt IvGraphic objects to do likewise.
%    * reset  	 - Clear the buffer.
%    * getN    	 - Get the N samples held in the buffer.
%    * getLastKnownXY     - Convenience wrapper for getLastN, that extracts the last N [xy,t] values (raw or processed, with or without NaNs).      
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
%       doc ivis.log.IvDataLog
%
%
