import ivis.classifier.* ivis.graphic.* ...
	      ivis.main.* ivis.log.*;

% 1
params = IvParams.getDefaultConfig('eyetracker.fixationMarker','none', 'graphics.monitorWidth_cm',45.20, 'graphics.monitorHeight_cm',36.10, 'graphics.testScreenWidth',1280, 'graphics.testScreenHeight',1024);
listings_demo_A_timing();

T(1,:) = [];
T = [T sum(T(:,1:4),2) sum(T,2)];
nanmean(T)

T1 = T;


%% 2
params = IvParams.getDefaultConfig('GUI.useGUI',false, 'eyetracker.fixationMarker','none', 'graphics.monitorWidth_cm',45.20, 'graphics.monitorHeight_cm',36.10, 'graphics.testScreenWidth',1280, 'graphics.testScreenHeight',1024);
listings_demo_A_timing();

T(1,:) = [];
T = [T sum(T(:,1:4),2) sum(T,2)];
nanmean(T)

T2 = T;


%%

save('timings.mat', 'T1','T2')
sum(~isnan(T1))
sum(~isnan(T2))

%%
    
nanmean(T1*1000)
nanstd(T1*1000)

nanmean(T2*1000)
nanstd(T2*1000)

