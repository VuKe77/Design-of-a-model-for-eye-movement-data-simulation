%Ovaj kod vrsi simulaciju signala pokreta oka, poziva se funkcija 
% sim_pokreti_oka kako bi se signali simulirali, a zatim se vrsi obrada 
% simuliranih signala pomocu funkcije detekcija_sakada
close all
clc
clear all


%% simulacija signala pokreta ociju
%rng(42) for debugging
Tmax = 10; %duzina simuliranog signala
Fs = 1000; %frekvencija odabiranja 
noise = 0;
SIM1 = simulate_signal(Tmax,Fs,noise);
SIM2 = simulate_signal(Tmax,Fs,noise);
%% iscrtavanje pocetaka i krajeva sakada signala SIM1
t = SIM1.SIGNALS.t;
onset_idx = find_indices(SIM1.PARAMS.onsets,t);
offset_idx = find_indices(SIM1.PARAMS.offsets,t);
peakpos_idx = find_indices(SIM1.PARAMS.peak_pos,t);

figure
    subplot(2,1,1)
        hold all;
        plot(t, SIM1.SIGNALS.AMP)
        plot(SIM1.PARAMS.onsets,SIM1.SIGNALS.AMP(onset_idx),'x')
        plot(SIM1.PARAMS.offsets,SIM1.SIGNALS.AMP(offset_idx),'o')
        ylabel("Amplituda s.v.u[\circ]")
        legend(["signal","pocetak", "kraj"])
        title("Prikaz obelezenih sakada")
     subplot(2,1,2)
        hold all;
        plot(t, SIM1.SIGNALS.VEL)
        plot(SIM1.PARAMS.onsets,SIM1.SIGNALS.VEL(onset_idx),'x')
        plot(SIM1.PARAMS.offsets,SIM1.SIGNALS.VEL(offset_idx),'o')
        plot(SIM1.PARAMS.peak_pos, SIM1.PARAMS.peak_vals,'*')
        ylabel("Apsolutna brzina promene s.v.u[\circ/s]")
        xlabel("Vreme[s]")
        legend(["signal", "maksimum","pocetak","kraj"])
     

    
    


    
%% provera koriscenjem algoritma detekcije

simulated = [SIM2.SIGNALS.AMP' SIM1.SIGNALS.AMP'];

DATA = saccade_detection(simulated,t);
%%
figure
    scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    xlabel('Amplituda[\circ]')
    ylabel("Maksimum brzine[\circ/s]")
    title("Glavna sekvenca")
    grid on;
figure
    scatter(DATA.SACC.amplitudes,DATA.SACC.durations)
    xlabel('Amplituda[\circ]')
    ylabel("Trajanje sakade[ms]")
    title("Glavna sekvenca")
    grid on;


   


        



