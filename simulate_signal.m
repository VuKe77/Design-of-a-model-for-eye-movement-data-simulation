function [SIM] = simulate_signal(Tmax,Fs,noise)
%Funkcija simulira signal pokreta ociju.
% ULAZ:
%     Tmax - ukupno trajanje signala u sekundama
%     Fs - frekvencija odabiranja signala\
%     noise - standardna devijacija gausovog suma, ukoliko je 0 nema suma
% IZLAZ:
%     SIM - struktura koja sadrzi sledece informacije
%         SIM.SIGNALS.t - vremenska osa simuliranog signala
%         SIM.SIGNALS.AMP - amplituda signala pokreta ociju
%         SIM.SIGNALS.VEL - apsolutna brzina promene amplitude signala pokreta ociju
% 
%         SIM.PARAMS.amplitudes - amplitude simuliranih sakada
%         SIM.PARAMS.peak_vals - maskimalne brzine simuliranih sakada
%         SIM.PARAMS.peak_pos - pozicije pikova
%         SIM.PARAMS.durations - trajanja simuliranih sakada
%         SIM.PARAMS.gaze_times - trajanja fiksacija u s 



% ucitavanje modela glavnih sekvenci
loadedData = load('ampPDF.mat');
amp_pdf =  loadedData.amp_pdf;


loadedData = load('modelPeak.mat');
model_peak = loadedData.best_model;

loadedData = load('modelDuration.mat');
model_duration = loadedData.best_model;

loadedData = load('gazePDF.mat');
model_gaze = loadedData.gaze_pdf;

%formiranje vremenske ose
Ts = 1/Fs;
t = 0:Ts:Tmax-Ts; 

sacc_amplitude = [0];
sacc_velocity = [0];

%Lista za monitoring parametara
amplitudes = [];
durations = [];
peak_vals = [];
gaze_times = [];
onsets = [];
offsets = [];
peak_pos = [];
t_last = 0;
E0 = 0;

%glavna petlja za simulaciju signala
while true
    %uzrokovanje neophodnih parametara
    amplitude = random(amp_pdf);
    td = model_duration(amplitude)/1000; %We need td in seconds
    Vmax = model_peak(amplitude);
    
    %Kontrolisanje znaka amplitude sakade
    if sacc_amplitude(end)>7
        prob=0.2;
    elseif sacc_amplitude(end)<-7
        prob=0.8;
    else
        prob = 0.5;
    end
    
    if rand>=prob 
        %negativna amplituda
        Emax = E0-amplitude;
    else
        %pozitivna amplituda
        Emax = E0 + amplitude;
    end

  
    
    %formiranje sakade
    [sacc,t1, amplitude] = trajectory_fit(Vmax,td,E0,Emax,Fs,t_last);
    td = length(sacc)/Fs;
    onsets = [onsets t_last];
    %edge case
    if t_last+td>=Tmax
        
        sacc_amplitude = [sacc_amplitude zeros(1,length(t)-length(sacc_amplitude))];
        sacc_velocity = [sacc_velocity zeros(1,length(t)-length(sacc_velocity))];
        break
    end 
    % saccade generated, increase time
    t_last = t_last+td;
    offsets = [offsets t_last+1/Fs]; %podrazumeva se da je kraj prvi odbirak koji pada na nulu
    sacc_amp = abs(amplitude-E0);
    E0 = amplitude;
    sacc1 = central_diff(sacc,Ts);
    [Vmax,Vmax_pos] = max(abs(sacc1));
    Vmax_pos = t1(Vmax_pos+1);
    
    %kreiranje fiksacije(pauze)
    pause = random(model_gaze)/1000;
    if t_last>=Tmax 
        pause=0;
    elseif t_last+pause>=Tmax
        pause = length(t) - (length(sacc_amplitude)+length(sacc));
    else
        pause = floor(pause*Fs);
        
    end
    if pause<0
        pause=0;
    end
    t_last = t_last+pause/Fs;
    
    sacc_amplitude = [sacc_amplitude sacc amplitude*ones(1,pause) ];
    sacc_velocity = [sacc_velocity sacc1 zeros(1, pause)];
    
    %monitor
    amplitudes = [amplitudes sacc_amp];
    peak_vals = [peak_vals Vmax];
    peak_pos = [peak_pos Vmax_pos];
    durations = [durations td];
    gaze_times = [gaze_times pause/Fs];
end

%dodavanje suma 
sacc_amplitude = sacc_amplitude + randn(1,length(sacc_amplitude))*noise;
sacc_velocity = central_diff(sacc_amplitude,Ts);

%Javlja se bug prilikom racunanja konkretno t_last=9.9..9 umesto 10,
%tako da ovo je mehanizam da vektori budu iste duzine
sacc_amplitude = sacc_amplitude(1:length(t));
sacc_velocity = sacc_velocity(1:length(t));

%vizualizacija
figure
    subplot(2,1,1)
        plot(t,sacc_amplitude)
        ylabel('Amplituda s.v.u[\circ]')
        title(['Simulacija signala pokreta oka, Fs = ' num2str(Fs) 'Hz'])
    subplot(2,1,2)
        plot(t,abs(sacc_velocity))
        xlabel('Vreme[s]')
        ylabel('Brzina promene s.v.u[\circ/s]')
%Cuvanje signal i parametara u strukturu
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
