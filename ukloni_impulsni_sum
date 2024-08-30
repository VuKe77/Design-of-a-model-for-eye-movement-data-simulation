function [filtered_sig] = ukloni_impulsni_sum(sig,Fs)
% Algoritam za uklanjanje impulsnog suma koji se javlja u signalu.
% Pretpostavljen oblik impulsnog suma je  pravougaona cetvrkte, pretpostavlja
% se da je nasiri impuls trajanja 10ms. Takodje je obradjen slucaj kada se jave 
% dva impulsna suma uzastopno. Ukoliko ima vise impulsnih sumova uzastopno najbolje
% je koristiti drugi algoritam
% 
% 
% 
% Ulaz:
%     sig - originalan 1D signal 
%     Fs - frekvencija odabiranja signala
% Izlaz
%     filtered_sig - filtriran signal
%     
    


filtered_sig=sig;
window = 10/1000*Fs; %10ms prozor
T = 5; %prag od 10 stepeni

%pronalazenje pocetka i kraja impulsa
impulse_flag = 0;
impulse_start = [0];
impulse_end = [0];
last_good = 0;
for i = 2:length(sig)
    if abs(sig(i)-sig(i-1))>T
        impulse_flag = xor(impulse_flag,1);
        if impulse_flag == 1
            %connect two impulses in signal
            if (i-impulse_end(end))<window
                impulse_end = impulse_end(1:end-1);
                impulse_end = [impulse_end i-1];
            else
                impulse_start = [impulse_start i];
            end


        else
            impulse_end = [impulse_end i-1];
        end

    end

end
%ignorisi nule sa pocetka niza
impulse_start = impulse_start(2:end);
impulse_end = impulse_end(2:end);

% interpolacija izgubljenog dela signala
for i=1:length(impulse_start)
    s = impulse_start(i)-1;
    e = impulse_end(i)+1;
    x = [s,e];
    y = [sig(s),sig(e)];
    xx = s:1:e;
    yy = spline(x,y,xx);
    signal(s:e) = yy;
    filtered_sig(s:e) = yy;
    

end




