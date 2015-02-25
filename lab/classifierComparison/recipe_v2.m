%%
pid = 'pj';
nTrialsPerCell = 8;
nCells = 8;
nTrialsTotal = nTrialsPerCell * nCells^2 %512
breakAfterTrial = 50:50:nTrialsTotal

%%
[xy, isSignal, maxSecs, xy_est, classification, timings] = mess_classifierComparison_v2('ll', nTrialsPerCell, nCells, breakAfterTrial);
anscorrect = (classification == isSignal);
save(sprintf('pid-ll-%s',datestr(now,30)), 'xy','isSignal','maxSecs','xy_est','classification','timings','anscorrect')

%%
[xy, isSignal, maxSecs, xy_est, classification, timings] = mess_classifierComparison_v2('box', nTrialsPerCell, nCells, breakAfterTrial);
anscorrect = (classification == isSignal);
save(sprintf('pid-box-%s',datestr(now,30)), 'xy','isSignal','maxSecs','xy_est','classification','timings','anscorrect')

%%


figure();
plot(xy(:,1),xy_est(:,1),'ro', xy(:,2),xy_est(:,2),'go', [0 2000],[0 2000],'k-')
%%
sum(anscorrect)/length(anscorrect)

[~,idx] = sort(maxSecs);
anscorrect(idx)

figure();
subplot(1,2,1); hist(timings(:,2)-timings(:,1),40); xlim([0 1.5])
subplot(1,2,2); hist(timings(:,3)-timings(:,1),40); xlim([0 1.5])

return
