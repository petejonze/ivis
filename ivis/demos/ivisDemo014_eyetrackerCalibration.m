function [] = ivisDemo014_eyetrackerCalibration()
% ivisDemo014_eyetrackerCalibration. Calibration using polynomial surface fitting and
% drift correction. In this demo the mouse cursor represents the 'true'
% fixation position, and the white dot texture represents the misaligned
% 'estimated' position (before and after calibration).
%
% When running, press space to start the calibration loop, and then press
% space when hovering the mouse cursor over each red circle.
%
% Requires:         ivis toolbox v1.5
%
% Matlab:           v2015 onwards
%
% See also:         ivisDemo013_externalConfigFiles.m
%                   ivisDemo015_identifyingSaccades.m
%
% Author(s):    	Pete R Jones <petejonze@gmail.com>
%
% Version History:  1.0.0	PJ  22/06/2013    Initial build
%                   1.1.0	PJ  18/10/2013    General tidy up (ivis 1.4)
%                   1.2.0	PJ  28/09/2017    Updating for ivis 1.5
%
%
% Copyright 2017 : P R Jones <petejonze@gmail.com>
% *********************************************************************
% 

    % clear memory and set workspace
    clearAbsAll();
    import ivis.main.* ivis.control.* ivis.broadcaster.* ivis.calibration.*;

    % verify, initialise, and launch the ivis toolbox
    IvMain.assertVersion(1.5);
    IvMain.initialise(IvParams.getDefaultConfig('GUI.useGUI',false, 'graphics.runScreenChecks',false));
    [eyetracker, log, InH, winhandle] = IvMain.launch();

    try % wrap in try..catch to ensure a graceful exit
        
        % initialise
        ShowCursor()
        eyetracker.updateDriftCorrection([0 0], [100 100], 99);
        calib = IvCalibration.getInstance();

        % idle until keypress
        fprintf('press space to start the calibration loop, and then press space when hovering the mouse cursor over each red circle.\n');
        while ~any(InH.getInput() == InH.INPT_SPACE.code)
            eyetracker.refresh(false); % false to suppress data logging
            DrawFormattedText(winhandle, 'press space to start the calibration loop\nthen press space when hovering the mouse cursor over each red circle');
            Screen('Flip', winhandle);
            WaitSecs(1/60);
        end
        
        % define calibration targets
        [w,h] = RectSize(Screen('Rect', winhandle));
        targs_xy = [0.1,0.1;.1,.5;.1,.9; 0.5,0.1;.5,.5;.5,.9; 0.9,0.1;.9,.5;.9,.9];
        targs_xy(:,1) = targs_xy(:,1) * w;
        targs_xy(:,2) = targs_xy(:,2) * h;
        
       	% gather calibration data
        n = size(targs_xy, 1);
        for i = 1:n
            while ~any(InH.getInput() == InH.INPT_SPACE.code)
                eyetracker.refresh(); % logging enabled
                Screen('DrawDots', winhandle, targs_xy(i,:), 40, [255 0 0]); % , 40, [255 0 0], [], 1);
                Screen('Flip', winhandle);
                WaitSecs(1/60);
            end
            resp = log.data.getLastN(10, 1:2);
            calib.addMeasurements(targs_xy(i,:), resp);
        end
        
        % compute calibration (which will be applied automatically
        % hereafter)
        calib.compute();
        
        % idle to show that it has worked
        fprintf('Try moving the mouse cursor around the target monitor.\nPress SPACE to exit\n');
        while ~any(InH.getInput() == InH.INPT_SPACE.code)
            eyetracker.refresh(false); % false to suppress data logging
            DrawFormattedText(winhandle, 'Calibration complete. Try looking around. Press space to end');
            Screen('Flip', winhandle);
            WaitSecs(1/60);
        end

    catch ME
        IvMain.finishUp();
        rethrow(ME);
    end

    % that's it! close open windows and release memory
    IvMain.finishUp();
    
    %% %%%%%%%% Run a simulation, demonstrating the same point %%%%%%%%%%%%
    
    % initialise params
    nSamples = 40;
    noise = [.01 .01];
    targs_xy = [1 3; 2.5 3; 4 3
                1 2; 2.5 2; 4 2
                1 1; 2.5 1; 4 1];
    shift = [.2 -.4; 0 -.4; -.2 -.4
             .2   0; 0   0; -.2 0
             .2  .4; 0  .4; -.2  .4];
    shift2 = [.3 -.3; 0 0; 0 0
               0  0; 0 0; 0 0
               0  0; 0 0; 0 0];
	params.drift.maxDriftCorrection_deg = [6 6];
    params.GUIidx = [];
    params.targCoordinates = [];
    params.presentationFcn = [];
    params.nRecursions = 0;
    params.outlierThresh_px = 10;
    calib = ivis.calibration.IvCalibration(params);
      
    % gather data
    [targ,resp] = lcl_genResponses(targs_xy, nSamples, noise, shift+shift2);
    calib.addMeasurements(targ, resp);

    
    % compute calibration
    calib.compute();

    % plot
    figure();
    tmp = targs_xy+shift+shift2;
    [resp_used, resp_excluded] = calib.getRawMeasurements();
    plot(resp_used(:,1),resp_used(:,2),'g+', resp_excluded(:,1),resp_excluded(:,2),'rx');
    hold on
    for i = 1:size(targs_xy,1)
        plot([targs_xy(i,1) tmp(i,1)], [targs_xy(i,2) tmp(i,2)], 'k-')
    end
        
    % gather some fresh points
    [targ, resp] = lcl_genResponses(targs_xy, nSamples, noise, shift);
%     X = [resp ones(size(resp,1),1)];
    X = [resp resp.^2 resp(:,1).*resp(:,2) ones(size(resp,1),1)];
    xhat = X*calib.cx; % e.g., xhat = cx(1)*x + cx(2)*y +cx(3);
    yhat = X*calib.cy; % e.g., yhat = cy(1)*x + cy(2)*y +cy(3);

    % add to plot
    hold on
    plot(xhat,yhat,'b^','MarkerSize',5, 'MarkerFaceColor',[1 1 .6]);
    plot(targ(:,1),targ(:,2),'o', 'MarkerFaceColor','k')
end


function [targ, resp] = lcl_genResponses(targs_xy, nSamples, noise, shift)
    n = size(targs_xy, 1);
    targ = nan(n*nSamples, 2);
    resp = nan(n*nSamples, 2);
    for i = 1:n
        idx = ((i-1)*nSamples+1):(i*nSamples);
        targ(idx,:) = repmat(targs_xy(i,:), nSamples, 1);

        mu = targs_xy(i,:) + shift(i,:);
        resp(idx,:) = mvnrnd(mu, noise, nSamples);
    end
end