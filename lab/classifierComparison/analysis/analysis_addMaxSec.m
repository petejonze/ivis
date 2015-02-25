function DAT = analysis_addMaxSec(DAT, nBins)

    x = linspace(min(DAT.maxSecs),max(DAT.maxSecs)+.1, nBins+1);
    [n,bin] = histc(DAT.maxSecs, x);
    centres = diff(x)/2 + x(1:end-1);
    pc = nan(1, nBins);
    for i = 1:nBins
%         pc(i) = mean(DAT.anscorrect(bin==i & DAT.isSignal==1));
        pc(i) = mean(DAT.anscorrect(bin==i));
    end
    DAT.analysis.maxSec.centres = centres;
    DAT.analysis.maxSec.pc = pc;
    
    
    %% Psychometric fit

    % construct fitting dataset
    xyn = [DAT.maxSecs DAT.anscorrect ones(size(DAT.maxSecs))];
    %
    shape = 'cumulative Gaussian';
    plotMode = 'no plot';
    lapseLim = .2;
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
    DAT.analysis.maxSec.pfit.xyn = xyn;
    DAT.analysis.maxSec.pfit.fit = fit;
    DAT.analysis.maxSec.pfit.thresh = thresh;
    DAT.analysis.maxSec.pfit.slope = slope;
                
                
end