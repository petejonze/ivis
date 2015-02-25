%  matrix data-structure that expands by a factor when capacity is exceeded.
% 
%  n.b., columns inputs only!
%  although it can expand, it is always best to allocate sufficient memory
%  in advance, where possible.
%  for example usage, see: CExpandableBuffer.unitTests();
% 
%  CExpandableBuffer Methods:
%    * CExpandableBuffer	- Constructor
%    * put               - Add data row(s)
%    * get               - Get rows at specified indices (blank input for all)
%    * getN              - Get N rows (first start)
%    * getLastN         	- Get N rows (from end)
%    * getBeforeEach     - Return elements in column K where elements in column J immediately precede the values specified in A
%    * getAfterX         - Return elements in column K where elements in column J > X
%    * getEqual          - Return elements in column K where elements in column J equal specified values
%    * nElements        	- Get {nrows, ncols}
%    * clear             - Reset counters and set all elements to NaN (maintain final capacity)
% 
%  See Also:
%    CCircularBuffer
% 
%  Example:
%    x = CExpandableBuffer(10,3), x.put([1 2 3; 11 12 13]), x.get()
% 
%  Author:
%    Pete R Jones <petejonze@gmail.com>
% 
%  Verinfo:
%    1.0 PJ 03/2013 : first_build\n
% 
%  Todo: Abstract some methods to a generic 'Buffer' class?
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
% 
%
