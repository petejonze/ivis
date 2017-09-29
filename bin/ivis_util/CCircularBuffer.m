%  circular-buffer (or: 'ring buffer') data-structure.
% 
%    FiFo: first-in first-out
%    n.b., columns inputs only!
%    for example usage, see: CCircularBuffer.unitTests();
% 
%  CCircularBuffer Methods:
%    * CCircularBuffer	- Constructor
%    * put               - Add data row(s)
%    * get               - Get rows at specified indices (blank input for all)
%    * getN             	- Get N rows
%    * nElements        	- Get {nrows, ncols}
%    * clear             - Reset counters and set all elements to NaN
% 
%  See Also:
%    CExpandableBuffer
% 
%  Example:
%    x = CCircularBuffer(10), y = x.put((1:20)')
% 
%  Author:
%    Pete R Jones <petejonze@gmail.com>
% 
%  Verinfo:
%    1.0 PJ 03/2013 : first_build\n
% 
%  Todo: add examples to function docs?
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
% 
%
%    Reference page in Doc Center
%       doc CCircularBuffer
%
%
