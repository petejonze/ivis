classdef IvCalibration < Singleton
    % Singleton responsible for maintaining a mapping of observed-to-actual
    % gaze coordinates, through (A) a polynomial surface map, and (B) a
    % drift-correction mechanism.
    %
    %   Note that this functionally sits on top of any calibration that may
    %   be going on within the eyetracking device, and in generally it is
    %   better to do the calibration 'in hardware' if possible, rather than
    %   relying on this class. However, this may be a little more flexible
    %   and transparent.
    %
    % IvCalibration Methods:
    %   * IvCalibration         - Constructor.
    %   * addMeasurements       - Add observed gaze measurements in response to a presented pair of gaze coordinates.
    %   * removeMeasurements	- Remove all obervations recorded in response to the specified targ coordinate pair.
    %   * clearMeasurements     - Remove all raw gaze observations.
    %   * getMeasurements       - Get all raw gaze observations, separated into those that were and weren't used in the computed calibration.
    %   * getNTargs             - Get number of unique targets that have been measured.
    %   * compute               - Compute a calibration map by fitting a least-square polynomial surface to a given set of targ- and resp- gaze coordinates.
    %   * clear                 - Clear the fitted calibration. N.b., doesn't clear the raw measurements.
    %   * save                  - Save the fitted calibration, either to the local directory, or to a specified location.
    %   * load                  - Load a fitted calibration.
    %   * resetDriftCorrection	- Clear any stored drift correction factor.
    %   * updateDriftCorrection	- Update the drift correction factor.
    %   * apply                 - Apply the stored calibration (and/or drift correction) to a given set of xy gaze coordinates..
    %          
    % See Also:
    %   None
    %
    % Example:
    %   None
    %
    % Author:
    %   Pete R Jones <petejonze@gmail.com>
    %
    % Verinfo:
    %   1.0 PJ 02/2013 : first_build\n
    %
    % @todo report goodness of fit metric
    % @todo visualization
    % @todo facility to query if point is outside calibrated area? (could
    % be done quite roughly / assuming a rectangle) [alt could be done more
    % elegantly using a graphic movement listener]
    %
    % Copyright 2014 : P R Jones
    % *********************************************************************
    %
    
    %% ====================================================================
    %  -----PROPERTIES-----
    %$ ====================================================================
    
    properties (GetAccess = public, SetAccess = private)
        guiElement        % handle to calibration GUI
        nRecursions       % n times to refit calibration (excluding outliers)
        outlierThresh_px % distance threshold for a calibration point to be considered at outlier (in whatever units the calibration is carried out in)
        % calibration
        targ = [];      % target gaze coordinates
        resp = [];      % measured gaze coordinates
        idx_used = [];  % indices in targ and resp used to compute threshold (after outlier exclusion)
        cx;             % horiztonal calibration factor
        cy;             % vertical calibration factor
        % drift correction
        driftCorrection_px = [0 0]; % drift correction factor
        maxDriftCorrection_deg;     % maximum acceptable offset (individual euclidean distance magnitudes greater than this will be ignored)
    end
    
    
    %% ====================================================================
    %  -----PUBLIC METHODS-----
    %$ ====================================================================
    
    methods (Access = public)
        
        %% == CONSTRUCTOR =================================================
        
        function obj = IvCalibration(calibParams)
            % IvCalibration Constructor.
            %
            % @param    calibParams parameter structure
            % @return   obj         IvCalibration object
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % set calibration params
            obj.nRecursions = calibParams.nRecursions;
            obj.outlierThresh_px = calibParams.outlierThresh_px;
            
            % set drift params
            obj.maxDriftCorrection_deg = calibParams.drift.maxDriftCorrection_deg;
            
            % initialise GUI element if GUIidx specified
            if ~isempty(calibParams.GUIidx)
                obj.guiElement = ivis.gui.IvGUIcalibration(calibParams.GUIidx, calibParams.targCoordinates, calibParams.presentationFcn);
            end
        end
        
        function [] = delete(obj)
            % IvCalibration Destructor.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % clear GUI element (if exists)
            if ~isempty(obj.guiElement) && ishandle(obj.guiElement)
                delete(obj.guiElement);
            end
        end
        
        
        %% == METHODS =====================================================
        
        function [] = addMeasurements(obj, targ, resp)
            % Add observed gaze measurements in response to a presented
            % pair of gaze coordinates. If size(targ,1)==1, will
            % automatically expand to match the number of rows in targ.
            %
            % @todo     check that Std Dev. within some specified criterion?
            %
            % @param    targ	xy presented coordinates - [n,2] matrix
            % @param    resp	xy observed coordinates - [n,2] matrix
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            n = size(resp,1);
            
            % expand to match, if required
            if size(targ,1) == 1
                targ = repmat(targ,n,1);
            end
            
            obj.targ = [obj.targ; targ];
            obj.resp = [obj.resp; resp];
        end
        
        function nRemoved = removeMeasurements(obj, targ)
            % Remove all obervations recorded in response to the specified
            % targ coordinate pair.
            %
            % @param	targ	 ######
            % @return	nRemoved ######
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % check if anything there to remove
            if isempty(obj.targ)
                return;
            end
            
            % find observations to remove
            idx = obj.targ(:,1)==targ(1) & obj.targ(:,2)==targ(2);
            
            % remove
            obj.targ(idx,:) = [];
            obj.resp(idx,:) = [];
            
            % count n removed (if any)
            nRemoved = sum(idx);
        end
        
        function [] = clearMeasurements(obj)
            % Remove all raw gaze observations.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.targ = [];
            obj.resp = [];
        end
        
        function n = getNTargs(obj)
            % Get number of unique targets that have been measured.
            %
            % @return	n       integer.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            n = size(unique(obj.targ,'rows'),1);
        end
        
        function [resp_used, resp_excluded] = getRawMeasurements(obj)
            % Get all raw gaze observations
            %
            % @return	resp_used       ######
            % @return	resp_excluded   ######
            %
            % @date     26/06/14
            % @author   PRJ
            %
            resp_used = obj.resp(obj.idx_used,:);
            resp_excluded = obj.resp(~obj.idx_used,:);
        end

        function ok = compute(obj, nRecursions, targ, resp)
            % Compute a calibration map by fitting a least-square
            % polynomial surface to a given set of targ- and resp- gaze
            % coordinates. If no gaze coordinates specified, will use those
            % that have previously been added. The fit will be repeated
            % nRecursions times, each times excluding any outliers that are
            % greater than an arbitrary distance away.
            %
            % @param	nRecursions	num of times to refit the calibration
            % @param	targ        optional, target gaze coordinates [n,2]
            % @param	resp        optional, response coordinates [n,2]
            % @return	ok          false if fit failed.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.idx_used = [];
            obj.cx = [];
            obj.cy = [];
            
            % parse inputs
            if nargin < 2 || isempty(nRecursions)
                nRecursions = obj.nRecursions;
            end
            if nargin < 3 || isempty(targ)
                targ = obj.targ;
            end
            if nargin < 4 || isempty(resp)
                resp = obj.resp;
            end
          
            % init
            ok = true;
            
            % min nPoints?
            if size(unique(targ,'rows'), 1) < 3
                warning('No valid calibration could be computed (insufficient targets)');
                ok = false;
                return;
            end
            
            % fit model (least squares 2nd order polynomial surface)
%             X = [resp ones(size(resp,1),1)];
            X = [resp resp.^2 resp(:,1).*resp(:,2) ones(size(resp,1),1)];
            [U,S,V] = svd(X,0);
            S = diag(1./diag(S));
            pseudINV = V*S*U';
            cx = pseudINV * targ(:,1); %#ok
            cy = pseudINV * targ(:,2); %#ok
            
            % calculate error
            err_x = (X*cx)-targ(:,1); %#ok
            err_y = (X*cy)-targ(:,2); %#ok
            err_dist = sqrt(err_x.^2 + err_y.^2);
            %err_mean = mean(err_dist)
            %err_rms = sqrt(mean(sum(err_dist.^2)))
            
            % compute
            idx_valid = err_dist <= obj.outlierThresh_px;
            
            % check if fit is valid (return if not)
            if ~any(idx_valid)
                warning('No valid calibration could be computed (all points excluded)');
                ok = false;
                return;
            end
            
            % store [may subsequently be cleared after further recursions]
            obj.idx_used = ismember(obj.resp,resp,'rows');
            obj.cx = cx; %#ok
            obj.cy = cy; %#ok
            
            % % compute the (approximate) rectangle specifying where on the
            % % screen has been calibrated
            % obj.calibratedRect = [min(targ) max(targ)]; % [x1 y1 x2 y2]
            
            % refit, if necessary, after excluding outliers
            if nRecursions > 0
                nRecursions = nRecursions - 1;
                ok = obj.compute(nRecursions, targ(idx_valid,:), resp(idx_valid,:));
            else
                % clear any existing drift correction
                fprintf('Clearing drift correction..\n');
                obj.resetDriftCorrection();
                % all done!
            end
        end
        
        function [] = clear(obj)
            % Clear the fitted calibration. N.b., doesn't clear the raw
            % measurements.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.idx_used = ones(size(obj.resp,1),1)==0;
            obj.cx = [];
            obj.cy = [];
        end
        
        function [] = save(obj, path)
            % Save the fitted calibration, either to the local directory,
            % or to a specified location. The file will contain a single
            % variable, called "calib".
            %
            % @param    path   directory to save into (pwd if unspecified)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            if nargin < 2
                path = [];
            end
            
            % automated way to do this?
            calib = struct;
            calib.targ = obj.targ;
            calib.resp = obj.resp;
            calib.idx_used = obj.idx_used;
            calib.cx = obj.cx;
            calib.cy = obj.cy;
            calib.driftCorrection_px = obj.driftCorrection_px;
            calib.maxDriftCorrection_deg = obj.maxDriftCorrection_deg; %#ok
            % save
            fn = fullfile(path, sprintf('IvCalibration-%s', datestr(now(),30)));
            save(fn, 'calib');
        end
        
        function [] = load(obj, fullFn)
            % Load a fitted calibration. The specified file should contain
            % a single variable, called "calib".
            %
            % @param	fullFn	file name to load, including path
            %
            % @date     26/06/14
            % @author   PRJ
            %
            calib = load(fullFn);
            % set
            obj.targ = calib.targ;
            obj.resp = calib.resp;
            obj.idx_used = calib.idx_used;
            obj.cx = calib.cx;
            obj.cy = calib.cy;
            obj.driftCorrection_px = calib.driftCorrection_px;
            obj.maxDriftCorrection_deg = calib.maxDriftCorrection_deg;
        end
        
        function [] = resetDriftCorrection(obj)
            % Clear any stored drift correction factor.
            %
            % @date     26/06/14
            % @author   PRJ
            %
            obj.driftCorrection_px = [0 0];
        end
        
        function [] = updateDriftCorrection(obj, trueXY, estXY, maxCorrection, weight)
            % Update the drift correction factor. Will compute the
            % euclidean difference between the specified trueXY and estXY,
            % and combine with the current offset using vector addition
            % (unless the distance > maxCorrection, in which case ignore).
            %
            % @todo in future versions may want to have different
            % tolerances for x and y deviations
            %
            % @param	trueXY          the "true" xy gaze coordinate 
            % @param	estXY           the observed xy gaze coordinate
            % @param	maxCorrection	the maximum acceptable deviation
            % @param    weight          amount of weight to give to new evidence (0 <= x <= 1)
            %
            % @date     26/06/14
            % @author   PRJ
            %
            if nargin < 4 || isempty(maxCorrection)
                maxCorrection = obj.maxDriftCorrection_deg; % if not manually overriding
            end
            if nargin < 5 || isempty(weight)
                weight = 1;
            end
         
            d_px = trueXY - estXY;
            d_deg = ivis.math.IvUnitHandler.getInstance().px2deg(d_px); % convert to degrees visual angle
            if any(abs(d_deg) > maxCorrection)
                beep();
                fprintf('WARNING: difference (%1.2f %1.2f) > maxDrift cutoff (%1.2f)\n', abs(d_deg), obj.maxDriftCorrection_deg);
            else
                fprintf('Dift Correction: %1.2f x %1.2f degrees    [%1.2f, %1.2f]\n', weight, sqrt(sum(d_deg.^2)), d_deg);
                obj.driftCorrection_px = (1-weight)*obj.driftCorrection_px + weight*(obj.driftCorrection_px+d_px);
            end
        end
        
        function xy = apply(obj, xy)
            % Apply the stored calibration (and/or drift correction) to a
            % given set of xy gaze coordinates.
            %
            % @param	xy	input gaze coordiantes {n, 2}
            % @return	xy	output gaze coordiantes {n, 2}
            %
            % @date     26/06/14
            % @author   PRJ
            %
            
            % apply calibration
            if ~isempty(obj.cx)
%                 X = [xy ones(size(xy,1),1)];
                X = [xy xy.^2 xy(:,1).*xy(:,2) ones(size(xy,1),1)];
                xy(:,1) = X*obj.cx;
                xy(:,2) = X*obj.cy;
            end
            
            % correct for drift (additive offset)
            if ~all(obj.driftCorrection_px==0)
                xy = bsxfun(@plus, xy, obj.driftCorrection_px);
            end
        end
    end
    
    
    %% ====================================================================
    %  -----SINGLETON BLURB-----
    %$ ====================================================================
    
    methods (Static, Access = ?Singleton)
        function obj = getSetSingleton(obj)
            persistent singleObj
            if nargin > 0, singleObj = obj; end
            obj = singleObj;
        end
    end
    methods (Static, Access = public)
        function obj = getInstance()
            obj = Singleton.getInstanceSingleton(mfilename('class'));
        end
        function [] = finishUp()
            Singleton.finishUpSingleton(mfilename('class'));
        end
        function isIn = isInit()
            o = ivis.main.IvParams.getSingleton(false);
            isIn = ~(isempty(o) || ~isvalid(o));
        end
    end
    
end