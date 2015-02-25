% n.b., have checked that tic/toc and profile results agree

try
	% launch ivis
	IvMain.initialise(params);
	[eyeTracker,log,InH,win] = IvMain.launch();

	% prepare graphic
	tex = Screen('MakeTexture',win,ones(1,1,3));
	gfc =IvGraphic('targ',tex,0,80,200,200,win);
	
	% prepare classifier
	clf = IvClassifierBox(gfc, 0.01);
	clf.show(); % visualise the hit box
    
    % run trial sequence
    k = 1;
    T = nan(50000,5);
    
    profile on
    
    for i = 1:100
        clf.start(); % initialise classifier
        while clf.isUndecided()
            tic();
            InH.getInput();	     % poll keyboard
            T(k,1) = toc(); tic();
            gfc.nudge(3,0);	     % update graphics
            T(k,2) = toc(); tic();
            eyeTracker.refresh();% poll eyetracker
            T(k,3) = toc(); tic();
            clf.update();		      % update classifier
            T(k,4) = toc(); tic();
            gfc.draw();		        % draw graphics
            Screen('Flip', win);
            T(k,5) = toc();
            WaitSecs(.01);		     % pause
            k = k + 1;
        end

    end
    
    profile off
    
	IvMain.finishUp(); % Finish up
	
catch ME
	IvMain.finishUp();
	rethrow(ME);
end