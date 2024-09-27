%This code simulates the eye movement signal, the function is called 
% sim_eye_movements to simulate the signals and then do the processing 
% of simulated signals using the saccade_detection function
close all
clc
clear all


%% simulation of eye movement signals
%rng(32)% for debugging
Tmax = 10; %length of simulated signal
Fs = 200; %sampling frequency
noise = 0;
SIM1 = simulate_signal(Tmax,Fs,noise);
SIM2 = simulate_signal(Tmax,Fs,noise);
%% plotting the beginnings and ends of saccades of the SIM1 signal
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
        ylabel("Amplitude d.v.a[\circ]")
        legend(["signal","start", "end"])
        title("Marked saccades")
     subplot(2,1,2)
        hold all;
        plot(t, SIM1.SIGNALS.VEL)
        plot(SIM1.PARAMS.onsets,SIM1.SIGNALS.VEL(onset_idx),'x')
        plot(SIM1.PARAMS.offsets,SIM1.SIGNALS.VEL(offset_idx),'o')
        plot(SIM1.PARAMS.peak_pos, SIM1.PARAMS.peak_vals,'*')
        ylabel("Absolute angular velocity[\circ/s]")
        xlabel("Time[s]")
        legend(["signal", "maximum","start","end"])
     

    
    


    


   


        



