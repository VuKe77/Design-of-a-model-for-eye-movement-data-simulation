%Kod obradjuje signal pokreta ociju cija je putanja specifirana promenljivom 
%data_path, vrsi se statisticka obrada parametara signala od znacaja i modeluju se
%njihove distribucije, kao i glavne sekvence sakadnih pokreta ociju
close all
clc
clear all

%% Ucitavanje podataka
data_path = "S_1001_S1_VD1.csv"; 
T = csvread(data_path,1,0);
Fs = 1000;
valid = T(:,4);
raw_data = T(:,2:3);
raw_data = raw_data(valid==0,:);
t = 0:1/Fs:(length(raw_data)-1)/Fs;

%% uklanjanje impulsnog suma
raw_1 = raw_data(:,1);
raw_2 = raw_data(:,2);
sig1 = remove_impulse_noise(raw_1,1000);
sig2 = remove_impulse_noise(raw_2,1000);
raw_data = [sig1 sig2];

figure
    hold all
    stem(t,raw_1)
    stem(t,sig1)
    title('Filtriranje impulsnog šuma i interpolacija') %svu - stepen vizuelnog ugla
    ylabel("Amplituda[\circ]")
    xlabel('Vreme[s]')
    legend(["originalan siglan", "filtriran signal"])

figure
    subplot(2,1,1)
        plot(t,raw_1)
        title('Horizontalni stepen vizuelnog ugla') %svu - stepen vizuelnog ugla
        ylabel("Amplituda[\circ]")
        xlabel('Vreme[s]')
     subplot(2,1,2)
        hold on;
        plot(t,raw_2)
        xlabel('Vreme[s]')
        ylabel('Amplituda[\circ]')
        title("Vertikalni stepen vizuelnog ugla")
figure
    subplot(2,1,1)
        hold on;
        plot(t,raw_1)
        plot(t,sig1)
        title('Horizontalni stepen vizuelnog ugla[\circ]') %svu - stepen vizuelnog ugla
        ylabel("Amplituda[\circ]")
        xlabel('Vreme[s]')
        legend(["originalan siglan", "filtriran signal"])
     subplot(2,1,2)
        hold on;
        plot(t,raw_2)
        plot(t,sig2)
        xlabel('t[s]')
        ylabel('Amplituda[\circ]')
         title("Vertikalni stepen vizuelnog ugla")
        legend(["originalan siglan", "filtriran signal"])



%% izdvajanje statistickih obelezja i sekvenci

DATA = saccade_detection(raw_data,t);
%%
set(gca,'fontsize', 2)
figure
    scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    xlabel('Amplituda[\circ]')
    ylabel("Maksimum brzine sakade[\circ/s]")
    title("Glavna sekvenca")
figure
    scatter(DATA.SACC.amplitudes,DATA.SACC.durations)
    xlabel('Amplituda[\circ]')
    ylabel("Trajanje sakade[ms]")
    title("Glavna sekvenca")
   
%% prikazivanje jedne sakade
ri = round(rand*length(DATA.SACC.durations));
d = DATA.SACC.offsets(ri)-DATA.SACC.onsets(ri);
figure
    subplot(2,1,1)
        hold all;
        plot(DATA.GAZE.t,DATA.GAZE.amp)
        plot(DATA.GAZE.t(DATA.SACC.onsets(ri)),DATA.GAZE.amp(DATA.SACC.onsets(ri)),'g*')
        plot(DATA.GAZE.t(DATA.SACC.offsets(ri)), DATA.GAZE.amp(DATA.SACC.offsets(ri)),'r*')
        xlim([DATA.GAZE.t(DATA.SACC.onsets(ri)-10) DATA.GAZE.t(DATA.SACC.offsets(ri)+10)])
        title(['Trajanje sakade: '  num2str(DATA.SACC.durations(ri),3) 'ms' '/' num2str(d,3) 'odb'])
        xlabel("Vreme[s]")
        ylabel("Amplituda s.v.u[\circ]")
        hold off;

    subplot(2,1,2)
        hold all;
        plot(DATA.GAZE.t,DATA.GAZE.vel)
        plot(DATA.GAZE.t(DATA.SACC.onsets(ri)),DATA.GAZE.vel(DATA.SACC.onsets(ri)),'g*')
        plot(DATA.GAZE.t(DATA.SACC.offsets(ri)), DATA.GAZE.vel(DATA.SACC.offsets(ri)),'r*')
        xlim([DATA.GAZE.t(DATA.SACC.onsets(ri)-10) DATA.GAZE.t(DATA.SACC.offsets(ri)+10)])
        xlabel("Vreme[s]")
        ylabel("Brzina promene s.v.u[\circ/s]")
        hold off;
a1 = autocorr(DATA.SACC.durations);

%% Histogrami statistickih parametara
figure
    histogram(DATA.SACC.amplitudes,'FaceColor','b')
    xlabel('Amplituda sakada[\circ]');
    ylabel('Učestanost[n]');
    title('Histogram amplituda sakada');
figure
    histogram(DATA.SACC.peak_vals,'FaceColor','b')
    xlabel('Maksimum brzine sakada[\circ/s]');
    ylabel('Učestanost[n]');
    title('Histogram maksimuma brzine sakada');

figure
    histogram(DATA.SACC.durations,'FaceColor','b')
    xlabel('Trajanje sakada[ms]');
    ylabel('Učestanost[n]');
    title('Histogram trajanja sakada');
figure
    histogram(DATA.SACC.gaze_times,'FaceColor','b')
    xlabel('Trajanje fiksacija[ms]');
    ylabel('Učestanost[n]');
    title('Histogram trajanja fiksacija');


%% modelovanje glavne sekvence amplituda - pik brzine(main sequence modeling)
%FIXED SQRT
ft_fsqrt = fittype( 'FIXED_SQRT(x,V,VA,Ath)','independent', 'x','coefficients','V','problem',{'VA','Ath'});
%SQRT
ft_sqrt = fittype( 'SQRT(x,V)','independent', {'x'},'coefficients',{},'problem',{});
%EXPONENTIAL
ft_exp = fittype( 'EXPONENTIAL(x,V, A0, k)','independent', {'x'},'coefficients',{'V','A0','k'},'problem',{});

options_fsqrt = fitoptions('Method','NonlinearLeastSquares','Algorithm','Levenberg-Marquardt','StartPoint',[0]);
options_sqrt = options_fsqrt;
options_exp = fitoptions('Method','NonlinearLeastSquares','Algorithm','Levenberg-Marquardt','StartPoint',[300,0,6]);

%Pronalazenje srednje vrednosti pika za amplitude od 1deg
Ath=1;
mask = (DATA.SACC.amplitudes<=Ath);
mask_upper1 = find(mask==0);
VA = mean(DATA.SACC.peak_vals(mask));

[f_fsqrt, gof_fsqrt] = fit(DATA.SACC.amplitudes(mask_upper1)',  DATA.SACC.peak_vals(mask_upper1)',ft_fsqrt,options_fsqrt,'problem',{VA,Ath});
[f_sqrt, gof_sqrt] = fit(DATA.SACC.amplitudes', DATA.SACC.peak_vals',ft_sqrt,options_sqrt);
[f_exp, gof_exp] = fit(DATA.SACC.amplitudes', DATA.SACC.peak_vals',ft_exp,options_exp);

% kreiranje modela pomocu simbolickih funkcija
model_fsqrt = @(x) f_fsqrt.VA + f_fsqrt.V*sqrt(x-f_fsqrt.Ath);
model_sqrt = @(x) f_sqrt.V*sqrt(x);
model_exp = @(x) f_exp.V*(1-exp(-(x-f_exp.A0)/f_exp.k));

pred_fsqrt = model_fsqrt(DATA.SACC.amplitudes(mask_upper1));
pred_sqrt = model_sqrt(DATA.SACC.amplitudes);
pred_exp = model_exp(DATA.SACC.amplitudes);

%MAPE-srednja apsolutna procentualna greska
mape_fsqrt = mean(abs((pred_fsqrt-DATA.SACC.peak_vals(mask_upper1))./DATA.SACC.peak_vals(mask_upper1)));
mape_sqrt = mean(abs((pred_sqrt-DATA.SACC.peak_vals)./DATA.SACC.peak_vals));
mape_exp = mean(abs((pred_exp-DATA.SACC.peak_vals)./DATA.SACC.peak_vals));

%Statistika rezidualnih grafika
%fsqrt
resm_fsqrt=mean(DATA.SACC.peak_vals(mask_upper1)-pred_fsqrt);
resd_fsqrt=std(DATA.SACC.peak_vals(mask_upper1)-pred_fsqrt);
%sqrt
resm_sqrt=mean(DATA.SACC.peak_vals-pred_sqrt);
resd_sqrt=std(DATA.SACC.peak_vals-pred_sqrt);
%exp
resm_exp=mean(DATA.SACC.peak_vals-pred_exp);
resd_exp=std(DATA.SACC.peak_vals-pred_exp);

%Racunanje autokorelacione funkcije za razidualni grafik
acor_fsqrt = autocorr(DATA.SACC.peak_vals(mask_upper1)-pred_fsqrt);
acor_sqrt = autocorr(DATA.SACC.peak_vals-pred_sqrt);
acor_exp = autocorr(DATA.SACC.peak_vals-pred_exp);


figure()
    subplot(2,1,1)
        stem(DATA.SACC.peak_vals(mask_upper1)-pred_fsqrt)
        xlabel('odbirak[n]')
        ylabel('greska predikcije[\circ/s]')
        title('Rezidualni grafik:FIXED SQRT')
    subplot(2,1,2)
        stem(acor_fsqrt)
        xlabel('odbirak[k]')
        ylabel('Amplituda[a.u]')
        title("Autokorelaciona f-ja rezidualnog grafika")
        
figure()
    subplot(2,1,1)
        stem(DATA.SACC.peak_vals-pred_sqrt)
        xlabel('odbirak[n]')
        ylabel('greska predikcije[\circ/s]')
        title('Rezidualni grafik:SQRT')  
   subplot(2,1,2)
        stem(acor_sqrt)
        xlabel('odbirak[k]')
        ylabel('Amplituda[a.u]')
        title("Autokorelaciona f-ja rezidualnog grafika")
figure()
    subplot(2,1,1)
        stem(DATA.SACC.peak_vals-pred_exp)
        xlabel('odbirak[n]')
        ylabel('greska predikcije[\circ/s]')
        title('Rezidualni grafik:EXP')

     subplot(2,1,2)
        stem(acor_exp)
        xlabel('odbirak[k]')
        ylabel('Amplituda[a.u]')
        title("Autokorelaciona f-ja rezidualnog grafika")
    
    


% visualize
figure()
    title({'FIXED SQRT',['R^2:' num2str(gof_fsqrt.rsquare,3) ', RMSE:' num2str(gof_fsqrt.rmse,3) ', MAPE:' num2str(mape_fsqrt,3)] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_fsqrt,DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    xlabel('Amplituda[\circ]')
    ylabel("Maksimum brzine[\circ/s]")
    legend(["Uzorci","Model"])
    grid on;
figure()
    title({'SQRT',['R^2:' num2str(gof_sqrt.rsquare,3) ', RMSE:' num2str(gof_sqrt.rmse,3) ', MAPE:' num2str(mape_sqrt,3) ] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_sqrt,DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    xlabel('Amplituda[\circ]')
    ylabel("Maksimum brzine[\circ/s]")
    legend(["Uzorci","Model"])
    grid on;
figure()
    title({'EXP',['R^2:' num2str(gof_exp.rsquare,3) ', RMSE:' num2str(gof_exp.rmse,3) ', MAPE:' num2str(mape_exp,3)] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_exp,DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    xlabel('Amplituda[\circ]')
    ylabel("Maksimum brzine[\circ/s]")
    legend(["Uzorci","Model"])
    grid on;
    
% Cuvanj najboljeg rezultata u .mat fajl
best_model = model_exp;
save('modelPeak.mat', 'best_model');
   
%% modelovanje glavne sekvence amplituda - trajanje sakade(main sequence modeling)
%FIXED SQRT
ft_fsqrt = fittype( 'FIXED_SQRT(x,V,VA,Ath)','independent', 'x','coefficients','V','problem',{'VA','Ath'});
%SQRT
ft_sqrt = fittype( 'SQRT(x,V)','independent', {'x'},'coefficients',{},'problem',{});
%EXPONENTIAL
ft_exp = fittype( 'EXPONENTIAL(x,V, A0, k)','independent', {'x'},'coefficients',{'V','A0','k'},'problem',{});

options_fsqrt = fitoptions('Method','NonlinearLeastSquares','Algorithm','Levenberg-Marquardt','StartPoint',[0]);
options_sqrt = options_fsqrt;
options_exp = fitoptions('Method','NonlinearLeastSquares','Algorithm','Levenberg-Marquardt','StartPoint',[300,0,6]);

%Pronalazenje srednje vrednosti pika za amplitude od 1deg
Ath=1;
mask = (DATA.SACC.amplitudes<=Ath);
mask_upper1 = find(mask==0);
VA = mean(DATA.SACC.durations(mask));

[f_fsqrt, gof_fsqrt] = fit(DATA.SACC.amplitudes(mask_upper1)',  DATA.SACC.durations(mask_upper1)',ft_fsqrt,options_fsqrt,'problem',{VA,Ath});
[f_sqrt, gof_sqrt] = fit(DATA.SACC.amplitudes', DATA.SACC.durations',ft_sqrt,options_sqrt);
[f_exp, gof_exp] = fit(DATA.SACC.amplitudes', DATA.SACC.durations',ft_exp,options_exp);

% kreiranje modela pomocu simbolickih funkcija 
model_fsqrt1 = @(x) f_fsqrt.VA + f_fsqrt.V*sqrt(x-f_fsqrt.Ath);
model_sqrt1 = @(x) f_sqrt.V*sqrt(x);
model_exp1 = @(x) f_exp.V*(1-exp(-(x-f_exp.A0)/f_exp.k));

pred_fsqrt = model_fsqrt1(DATA.SACC.amplitudes(mask_upper1));
pred_sqrt = model_sqrt1(DATA.SACC.amplitudes);
pred_exp = model_exp1(DATA.SACC.amplitudes);

%MAPE-srednja apsolutna procentualna greska
mape_fsqrt = mean(abs((pred_fsqrt-DATA.SACC.durations(mask_upper1))./DATA.SACC.durations(mask_upper1)));
mape_sqrt = mean(abs((pred_sqrt-DATA.SACC.durations)./DATA.SACC.durations));
mape_exp = mean(abs((pred_exp-DATA.SACC.durations)./DATA.SACC.durations));

%Statistika rezidualnih grafika
%fsqrt
resm_fsqrt=mean(DATA.SACC.durations(mask_upper1)-pred_fsqrt);
resd_fsqrt=std(DATA.SACC.durations(mask_upper1)-pred_fsqrt);
%sqrt
resm_sqrt=mean(DATA.SACC.durations-pred_sqrt);
resd_sqrt=std(DATA.SACC.durations-pred_sqrt);
%exp
resm_exp=mean(DATA.SACC.durations-pred_exp);
resd_exp=std(DATA.SACC.durations-pred_exp);


%Racunanje autokorelacione funkcije za razidualni grafik
acor_fsqrt = autocorr(DATA.SACC.durations(mask_upper1)-pred_fsqrt);
acor_sqrt = autocorr(DATA.SACC.durations-pred_sqrt);
acor_exp = autocorr(DATA.SACC.durations-pred_exp);


figure()
    subplot(2,1,1)
        stem(DATA.SACC.durations(mask_upper1)-pred_fsqrt)
        xlabel('odbirak[n]')
        ylabel('greska predikcije[ms]')
        title('Rezidualni grafik:FIXED SQRT')
    subplot(2,1,2)
        stem(acor_fsqrt)
        xlabel('odbirak[k]')
        ylabel('Amplituda[a.u]')
        title("Autokorelaciona f-ja rezidualnog grafika")
 figure()
    subplot(2,1,1)
        stem(DATA.SACC.durations-pred_sqrt)
        xlabel('odbirak[n]')
        ylabel('greska predikcije[ms]')
        title('Rezidualni grafik:SQRT')  
   subplot(2,1,2)
        stem(acor_sqrt)
        xlabel('odbirak[k]')
        ylabel('Amplituda[a.u]')
        title("Autokorelaciona f-ja rezidualnog grafika")
figure()
    subplot(2,1,1)
        stem(DATA.SACC.durations-pred_exp)
        xlabel('odbirak[n]')
        ylabel('greska predikcije[ms]')
        title('Rezidualni grafik:EXP')

     subplot(2,1,2)
        stem(acor_exp)
        xlabel('odbirak[k]')
        ylabel('Amplituda[a.u]')
        title("Autokorelaciona f-ja rezidualnog grafika")
    
    
    


% visualize

figure()
    title({'FIXED SQRT',['R^2:' num2str(gof_fsqrt.rsquare,3) ', RMSE:' num2str(gof_fsqrt.rmse,3) ', MAPE:' num2str(mape_fsqrt,3)] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_fsqrt,DATA.SACC.amplitudes,DATA.SACC.durations)
    xlabel('Amplituda[\circ]')
    ylabel("Trajanje sakade[ms]")
    legend(["Uzorci","Model"])
    grid on;
figure()
    title({'SQRT',['R^2:' num2str(gof_sqrt.rsquare,3) ', RMSE:' num2str(gof_sqrt.rmse,3) ', MAPE:' num2str(mape_sqrt,3) ] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_sqrt,DATA.SACC.amplitudes,DATA.SACC.durations)
    xlabel('Amplituda[\circ]')
    ylabel("Trajanje sakade[ms]")
    legend(["Uzorci","Model"])
    grid on;
figure()
    title({'EXP',['R^2:' num2str(gof_exp.rsquare,3) ', RMSE:' num2str(gof_exp.rmse,3) ', MAPE:' num2str(mape_exp,3)] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_exp,DATA.SACC.amplitudes,DATA.SACC.durations)
    xlabel('Amplituda[\circ]')
    ylabel("Trajanje sakade[ms]")
    legend(["Uzorci","Model"])
    grid on;

% Cuvanj najboljeg rezultata u .mat fajl
best_model = model_exp1;
save('modelDuration.mat', 'best_model');

%% fitovanje amplituda sakada na gamma raspodelu
data= DATA.SACC.amplitudes';
amp_pdf = fitdist(data,'Weibull');

save('ampPDF.mat', 'amp_pdf');

x_values = linspace(min(data), max(data), 100);
y_values = pdf(amp_pdf, x_values);
% Plot the histogram of the data
figure
    histogram(data, 'Normalization', 'pdf', 'EdgeColor', 'none');
    hold on;
    plot(x_values, y_values, 'r-', 'LineWidth', 2);
    xlabel('Amplituda sakada[\circ]');
    ylabel('FGV');
    legend('Histogram podataka', 'Uklopjena  raspodela');
    title('Uklapanje Vajbulove raspodele nad odbircima amplitude sakada');
hold off;




%% provera distribucije trajanja fiksacije

figure
    plot(DATA.SACC.amplitudes(2:end), DATA.SACC.gaze_times, 'bo')
    xlabel('Amplituda[\circ]')
    ylabel('Vreme fiksacije[ms]')
    title('Odnos izmedju trajanja fiksacije i amplituda sakade')
    grid on;
% fitovanje vremena pauze na distribuciju
data= DATA.SACC.gaze_times';
not_valid = (data~=0);
data = data(not_valid);

gaze_pdf = fitdist(data,'Weibull');

save('gazePDF.mat', 'gaze_pdf');

x_values = linspace(min(data), max(data), 100);
y_values = pdf(gaze_pdf, x_values);
% Plot the histogram of the data
figure
    histogram(data, 'Normalization', 'pdf', 'EdgeColor', 'none');
    hold on;
    plot(x_values, y_values, 'r-', 'LineWidth', 2);
    xlabel('Vreme[ms]');
    ylabel('FGV');
    legend('Histogram podataka', 'Uklopljena raspodela');
    title('Uklapanje Vajbulove raspodele nad odbircima trajanja fiksacija oka');
hold off;