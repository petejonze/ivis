import ivis.classifier.* ivis.graphic.* ...
	      ivis.main.* ivis.log.*;

try
	% launch ivis
	params = IvParams.getDefaultConfig();
	IvMain.initialise(params);
	[eyeTracker,log,InH,win] = IvMain.launch();

	% prepare graphic
	tex = Screen('MakeTexture',win,ones(1,1,3));
	gfc =IvGraphic('targ',tex,400,80,90,90,win);
	
	% prepare classifier
	clf = IvClassifierBox(gfc, 0.01);
	clf.show(); % visualise the hit box
	
	% run trial sequence
	for i = 1:100
		clf.start(); % initialise classifier
		while clf.isUndecided()
			InH.getInput();	     % poll keyboard
			gfc.nudge(3,0);	     % update graphics
			gfc.draw();		        % draw graphics
			eyeTracker.refresh();% poll eyetracker
			clf.update();		      % update classifier
			Screen('Flip',win);  % update screen
			WaitSecs(.01);		     % pause
		end
		
		% compute whether a hit
		resp = clf.interogate().name();
		hit(i) = strcmpi('targ', resp);
		
		% give visual feedback
		DrawFormattedText(win, resp);
		Screen('Flip', win);
		WaitSecs(0.5);
		
		% save data
		log = IvDataLog.getInstance();
		fn{i} = log.save(sprintf('trl-%i',i));
        
		% update graphics accordingly
		w = gfc.width*abs(1.5-hit(i)*2);
		gfc.reset(0,80,w,w);
	end
	
	% save trial sequence and exit
	save('data', 'fn', 'hit');
	IvMain.finishUp(); % Finish up
	
catch ME
	IvMain.finishUp();
	rethrow(ME);
end