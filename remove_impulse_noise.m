function [filtered_sig] = remove_impulse_noise(sig,Fs)
% Algorithm for removing impulse noise that occurs in the signal.
% The assumed shape of the impulse noise is a rectangular pulse, with a 
% duration of 10 ms. The algorithm also handles the case where two impulse 
% noises occur consecutively. If there are more than two consecutive impulse 
% noises, it is recommended to use a different algorithm.

% INPUT:
%     sig - original 1D signal
%     Fs - signal sampling frequency
% OUTPUT:
%     filtered_sig - filtered signal

filtered_sig = sig;
window = 10/1000*Fs; % 10 ms window
T = 5; % 5 degree threshold

% Finding nosie start and end
impulse_flag = 0;
impulse_start = [0];
impulse_end = [0];
last_good = 0;

for ind = 2:length(sig)
    if abs(sig(ind) - sig(ind-1)) > T
        impulse_flag = xor(impulse_flag, 1);
        if impulse_flag == 1
            % connect two impulses in signal
            if (ind-impulse_end(end)) < window
                impulse_end = impulse_end(1: end-1);
                impulse_end = [impulse_end ind-1];
            else
                impulse_start = [impulse_start ind];
            end
        else
            impulse_end = [impulse_end ind-1];
        end
    end
end

% ignore zeros from start of the array
impulse_start = impulse_start(2: end);
impulse_end = impulse_end(2: end);

% interpolation
for ind = 1:length(impulse_start)
    s = impulse_start(ind) - 1;
    e = impulse_end(ind) + 1;
    x = [s, e];
    y = [sig(s), sig(e)];
    xx = s:1:e;
    yy = spline(x, y, xx);
    signal(s:e) = yy;
    filtered_sig(s:e) = yy;
end
