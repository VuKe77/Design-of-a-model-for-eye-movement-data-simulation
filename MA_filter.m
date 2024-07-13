function [filterd_signal] = MA_filter(signal,window_length)
%Performs offline MA filtering of signal with point centered at the
%window using for filtering. Window length is in samples[n]

filterd_signal = zeros(1,length(signal))';
half_window = ceil(window_length/2);

for i=1:length(signal)-half_window
    filterd_signal(i) = sum(signal(max(1,i-half_window):min(length(signal),i+half_window-1)))/2/half_window;
end

end