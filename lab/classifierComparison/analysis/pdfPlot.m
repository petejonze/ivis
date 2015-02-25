function hFig = pdfPlot(mu1, sigma1, mu2, sigma2, width, height, DAT)

    %%%%%%%
    %% 1 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % user params
    d = 2.5; % duration of each animation segment (same for all)
    Fs = 20;

    % mu1 = [270 500]; sigma1 = [175 175];
    % mu2 = [750 150]; sigma2 = [175 175];

%     width = 1024; height = 768;
N = 100;


    %%%%%%%
    %% 2 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Draw Figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % create figure
    hFig = figure('Position',[1 1 550 400]);
    axes('position',[.2,.3,.6,.5],'YAxisLocation','Right'); % make axes, leave room for labels

    % plot params
    x = linspace(1,width, N);
    y = linspace(1,height, N);
    [X1,X2] = meshgrid(x', y');
    xy = [X1(:) X2(:)];

    % Setup ticks and labels
    xl = xlabel(' ','fontsize',18);
    yl = ylabel(' ','fontsize',18);
    zl = zlabel('pdf','fontsize',18);
    set(gca,'XTick',[],'YTick',[],'ZTick',[]);
    xlim([0 width]);
    ylim([0 height]);

    % plot data
    hold on

%     %     % objects
%     img=imread('pics/Panda.png','BackgroundColor',[1 1 1]); 
%     surf([0 0; width width],[0 height;0 height],[0 0; 1 1], 'facecolor','texturemap','cdata',img);


    
        % Plot 1 3D
        P1_3D = mvnpdf(xy, mu1, sigma1.^2);
        s1 = surfc(X1,X2,reshape(P1_3D,N,N));alpha(s1,'color');

        % Plot 2 3D
        P2_3D = mvnpdf(xy, mu2, sigma2.^2);
        s1 = surfc(X1,X2,reshape(P2_3D,N,N));alpha(s1,'color');
        shading interp


    hold off

    view(-18,30)

    % plot data
    hold on
    stem3(DAT(:,1),DAT(:,2),zeros(size(DAT,1),1),'b.');
    
    
    
    hold off

end