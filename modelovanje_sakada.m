%Ovaj kod vrsi simulaciju signala pokreta oka, poziva se funkcija 
% sim_pokreti_oka kako bi se signali simulirali, a zatim se vrsi obrada 
% simuliranih signala pomocu funkcije detekcija_sakada
close all
clc
clear all


%% simulacija signala pokreta ociju
Tmax = 60; %duzina simuliranog signala
Fs = 1000; %frekvencija odabiranja 
noise = 0;
SIM1 = sim_pokreti_oka(Tmax,Fs,noise);
SIM2 = sim_pokreti_oka(Tmax,Fs,noise);
%% iscrtavanje pocetaka i krajeva sakada signala SIM1
t = SIM1.SIGNALS.t;
onset_idx = find_indices(SIM1.PARAMS.onsets,t);
offset_idx = find_indices(SIM1.PARAMS.offsets,t);

figure
    subplot(2,1,1)
        hold all;
        plot(t, SIM1.SIGNALS.AMP)
        plot(SIM1.PARAMS.onsets,SIM1.SIGNALS.AMP(onset_idx),'x')
        plot(SIM1.PARAMS.offsets,SIM1.SIGNALS.AMP(offset_idx),'o')
        ylabel("Amplituda s.v.u[deg]")
        legend(["signal","pocetak", "kraj"])
        title("Prikaz obelezenih sakada")
     subplot(2,1,2)
        hold all;
        plot(t, SIM1.SIGNALS.VEL)
        plot(SIM1.PARAMS.onsets,SIM1.SIGNALS.VEL(onset_idx),'x')
        plot(SIM1.PARAMS.offsets,SIM1.SIGNALS.VEL(offset_idx),'o')
        ylabel("Apsolutna brzina promene s.v.u[deg/s]")
        xlabel("Vreme[s]")
     

    
    


    
%% provera koriscenjem algoritma detekcije

simulated = [SIM2.SIGNALS.AMP' SIM1.SIGNALS.AMP'];

DATA = detekcija_sakada(simulated,t);
figure
    scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    xlabel('Amplituda[deg]')
    ylabel("Maksimum brzine[deg/s]")
    title("Glavna sekvenca")
    grid on;
figure
    scatter(DATA.SACC.amplitudes,DATA.SACC.durations)
    xlabel('Amplituda[deg]')
    ylabel("Trajanje sakade[s]")
    title("Glavna sekvenca")
    grid on;


   


        



