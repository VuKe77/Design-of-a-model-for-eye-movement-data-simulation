% This code processes an eye movement signal, with the trajectory specified by 
% the variable data_path. It performs statistical analysis of the relevant signal 
% parameters and models their distributions, as well as the main sequences of 
% saccadic eye movements.
close all
clc
clear all

%% Data loading
data_path = "S_1001_S1_VD1.csv"; 
T = csvread(data_path,1,0);
Fs = 1000;
valid = T(:,4);
raw_data = T(:,2:3);
raw_data = raw_data(valid==0,:);
t = 0:1/Fs:(length(raw_data)-1)/Fs;

%% Remove impulse noise
raw_1 = raw_data(:,1);
raw_2 = raw_data(:,2);
sig1 = remove_impulse_noise(raw_1,1000);
sig2 = remove_impulse_noise(raw_2,1000);
raw_data = [sig1 sig2];

figure
    hold all
    stem(t,raw_1)
    stem(t,sig1)
    title('Impulse noise filtration and interpolation') 
    ylabel("Amplitude[\circ]")
    xlabel('Time[s]')
    legend(["original signal", "filtrated signal"])

figure
    subplot(2,1,1)
        plot(t,raw_1)
        title('Horizontal degree of visal angle') 
        ylabel("Amplitude[\circ]")
        xlabel('Time[s]')
     subplot(2,1,2)
        hold on;
        plot(t,raw_2)
        xlabel('Time[s]')
        ylabel('Amplitude[\circ]')
        title("Vertical degree of visal angle")
figure
    subplot(2,1,1)
        hold on;
        plot(t,raw_1)
        plot(t,sig1)
        title('Horizontal degree of visal angle[\circ]') %svu - stepen vizuelnog ugla
        ylabel("Amplitude[\circ]")
        xlabel('Time[s]')
        legend(["original signal", "filtrated signal"])
     subplot(2,1,2)
        hold on;
        plot(t,raw_2)
        plot(t,sig2)
        xlabel('t[s]')
        ylabel('Amplituda[\circ]')
         title("Vertikalni stepen vizuelnog ugla")
        legend(["originalan signal", "filtriran signal"])



%% Extraction of features and sequences
DATA = saccade_detection(raw_data,t);
%%

figure
    scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    xlabel('Amplitude[\circ]')
    ylabel("Saccade peak[\circ/s]")
    title("Main sequence")
figure
    scatter(DATA.SACC.amplitudes,DATA.SACC.durations)
    xlabel('Amplitude[\circ]')
    ylabel("Saccade duration[ms]")
    title("Main sequence")
   
%% Showing one saccade
ri = round(rand*length(DATA.SACC.durations));
d = DATA.SACC.offsets(ri)-DATA.SACC.onsets(ri);
figure
    subplot(2,1,1)
        hold all;
        plot(DATA.GAZE.t,DATA.GAZE.amp)
        plot(DATA.GAZE.t(DATA.SACC.onsets(ri)),DATA.GAZE.amp(DATA.SACC.onsets(ri)),'g*')
        plot(DATA.GAZE.t(DATA.SACC.offsets(ri)), DATA.GAZE.amp(DATA.SACC.offsets(ri)),'r*')
        xlim([DATA.GAZE.t(DATA.SACC.onsets(ri)-10) DATA.GAZE.t(DATA.SACC.offsets(ri)+10)])
        title(['Saccade duration: '  num2str(DATA.SACC.durations(ri),3) 'ms' '/' num2str(d,3) 'sample'])
        xlabel("Time[s]")
        ylabel("Amplitude d.v.a[\circ]") 
        hold off;

    subplot(2,1,2)
        hold all;
        plot(DATA.GAZE.t,DATA.GAZE.vel)
        plot(DATA.GAZE.t(DATA.SACC.onsets(ri)),DATA.GAZE.vel(DATA.SACC.onsets(ri)),'g*')
        plot(DATA.GAZE.t(DATA.SACC.offsets(ri)), DATA.GAZE.vel(DATA.SACC.offsets(ri)),'r*')
        xlim([DATA.GAZE.t(DATA.SACC.onsets(ri)-10) DATA.GAZE.t(DATA.SACC.offsets(ri)+10)])
        xlabel("Time[s]")
        ylabel("Absolute angular velocity [\circ/s]")
        hold off;
a1 = autocorr(DATA.SACC.durations);

%% Histograms of statistical parameters
figure
    histogram(DATA.SACC.amplitudes,'FaceColor','b')
    xlabel('Saccades amplitude[\circ]');
    ylabel('Frequency[n]');
    title('Saccade amplitude histogram');
figure
    histogram(DATA.SACC.peak_vals,'FaceColor','b')
    xlabel('Saccade peaks\circ/s]');
    ylabel('Frequency[n]');
    title('Saccade peaks histogram');

figure
    histogram(DATA.SACC.durations,'FaceColor','b')
    xlabel('Trajanje sakada[ms]');
    ylabel('Učestanost[n]');
    title('Histogram trajanja sakada');
figure
    histogram(DATA.SACC.gaze_times,'FaceColor','b')
    xlabel('Fixation duration[ms]');
    ylabel('Frequency[n]');
    title('Fixation duration histogram');


%% Main sequence modeling - velocity peak
%FIXED SQRT
ft_fsqrt = fittype( 'FIXED_SQRT(x,V,VA,Ath)','independent', 'x','coefficients','V','problem',{'VA','Ath'});
%SQRT
ft_sqrt = fittype( 'SQRT(x,V)','independent', {'x'},'coefficients',{},'problem',{});
%EXPONENTIAL
ft_exp = fittype( 'EXPONENTIAL(x,V, A0, k)','independent', {'x'},'coefficients',{'V','A0','k'},'problem',{});

options_fsqrt = fitoptions('Method','NonlinearLeastSquares','Algorithm','Levenberg-Marquardt','StartPoint',[0]);
options_sqrt = options_fsqrt;
options_exp = fitoptions('Method','NonlinearLeastSquares','Algorithm','Levenberg-Marquardt','StartPoint',[300,0,6]);

%Finding the mean value of the peak for an amplitude of 1 degree
Ath=1;
mask = (DATA.SACC.amplitudes<=Ath);
mask_upper1 = find(mask==0);
VA = mean(DATA.SACC.peak_vals(mask));

[f_fsqrt, gof_fsqrt] = fit(DATA.SACC.amplitudes(mask_upper1)',  DATA.SACC.peak_vals(mask_upper1)',ft_fsqrt,options_fsqrt,'problem',{VA,Ath});
[f_sqrt, gof_sqrt] = fit(DATA.SACC.amplitudes', DATA.SACC.peak_vals',ft_sqrt,options_sqrt);
[f_exp, gof_exp] = fit(DATA.SACC.amplitudes', DATA.SACC.peak_vals',ft_exp,options_exp);

%Creating models using symbolic functions
model_fsqrt = @(x) f_fsqrt.VA + f_fsqrt.V*sqrt(x-f_fsqrt.Ath);
model_sqrt = @(x) f_sqrt.V*sqrt(x);
model_exp = @(x) f_exp.V*(1-exp(-(x-f_exp.A0)/f_exp.k));

pred_fsqrt = model_fsqrt(DATA.SACC.amplitudes(mask_upper1));
pred_sqrt = model_sqrt(DATA.SACC.amplitudes);
pred_exp = model_exp(DATA.SACC.amplitudes);

%MAPE
mape_fsqrt = mean(abs((pred_fsqrt-DATA.SACC.peak_vals(mask_upper1))./DATA.SACC.peak_vals(mask_upper1)));
mape_sqrt = mean(abs((pred_sqrt-DATA.SACC.peak_vals)./DATA.SACC.peak_vals));
mape_exp = mean(abs((pred_exp-DATA.SACC.peak_vals)./DATA.SACC.peak_vals));

%Statistics of residual graphs
%fsqrt
resm_fsqrt=mean(DATA.SACC.peak_vals(mask_upper1)-pred_fsqrt);
resd_fsqrt=std(DATA.SACC.peak_vals(mask_upper1)-pred_fsqrt);
%sqrt
resm_sqrt=mean(DATA.SACC.peak_vals-pred_sqrt);
resd_sqrt=std(DATA.SACC.peak_vals-pred_sqrt);
%exp
resm_exp=mean(DATA.SACC.peak_vals-pred_exp);
resd_exp=std(DATA.SACC.peak_vals-pred_exp);

%Calculation of the autocorrelation function for the residual graph
acor_fsqrt = autocorr(DATA.SACC.peak_vals(mask_upper1)-pred_fsqrt);
acor_sqrt = autocorr(DATA.SACC.peak_vals-pred_sqrt);
acor_exp = autocorr(DATA.SACC.peak_vals-pred_exp);


figure()
    subplot(2,1,1)
        stem(DATA.SACC.peak_vals(mask_upper1)-pred_fsqrt)
        xlabel('sample[n]')
        ylabel('prediction error[\circ/s]')
        title('Residual graph:FIXED SQRT')
    subplot(2,1,2)
        stem(acor_fsqrt)
        xlabel('sample[k]')
        ylabel('Amplitude[a.u]')
        title("Autocorrelation function of residual graph")
        
figure()
    subplot(2,1,1)
        stem(DATA.SACC.peak_vals-pred_sqrt)
        xlabel('sample[n]')
        ylabel('prediction error[\circ/s]')
        title('Residual graph:SQRT')  
   subplot(2,1,2)
        stem(acor_sqrt)
        xlabel('sample[k]')
        ylabel('Amplitude[a.u]')
        title("Autocorrelation function of residual graph")
figure()
    subplot(2,1,1)
        stem(DATA.SACC.peak_vals-pred_exp)
        xlabel('sample[n]')
        ylabel('prediction error[\circ/s]')
        title('Residual graph: EXP')

     subplot(2,1,2)
        stem(acor_exp)
        xlabel('sample[k]')
        ylabel('Amplitude[a.u]')
        title("Autocorrelation function of residual graph")
    
% Visualization
figure()
    title({'FIXED SQRT',['R^2:' num2str(gof_fsqrt.rsquare,3) ', RMSE:' num2str(gof_fsqrt.rmse,3) ', MAPE:' num2str(mape_fsqrt,3)] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_fsqrt,DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    xlabel('Amplitude[\circ]')
    ylabel("Velocity peak[\circ/s]")
    legend(["Samples","Model"])
    grid on;
figure()
    title({'SQRT',['R^2:' num2str(gof_sqrt.rsquare,3) ', RMSE:' num2str(gof_sqrt.rmse,3) ', MAPE:' num2str(mape_sqrt,3) ] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_sqrt,DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    xlabel('Amplitude[\circ]')
    ylabel("Velocity peak[\circ/s]")
    legend(["Samples","Model"])
    grid on;
figure()
    title({'EXP',['R^2:' num2str(gof_exp.rsquare,3) ', RMSE:' num2str(gof_exp.rmse,3) ', MAPE:' num2str(mape_exp,3)] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_exp,DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    xlabel('Amplitude[\circ]')
    ylabel("Velocity peak[\circ/s]")
    legend(["Uzorci","Model"])
    grid on;
    
% Saving the best result - EXPONENTIAL FUNCTION
best_model = model_exp;
save('modelPeak.mat', 'best_model');
   
%% Main sequence modeling - saccade duration
%FIXED SQRT
ft_fsqrt = fittype( 'FIXED_SQRT(x,V,VA,Ath)','independent', 'x','coefficients','V','problem',{'VA','Ath'});
%SQRT
ft_sqrt = fittype( 'SQRT(x,V)','independent', {'x'},'coefficients',{},'problem',{});
%EXPONENTIAL
ft_exp = fittype( 'EXPONENTIAL(x,V, A0, k)','independent', {'x'},'coefficients',{'V','A0','k'},'problem',{});

options_fsqrt = fitoptions('Method','NonlinearLeastSquares','Algorithm','Levenberg-Marquardt','StartPoint',[0]);
options_sqrt = options_fsqrt;
options_exp = fitoptions('Method','NonlinearLeastSquares','Algorithm','Levenberg-Marquardt','StartPoint',[300,0,6]);

%Finding the mean value of the peak for an amplitude of 1 degree
Ath=1;
mask = (DATA.SACC.amplitudes<=Ath);
mask_upper1 = find(mask==0);
VA = mean(DATA.SACC.durations(mask));

[f_fsqrt, gof_fsqrt] = fit(DATA.SACC.amplitudes(mask_upper1)',  DATA.SACC.durations(mask_upper1)',ft_fsqrt,options_fsqrt,'problem',{VA,Ath});
[f_sqrt, gof_sqrt] = fit(DATA.SACC.amplitudes', DATA.SACC.durations',ft_sqrt,options_sqrt);
[f_exp, gof_exp] = fit(DATA.SACC.amplitudes', DATA.SACC.durations',ft_exp,options_exp);

%Creating models using symbolic functions
model_fsqrt1 = @(x) f_fsqrt.VA + f_fsqrt.V*sqrt(x-f_fsqrt.Ath);
model_sqrt1 = @(x) f_sqrt.V*sqrt(x);
model_exp1 = @(x) f_exp.V*(1-exp(-(x-f_exp.A0)/f_exp.k));

pred_fsqrt = model_fsqrt1(DATA.SACC.amplitudes(mask_upper1));
pred_sqrt = model_sqrt1(DATA.SACC.amplitudes);
pred_exp = model_exp1(DATA.SACC.amplitudes);

%MAPE
mape_fsqrt = mean(abs((pred_fsqrt-DATA.SACC.durations(mask_upper1))./DATA.SACC.durations(mask_upper1)));
mape_sqrt = mean(abs((pred_sqrt-DATA.SACC.durations)./DATA.SACC.durations));
mape_exp = mean(abs((pred_exp-DATA.SACC.durations)./DATA.SACC.durations));

%Statistics of residual graphs
%fsqrt
resm_fsqrt=mean(DATA.SACC.durations(mask_upper1)-pred_fsqrt);
resd_fsqrt=std(DATA.SACC.durations(mask_upper1)-pred_fsqrt);
%sqrt
resm_sqrt=mean(DATA.SACC.durations-pred_sqrt);
resd_sqrt=std(DATA.SACC.durations-pred_sqrt);
%exp
resm_exp=mean(DATA.SACC.durations-pred_exp);
resd_exp=std(DATA.SACC.durations-pred_exp);


%Calculation of the autocorrelation function for the residual graph
acor_fsqrt = autocorr(DATA.SACC.durations(mask_upper1)-pred_fsqrt);
acor_sqrt = autocorr(DATA.SACC.durations-pred_sqrt);
acor_exp = autocorr(DATA.SACC.durations-pred_exp);


figure()
    subplot(2,1,1)
        stem(DATA.SACC.durations(mask_upper1)-pred_fsqrt)
        xlabel('sample[n]')
        ylabel('prediction error[ms]')
        title('Residual graph:FIXED SQRT')
    subplot(2,1,2)
        stem(acor_fsqrt)
        xlabel('sample[k]')
        ylabel('Amplitude[a.u]')
        title("Autocorrelation function of residual graph")
 figure()
    subplot(2,1,1)
        stem(DATA.SACC.durations-pred_sqrt)
        xlabel('sample[n]')
        ylabel('prediction error[ms]')
        title('Residual graph:SQRT') 
   subplot(2,1,2)
        stem(acor_sqrt)
        xlabel('sample[k]')
        ylabel('Amplitude[a.u]')
        title("Autocorrelation function of residual graph")
figure()
    subplot(2,1,1)
        stem(DATA.SACC.durations-pred_exp)
        xlabel('sample[n]')
        ylabel('prediction error[ms]')
        title('Residual graph:EXP')

     subplot(2,1,2)
        stem(acor_exp)
        xlabel('sample[k]')
        ylabel('Amplitude[a.u]')
        title("Autocorrelation function of residual graph")


% Visualization

figure()
    title({'FIXED SQRT',['R^2:' num2str(gof_fsqrt.rsquare,3) ', RMSE:' num2str(gof_fsqrt.rmse,3) ', MAPE:' num2str(mape_fsqrt,3)] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_fsqrt,DATA.SACC.amplitudes,DATA.SACC.durations)
    xlabel('Amplitude[\circ]')
    ylabel("Saccade duration[ms]")
    legend(["Samples","Model"])
    grid on;
figure()
    title({'SQRT',['R^2:' num2str(gof_sqrt.rsquare,3) ', RMSE:' num2str(gof_sqrt.rmse,3) ', MAPE:' num2str(mape_sqrt,3) ] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_sqrt,DATA.SACC.amplitudes,DATA.SACC.durations)
    xlabel('Amplitude[\circ]')
    ylabel("Saccade duration[ms]")
    legend(["Samples","Model"])
    grid on;
figure()
    title({'EXP',['R^2:' num2str(gof_exp.rsquare,3) ', RMSE:' num2str(gof_exp.rmse,3) ', MAPE:' num2str(mape_exp,3)] })
    hold all;
    %scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    plot(f_exp,DATA.SACC.amplitudes,DATA.SACC.durations)
    xlabel('Amplitude[\circ]')
    ylabel("Saccade duration[ms]")
    legend(["Samples","Model"])
    grid on;

% Saving the best results in .mat fajl
best_model = model_exp1;
save('modelDuration.mat', 'best_model');

%% Saccade amplitude histograms fitting on Weibulls distribution
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
    xlabel('Saccade amplitude[\circ]');
    ylabel('PDF');
    legend('Data histogram', 'Fitted distribution');
    title('Fitting a Weibull distribution over saccade amplitude samples');
hold off;


%% Checking fixation duration and saccade amplitude relationship

figure
    plot(DATA.SACC.amplitudes(2:end), DATA.SACC.gaze_times, 'bo')
    xlabel('Amplitude[\circ]')
    ylabel('Fixation time[ms]')
    title('Relationship between fixation duration and saccade amplitude')
    grid on;
%%  Fixation duration histograms fitting on Weibulls distribution
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
    xlabel('Time[ms]');
    ylabel('PDF');
    legend('Data histogram', 'Fitted distribution');
    title('Fitting a Weibull distribution over fixation duration samples');
hold off;
