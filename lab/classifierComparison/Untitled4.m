 close all
 figure();

        screenwidth = 1000;
        screenheight = 1000;
        screenmargin = .79;
        graphicwidth = 200;
        graphicheight = 200;
        maxscreenmargin = 1 - max(graphicwidth/screenwidth, graphicheight/screenheight)
        x = randi(round(screenwidth*(1-screenmargin))-graphicwidth, [100 1]) + graphicwidth/2 + screenwidth*screenmargin/2;
        y = randi(round(screenheight*(1-screenmargin))-graphicheight, [100 1]) + graphicheight/2 + screenheight*screenmargin/2;
  

plot(x,y,'o');       
xlim([0 screenwidth]);
ylim([0 screenheight]);