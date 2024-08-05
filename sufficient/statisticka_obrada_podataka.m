close all
clear all
clc

%statisticka obrada podataka

%% ucitavanje
SBJ1 = load("D:\ETF nastava\VIII semsetar\Diplomski\EMA_Toolbox\DATA\EYELINK\SBJ1_PROC.mat");
t = SBJ1.ET.TIME; %vremenska osa
%left eye

%pocetne, krajne tacke, trajanje sakade, pik brzine,amplitude
start_points = SBJ1.PROC.SACC_LE.Tstart;
end_points = SBJ1.PROC.SACC_LE.Tend;
durations = end_points - start_points;
vel_peak = SBJ1.PROC.SACC_LE.MAX_VEL_DEG;
amplitudes = SBJ1.PROC.SACC_LE.AMP_DEG;


%pronalazenje vremenskih indeksa pomenutih trenutaka
start_idxs = find_indices(start_points,t);
end_idxs = find_indices(end_points,t);

%velocity
vel_deg = SBJ1.ET.LE.VEL.DEG;
vel_degx = SBJ1.ET.LE.VEL.DEG_X;
vel_degy = SBJ1.ET.LE.VEL.DEG_Y;

vel = sqrt(vel_degx.^2 + vel_degy.^2);%KAKO SE RACUNA absolutna BRZINA na osnovu dve brzine!

%position
pos_pix = SBJ1.ET.LE.POS.PIX;
pos_deg = SBJ1.ET.LE.POS.DEG;


%traj abs
traj_abs = SBJ1.PROC.SACC_LE.TRAJ_ABS;
pos_deg_abs = sqrt(pos_deg(:,1).^2+pos_deg(:,2).^2);
pos_pix_abs = sqrt(pos_pix(:,1).^2+pos_pix(:,2).^2);

%% Moj nacin
%konstante
resolution_pix = [1920, 1080];
center = resolution_pix/2;
resolution_cm = [125, 77];
distance = 100;
ratio = resolution_cm./resolution_pix;







raw_data = SBJ1.ET.ORIG.RAW.LE;
raw_x = raw_data(:,1);
raw_y = raw_data(:,2);
figure()
plot(raw_x,raw_y)
title('Koordinate pogleda na ekranu')
xlabel('x')
ylabel('y')


sacc_amp = atan(sqrt(((raw_x-center(1))*ratio(1)).^2 + ((raw_y-center(2))*ratio(2)).^2)/distance)*180/pi;
sacc_vel = central_diff(sacc_amp',1/250);
figure()
plot(sacc_amp)
figure()
hold all
plot(abs(sacc_vel))
plot(SBJ1.ET.LE.VEL.DEG)




%% filter nan values
%find nan indices and filter
nan_indices1 = find(isnan(start_points))
nan_indices2 = find(isnan(end_points))
valid_indices = 1:length(end_points);
valid_indices(nan_indices2) =[];



%% distribucija parametara

%trajanje sakade
duration_mean = mean(durations(valid_indices));
duration_std = std(durations(valid_indices));
x = [0:0.001:0.18];
duration_normal = normpdf(x,duration_mean,duration_std);
figure
    hold on;
    title(['Histogram trajanja sakada: \mu =' , num2str(duration_mean,2) ', \sigma = ', num2str(duration_std,2)])
    histogram(durations,25,'Normalization','pdf')
    plot(x,duration_normal)
    hold off;
%maks brzina sakade
x = 0:1:800;
velpeak_mean = mean(vel_peak(valid_indices));
velpeak_std = std(vel_peak(valid_indices));
velpeak_normal = normpdf(x,velpeak_mean,velpeak_std);
figure
    hold on;
    title(['Histogram pikova brzina sakada: \mu =' , num2str(velpeak_mean,2) ', \sigma = ', num2str(velpeak_std,2)])
    histogram(vel_peak,25,'Normalization','pdf')
    plot(x,velpeak_normal)
    hold off;


%amplituda sakade
%trajanje sakade
amplitude_mean = mean(amplitudes(valid_indices));
amplitude_std = std(amplitudes(valid_indices));
x = [0:0.01:20];
amplitude_normal = normpdf(x,amplitude_mean,amplitude_std);
figure
    hold on;
    title(['Histogram amplituda sakada: \mu =' , num2str(amplitude_mean,2) ', \sigma = ', num2str(amplitude_std,2)])
    histogram(amplitudes,25,'Normalization','pdf')
    plot(x,amplitude_normal)
    hold off;
    
    
qqplot(durations)
ylim([0,0.18])

title("QQ grafik za trajanje sakada")
xlabel("teorijska normalna raspodela")
ylabel("uzorci")




