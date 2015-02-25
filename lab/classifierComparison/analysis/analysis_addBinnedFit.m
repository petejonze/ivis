function DAT = analysis_addBinnedFit(x, y, nBins, lapseLim)

    %% init
    if nargin < 4 || isempty(lapseLim)
        lapseLim = 0.05;
    end
        

    %% bin raw
    scale = linspace(min(x),max(x)+.1, nBins+1);
    [n,bin] = histc(x, scale);
    centres = diff(scale)/2 + scale(1:end-1);
    pc = nan(1, nBins);
    for i = 1:nBins
        pc(i) = mean(y(bin==i));
    end
    DAT.centres = centres;
    DAT.pc = pc;
    DAT.n = n(1:end-1);
    
    %% Psychometric fit

    % construct fitting dataset
    xyn = [x y ones(size(y))];
    xyn = [DAT.centres' DAT.pc' DAT.n]
    %
    shape = 'cumulative Gaussian';
    plotMode = 'no plot';
%     lapseLim = .2;
    n_intervals = 1;
    nruns = 0; % 2000; % 0; % 2000;
    th_level = .707; %the point targeted by 2up-1down
    isDebugMode = 0;
    %  
    % perform fit ( ... xyn, 'plot', ...  for lots of plotting goodness)
    fit = pfit(xyn,'n_intervals', n_intervals, 'verbose', isDebugMode, 'runs', nruns, 'shape', shape, 'PLOT_OPT', plotMode,'gamma_limits',[0 lapseLim],'lambda_limits',[0 lapseLim]);
    thresh = findthreshold(shape, fit.params.est, th_level, 'performance'); % get threshold also
    slope = findslope(shape, fit.params.est, th_level, 'performance');
    %
    % store values
    DAT.xyn = xyn;
    DAT.fit = fit;
    DAT.thresh = thresh;
    DAT.slope = slope;
                
                
end