close all
clc 
clear all

%%
data1 = load("D:\ETF nastava\VIII semsetar\Diplomski\Data\DATA_SAVE\AGO1\100_O90.mat");
data = data1.D_orig;
t = data(:,1);
t = (t-t(1))/250;
x_data = data(:,2);
y_data = data(:,3);
valid_x = x_data<1920 & x_data>0;
valid_y = y_data<1080 & y_data>0;
valid = valid_x | valid_y;
valid_idxs = find(valid==1);
x_data = x_data(valid_idxs);
y_data = y_data(valid_idxs);
raw_data = [x_data  y_data];
t = (0:1:length(raw_data)-1)/250;




%% izdvajanje statistickih obelezja i sekvenci
DATA = detekcija_sakada(raw_data,t);
%%
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
%% dodavanje suma razlicitih vrednosti 
sacc1 = SIM2.SIGNALS.AMP + randn(1,length(SIM2.SIGNALS.AMP))*0.1;
sacc2 = SIM2.SIGNALS.AMP + randn(1,length(SIM2.SIGNALS.AMP))*0.5;
sacc3 = SIM2.SIGNALS.AMP + randn(1,length(SIM2.SIGNALS.AMP))*1;
figure
    subplot(3,1,1)
        plot(t,sacc1)
        xlabel("Vreme[s]")
        ylabel("Amplituda s.v.u")
        title("\sigma=0.1[deg]")
    subplot(3,1,2)
        plot(t,sacc2)
        title("\sigma=0.5[deg]")
        xlabel("Vreme[s]")
        ylabel("Amplituda s.v.u")
     subplot(3,1,3)
        plot(t,sacc3)
        title("\sigma=1[deg]")
        xlabel("Vreme[s]")
        ylabel("Amplituda s.v.u")
    