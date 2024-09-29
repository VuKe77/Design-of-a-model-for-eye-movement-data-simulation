function [SIM] = simulate_signal(Tmax,Fs,noise)
% The function simulates an eye movement signal.
% INPUT:
%     Tmax - total duration of the signal in seconds
%     Fs - signal sampling frequency
%     noise - standard deviation of Normal noise; if 0, noise is not added
% OUTPUT:
%     SIM - a structure containing the following information
%         SIM.SIGNALS.t - time axis of the simulated signal
%         SIM.SIGNALS.AMP - amplitude of the eye movement signal
%         SIM.SIGNALS.VEL - absolute velocity of amplitude change of the eye movement signal
% 
%         SIM.PARAMS.amplitudes - amplitudes of the simulated saccades
%         SIM.PARAMS.peak_vals - peak velocities of the simulated saccades
%         SIM.PARAMS.peak_pos - positions of the peaks
%         SIM.PARAMS.durations - durations of the simulated saccades
%         SIM.PARAMS.gaze_times - durations of fixations in seconds


% loading main sequence models
loadedData = load('ampPDF.mat');
amp_pdf =  loadedData.amp_pdf;

loadedData = load('modelPeak.mat');
model_peak = loadedData.best_model;

loadedData = load('modelDuration.mat');
model_duration = loadedData.best_model;

loadedData = load('gazePDF.mat');
model_gaze = loadedData.gaze_pdf;

% create time axis
Ts = 1/Fs;
t = 0:Ts:Tmax-Ts; 

sacc_amplitude = [0];
sacc_velocity = [0];

% list of monitored parameters
amplitudes = [];
durations = [];
peak_vals = [];
gaze_times = [];
onsets = [];
offsets = [];
peak_pos = [];
t_last = 0;
E0 = 0;

% main loop for signal generation
while true
    % sampling neccessery parameters
    amplitude = random(amp_pdf);
    td = model_duration(amplitude)/1000; % We need td in seconds
    Vmax = model_peak(amplitude);
    
    % Control sign of saccade amplitude
    if sacc_amplitude(end) > 7
        prob = 0.2;
    elseif sacc_amplitude(end) < -7
        prob = 0.8;
    else
        prob = 0.5;
    end
    
    if rand >= prob 
        % negative amplitude
        Emax = E0-amplitude;
    else
        % positive amplitude
        Emax = E0 + amplitude;
    end
    
    % saccade simulation
    [sacc,t1, amplitude] = trajectory_fit(Vmax, td, E0, Emax, Fs, t_last);
    td = length(sacc)/Fs;
   
    % edge case
    if t_last + td >= Tmax
        sacc_amplitude = [sacc_amplitude zeros(1, length(t) - length(sacc_amplitude))];
        sacc_velocity = [sacc_velocity zeros(1, length(t) - length(sacc_velocity))];
        break
    end
    % saccade generated, increase time
    onsets = [onsets t_last];
    t_last = t_last + td;
    offsets = [offsets t_last + 1/Fs]; % it is assumed that the offset is the first sample that falls to zero
    sacc_amp = abs(amplitude - E0);
    E0 = amplitude;
    sacc1 = central_der(sacc, Ts);
    [Vmax, Vmax_pos] = max(abs(sacc1));
    Vmax_pos = t1(Vmax_pos + 1);
    
    % creating fixation
    pause = random(model_gaze)/1000;
    if t_last >= Tmax 
        pause = 0;
    elseif t_last + pause >= Tmax
        pause = length(t) - (length(sacc_amplitude) + length(sacc));
    else
        pause = floor(pause*Fs);
    end
    if pause < 0
        pause = 0;
    end
    t_last = t_last + pause/Fs;
    
    sacc_amplitude = [sacc_amplitude sacc amplitude*ones(1, pause)];
    sacc_velocity = [sacc_velocity sacc1 zeros(1, pause)];
    
    % monitor
    amplitudes = [amplitudes sacc_amp];
    peak_vals = [peak_vals Vmax];
    peak_pos = [peak_pos Vmax_pos];
    durations = offsets - onsets;
    gaze_times = [gaze_times pause/Fs];
end

% adding noise
sacc_amplitude = sacc_amplitude + randn(1, length(sacc_amplitude))*noise;
sacc_velocity = central_der(sacc_amplitude, Ts);

% A bug appears when calculating specifically t_last = 9.9..9 instead of 10,
% so this is a mechanism to keep vectors the same length
sacc_amplitude = sacc_amplitude(1:length(t));
sacc_velocity = sacc_velocity(1:length(t));

% Visualization
figure
    subplot(2,1,1)
        plot(t,sacc_amplitude)
            ylabel("Amplitude - degrees of angle [\circ]")
            title(["Eye movement signal simulation, Fs = " num2str(Fs) "Hz"])
    subplot(2,1,2)
        plot(t,abs(sacc_velocity))
            xlabel("Time [s]")
            ylabel("Absolute angular velocity [\circ/s]")

% Saving signal and parameters in a structure
SIM = struct;
SIM.SIGNALS.t = t;
SIM.SIGNALS.AMP = sacc_amplitude;
SIM.SIGNALS.VEL = abs(sacc_velocity);

SIM.PARAMS.amplitudes = amplitudes;
SIM.PARAMS.peak_vals = peak_vals;
SIM.PARAMS.peak_pos = peak_pos;
SIM.PARAMS.durations = durations;
SIM.PARAMS.gaze_times = gaze_times;
SIM.PARAMS.onsets = onsets;
SIM.PARAMS.offsets = offsets;
