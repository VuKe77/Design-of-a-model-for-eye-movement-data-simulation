function DATA = detekcija_sakada(raw_data,t)
%Algoritam za detekciju sakada i izdvajanje statistickih obelezja.
% Na osnovu x i y koordinata pogleda ociju na ekranu se racuna ugaoni pomeraj
% oka i brzina ugaonog pomeraja oka, zatim se vrsi detekcija sakada
% pomocu algoritma opisanog u radu Nystrom,Holmqvist(2010). 
% Na kraju se izdvajaju informacije od znacaja i statisticka obelezja sakada

%Ulaz: 
%        data - 2D vektor cije su kolone vrednost x,y koordinata u pikselima
%        t - vremenska osa
%Izlaz:
%        DATA - struktura koja sadrzi sledece informacije
%            DATA.GAZE.t - vremenska osa [s]
%            DATA.GAZE.amp - apsolutna amplituda ugla pomeraja ociju [deg]
%            DATA.GAZE.vel - brzina pomeraja ociju [deg/s]
% 
%            DATA.SACC.peak_vals - pikovi brzine sakada [deg/s]
%            DATA.SACC.peak_idxs - indeksi pikova brzina sakada
%            DATA.SACC.onsets - indeksi pocetka sakada
%            DATA.SACC.offsets - indeksi krajeva sakada
%            DATA.SACC.durations - trajanje sakada [ms]
%            DATTA.SACC.gaze_times - trajanje fiksacije ociju/ vreme izmedju sakada [ms]
%            DATA.SACC.amplitudes - amplitude sakada [deg]
%            DATA.SACC.traj - niz trajektorija sakada [deg]
%            DATA.SACC.traj_t - niz vremena koja odgovaraju trajektorijama sakada [s]

%definisanje konstanti vezanih za postavku eksperimenta

Fs = 1000;
resolution_pix = [1920, 1080];
center = resolution_pix/2;
resolution_cm = [129.54, 78.486];
distance = 100;
ratio = resolution_cm./resolution_pix;
%visualizacija pogleda na ekran


raw_x = raw_data(:,1);
raw_y = raw_data(:,2);

figure()
plot(raw_x,raw_y)
title('Koordinate pogleda na ekranu')
xlabel('x[piksel]')
ylabel('y[piksel]')

%% filtriranje

filt_x = MA_filter(raw_x, floor(Fs/1000*25)); %window length of 25 ms
filt_y = MA_filter(raw_y, floor(Fs/1000*25));
% filt_x = raw_x
% filt_y = raw_y
figure()
    hold on;
    title('Filtriranje x koordinate piksela')
    plot(t,raw_x)
    plot(t,filt_x)
    xlabel('t[s]')
    ylabel('Amplituda[pix]')
    legend(["originalan signal", "filtriran signal"])
    hold off;

%% racunaje pozicije(amplitude) i brzine pomeraja ocne jabucice


%gaze_amp = atan(sqrt(((filt_x-center(1))*ratio(1)).^2 + ((filt_y-center(2))*ratio(2)).^2)/distance)*180/pi;
% gaze_amp = atan(abs((filt_x-center(1))*ratio(1))/distance)*180/pi;
% gaze_vel = abs(central_diff(gaze_amp',1/Fs));
gaze_amp = raw_data(:,1);
gaze_vel = abs(central_diff(gaze_amp',1/Fs));
figure()
    plot(gaze_amp)
    title("Amplituda pomeraja ocne jabucice")
    xlabel('t[s]')
    ylabel('Amplituda[deg]')
figure()
    title("Apsolutna vrednost brzine pomeraja ocne jabucice")
    hold all
    plot( abs(gaze_vel))
    xlabel('odbirci[n]')
    ylabel('Amplituda[deg]')
%% ALGORITAM ZA DETKCIJU SAKADA %%

%inicijalizacija praga
PT = 100 + 200*rand(1);
run_flag = true;
iter = 0;
PTs = [];
while run_flag
    PTs = [PTs PT];
    iter = iter+1;
    PT_old = PT;
    noise = gaze_vel(gaze_vel<PT_old); 
    noise_mean = mean(noise);
    noise_std = std(noise);
    PT = noise_mean + 6*noise_std;
    if abs(PT-PT_old)<1
        run_flag = false;
        disp(['Algoritam je konvergirao: PT = ' num2str(PT,4)])
    end      
end

%Algoritam konvergira ka istoj vrednosti veoma brzo!
figure()
    plot(PTs)
    xlabel("Vrednost praga PT [deg/s]")
    ylabel("Iteracija[n]")
    title("Algoritam za detekciju praga")
    curtick = get(gca, 'XTick');
    set(gca, 'XTick', unique(round(curtick)))
    

%% Detekcija sakada
%detekcija pikova
[peak_vals,peak_idxs] = findpeaks(gaze_vel,"MinPeakDistance",Fs/1000*50,"MinPeakHeight", PT);

    
%detekcija onset-a
T_onset = noise_mean + 3*noise_std;
onset_idxs = [];
for i=1:length(peak_idxs)
    j=1;
    %iterative find first local minimum left from peak
    while 1
       if peak_idxs(i)-j-1 == 0 %edge case
           onset_idxs = [onset_idxs 1];
           break;
       end
        if gaze_vel(peak_idxs(i)-j)<T_onset 
           if gaze_vel(peak_idxs(i)-j)-gaze_vel(peak_idxs(i)-j-1)<=0
                onset_idxs = [onset_idxs peak_idxs(i)-j]; 
                break;
            end
        end
        j = j+1;
        
    end
end
%ofset
noise_window = floor(Fs/1000*40); %40ms window
a=0.7;
b=0.3;
offset_idxs = [];
for i = 1:length(peak_idxs)
    local_noise = mean(gaze_vel(max(peak_idxs(i)-noise_window,1): peak_idxs(i)));
    T_offset = a*T_onset + b*local_noise;
    j=1;
    %iterative find first local minimum right from peak
    while 1
        if peak_idxs(i)+j+1>length(gaze_vel) %edge case
            offset_idxs = [offset_idxs length(gaze_vel)]; 
            break;
        end
        
        if gaze_vel(peak_idxs(i)+j)<T_onset 
           if gaze_vel(peak_idxs(i)+j) - gaze_vel(peak_idxs(i)+j+1)<=0
                offset_idxs = [offset_idxs peak_idxs(i)+j]; 
                break;
            end
        end
        j = j+1;
    end
    
    
    
    
end

offset_vals = gaze_vel(offset_idxs);
onset_vals = gaze_vel(onset_idxs);
durations = offset_idxs-onset_idxs;
valid = ones(1,length(durations));
% odbacivanje nepravilnih sakada 
%Sakade koje su krace od 10ms se odbacuju
min_duration=ceil(Fs/1000*10);
valid(durations<min_duration)=0;
valid(peak_vals>1000) = 0; %sakade vece od 1000 deg/s nisu moguce







%problem gde se ne pronadje offset sakade lepo
for i=2:length(valid)
    if valid(i)==0
        continue
    end
    if peak_idxs(i)<offset_idxs(i-1) %kako bismo izbacili pikove koji su pogresni
        valid(i)=0;
        
    end
end
%postavi validne podatke
disp(['Excluded number of samples:' num2str(length(find(valid==0)))])
peak_idxs = peak_idxs(valid==1);
onset_idxs = onset_idxs(valid==1);
offset_idxs = offset_idxs(valid==1);
peak_vals = peak_vals(valid==1);
onset_vals = onset_vals(valid==1);
offset_vals = offset_vals(valid==1);
durations = durations(valid==1);
gaze_times =onset_idxs(2:end)- offset_idxs(1:end-1); 



durations = durations/Fs*1000;
gaze_times = gaze_times/Fs*1000;

        
figure()
    hold all
    title("Brzina sakada")
    plot(t,gaze_vel)
    plot(t(peak_idxs),peak_vals,'x')
    plot(t(onset_idxs),onset_vals,'o')
    plot(t(offset_idxs),offset_vals,'*')
    xlabel('t[s]')
    ylabel('Brzina[deg/s]')
    legend(["brzina sakada", "pocetak", "kraj"])
    hold off;
figure()
    hold all
    title("Amplituda sakada")
    plot(t,gaze_amp)
    plot(t(onset_idxs),gaze_amp(onset_idxs),'o')
    plot(t(offset_idxs),gaze_amp(offset_idxs),'*')
    xlabel('t[s]')
    ylabel('Amplituda[deg/s]')
    legend(["amplituda sakada", "pocetak", "kraj"])
    hold off;
    
%%izdvajanje sakada
sacc_traj = {};
sacc_traj_t = {};
for i=1:length(peak_idxs)
    sacc_traj{i} = gaze_amp(onset_idxs(i):offset_idxs(i));
    sacc_traj_t{i} = t(onset_idxs(i):offset_idxs(i));
end
    
    
%% racunanje statisickih obelezja
sacc_amplitudes = abs(gaze_amp(onset_idxs)'-gaze_amp(offset_idxs)');


DATA = struct;
DATA.GAZE.t = t;
DATA.GAZE.amp = gaze_amp;
DATA.GAZE.vel = gaze_vel;

DATA.SACC.peak_vals = peak_vals;
DATA.SACC.peak_idxs = peak_idxs;
DATA.SACC.onsets = onset_idxs;
DATA.SACC.offsets = offset_idxs;
DATA.SACC.durations = durations;
DATA.SACC.gaze_times = gaze_times;
DATA.SACC.amplitudes = sacc_amplitudes;
DATA.SACC.traj = sacc_traj;
DATA.SACC.traj_t = sacc_traj_t;




end

