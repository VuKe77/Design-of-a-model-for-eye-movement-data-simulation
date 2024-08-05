function [filterd_signal] = MA_filter(signal,window_length)
%Izvodi offline MA filtriranje signala sa tačkom centriranom u
%prozoru koji se koristi za filtriranje. Dužina prozora je u uzorcima[n]

filterd_signal = signal;
half_window = ceil(window_length/2);

for i=1:length(signal)-half_window
    filterd_signal(i) = sum(signal(max(1,i-half_window):min(length(signal),i+half_window-1)))/2/half_window;
end

end