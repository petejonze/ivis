classdef CExpandableBuffer < handle
    % matrix data-structure that expands by a factor when capacity is exceeded.
    %
    % n.b., columns inputs only!
    % although it can expand, it is always best to allocate sufficient memory
    % in advance, where possible.
    % for example usage, see: CExpandableBuffer.unitTests();
    %
    % CExpandableBuffer Methods:
    %   * CExpandableBuffer	- Constructor
    %   * put               - Add data row(s)
    %   * get               - Get rows at specified indices (blank input for all)
    %   * getN              - Get N rows (first start)
    %   * getLastN         	- Get N rows (from end)
    %   * getBeforeEach     - Return elements in column K where elements in column J immediately precede the values specified in A
    %   * getAfterX         - Return elements in column K where elements in column J > X
    %   * getEqual          - Return elements in column K where elements in column J equal specified values
    %   * nElements        	- Get {nrows, ncols}
    %   * clear             - Reset counters and set all elements to NaN (maintain final capacity)
    %
    % See Also:
    %   CCircularBuffer
    %
    % Example:
    %   x = CExpandableBuffer(10,3), x.put([1 2 3; 11 12 13]), x.get()
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 03/2013 : first_build\n
    %
    % Todo: Abstract some methods to a generic 'Buffer' class?
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %
    
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (Constant)
        DEFAULT_EXPANSION_FACTOR = 2; % default amount to multiply capacity by
    end
        
    properties (Access = private)
        buffer      % the data
    end
    
    properties (GetAccess = public, SetAccess = private)
        capacity        % max n data rows
        ncols           % n data columns
        expansionFactor % amount to multiply capacity by
        nrows = 0       % internal nElements counter
    end

    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        function obj = CExpandableBuffer(n, m, expansionFactor)
            % CExpandableBuffer Constructor.
            %
            %   obj = CExpandableBuffer(n[,m=1][, expansionFactor=2]) 
            %
            % @param    n               initial n data rows (int)
            % @param    m               n data columns (int)
            % @param    expansionFactor amount to increase "n" by once 90 percent capacity exceeded (float)
            % @return   obj             CExpandableBuffer object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % parse user inputs
            if nargin < 2 || isempty(m)
                m = 1;
            end
            if nargin < 3 || isempty(expansionFactor)
                expansionFactor = CExpandableBuffer.DEFAULT_EXPANSION_FACTOR;
            end
            
            % initialise & store
            obj.capacity = n;
            obj.ncols = m;
            obj.expansionFactor = expansionFactor;
            obj.buffer =  nan(n,m);
        end

        function [] = put(obj, x)
            % put Add data row(s).
            %
            %   obj.put(x)
            %
            % @param    x data rows (float)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % init
            i1 = obj.nrows + 1; % start idx
            ii = obj.nrows + size(x,1); % stop idx
            
            % store
            obj.buffer(i1:ii,:) = x;
            obj.nrows = ii;
            
            % grow by expansion factor if within 10% of end
            if (ii/obj.capacity) > 0.9
                tic()
                newN = floor(obj.capacity * obj.expansionFactor);
                obj.buffer = [obj.buffer; nan(newN-obj.capacity, obj.ncols)];
                fprintf('           Growing data store... (%i -> %i) [%1.5f secs]\n',obj.capacity,newN,toc());
                obj.capacity = newN;
            end
        end
        
        function y = get(obj, ni, mi)
            % get Get rows at specified indices (blank input for all).
            %
            %   y = obj.get([ni][, mi])
            %
            % @param    ni  row indices
            % @param    mi  col indices
            % @return   y   data rows (float)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if nargin < 2 || isempty(ni)
                ni = 1:obj.nrows;
            end
            if nargin < 3 || isempty(mi)
                mi = 1:obj.ncols; % for selecting specific columns
            end
            
            y = obj.buffer(ni, mi);
        end
        
        function y = getN(obj, n, mi)
            % getN Get N rows (first start).
            %
            %   y = obj.getN(n[, mi])
            %
            % @param    n   number of rows to return
            % @param    mi  col indices
            % @return   y   data rows (float)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if nargin < 2 || isempty(n)
                error('CExpandableBuffer:InvalidInput', 'no number of elements requested')
            end
            if nargin < 3 || isempty(mi)
                mi = 1:obj.ncols; % for selecting specific columns (defaults to all)
            end
            
            if n > obj.nrows
                error('CExpandableBuffer:OutOfBounds', '%i elements requested, but only %i elements stored in buffer\n', n, obj.nrows)
            end
            
            y = obj.buffer(1:n, mi);
        end
        
        function y = getLastN(obj, n, mi)
            % getLastN Get N rows (from end).
            %
            %   y = obj.getLastN(n[, mi])
            %
            % @param    n   n rows (int)
            % @param    mi  col indices
            % @return   y   data rows (float)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if nargin < 2 || isempty(n)
                error('CExpandableBuffer:InvalidInput', 'no number of elements requested')
            end
            if nargin < 3 || isempty(mi)
                mi = 1:obj.ncols; % for selecting specific columns (defaults to all)
            end
            
            if n > obj.nrows
                error('CExpandableBuffer:OutOfBounds', '%i elements requested, but only %i elements stored in buffer\n', n, obj.nrows)
            end
            
            y = obj.buffer((obj.nrows-(n-1)):obj.nrows, mi);
        end
        
        function y = getLastNnonNaN(obj, n, mi)
            % getLastNnonNaN Get N rows (from end), discounting any rows with
            % NaNs in.
            %
            %   y = obj.getLastNnonNaN(n[, mi])
            %
            % @param    n   n rows (int)
            % @param    mi  col indices
            % @return   y   data rows (float)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if nargin < 2 || isempty(n)
                error('CExpandableBuffer:InvalidInput', 'no number of elements requested')
            end
            if nargin < 3 || isempty(mi)
                mi = 1:obj.ncols; % for selecting specific columns (defaults to all)
            end
            
            idx = all(~isnan(obj.buffer(:, mi)),2);
            nrows_nonNaN = sum(idx);
           
            if n > nrows_nonNaN
                error('CExpandableBuffer:OutOfBounds', '%i elements requested, but only %i non-NaN elements stored in buffer\n', n, nrows_nonNaN)
            end
            
            idx = find(idx,n,'last');
            y = obj.buffer(idx, mi);
        end
        function nrows_nonNaN = computeNnonNaN(obj, mi)
            if nargin < 2 || isempty(mi)
                mi = 1:obj.ncols; % for selecting specific columns (defaults to all)
            end
            
            idx = all(~isnan(obj.buffer(:, mi)),2);
            nrows_nonNaN = sum(idx);
        end
        
        function y = getBeforeEach(obj, A, testCol, mi)
            % getBeforeEach Return elements in column K where elements in
            % column J immediately precede values specified in A.
            %
            %   y = obj.getBeforeEach(A, testCol[, mi])
            %
            % @param    A       values to test against [column of floats]
            % @param    testCol column num to test A against (int)
            % @param    mi      column indices to return
            % @return   y       data rows (float)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            % may start to be unacceptably slow as the n points increases
            if nargin < 3 || isempty(mi)
                mi = 1:obj.ncols; % for selecting specific columns
            end
            
            % For each element of A, find the nearest smaller-or-equal value in B:
            B = obj.buffer(:,testCol);
            [~,ib] = histc(A, [-inf; B; inf]);
            y = obj.buffer(ib-1,mi);
        end
    
        function y = getAfterX(obj, X, testCol, mi)
            % getAfterX Return elements in column K where elements in
            % column J > X.
            %
            %   y = obj.getAfterX(X, testCol[, mi])
            %
            % @param    X       value to test against [float scalar]
            % @param    testCol column num to test A against (int)
            % @param    mi      column indices to return
            % @return   y       data rows (float)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if nargin < 3 || isempty(mi)
                mi = 1:obj.ncols; % for selecting specific columns
            end
            y = obj.buffer(obj.buffer(:,testCol)>X,mi);
        end
        
        function y = getEqual(obj, X, testCol, mi)
            % getEqual Return elements in column K where elements in
            % column J equal specified values.
            %
            %   y = obj.getEqual(X, testCol[, mi])
            %
            % @param    X       value to test against [float scalar]
            % @param    testCol column num to test A against (int)
            % @param    mi      column indices to return
            % @return   y       data rows (float)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if nargin < 3 || isempty(mi)
                mi = 1:obj.ncols; % for selecting specific columns
            end
            y = obj.buffer(ismember(obj.buffer(:,testCol), X),mi);
        end
        
        function [n,m] = nElements(obj)
            % nElements Get {nrows, ncols}
            %
            % 	[n,m] = obj.nElements()
            %
            % @return   n nrows
            % @return   m ncols
            %
            % @date     26/06/14
            % @author   PRJ
            %
            n = obj.nrows;
            m = obj.ncols;
        end
        
        function [] = clear(obj)
            % clear Reset counters and set all elements to NaN (maintain
            % final capacity).
            %
            %	obj.clear()
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.buffer(:,:) = NaN;
            obj.nrows = 0;
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
            suite = testSuiteFromStatic('CExpandableBuffer');
            suite.run(VerboseTestRunDisplay(1));
        end
        
        function [] = testVector()
            % Unit Test
            %
            % @date     26/06/14
            % @author   PRJ
            %  
            
            % check init
            x = CExpandableBuffer(100);
            assertEqual(x.capacity, 100);
            
            % put/get
            x.put(1);
            assertEqual(x.get, 1);
            x.put(2);
            assertEqual(x.get, [1;2]);
            x.put((3:6)');
            assertEqual(x.get, (1:6)');
            
            % get/getN/getLastN
            assertEqual(x.get(), (1:6)');
            assertEqual(x.getN(1), 1);
            assertEqual(x.getLastN(1), 6);
            
            % nElements
            assertEqual(x.nElements(), 6);
            x.put((7:20)');
            assertEqual(x.nElements(), 20);
            
            % clear
            x.clear();
            assertTrue(isempty(x.get()));
            assertEqual(x.nElements(), 0);
            x.put((7:10)');
            assertEqual(x.get(), (7:10)');
            assertEqual(x.nElements(), 4);
            
            % getBeforeEach
            assertEqual(x.getBeforeEach([7.1 7.2 7.3 7.4 8.2 9.3 100], 1, 1), [7 7 7 7 8 9 10]');
            
            % getAfterX
            assertEqual(x.getAfterX(7, 1, 1), [8 9 10]');
            
            % getEqual
            assertEqual(x.getEqual([7 8], 1, 1), [7 8]');
            x.put(7);
            assertEqual(x.getEqual([7 8], 1, 1), [7 8 7]');
        end
        
        function [] = testMatrix()
            % Unit Test
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            x = CExpandableBuffer(100,3);
            
            % put
            x.put([1 2 3; 11 12 13]);
            assertExceptionThrown(@()x.put([1 2]), 'MATLAB:subsassigndimmismatch');
            assertExceptionThrown(@()x.put([1 2 3 4]), 'MATLAB:subsassigndimmismatch');
            
            % get/getN/getLastN
            assertEqual(x.get(), [1 2 3; 11 12 13]);
            assertEqual(x.getN(1), [1 2 3]);
            assertEqual(x.getLastN(1), [11 12 13]);
            
            % getBeforeEach
            assertEqual(x.getBeforeEach([12 10], 1, 3), [13 3]');
            
            % getAfterX
            assertEqual(x.getAfterX(7, 1, 2:3), [12 13]);
            
            % getEqual
            assertEqual(x.getEqual(11, 1, 2), 12);
            x.put([21 22 23]);
            assertEqual(x.getEqual([1 21], 1, 3), [3; 23]);
        end
        
        function [] = testSpeed()
            % Unit Test
            %
            % @date     26/06/14
            % @author   PRJ
            %              
            N = 1000;
            x = CExpandableBuffer(10,3);
            dat1 = rand(1,3);
            dat10 = rand(10,3);
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
                x.put(dat10);
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
                x.get(1:10);
            end
            fprintf('         mean get(1:10) time: %1.6f seconds\n', toc()/N)
            fprintf('%62s','');
        end
    end
    
end