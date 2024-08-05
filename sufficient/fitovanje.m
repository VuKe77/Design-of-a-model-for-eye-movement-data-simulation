clc
close all
clear all

%% Hill's equation

E0 = 10;
Emax = 50;
Ts= 0.01;
t = 0:Ts:50;
E50 = 15;
a=0:1:10;

%y = E0 + (Emax - E0).* t.^a./(E50.^a+t.^a);
legend_str=[];
figure
a=10
for i=1:length(a)
    y = E0 + (Emax - E0).* t.^a(i)./(E50.^a(i)+t.^a(i));
    y1 = central_diff(y,Ts);
    subplot(2,1,1)
        hold on;
        plot(t,y)
        %xlabel('Vreme[s]')
        ylabel('Amplituda[a.u]')
        legend_info{i} = ['a=' num2str(a(i))];
        title('Hilova jednacina')
        xlim([0,30])
        hold off;
    subplot(2,1,2)
        hold on;
        plot(t,y1)
        xlabel('Vreme[s]')
        ylabel('Amplituda[a.u]')
        %legend_info{i} = ['a=' num2str(a(i))];
        title('Prvi izvod')
        %legend(legend_info)
        hold off;
        xlim([0,30])

end
hold off

%% Fitovanje sqrt
V = [138.7 140.4 93.2 100];
deg = 0:1:25;
figure
hold all
for i = 1:length(V)
    y = V(i)*sqrt(deg);
    plot(deg,y)
    xlabel('Amplituda[deg]')
    ylabel('Brzina pika[deg/s]')
    legend_info{i} = ['V=' num2str(V(i))];
end
hold off
legend(legend_info)



%% numericki algoritam sa Emax i E0
Ts = 0.001;
Emax =20;
td = model_duration(Emax)/1000; %We need td in seconds
Vmax = model_peak(Emax);
E0=0;
[y,t] = fitovanje_trajektorije(Vmax, td, E0, Emax,Ts);
y_1 = central_diff(y,0.001);
figure
    
    subplot(2,1,1)
        stem(t,y)
        ylabel('Amplituda[deg]')
        title("Amplituda sakade")
    subplot(2,1,2)
        stem(t,y_1)
        xlabel('Vreme[s]')
        ylabel('Brzina[deg/s]')
        title("Brzina sakade")
        
%% Algoritam sa semplovanjem duzine i max_amplitude
amplitudes = 0:0.1:25;
amps = randomsample(amplitudes,5);
peak_vels = 180 + sqrt(138.7*peak_vels - 1);




%%
SBJ1 = load("D:\ETF nastava\VIII semsetar\Diplomski\EMA_Toolbox\DATA\EYELINK\SBJ1\SBJ1_PROC.mat");
t = SBJ1.ET.TIME; %vremenska osa
sbj1_pos_deg = SBJ1.ET.LE.POS.DEG;
sbj1_vel_deg = SBJ1.ET.LE.VEL.DEG;

a = central_diff(sbj1_pos_deg(:,2)',1/250);
figure
    subplot(2,1,1)
        plot(t, sbj1_pos_deg(:,2))
        xlim([54.25 54.35])
    subplot(2,1,2)
        hold all
        plot(t, sbj1_vel_deg)
        plot(t,abs(a))
        hold off;
        xlim([54.25 54.35])
        


