classdef CCircularBuffer < handle
    % circular-buffer (or: 'ring buffer') data-structure.
    %
    %   FiFo: first-in first-out
    %   n.b., columns inputs only!
    %   for example usage, see: CCircularBuffer.unitTests();
    %
    % CCircularBuffer Methods:
    %   * CCircularBuffer	- Constructor
    %   * put               - Add data row(s)
    %   * get               - Get rows at specified indices (blank input for all)
    %   * getN             	- Get N rows
    %   * nElements        	- Get {nrows, ncols}
    %   * clear             - Reset counters and set all elements to NaN
    %
    % See Also:
    %   CExpandableBuffer
    %
    % Example:
    %   x = CCircularBuffer(10), y = x.put((1:20)')
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 03/2013 : first_build\n
    %
    % Todo: add examples to function docs?
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (Access = private)
        buffer      % the data
        i = 0       % internal nElements counter
    end
    
    properties (GetAccess = public, SetAccess = private)
        capacity    % max n data rows
        ncols       % n data columns
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        function obj = CCircularBuffer(m, n)
            % CCircularBuffer Constructor.
            %
            %   obj = CCircularBuffer(n[, m=1])
            %
            % @param    m 	initial num data rows (int)
            % @param    n 	num data columns (int)
            % @return   obj	CCircularBuffer object            
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % parse user inputs
            if nargin < 2 || isempty(n)
                n = 1;
            end
            
            % initialise & store
            obj.capacity = m;
            obj.ncols = n;
            obj.buffer =  nan(m,n);
        end
        
        function [buff,y] = put(obj, x)
            % put Add data row(s)
            %
            %   y = obj.put(x)
            %
            % @param    x   data rows (float)
            % @return   y   any overwritten rows (float)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            inputLength = size(x,1);
            
            idx = mod((1:inputLength)-1+obj.i,obj.capacity)+1;
            
            if nargout > 1 % only compute if output has been requested
                y = [obj.buffer(idx(1:min(obj.capacity, inputLength-max(obj.capacity-obj.i,0))), :); x((1:inputLength)<=(inputLength-obj.capacity),:)];
            end
            
            % set
            obj.buffer(idx,:) = x;
            obj.i = obj.i + inputLength;
            
            if nargout % only compute if output has been requested
                buff = obj.buffer;
            end
        end
        
        function y = getN(obj, n, mi)
            % getN return the specified number of elements.
            %
            % 	y = obj.getN([n][, mi])
            %
            % @param    n   number of elements to return
            % @param    mi  col indices
            % @return   y   data rows (float)
            %
            % @date     26/06/14
            % @author   PRJ
            if nargin < 2 || isempty(n)
                n = min(obj.i, obj.capacity);
            end
            if nargin < 3 || isempty(mi)
                mi = 1:obj.ncols; % for selecting specific columns (defaults to all)
            end
            
            if n > obj.i
                error('CCircularBuffer:OutOfBounds', '%i elements requested, but only %i elements stored in buffer\n', n, obj.i)
            end
            y = obj.buffer(mod((1:n)-1+obj.i+max(0, obj.capacity-obj.i),obj.capacity)+1, mi);
        end
        
        function y = get(obj, ni, mi)
            % get return the elements at specified indices
            %
            % 	y = obj.get([ni][, mi])
            %
            % @param    ni  row indices
            % @param    mi  col indices
            % @return   y   data rows (float)
            %
            % @date     26/06/14
            % @author   PRJ
            %            
            % 
            if nargin < 2 || isempty(ni)
                ni = 1:min(obj.i, obj.capacity);
            end
            if nargin < 3 || isempty(mi)
                mi = 1:obj.ncols; % for selecting specific columns
            end
            
            if any(ni > obj.i)
                error('CCircularBuffer:OutOfBounds', 'specified element-indices requested [%s], but only %i elements stored in buffer\n', num2str(ni(ni>obj.i)), obj.i)
            end
            
            y = obj.buffer(mod(ni-1+obj.i+max(0, obj.capacity-obj.i),obj.capacity)+1, mi);
        end
        
        function [n,m] = nElements(obj)
            % nElements Get {nrows, ncols}.
            %
            % 	[n,m] = obj.nElements()
            %
            % @return   n nrows
            % @return   m ncols
            %
            % @date     26/06/14
            % @author   PRJ
            %
            n = min(obj.i, obj.capacity);
            m = obj.ncols;
        end
        
        function [] = clear(obj)
            % clear Reset counters and set all elements to NaN.
            %
            % 	obj.clear()
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.buffer(:,:) = NaN;
            obj.i = 0;
        end
    end
    
    
    %% ====================================================================
    %  -----STATIC METHODS (public)-----
    %$ ====================================================================
    
    methods (Static, Access = public)
        
        % Unit tests -----------------------------------------------------
        function [] = unitTests()
            % Unit test main entry point.
            %
            % @date     26/06/14
            % @author   PRJ
            %            
            suite = testSuiteFromStatic('CCircularBuffer');
            suite.run(VerboseTestRunDisplay(1));
        end
        
        function [] = testVector()
            % Unit Test
            %
            % @date     26/06/14
            % @author   PRJ
            %  
            
            % check init
            x = CCircularBuffer(10);
            assertEqual(x.capacity, 10);
            
            % check put (no overwriting)
            out = x.put([1 2 3]');
            assertTrue(isempty(out));
            out = x.put((4:10)');
            assertTrue(isempty(out));
            
            % check that put returns overwritten values
            out = x.put(11);
            assertEqual(out, 1, 'Should return the first element to be overwritten');
            assertEqual(x.get(), (2:11)');
            
            % check that get returns oldest elements (first in first out)
            assertEqual(x.get(1), 2, 'Should return the oldest element');
            
            % check clear
            x.clear()
            assertTrue(isempty(x.get()));
            
            % check can only get the N elements present
            assertExceptionThrown(@()x.get(3), 'CCircularBuffer:OutOfBounds');
            
            % check get using multiple elements
            x.put((1:4)');
            assertEqual(x.get(),(1:4)');
            
            % check get specified indices
            assertEqual(x.get(1:3),(1:3)');
            assertEqual(x.get([1 3]),[1;3]);
            
            % check getN
            assertEqual(x.getN(3),(1:3)');
            
            % nElements
            assertEqual(x.nElements(), 4);
            x.put((5:20)');
            assertEqual(x.nElements(), 10);
        end
        
        function [] = testMatrix()
            % Unit Test
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            x = CCircularBuffer(10,3);
            assertEqual(x.capacity, 10);
            
            % put
            x.put([1 2 3]);
            assertExceptionThrown(@()x.put([1 2]), 'MATLAB:subsassigndimmismatch');
            assertExceptionThrown(@()x.put([1 2 3 4]), 'MATLAB:subsassigndimmismatch');
            
            % get
            assertEqual(x.get, [1 2 3]);
            x.put([11 12 13]);
            assertEqual(x.get, [1 2 3; 11 12 13]);
            assertEqual(x.get(2,[1 3]), [11 13]);
            assertEqual(x.getN(1),[1 2 3]);
            assertEqual(x.getN(1,[1 3]),[1 3]);
        end
        
        function [] = testSpeed()
            % Unit Test
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            N = 1000;
            x = CCircularBuffer(10,3);
            dat1 = rand(1,3);
            datAll = rand(10,3);
            fprintf('\n      N=%i; buffer = {10,3};\n', N);
            
            % put 1
            tic();
            for j = 1:N
                x.put(dat1);
            end
            fprintf('         mean put(<rand(1,3)>) time: %1.6f seconds\n', toc()/N)
            % put all
            tic();
            for j = 1:N
                x.put(datAll);
            end
            fprintf('         mean put(<rand(10,3)>) time: %1.6f seconds\n', toc()/N)
            % get 1
            tic();
            for j = 1:N
                x.get(1);
            end
            fprintf('         mean get(1) time: %1.6f seconds\n', toc()/N)
            % get all
            tic();
            for j = 1:N
                x.get();
            end
            fprintf('         mean get() time: %1.6f seconds\n', toc()/N)
            fprintf('%62s','');
        end
    end
    
end