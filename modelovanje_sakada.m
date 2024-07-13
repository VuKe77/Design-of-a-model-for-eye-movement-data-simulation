close all
clear all
clc


%% ucitavanje
SBJ1 = load("D:\ETF nastava\VIII semsetar\Diplomski\EMA_Toolbox\DATA\EYELINK\SBJ1_PROC.mat");
raw_data = SBJ1.ET.LE.POS.PIX;
t = SBJ1.ET.TIME;
%% ucitavanje2
data1 = load("D:\ETF nastava\VIII semsetar\Diplomski\Data\DATA_SAVE\AGO1\100_O90.mat");
data = data1.D_orig;
t = data(:,1);
t = (t-t(1))/250;
x_data = data(:,2);
y_data = data(:,3);
valid_x = x_data<1920 & x_data>0;
valid_y = y_data<1080 & y_data>0;
valid = valid_x & valid_y;
valid_idxs = find(valid==1);
x_data = x_data(valid_idxs);
y_data = y_data(valid_idxs);
raw_data = [x_data  y_data];
t = (0:1:length(raw_data)-1)/250;
%% izdvajanje statistickih obelezja i sekvenci
DATA = detekcija_sakada(raw_data,t);
figure
    scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    xlabel('Amplituda[deg]')
    ylabel("Peak brzine[deg/s]")
    title("Glavna sekvenca")
figure
    scatter(DATA.SACC.amplitudes,DATA.SACC.durations)
    xlabel('Amplituda[deg]')
    ylabel("Trajanje sakade[s]")
    title("Glavna sekvenca")
   

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
mask_under1 = find(mask==1);
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

figure()
    stem(DATA.SACC.peak_vals-pred_sqrt)
    xlabel('odbirak[n]')
    ylabel('greska predikcije[deg/s]')
     title('Rezidualni grafik:SQRT')
figure()
    stem(DATA.SACC.peak_vals(mask_upper1)-pred_fsqrt)
    xlabel('odbirak[n]')
    ylabel('greska predikcije[deg/s]')
    title('Rezidualni grafik:FIXED SQRT')
    
figure()
    stem(DATA.SACC.peak_vals-pred_exp)
    xlabel('odbirak[n]')
    ylabel('greska predikcije[deg/s]')
    title('Rezidualni grafik:EXP')
    
    


% visualize
figure()
    title({'FIXED SQRT',['R^2:' num2str(gof_fsqrt.rsquare,3) ', RMSE:' num2str(gof_fsqrt.rmse,3) ', MAPE:' num2str(mape_fsqrt,3)] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_fsqrt,DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    xlabel('Amplituda[deg]')
    ylabel("Peak brzine[deg/s]")
    legend(["Uzorci","Model"])
    grid on;
figure()
    title({'SQRT',['R^2:' num2str(gof_sqrt.rsquare,3) ', RMSE:' num2str(gof_sqrt.rmse,3) ', MAPE:' num2str(mape_sqrt,3) ] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_sqrt,DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    xlabel('Amplituda[deg]')
    ylabel("Peak brzine[deg/s]")
    legend(["Uzorci","Model"])
    grid on;
figure()
    title({'EXP',['R^2:' num2str(gof_exp.rsquare,3) ', RMSE:' num2str(gof_exp.rmse,3) ', MAPE:' num2str(mape_exp,3)] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_exp,DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    xlabel('Amplituda[deg]')
    ylabel("Peak brzine[deg/s]")
    legend(["Uzorci","Model"])
    grid on;
    
    
    
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
mask_under1 = find(mask==1);
mask_upper1 = find(mask==0);
VA = mean(DATA.SACC.peak_vals(mask));

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

figure()
    stem(DATA.SACC.durations-pred_sqrt)
    xlabel('odbirak[n]')
    ylabel('greska predikcije[deg/s]')
     title('Rezidualni grafik:SQRT')
figure()
    stem(DATA.SACC.durations(mask_upper1)-pred_fsqrt)
    xlabel('odbirak[n]')
    ylabel('greska predikcije[deg/s]')
    title('Rezidualni grafik:FIXED SQRT')
    
figure()
    stem(DATA.SACC.durations-pred_exp)
    xlabel('odbirak[n]')
    ylabel('greska predikcije[deg/s]')
    title('Rezidualni grafik:EXP')
    
    


% visualize

figure()
    title({'FIXED SQRT',['R^2:' num2str(gof_fsqrt.rsquare,3) ', RMSE:' num2str(gof_fsqrt.rmse,3) ', MAPE:' num2str(mape_fsqrt,3)] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_fsqrt,DATA.SACC.amplitudes,DATA.SACC.durations)
    xlabel('Amplituda[deg]')
    ylabel("Trajanje sakade[s]")
    legend(["Uzorci","Model"])
    grid on;
figure()
    title({'SQRT',['R^2:' num2str(gof_sqrt.rsquare,3) ', RMSE:' num2str(gof_sqrt.rmse,3) ', MAPE:' num2str(mape_sqrt,3) ] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_sqrt,DATA.SACC.amplitudes,DATA.SACC.durations)
    xlabel('Amplituda[deg]')
    ylabel("Trajanje sakade[s]")
    legend(["Uzorci","Model"])
    grid on;
figure()
    title({'EXP',['R^2:' num2str(gof_exp.rsquare,3) ', RMSE:' num2str(gof_exp.rmse,3) ', MAPE:' num2str(mape_exp,3)] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_exp,DATA.SACC.amplitudes,DATA.SACC.durations)
    xlabel('Amplituda[deg]')
    ylabel("Trajanje sakade[s]")
    legend(["Uzorci","Model"])
    grid on;




    
















