function DATA = saccade_detection(raw_data,t)
%Algoritam za detekciju sakada i izdvajanje statistickih obelezja.
% Na osnovu horizontalnog stepena vizuelnog ugla se vrsi detekcija sakada
% inspirisan algoritmom opisanim u radu Nystrom,Holmqvist(2010). 
% Na kraju se izdvajaju informacije od znacaja i statisticka obelezja sakada

%Ulaz: 
%        data - 2D vektor cije su kolone vrednosti horizontalnog i
%        vertikalnog stepena vizuelnog ugla
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
resolution_pix = [1680, 1050];
center = [840 525+127.2727];
resolution_cm = [47.4, 29.7];
distance = 55;
ratio = resolution_cm./resolution_pix;
%visualizacija pogleda na ekran

deg_x = raw_data(:,1);
deg_y = raw_data(:,2);

raw_x = tan(pi/180*deg_x)*distance/ratio(1)+center(1);
raw_y = tan(pi/180*deg_y)*distance/ratio(2)+center(2);


figure()
plot(raw_x,raw_y)
title('Koordinate pogleda na ekranu')
xlabel('x[piksel]')
ylabel('y[piksel]')
%% vizualizacija 
figure
    plot(t,deg_x)
    ylabel('Amplituda s.v.u[\circ]')
    xlabel('Vreme[s]')
    title(['Originalan signal pokreta oka'])

%% filtriranje

filt_x = MA_filter(deg_x, floor(Fs/1000*5)); %window length of 5 ms
filt_y = MA_filter(deg_y, floor(Fs/1000*5));

figure()
    hold on;
    title('Filtriranje horizontalnog s.v.u MA filtrom ')
    plot(t,deg_x)
    plot(t,filt_x)
    xlabel('Vreme[s]')
    ylabel('Amplituda[\circ]')
    legend(["originalan signal", "filtriran signal"])
    hold off;

%% racunaje pozicije(amplitude) i brzine pomeraja ocne jabucice
%analiza se vrsi samo na horizontalnim sakadama
gaze_amp = filt_x; 
gaze_vel = abs(central_diff(gaze_amp',1/Fs));
figure()
    plot(t,gaze_amp)
    title("Amplituda stepena vizuelnog ugla")
    xlabel('Vreme[s]')
    ylabel('Amplituda[\circ]')
figure()
    title("Apsolutna vrednost brzine promene s.v.u")
    hold all
    plot(t,abs(gaze_vel))
    xlabel('Vreme[s]')
    ylabel('Amplituda[\circ/s]')
%% ALGORITAM ZA DETKCIJU SAKADA %%

%inicijalizacija praga
PT = 100 + 200*rand(1);
PT = 200; %za diplomski, kako bi rezultati bili konzistentni
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
    ylabel("Vrednost praga PT [\circ/s]")
    xlabel("Iteracija[n]")
    title("Konvergencija algoritma za detekciju praga")
    curtick = get(gca, 'XTick');
    set(gca, 'XTick', unique(round(curtick)))
    

%% Detekcija sakada
%detekcija pikova
[peak_vals,peak_idxs] = findpeaks(gaze_vel,"MinPeakDistance",Fs/1000*40,"MinPeakHeight", PT);

    
%detekcija onset-a
T_onset = noise_mean + 3*noise_std;
onset_idxs = [];
for i=1:length(peak_idxs)
    j=1;
    %iterativno nalazenje prvog lokalnog minimuma levo od pika
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
%detekcija offseta
noise_window = floor(Fs/1000*40); %40ms window
a=0.7;
b=0.3;
offset_idxs = [];
for i = 1:length(peak_idxs)
    local_noise = mean(gaze_vel(max(peak_idxs(i)-noise_window,1): peak_idxs(i)));
    T_offset = a*T_onset + b*local_noise;
    j=1;
    %iterativno nalazenje prvog lokalnog minimuma desno od pika
    while 1
        if peak_idxs(i)+j+1>length(gaze_vel) %edge case
            offset_idxs = [offset_idxs length(gaze_vel)]; 
            break;
        end
        
        if gaze_vel(peak_idxs(i)+j)<T_offset 
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
%Odbacivanje nepravilnih sakada 
min_duration=ceil(Fs/1000*10);
valid(durations<min_duration)=0;%Sakade koje su krace od 10ms se odbacuju
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
%filtriranje validnih podataka
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

%vizualizacija    
figure()
    hold all
    title("Apsolutna vrednost brzine promene s.v.u")
    plot(t,gaze_vel)
    plot(t(peak_idxs),peak_vals,'x')
    plot(t(onset_idxs),onset_vals,'o')
    plot(t(offset_idxs),offset_vals,'*')
    xlabel('Vreme[s]')
    ylabel('Brzina[\circ/s]')
    legend(["signal","maksimumi", "pocetak", "kraj"])
    hold off;
figure()
    hold all
    title("Amplituda s.v.u")
    plot(t,gaze_amp)
    plot(t(onset_idxs),gaze_amp(onset_idxs),'o')
    plot(t(offset_idxs),gaze_amp(offset_idxs),'*')
    xlabel('Vreme[s]')
    ylabel('Amplituda[\circ/s]')
    legend(["signal", "pocetak", "kraj"])
    hold off;
    
%izdvajanje trajektorija sakada
sacc_traj = {};
sacc_traj_t = {};
for i=1:length(peak_idxs)
    sacc_traj{i} = gaze_amp(onset_idxs(i):offset_idxs(i));
    sacc_traj_t{i} = t(onset_idxs(i):offset_idxs(i));
end
    
    
%% racunanje statisickih obelezja
sacc_amplitudes = abs(gaze_amp(onset_idxs)'-gaze_amp(offset_idxs)');

%output
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

