%  Singleton responsible for maintaining a mapping of observed-to-actual
%  gaze coordinates, through (A) a polynomial surface map, and (B) a
%  drift-correction mechanism.
% 
%    Note that this functionally sits on top of any calibration that may
%    be going on within the eyetracking device, and in generally it is
%    better to do the calibration 'in hardware' if possible, rather than
%    relying on this class. However, this may be a little more flexible
%    and transparent.
% 
%  IvCalibration Methods:
%    * IvCalibration         - Constructor.
%    * addMeasurements       - Add observed gaze measurements in response to a presented pair of gaze coordinates.
%    * removeMeasurements	- Remove all obervations recorded in response to the specified targ coordinate pair.
%    * clearMeasurements     - Remove all raw gaze observations.
%    * getMeasurements       - Get all raw gaze observations, separated into those that were and weren't used in the computed calibration.
%    * compute               - Compute a calibration map by fitting a least-square polynomial surface to a given set of targ- and resp- gaze coordinates.
%    * clear                 - Clear the fitted calibration. N.b., doesn't clear the raw measurements.
%    * save                  - Save the fitted calibration, either to the local directory, or to a specified location.
%    * load                  - Load a fitted calibration.
%    * resetDriftCorrection	- Clear any stored drift correction factor.
%    * updateDriftCorrection	- Update the drift correction factor.
%    * apply                 - Apply the stored calibration (and/or drift correction) to a given set of xy gaze coordinates..
%           
%  See Also:
%    None
% 
%  Example:
%    None
% 
%  Author:
%    Pete R Jones <petejonze@gmail.com>
% 
%  Verinfo:
%    1.0 PJ 02/2013 : first_build\n
% 
%  @todo report goodness of fit metric
%  @todo visualization
%  @todo facility to query if point is outside calibrated area? (could
%  be done quite roughly / assuming a rectangle) [alt could be done more
%  elegantly using a graphic movement listener]
% 
%  Copyright 2014 : P R Jones
%  *********************************************************************
% 
%
