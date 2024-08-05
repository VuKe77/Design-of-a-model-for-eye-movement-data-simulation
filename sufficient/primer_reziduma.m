x = 0:0.1:10;
y1 = sin(x);
y2 = -1+2*rand(size(x));
figure()
    subplot(2,1,1)
        stem(x,y1)
        xlabel('odbirak[n]')
        ylabel('greska predikcije[a.u]')
        title('Primer lošeg rezidualnog grafika')
      subplot(2,1,2)
        stem(x,y2)
        xlabel('odbirak[n]')
        ylabel('greska predikcije[a.u]')
        title('Primer dobrog rezidualnog grafika')
     