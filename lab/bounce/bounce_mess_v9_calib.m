% some tweaks to how the gabor is created. Clarifications to parameter
% values.
clc; close all; clear all


clearAbsAll();
javaaddpath(which('MatlabGarbageCollector.jar'))
jheapcl

load gammaTables-08-Jul-2013
gammaTable = gammaTable_avg;

%%%%%%%
%% 1 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% User Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% user params
testScreenNum = 2;
nPoints = 1;
fullScreen = true;
maxVelocity = 0; % 512; % 256; % per frame
maxRotationVelocity = 0; % 8; % per framemaxVelocity
scale = 1;
rotAngles = zeros(1, nPoints) * 215; % rotation angles (in degrees: 0-360) gammaTable2 

% others tried:
% rotAngles = rand(1, nPoints) * 360; random
% rotAngles = ones(1, nPoints) * 145;
% rotAngles = ones(1, nPoints) * 60; % used with gammaTable3?

%%
screenWidth_cm = 59.5;

rect=Screen('Rect', testScreenNum);
screenWidth_px = rect(3); % e.g. 1920
viewingDist_cm = 30;
%
pixel_per_cm = screenWidth_px/screenWidth_cm
screenWidth_dg = 2*rad2deg(atan(screenWidth_cm/(2*viewingDist_cm)))
pixel_per_dg = screenWidth_px/screenWidth_dg
maxFreq_cpd = pixel_per_dg/2 % cycles per degree

%%

% ptb-3 params
targFrameRate = 60;
phase = 0;          % Phase of underlying sine grating (degrees)
sc = 60.0;          % Spatial constant of the exponential "hull" (ie. the "sigma" value in the exponential function)
freq = .1;         % Frequency of sine grating (cycles per pixel)
contrast = 1; % .2;       % Contrast of grating:
aspectratio = 1.0;  % Aspect ratio width vs. height (n.b. this param is ignored since nonSymmetric flag is set to 0 below)


res = 1*[512 512];

try
    
    %%%%%%%
    %% 2 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Init PsychToolBox %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
    % PTB-3 correctly installed and functional? Abort otherwise.
    AssertOpenGL;

    % !!!!required to work on slow computers!!! Use with caution!!!!!
    Screen('Preference', 'SkipSyncTests', 1);
    
    % Enable unified mode of KbName, so KbName accepts identical key names 
    % on all operating systems
    KbName('UnifyKeyNames');
    
    %funnily enough, the very first call to KbCheck takes itself some
    %time - after this it is in the cache and very fast
    %to make absolutely sure, we thus call it here once for no other
    %reason than to get it cached. This btw. is true for all major
    %functions in Matlab, so calling each of them once before entering the
    %trial loop will make sure that the 1st trial goes smooth wrt. timing.
    KbCheck;
    
    %disable output of keypresses to Matlab. !!!use with care!!!!!!
    %if the program gets stuck you might end up with a dead keyboard
    %if this happens, press CTRL-C to reenable keyboard handling -- it is
    %the only key still recognized.
    ListenChar(2);
    
    %get rid of the mouse cursor, we don't have anything to click at anyway
    HideCursor;
    
    % Open a fullscreen, onscreen window with gray background. Enable 32bpc
    % floating point framebuffer via imaging pipeline on it, if this is
    % possible on your hardware while alpha-blending is enabled. Otherwise
    % use a 16bpc precision framebuffer together with alpha-blending. We
    % need alpha-blending here to implement the nice superposition of
    % overlapping gabors. The demo will abort if your graphics hardware is
    % not capable of any of this.
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    % PsychImaging('AddTask', 'General', 'UseFastOffscreenWindows');
    % PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
    % PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput');
    % PsychImaging('AddTask', 'General', 'EnableGenericHighPrecisionLuminanceOutput', lut);
    % PsychImaging('AddTask', 'General', 'EnableNative10BitFramebuffer');
    % PsychImaging('AddTask', 'General', 'EnableVideoSwitcherCalibratedLuminanceOutput');
    
   	% Find the color values which correspond to white and black: Usually
	% black is always 0 and white 255, but this rule is not true if one of
	% the high precision framebuffer modes is enabled via the
	% PsychImaging() commmand, so we query the true values via the
	% functions WhiteIndex and BlackIndex:
	white=WhiteIndex(testScreenNum);
	black=BlackIndex(testScreenNum);
    
    % Round gray to integral number, to avoid roundoff artifacts with some
    % graphics cards:
	gray=round((white+black)/2);

    % This makes sure that on floating point framebuffers we still get a
    % well defined gray. It isn't strictly neccessary in this demo:
    if gray == white
		gray=white / 2;
    end
    
    % Open Window
    if fullScreen
        [graphicParams.winhandle,winRect]=PsychImaging('OpenWindow',testScreenNum,gray, [], [], 2);
        [w, h] = RectSize(winRect);
        minX = 0;
        minY = 0;
        maxX = w-1;
        maxY = h-1;
    else
        minX = 0;
        maxX = 600;
        minY = 0;
        maxY = 600;
        [graphicParams.winhandle,winRect] = PsychImaging('OpenWindow',testScreenNum,gray, [minX minY maxX maxY], [], 2);
    end
    
    % Gamma-adjustment (linearisation)
    if exist('gammaTable','var');
        Screen('LoadNormalizedGammaTable', graphicParams.winhandle, gammaTable*[1 1 1]);
    end
    
 	% Enable alpha-blending, set it to a blend equation useable for linear
    % superposition with alpha-weighted source. This allows to linearly
    % superimpose gabor patches in the mathematically correct manner, 
    % should they overlap. Alpha-weighted source means: The 'globalAlpha' 
    % parameter in the 'DrawTextures' can be used to modulate the intensity
    % of each pixel of the drawn patch before it is superimposed to the
    % framebuffer image, ie., it allows to specify a global per-patch
    % contrast value:
    Screen('BlendFunction', graphicParams.winhandle, GL_ONE, GL_ONE);
    
    % Compute graphic params
    screenDimensions=[RectWidth(winRect), RectHeight(winRect)];
    ifi=Screen('GetFlipInterval', graphicParams.winhandle);
    maxFlipsPerSecond = 1/ifi;
    waitframes = maxFlipsPerSecond/targFrameRate;
    %
    graphicParams.screenWidth = screenDimensions(1);
    graphicParams.screenHeight = screenDimensions(2);
    graphicParams.ifi = ifi;
    graphicParams.waitframes = waitframes;
    graphicParams.Fr = maxFlipsPerSecond/waitframes; % effective framerate
    graphicParams.waitDuration = (graphicParams.waitframes - 0.5) * graphicParams.ifi;    
    [graphicParams.mx, graphicParams.my] = RectCenter(winRect);
    [graphicParams.w, graphicParams.h] = RectSize(winRect);
    
    % parse user params
   	scales = repmat(scale,1,nPoints);

    % Define prototypical gabor patch of res(1) x res(2) pixels. Later on, the 'DrawTexture' command will
    % simply scale this patch up and down to draw individual patches of the
    % different wanted sizes:
    tw = res(1);
    th = res(2);
    
    % Initialize matrix with spec for all 'ngabors' patches to start off
    % identically:
    mypars = repmat([phase+180, freq, sc, contrast, aspectratio, 0, 0, 0]', 1, nPoints);
    
    % Build a procedural gabor texture for a gabor with a support of tw x
    % th pixels and the 'nonsymetric' flag set to 0 to force only symmetric
    % aspect ratios
    nonSymmetric = 0;
    backgroundColorOffset = [0 0 0 0];
    disableNorm = 1;
    contrastPreMultiplicator = 0.5;
    gabortex = CreateProceduralGabor(graphicParams.winhandle, tw, th, nonSymmetric, backgroundColorOffset, disableNorm, contrastPreMultiplicator);
    
    % as per Nyquist/Shannon
    minFreq_cpp = 0.01; % (cycles per pixel)
    maxFreq_cpp = 0.5; % (cycles per pixel)

    % Draw the gabor once, just to make sure the gfx-hardware is ready for
    % the benchmark run below and doesn't do one time setup work inside the
    % benchmark loop. The flag 'kPsychDontDoRotation' tells 'DrawTexture'
    % not to apply its built-in texture rotation code for rotation, but
    % just pass the rotation angle to the 'gabortex' shader -- it will
    % implement its own rotation code, optimized for its purpose.
    % Additional stimulus parameters like phase, sc, etc. are passed as
    % 'auxParameters' vector to 'DrawTexture', this vector is just passed
    % along to the shader. For technical reasons this vector must always
    % contain a multiple of 4 elements, so we pad with three zero elements
    % at the end to get 8 elements.
    Screen('DrawTexture', graphicParams.winhandle, gabortex, [], [], [], [], [], [], [], kPsychDontDoRotation, [phase, freq, sc, contrast, aspectratio, 0, 0, 0]);
    
    % Preallocate array with destination rectangles: This also defines
    % initial gabor patch orientations, scales and location for the very
    % first drawn stimulus frame:
    texrect = Screen('Rect', gabortex);
    inrect = repmat(texrect', 1, nPoints);
    dstRects = zeros(4, nPoints);
    for i=1:nPoints
        dstRects(:, i) = CenterRectOnPoint(texrect * scales(i), rand * graphicParams.w, rand * graphicParams.h)';
    end
    

    
    %%%%%%%
    %% 3 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Init Movement Handler %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
            
%         % Press any key to continue
%         myFlip(graphicParams); % clear
%         DrawFormattedText(graphicParams.winhandle, 'Press any key to continue', 'center', 'center', 255, 75, false, false, 1.5);
%         myFlip(graphicParams); % show text on next refresh cycle
%         KbWait([], 3); % Wait for key stroke.
        
 	InH = InputHandler([], {'a','s'});
        
    while 1
        
        [w, h] = RectSize(winRect);
        minX = 0;
        maxX = w;
        minY = 0;
        maxY = h;
        
        % init movement handler
        sigma = sc*8; % hack?
        b = [minX maxX minY maxY];
        %
        margin = .05;
        xmargin = margin * w;
        ymargin = margin * h;
        minX = (minX + xmargin) + sc;
        maxX = (maxX - xmargin) - sc;
        minY = (minY + ymargin) + sc;
        maxY = (maxY - ymargin) - sc;
        x = minX + (maxX-minX).*rand(nPoints,1);
        y = minY + (maxY-minY).*rand(nPoints,1);
        s = 0; % init speed
        v = (3-randi(2,[nPoints,1])*2) * maxVelocity/2 + maxVelocity*rand(nPoints,1);
        u = (3-randi(2,[nPoints,1])*2) * maxVelocity/2 + maxVelocity*rand(nPoints,1);
        m = ones(nPoints,1);
        myLJP = LennardJonesPotential(x,y,v,u,m,b,sigma,ifi,[],maxVelocity);
        
        %%%%%%%
        %% 4 %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Run %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Run
        t = [];
        vbl = 0;
        usrinput = inf;
        while first(usrinput ~= InH.INPT_SPACE.code)
            
            usrinput = InH.getInput();
            if usrinput == 1
                freq = freq-.01;
                freq = max(freq,0);
            elseif usrinput == 2
                freq = freq+.01;
                freq = min(freq,0.5);
            end
            mypars = repmat([phase+180, freq, sc, contrast, aspectratio, 0, 0, 0]', 1, nPoints);
            
            tic
            % Batch-Draw all gabor patches at the positions and orientations
            % and with the stimulus parameters 'mypars', computed during last
            % loop iteration:
            Screen('DrawTextures', graphicParams.winhandle, gabortex, [], dstRects, rotAngles, [], [], [], [], kPsychDontDoRotation, mypars);
            Screen('DrawText', graphicParams.winhandle, sprintf('freq = %1.3f (%1.3f)    cont = %1.3f     r = %1.2f',freq,freq*pixel_per_dg,contrast,rotAngles(1)), 0, 0, [255, 0, 0, 255]);
            
            % Mark drawing ops as finished, so the GPU can do its drawing job
            % while we can compute updated parameters for next animation frame.
            % This command is not strictly needed, but it may give a slight
            % additional speedup, because the CPU can compute new stimulus
            % parameters in Matlab, while the GPU is drawing the stimuli for
            % this frame. Sometimes it helps more, sometimes less, or not at
            % all, depending on your system and code, but it only seldomly
            % hurts. performance...
            Screen('DrawingFinished', graphicParams.winhandle);
            
            % Compute updated positions and orientations for next frame. This
            % code is vectorized, but could be probably optimized even more.
            % Indeed, these few lines of Matlab code are the main
            % speed-bottleneck for this demos animation loop on modern graphics
            % hardware, not the actual drawing of the stimulus. The demo as
            % written here is CPU bound - limited in speed by the speed of your
            % main processor.
            if maxVelocity ~= 0 % else vars will never change, and may even run into division-by-zero errors
                [x,y,s] = myLJP.calcNextTimestep();
            end
            
            % x = minX + (maxX-minX).*rand(nPoints,1);
            % y = minY + (maxY-minY).*rand(nPoints,1);
            
            
            % Recompute dstRects destination rectangles for each patch, given
            % the 'per gabor' scale and new center location (x,y):
            if nPoints == 1
                r = (inrect .* repmat(scales,4,1))';
            else
                r = inrect .* repmat(scales,4,1);
            end
            dstRects = CenterRectOnPointd(r, x', y');
            
            % Compute new random orientation for each patch in next frame:
            if maxRotationVelocity ~= 0 % else vars will never change, and may even run into division-by-zero errors
                rotAngles = rotAngles+maxRotationVelocity*(s'/maxVelocity)/sqrt(2); % TODO: simplify
            end
            
            % flip
            vbl = Screen('Flip', graphicParams.winhandle, vbl + graphicParams.waitDuration);
            
            t(end+1) = toc;
            
            WaitSecs(ifi/2);
        end
        
        mean(t)
        std(t)
        min(t)
        max(t)
        
    end
    
    %%%%%%%
    %% 5 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Finish-up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    ShowCursor;
    ListenChar(0);
    Screen('CloseAll');
    ListenChar(0);
catch ME
    ShowCursor;
    ListenChar(0);
    Screen('CloseAll');
    ListenChar(0);
    rethrow(ME);
end