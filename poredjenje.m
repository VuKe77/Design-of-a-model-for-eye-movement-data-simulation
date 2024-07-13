clc
close all
clear all

%% numericki algoritam sa Emax i E0
%parametri
td=0.07;
Vmax = 600;
Emax=25;
E0=0;
[y,t] = fitovanje_trajektorije(Vmax, td, E0, Emax);
y_1 = central_diff(y,0.001);
figure
    title("sakade")
    subplot(2,1,1)
        plot(t,y)
        ylabel('Amplituda[deg]')
    subplot(2,1,2)
        plot(t,y_1)
        xlabel('t[s]')
        ylabel('Brzina[deg/s]')
%%     
SBJ1 = load("D:\ETF nastava\VIII semsetar\Diplomski\EMA_Toolbox\DATA\EYELINK\SBJ1\SBJ1_PROC.mat");
t = SBJ1.ET.TIME; %vremenska osa

%pocetne, krajne tacke, trajanje sakade, pik brzine
start_points = SBJ1.PROC.SACC_LE.Tstart;
end_points = SBJ1.PROC.SACC_LE.Tend;
durations = end_points - start_points;
vel_peak = SBJ1.PROC.SACC_LE.MAX_VEL_DEG;

%pronalazenje vremenskih indeksa pomenutih trenutaka
start_idxs = find_indices(start_points,t);
end_idxs = find_indices(end_points,t);

%filtriranje NaN vrednosti
nan_indices1 = find(isnan(start_points));
nan_indices2 = find(isnan(end_points));
valid_indices = 1:length(end_points);
valid_indices(nan_indices2) =[];
valid_indices(nan_indices1) = [];

%amplituda sakade 
sbj1_pos_deg = SBJ1.ET.LE.POS.DEG(:,1);
sbj1_vel_deg = SBJ1.ET.LE.VEL.DEG;

%pronalazenje parametara modela
E0s = sbj1_pos_deg(start_idxs); 
Emaxs = sbj1_pos_deg(end_idxs);



verbose=1;
error =[];
for index=1:10
    i = valid_indices(index);
    E0 = E0s(i);
    Emax = Emaxs(i);
    Vmax = vel_peak(i);
    td = durations(i);

    [y,t1] = fitovanje_trajektorije(Vmax, td, E0, Emax,t(start_idxs(i)));
    %pronalazenje indeksa niza y koji odgovaraju nizu y1 koji ima manju
    %frekvenciju odabiranja
    indices_undersampled = find_indices(t(start_idxs(i):end_idxs(i)),t1);
    
    %pronalazenje srednje kvadratne greske amplitude sakade
    error_i = mean(abs(y(indices_undersampled)-sbj1_pos_deg(start_idxs(i):end_idxs(i))));
    error = [error error_i];
    
    %racunanje brzine sakade
    y1 = central_diff(y,0.001);
    if verbose==1
        figure
            subplot(2,1,1)
                title(['Vmax: ' num2str(Vmax) ', td: ' num2str(td)])
                hold all;
                plot(t(start_idxs(i):end_idxs(i)),sbj1_pos_deg(start_idxs(i):end_idxs(i)))
                plot(t1,y)
                hold off;
                xlim([t(start_idxs(i)),t(end_idxs(i))])
                ylabel(['Amplituda[deg]'])
                legend(["original" ,"model"])
            subplot(2,1,2)
                hold all;
                plot(t(start_idxs(i):end_idxs(i)),sbj1_vel_deg(start_idxs(i):end_idxs(i)))
                plot(t1,abs(y1))
                hold off;
                xlim([t(start_idxs(i)),t(end_idxs(i))])
                xlabel('t[s]')
                ylabel(['Brzina[deg]'])
    end
            
end




disp([ 'Srednja apsolutna greska: ' num2str(mean(error),2)])




%% Racunanje uglova

%racunanje ugla 
center = [960,540];
size = (SBJ1.ET.ORIG.RAW.LE -center).*[125/1920 77/1080];
angles = atan(size/100)*180/pi;
size1 = sqrt(size(:,1).^2 + size(:,2).^2); %zzasto se ne poklapa?!
angle = atan(size1/100)*180/pi;

%mozda
angles = atan(size/100)*180/pi;
%tanaksovic
x1=SBJ1.ET.ORIG.RAW.LE(:,1);
x2 = [0 ;SBJ1.ET.ORIG.RAW.LE(1:end-1,1)];
y1 = SBJ1.ET.ORIG.RAW.LE(:,2);
y2 =[0 ;SBJ1.ET.ORIG.RAW.LE(1:end-1,2)];
x_1 = central_diff(SBJ1.ET.ORIG.RAW.LE(:,1)',1);
y_1 = central_diff(SBJ1.ET.ORIG.RAW.LE(:,2)',1);
angle = sqrt(((82/1920)*x_1).^2 + (52/1080)*y_1.^2)*180/pi
%angle = acos((100.^2 + x1.*x2 +y1.*y2)./sqrt((100^2+x1.^2+y1.^2).*(100.^2+x2.^2+y2.^2)))* 57.296;
figure
    hold on;
    plot(angle)
    %plot(SBJ1.ET.LE.VEL.DEG)

x = atan((405.8000-960)*125/1920/100)*180/pi

%%
%vel =fitovanje_brzine(start_idxx);

amp_deg = SBJ1.PROC.SACC_LE.AMP_DEG;

t1 = SBJ1.PROC.SACC_LE.TRAJ_ABS(:,1);
t2 = SBJ1.PROC.SACC_LE.TRAJ_ABS_FIT(:,1);
t3 = SBJ1.ET.ORIG.RAW.LE;



figure
    hold on;
%    plot(t3)
    plot(t1)
    plot(t2)

figure
    plot(t, sbj1_vel_deg)
    hold on;
    stem(t(start_idxs),sbj1_vel_deg(start_idxs),'rx')
    stem(t(end_idxs),sbj1_vel_deg(end_idxs),'gx')
    hold off;
    
    

 