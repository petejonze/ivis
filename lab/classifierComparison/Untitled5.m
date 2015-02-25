       screenwidth = 1024;
        screenheight = 768;
        startscreenmargin = .15;
        graphicwidth = 200;
        graphicheight = 200;
        maxscreenmargin = 1 - max(graphicwidth/screenwidth, graphicheight/screenheight);
        
nTrialsPerMargin = 100;
nMargin = 4;
        nTrialsTotal = nTrialsPerMargin*nMargin;
        screenmargin = linspace(startscreenmargin, maxscreenmargin, nMargin+1);
        screenmargin(end) = [];
        screenmargin = repmat(screenmargin, nTrialsPerMargin, 1);
        screenmargin = Shuffle(screenmargin(:))

        
        x = round(rand(nTrialsTotal,1).*(screenwidth*(1-screenmargin)-graphicwidth)) + graphicwidth/2 + screenwidth*screenmargin/2
        y = round(rand(nTrialsTotal,1).*(screenheight*(1-screenmargin)-graphicheight)) + graphicheight/2 + screenheight*screenmargin/2
        
        
        
       close all
 figure();
  
plot(x,y,'o');       
xlim([0 screenwidth]);
ylim([0 screenheight]);