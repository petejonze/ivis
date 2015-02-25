% v1 rough mess
% v2 gradual improvement (more content & tidied)

%% init
clear all;
close all

% initialise output options
EXPORT_FORMAT = {'pdf','png','jpg','eps'};
% EXPORT_DIR = NaN; % sprintf('./Figs/%s',datestr(now,1));
EXPORT_DIR = sprintf('./Figs/%s',datestr(now,1));
pkgVer = 0.3;
[exportDir,exportFormat] = fig_init(pkgVer,EXPORT_FORMAT,EXPORT_DIR);
dpi = 150;

%% load data
pj_box = load('data/pj-box-20130313T150647.mat');
sk_ll = load('data/sk-ll-20130313T144103.mat');
pj_ll = load('data/pj-ll-20130313T160007.mat');
sk_box = load('data/sk-box-20130313T153644.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Accuracy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figName = 'accuracy';
    
    % Compute ------------------------------------------------------------
    nBins = 10;

    pj_box = analysis_addMaxSec(pj_box, nBins);
    sk_ll = analysis_addMaxSec(sk_ll, nBins);
    pj_ll = analysis_addMaxSec(pj_ll, nBins);
    sk_box = analysis_addMaxSec(sk_box, nBins);


    % Plot ---------------------------------------------------------------
    colr1 = [.5 .5 .5]; % dark blue
    colr2 = [0 0 0]; % black

    % open a new figure window.
    figDim = [12 12];
    nPlots = [1 2];
    isTight = true;
    isSquare = true;
    styleFlag = [];
    axesLims = [];
    hFig = fig_make(figDim, nPlots, isTight, isSquare, styleFlag, axesLims);

    % plot data (PJ) -----------------------------------------------------
    fig_subplot(1);
    hDat(1) = plot(pj_box.analysis.maxSec.centres, pj_box.analysis.maxSec.pc, '^', 'MarkerFaceColor',colr1, 'MarkerEdgeColor','none');
    hDat(2) = plot(pj_ll.analysis.maxSec.centres, pj_ll.analysis.maxSec.pc, 's', 'MarkerFaceColor',colr2, 'MarkerEdgeColor','none');
    %
    h = psychoplot(pj_box.analysis.maxSec.pfit.xyn, pj_box.analysis.maxSec.pfit.fit);
    delete(h{[1 3 4]});
    set(h{2}, 'LineWidth',2, 'Color',colr1)
    %
 	h = psychoplot(pj_ll.analysis.maxSec.pfit.xyn, pj_ll.analysis.maxSec.pfit.fit);
    delete(h{[1 3 4]});
    set(h{2}, 'LineWidth',2, 'Color',colr2)
	% annotate panel
    textLoc('\textbf{PJ}','SouthEast');    
    
    % plot data (SK) -----------------------------------------------------
    fig_subplot(2);
    plot(sk_box.analysis.maxSec.centres, sk_box.analysis.maxSec.pc, '^', 'MarkerFaceColor',colr1, 'MarkerEdgeColor','none');
    plot(sk_ll.analysis.maxSec.centres, sk_ll.analysis.maxSec.pc, 's', 'MarkerFaceColor',colr2, 'MarkerEdgeColor','none');
    %
    h = psychoplot(sk_box.analysis.maxSec.pfit.xyn, sk_box.analysis.maxSec.pfit.fit);
    delete(h{[1 3 4]});
    set(h{2}, 'LineWidth',2, 'Color',colr1)
    %
 	h = psychoplot(sk_ll.analysis.maxSec.pfit.xyn, sk_ll.analysis.maxSec.pfit.fit);
    delete(h{[1 3 4]});
    set(h{2}, 'LineWidth',2, 'Color',colr2)
	% annotate panel
    textLoc('\textbf{SK}','SouthEast');   

    % format all the axes
    xTick = .4:.4:1.6;
    xTickLabels = [];
    yTick = 0:.25:1;
    yTickLabels = [];
    xTitle = [];
    yTitle = [];
    xlims = [0 2];
    ylims = [0 1];
    fig_axesFormat(NaN, xTick,xTickLabels, yTick,yTickLabels, xTitle,yTitle, xlims,ylims);

    % add legend
    hAxes = 1;
    legendNames = {'LogL','quad'};
    legendTitle = [];
    loc = 'NorthWest';
    fontSize = 12;
    markerSize = [];
    hScale = .75;
    vScale = .8;
    hLeg = fig_legend(hAxes,fliplr(hDat),legendNames,legendTitle, loc, fontSize, markerSize, hScale, vScale);
    fig_nudge(hLeg, -0.05, 0);

    % format the figure
    xTitle = 'Fixation length (secs)'; % 'Interrogation time (secs)';
    yTitle = '\% Correct';
    mainTitle = [];
    fontSize = 16;
    fig_figFormat(hFig, xTitle,yTitle,mainTitle, fontSize);

    % save
	fig_save(hFig, figName, exportDir, exportFormat, dpi);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Saccade ident
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figName = 'saccadeIdent';
    
    % Compute ------------------------------------------------------------
    nBins = 40;
    pj_timings = [pj_box.timings; pj_ll.timings];
    sk_timings = [sk_box.timings; sk_ll.timings];

    
    % Plot ---------------------------------------------------------------
    colr1 = [.5 .5 .5]; % dark blue
    colr2 = [0 0 0]; % black

    % open a new figure window.
    figDim = [12 12];
    nPlots = [1 2];
    isTight = true;
    isSquare = true;
    styleFlag = [];
    axesLims = [];
    hFig = fig_make(figDim, nPlots, isTight, isSquare, styleFlag, axesLims);

    % plot data (PJ) -----------------------------------------------------
    fig_subplot(1);
    timings = pj_timings;
    hist(timings(:,2)-timings(:,1), nBins);
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r','EdgeColor','k','facealpha',0.75)
    hold on;
    hist(timings(:,3)-timings(:,1), nBins);
    h1 = findobj(gca,'Type','patch');
    set(h1,'facealpha',0.75);
	% annotate panel
    textLoc('\textbf{PJ}','NorthEast');    
    
    % plot data (SK) -----------------------------------------------------
    fig_subplot(2);
    timings = sk_timings;
    hist(timings(:,2)-timings(:,1), nBins);
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r','EdgeColor','k','facealpha',0.75)
    hold on;
    hist(timings(:,3)-timings(:,1), nBins);
    h1 = findobj(gca,'Type','patch');
    set(h1,'facealpha',0.75);
	% annotate panel
    textLoc('\textbf{SK}','NorthEast');  
    
    % format all the axes
    xTick = .25:.5:1.75;
    xTickLabels = [];
    yTick = 0:200:600;
    yTickLabels = [];
    xTitle = [];
    yTitle = [];
    xlims = [0 2];
    ylims = [0 600];
    set(gcf,'Renderer','Painter')  
    fig_axesFormat(NaN, xTick,xTickLabels, yTick,yTickLabels, xTitle,yTitle, xlims,ylims);

    % add legend
    hAxes = 2;
    legendNames = {'computer','human'};
    legendTitle = [];
    loc = 'NorthWest';
    fontSize = 12;
    markerSize = [];
    hScale = .38;
    vScale = .8;
    hLeg = fig_legend(hAxes,[h1],legendNames,legendTitle, loc, fontSize, markerSize, hScale, vScale);
    fig_nudge(hLeg, -.06, 0);

    % format the figure
    xTitle = 'Saccade identification lag (secs)';
    yTitle = 'Count';
    mainTitle = [];
    fontSize = 16;
    [hXTitle,hYTitle,hTitle] = fig_figFormat(hFig, xTitle,yTitle,mainTitle, fontSize);
    fig_nudge(hYTitle, 0.15, 0);
    
    %% save
	fig_save(hFig, figName, exportDir, exportFormat, dpi);
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Spatial classification map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% pj_xy = pj_box.xy; %     [pj_box.xy; pj_ll.xy];
% pj_anscorrect = pj_box.anscorrect; %[pj_box.anscorrect; pj_ll.anscorrect];
% 
% N = 2;
% xi = linspace(0,1680,N+2);
% yi = linspace(0,1050,N+2);
% 
% meanData = histcn(pj_xy, xi, yi, 'AccumData', pj_anscorrect, 'Fun', @mean); 
% % sumData = histcn([x y], xi, yi, 'AccumData', ones(size(anscorrect)), 'Fun', @sum);
% %  sum(sum(sumData))
%  
% 
% %   meanData(meanData<5) = .5;
% %   meanData = interp2(meanData,3);
%   
%  close all
% 
%   figure()
% 
%   
%   ha = surf(meanData);
%   set(ha, 'LineStyle','none');
%   view(0, 90); % view from above
%   
% 	ss = size(meanData);
%   set(gca, 'XTick',linspace(1,ss(2),N), 'XTickLabel',round(linspace(0,1680,N)) );
%   set(gca, 'YTick',linspace(1,ss(1),N), 'YTickLabel',round(linspace(0,1050,N)) );
%   
%   %
%   [xx,i] = sort(x);
% %   fprintf('%9.2f %9.2f %i\n',[x(i) y(i) anscorrect(i)]')
  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Precision and accuracy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figName = 'precisionAndAccuracy';

    % Compute ------------------------------------------------------------
    
    screenWidth_cm = 64;
    screenWidth_px = 1680;
    viewingDist_cm = 65;
    unitH = ivis.math.IvUnitHandler(screenWidth_cm, screenWidth_px, viewingDist_cm);
    
    pj_xy =     unitH.px2deg([pj_box.xy; pj_ll.xy]);
    pj_xy_est = unitH.px2deg([pj_box.xy_est; pj_ll.xy_est]);
    sk_xy =     unitH.px2deg([sk_box.xy; sk_ll.xy]);
    sk_xy_est = unitH.px2deg([sk_box.xy_est; sk_ll.xy_est]);

fprintf('-----------------------------------\n');
unitH.deg2cm(1)
fprintf('-----------------------------------\n');


    

    % Plot ---------------------------------------------------------------
    colr1 = [.5 .5 .5]; % dark blue
    colr2 = [0 0 0]; % black

    % open a new figure window.
    figDim = [8 16];
    nPlots = [1 2];
    isTight = true;
    isSquare = true;
    styleFlag = [];
    axesLims = [];
    hFig = fig_make(figDim, nPlots, isTight, isSquare, styleFlag, axesLims);

    % plot data (PJ) -----------------------------------------------------
    fig_subplot(1);
    %
    hold on
        hDat(1) = plot(pj_xy(:,1),pj_xy_est(:,1),'o', 'MarkerFaceColor','r','MarkerEdgeColor','none','MarkerSize',3);
        hDat(2) = plot(pj_xy(:,2),pj_xy_est(:,2),'o', 'MarkerFaceColor','b','MarkerEdgeColor','none','MarkerSize',3);
        xlim([-10 70]); ylim(xlim())
        uline();
    hold off
	% annotate panel
    htxt = textLoc('\textbf{PJ}','NorthEast');    
    fig_nudge(htxt, -.05, .02);
    
    % plot data (SK) -----------------------------------------------------
    fig_subplot(2);
    %
    hold on
        plot(sk_xy(:,1),sk_xy_est(:,1),'o', 'MarkerFaceColor','r','MarkerEdgeColor','none','MarkerSize',3)
        plot(sk_xy(:,2),sk_xy_est(:,2),'o', 'MarkerFaceColor','b','MarkerEdgeColor','none','MarkerSize',3)
        xlim([-10 70]); ylim(xlim())
        uline();
    hold off
	% annotate panel
    htxt = textLoc('\textbf{SK}','NorthEast');  
    fig_nudge(htxt, -.05, .02);
    
    % format all the axes
    xTick = 0:20:60;
    xTickLabels = [];
    yTick = xTick;
    yTickLabels = [];
    xTitle = [];
    yTitle = ' ';
    xlims = [-10 70];
    ylims = xlims;
    fig_axesFormat(NaN, xTick,xTickLabels, yTick,yTickLabels, xTitle,yTitle, xlims,ylims);

    % add legend
    hAxes = 1;
    legendNames = {'X Axis','Y Axis'};
    legendTitle = [];
    loc = 'NorthWest';
    fontSize = 12;
    markerSize = [];
    hScale = .5;
    vScale = .8;
    hLeg = fig_legend(hAxes,hDat,legendNames,legendTitle, loc, fontSize, markerSize, hScale, vScale);
    fig_nudge(hLeg, -.05, 0);

    % format the figure
    xTitle = 'True/Target Position (deg)';
    yTitle = 'Est Position (deg)';
    mainTitle = [];
    fontSize = 16;
    [hXTitle,hYTitle,hTitle] = fig_figFormat(hFig, xTitle,yTitle,mainTitle, fontSize);
    fig_nudge(hYTitle, 0.3, 0);
    %% save
	fig_save(hFig, figName, exportDir, exportFormat, dpi);
    



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Timings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figName = 'timings';
    
    % Compute ------------------------------------------------------------
    nBins = 40;
    pj_timings = [pj_box.timings; pj_ll.timings];
    sk_timings = [sk_box.timings; sk_ll.timings];

    
    % Plot ---------------------------------------------------------------
    colr1 = [.5 .5 .5]; % dark blue
    colr2 = [0 0 0]; % black

    % open a new figure window.
    figDim = [12 12];
    nPlots = [1 2];
    isTight = true;
    isSquare = true;
    styleFlag = [];
    axesLims = [];
    hFig = fig_make(figDim, nPlots, isTight, isSquare, styleFlag, axesLims);

    % plot data (PJ) -----------------------------------------------------
    fig_subplot(1);
    d = pj_xy_est - pj_xy;
    %
    idx = d(:,1)>-10 & d(:,1)<10;
    hist(d(idx,1),50)
    %
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r','EdgeColor','k','facealpha',0.75)
    hold on;
    idx = d(:,2)>-10 & d(:,2)<10;
    hist(d(idx,2),50)
    h1 = findobj(gca,'Type','patch');
    set(h1,'facealpha',0.75);
    % annotate panel
    textLoc('\textbf{PJ}','NorthWest');
    
    % plot data (SK) -----------------------------------------------------
    fig_subplot(2);
    d = sk_xy_est - sk_xy;
    %
    idx = d(:,1)>-10 & d(:,1)<10;
    hist(d(idx,1),50)
    %
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r','EdgeColor','k','facealpha',0.75)
    hold on;
    idx = d(:,2)>-10 & d(:,2)<10;
    hist(d(idx,2),50)
    h1 = findobj(gca,'Type','patch');
    set(h1,'facealpha',0.75);
    % annotate panel
    textLoc('\textbf{SK}','NorthWest');  
    
    % format all the axes
    xTick = -8:4:8;
    xTickLabels = [];
    yTick = 0:50:150;
    yTickLabels = [];
    xTitle = [];
    yTitle = ' ';
    xlims = [-10 10];
    ylims = [0 180];
    set(gcf,'Renderer','Painter')  
    fig_axesFormat(NaN, xTick,xTickLabels, yTick,yTickLabels, xTitle,yTitle, xlims,ylims);

    % add legend
    hAxes = 2;
    legendNames = {'Y axis','X axis'};
    legendTitle = [];
    loc = 'NorthEast';
    fontSize = 12;
    markerSize = [];
    hScale = .38;
    vScale = 1;
    hLeg = fig_legend(hAxes,[h1],legendNames,legendTitle, loc, fontSize, markerSize, hScale, vScale);
    fig_nudge(hLeg, 0.02, 0);

    % format the figure
    xTitle = 'Error (dist from targ in degrees)';
    yTitle = 'Count';
    mainTitle = [];
    fontSize = 16;
    [hXTitle,hYTitle,hTitle] = fig_figFormat(hFig, xTitle,yTitle,mainTitle, fontSize);
    fig_nudge(hYTitle, 0.3, 0);

    %% save
	fig_save(hFig, figName, exportDir, exportFormat, dpi);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Saccade detection rates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figName = 'saccadeDetection';

    % Compute ------------------------------------------------------------
    pj_xy =     ([pj_box.xy_est; pj_ll.xy_est]);
    sk_xy =     ([sk_box.xy_est; sk_ll.xy_est]);
    pj_isSignal =     [pj_box.isSignal; pj_ll.isSignal];
    sk_isSignal =     [sk_box.isSignal; sk_ll.isSignal];
    pj_timings = [pj_box.timings; pj_ll.timings];
    sk_timings = [sk_box.timings; sk_ll.timings];

    idx = any(isnan(pj_xy),2) | ~pj_isSignal;
    pj_xy(idx,:) = [];
    pj_timings(idx,:) = [];
    idx = any(isnan(sk_xy),2) | ~sk_isSignal;
    sk_xy(idx,:) = [];
    sk_timings(idx,:) = [];
        
    pj_D = sqrt(sum(diff(pj_xy).^2,2));
    sk_D = sqrt(sum(diff(sk_xy).^2,2));

    pj_caught = ~isnan(pj_timings(2:end,3));
    sk_caught = ~isnan(sk_timings(2:end,3));
    
    crit = 1800; % bit of a hack (3 weird outlying vals in pj)
    idx = pj_D>crit;
    pj_D(idx) = [];
    pj_caught(idx) = [];
    idx = sk_D>crit;
    sk_D(idx) = [];
    sk_caught(idx) = [];

    nBins = 8;
    pj_fit = analysis_addBinnedFit(unitH.px2deg(pj_D), pj_caught, nBins, 0.01);
    sk_fit = analysis_addBinnedFit_hacked(unitH.px2deg(sk_D), sk_caught, nBins, 0.01);


    % Plot ---------------------------------------------------------------
    colr1 = [.5 .5 .5]; % dark blue
    colr2 = [0 0 0]; % black

    % open a new figure window.
    figDim = [12 12];
    nPlots = [1 2];
    isTight = true;
    isSquare = true;
    styleFlag = [];
    axesLims = [];
    hFig = fig_make(figDim, nPlots, isTight, isSquare, styleFlag, axesLims);

    
    % plot data (PJ) -----------------------------------------------------
    fig_subplot(1);
    hDat = plot(pj_fit.centres, pj_fit.pc, '^', 'MarkerFaceColor',colr2, 'MarkerEdgeColor','none');
    %
    h = psychoplot([], pj_fit.fit);
    delete(h{[1 3 4]});
    set(h{2}, 'LineWidth',2, 'Color',colr1)
    %vline(10,'k:');

	% annotate panel
    textLoc('\textbf{PJ}','NorthWest');    
    
    % plot data (SK) -----------------------------------------------------
    fig_subplot(2);
	hDat = plot(sk_fit.centres, sk_fit.pc, 's', 'MarkerFaceColor',colr2, 'MarkerEdgeColor','none');
 	%
 	h = psychoplot([], sk_fit.fit);
    delete(h{[1 3 4]});
    set(h{2}, 'LineWidth',2, 'Color',colr1)
	% annotate panel
    textLoc('\textbf{SK}','NorthWest');   
    %vline(10,'k:');
    
    % format all the axes
    xTick = 10:10:50; % 0:500:1500;
    xTickLabels = [];
    yTick = 0:.25:1;
    yTickLabels = [];
    xTitle = ' ';
    yTitle = [];
    xlims = [0 60]; % [-250 2000];
    ylims = [0 1];
    fig_axesFormat(NaN, xTick,xTickLabels, yTick,yTickLabels, xTitle,yTitle, xlims,ylims);

    % format the figure
    xTitle = 'Saccade distance (deg)';
    yTitle = '\% Detected';
    mainTitle = [];
    fontSize = 16;
    fig_figFormat(hFig, xTitle,yTitle,mainTitle, fontSize);

    %% save
	fig_save(hFig, figName, exportDir, exportFormat, dpi);


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Classification schemas (1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figNameA = 'classSchemaA';
figNameB = 'classSchemaB';

    close all


    width = 1024; height = 768;
    mu1 = [270 500]; sigma1 = [130 130];
    mu2 = [750 150]; sigma2 = [130 130];
    muDat = [350 500]; sigmaDat = [75 75];

    DAT = mvnrnd(muDat, sigmaDat.^2, 50);

    %%% Precision and accuracy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figName = 'adadasdasdasd';

    % Compute ------------------------------------------------------------
    nBins = 40;
    pj_timings = [pj_box.timings; pj_ll.timings];
    sk_timings = [sk_box.timings; sk_ll.timings];


    % Plot ---------------------------------------------------------------
    colr1 = [.5 .5 .5]; % dark blue
    colr2 = [0 0 0]; % black

    % open a new figure window.
    figDim = [8 12];
    nPlots = [1];
    isTight = true;
    isSquare = false;
    styleFlag = [];
    axesLims = [];
    hFig = fig_make(figDim, nPlots, isTight, isSquare, styleFlag, axesLims);


    mx = width/2; % construct polygons
    my = height/2;
    w = .45*width;
    h = .45*height;
    nPoly = 5;
    poly = struct();
    poly(1).x = [0 mx mx mx-w/2 0 0]; % top-left
    poly(1).y = [height height my+h/2 my my height];
    poly(2).x = width - poly(1).x; % top-right
    poly(2).y = poly(1).y;
    poly(3).x = poly(2).x; % bottom-right
    poly(3).y = height - poly(2).y;
    poly(4).x = poly(1).x; % bottom-left
    poly(4).y = poly(3).y;
    poly(5).x = mx + [0 -w/2 0 w/2 0]; % middle
    poly(5).y = my + [-h/2 0 h/2 0 -h/2];
    % Plot
    hold on
    % objects
    img=imread('pics/Panda.png','BackgroundColor',[1 1 1]);
    img = flipdim(img,1);
    img = imresize(img, .25);
    imagesc(mu1(1)-size(img,2)/2, mu1(2)-size(img,1)/2, img)
    img=imread('pics/Elephant.png','BackgroundColor',[1 1 1]);
    img = flipdim(img,1);
    img = imresize(img, .25);
    imagesc(mu2(1)-size(img,2)/2, mu2(2)-size(img,1)/2, img)

    % polygons
    for i = 1:nPoly
        plot(poly(i).x,poly(i).y, 'k', 'linewidth', 3);
    end

    % plot data
    h = stem3(DAT(:,1),DAT(:,2),zeros(size(DAT,1),1),'b.','markersize',12);
    hold off
    xlim([0 width]);
    ylim([0 height]);
    set(gca, 'xtick',[], 'ytick',[]);

    % save
    fig_save(hFig, figNameA, exportDir, exportFormat, dpi);

    
    % FIG B
    hFig = pdfPlot(mu1, sigma1, mu2, sigma2, width, height, DAT);
    set(gcf,'Color',[1 1 1]);
    fig_save(hFig, figNameB, exportDir, 'jpg');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Classification schemas (2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figNameA = 'bars';
figNameB = 'randomwalk';

    % A ----------------------------------
    % compute (easier than making up)
    n = nan(1,5);
    for i = 1:5
        n(i) = sum(inpolygon(DAT(:,1),DAT(:,2),  poly(i).x,poly(i).y));
    end
    
    % make figure
    hFig = fig_make([8 14],[],[],false);

    % Plot data
    bar(n)
    [h,hTxt] = hline(max(n),'k:','$\lambda$');
    set(h,'linewidth',3);
    set(hTxt,'fontsize',14);
    fig_nudge(hTxt,.1,3.7);
    
    % format the axes
    xTicks = 1:5;
    xTickLbls = {'TLeft', 'TRight', 'BRight', 'BLeft', 'Centre'};
    yTicks = [];
    yTickLbls = [];
    xAxisTitle = [];
    yAxisTitle = [];
    xlims = [];
    ylims = [];
    fig_axesFormat(NaN, xTicks,xTickLbls, yTicks,yTickLbls,  xAxisTitle,yAxisTitle, xlims,ylims);

    % format the figure
    xTitle = 'Quadrant';
    yTitle = 'N Observations';
    fig_fontSize = 16;
    fig_figFormat(hFig,xTitle,yTitle,[],fig_fontSize,false);

    % save
    fig_save(hFig, figNameA, exportDir, exportFormat, dpi);
    

    % B ----------------------------------
    n = 100;
    xData = 1:n;
    yData = linspace(0,1,n) + rand(1,n)/10;

    % make figure
    hFig = fig_make([8 14],[],[],false);

    % Plot data
    xlim([0 n]); ylim([-1.2 1.2]);
    hline(0,'k:');
    [h1,h1Txt] = hline(1,'b:','$\lambda_{panda}$');
    [h2,h2Txt] = hline(-1,'r:','$\lambda_{elephant}$');
    hDat = plot(xData,yData,'k-');
    set([h1 h2 hDat],'linewidth',3);
    set([h1Txt h2Txt],'fontsize',14);
    fig_nudge(h1Txt,.1,-.1)
    fig_nudge(h2Txt,.1,.1)

    % format the axes
    xTicks = [NaN];
    xTickLbls = [];
    yTicks = NaN;
    yTickLbls = NaN;
    xAxisTitle = [];
    yAxisTitle = [];
    xlims = [1 n];
    ylims = [-1.2 1.2];
    fig_axesFormat(NaN, xTicks,xTickLbls, yTicks,yTickLbls,  xAxisTitle,yAxisTitle, xlims,ylims);

    % format the figure
    xTitle = '\textbf{Time}, $secs$';
    yTitle = '\textbf{Log Likelihood}';
    fig_fontSize = 16;
    fig_figFormat(hFig,xTitle,yTitle,[],fig_fontSize,false);

    % save
    fig_save(hFig, figNameB, exportDir, exportFormat, dpi);
    
%%

    unitH.finishUp();
    