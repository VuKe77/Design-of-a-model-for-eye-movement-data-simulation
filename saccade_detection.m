function DATA = saccade_detection(raw_data,t)
% Algorithm for saccade detection and extraction of statistical features.
% Saccade detection is performed based on the horizontal visual angle,
% inspired by the algorithm described in Nystrom and Holmqvist (2010).
% Finally, relevant information and statistical features of saccades are extracted.

% INPUT:
%     data - 2D vector where columns represent horizontal and vertical visual angles
%     t - time axis
% OUTPUT:
%     DATA - a structure containing the following information:
%         DATA.GAZE.t - time axis [s]
%         DATA.GAZE.amp - absolute amplitude of eye movement angle [deg]
%         DATA.GAZE.vel - eye movement velocity [deg/s]
% 
%         DATA.SACC.peak_vals - peak saccade velocities [deg/s]
%         DATA.SACC.peak_idxs - indices of saccade velocity peaks
%         DATA.SACC.onsets - indices of saccade onsets
%         DATA.SACC.offsets - indices of saccade offsets
%         DATA.SACC.durations - saccade durations [ms]
%         DATA.SACC.gaze_times - fixation durations/intervals between saccades [ms]
%         DATA.SACC.amplitudes - saccade amplitudes [deg]
%         DATA.SACC.traj - array of saccade trajectories [deg]
%         DATA.SACC.traj_t - array of times corresponding to saccade trajectories [s]

% defining constants related to the experiment setup
Fs = 1000;
resolution_pix = [1680, 1050];
center = [840 525+127.2727];
resolution_cm = [47.4, 29.7];
distance = 55;
ratio = resolution_cm./resolution_pix;

% visualization of the subject screen view
deg_x = raw_data(:, 1);
deg_y = raw_data(:, 2);

raw_x = tan(pi/180*deg_x)*distance/ratio(1)+center(1);
raw_y = tan(pi/180*deg_y)*distance/ratio(2)+center(2);

figure
    plot(raw_x, raw_y)
        title("Coordinates of the screen view")
        xlabel("x [pix]")
        ylabel("y [pix]")

%% Visualization
figure
    plot(t, deg_x)
        ylabel("Amplitude d.v.a. [\circ]")
        xlabel("Time [s]")
        title(["Measured signal"])

%% Filtering
filt_x = MA_filter(deg_x, floor(Fs/1000*5)); % window length of 5 ms
filt_y = MA_filter(deg_y, floor(Fs/1000*5));

figure
    hold on;
            title("Filtering of horizontal d.v.a. using MA filter")
        plot(t, deg_x)
        plot(t, filt_x)
            xlabel("Time [s]")
            ylabel("Amplitude [\circ]")
            legend(["measured signal", "filtrated signal"])
    hold off;

%% Calculates the position (amplitude) and speed of eyeball movement
% analysis is performed only on horizontal saccades
gaze_amp = filt_x; 
gaze_vel = abs(central_der(gaze_amp', 1/Fs));

figure
    plot(t, gaze_amp)
        title("Amplitude of degree of visual angle")
        xlabel("Time [s]")
        ylabel("Amplitude [\circ]")

figure
            title("Absolute angular velocity")
    hold all
        plot(t, abs(gaze_vel))
            xlabel("Time [s]")
            ylabel("Amplitude [\circ/s]")
            
%% Saccade detection algorithm %% 

% Threshold initialization
PT = 100 + 200*rand(1);
% PT = 200;
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
    if abs(PT-PT_old) < 1
        run_flag = false;
        disp(["Algorithm converged: PT = " num2str(PT,4)])
    end      
end

% Algorithm converges to the same value very fast
figure
    plot(PTs)
        ylabel("Threshold value PT [\circ/s]")
        xlabel("Iteration [n]")
        title("Threshold algorithm convergence")
    curtick = get(gca, 'XTick');
    set(gca, 'XTick', unique(round(curtick)))
    
%% Saccade detection
% detecting peaks
[peak_vals,peak_idxs] = findpeaks(gaze_vel, "MinPeakDistance", Fs/1000*40, "MinPeakHeight", PT);

% onset detection 
T_onset = noise_mean + 3*noise_std;
onset_idxs = [];
for ind = 1:length(peak_idxs)
    jt = 1; 
    % iteratively finding the first local minimum to the left of the peak
    while 1
       if peak_idxs(ind) - jt - 1 == 0 % edge case
           onset_idxs = [onset_idxs 1];
           break;
       end
        if gaze_vel(peak_idxs(ind) - jt) < T_onset 
           if gaze_vel(peak_idxs(ind) - jt) - gaze_vel(peak_idxs(ind) - jt - 1) <= 0
                onset_idxs = [onset_idxs peak_idxs(ind) - jt]; 
                break;
            end
        end
        jt = jt + 1;
    end
end

% offset detection
noise_window = floor(Fs/1000*40); % 40 ms window
a = 0.7;
b = 0.3;
offset_idxs = [];

for ind = 1 : length(peak_idxs)
    local_noise = mean(gaze_vel(max(peak_idxs(ind)-noise_window,1): peak_idxs(ind)));
    T_offset = a*T_onset + b*local_noise;
    jt = 1;
    % iteratively finding the first local minimum to the right of the peak
    while 1
        if peak_idxs(ind) + jt + 1 > length(gaze_vel) % edge case
            offset_idxs = [offset_idxs length(gaze_vel)]; 
            break;
        end
        if gaze_vel(peak_idxs(ind) + jt) < T_offset 
           if gaze_vel(peak_idxs(ind) + jt) - gaze_vel(peak_idxs(ind) + jt + 1 ) <= 0
                offset_idxs = [offset_idxs peak_idxs(ind) + jt]; 
                break;
            end
        end
        jt = jt + 1;
    end
end

offset_vals = gaze_vel(offset_idxs);
onset_vals = gaze_vel(onset_idxs);
durations = offset_idxs-onset_idxs;
valid = ones(1, length(durations));

% Rejection of irregular saccades
min_duration = ceil(Fs/1000*10);
valid(durations < min_duration) = 0; % Saccades shorter than 10 ms are discarded
valid(peak_vals > 1000) = 0; % Saccades higher than 1000 deg/s are not possible

% problem where the saccade offset is not found well
for ind = 2:length(valid)
    if valid(ind) == 0
        continue
    end
    if peak_idxs(ind) < offset_idxs(ind-1) % finding invalid peaks 
        valid(ind) = 0;
    end
end

% filtering valid data
disp(["Excluded number of samples: " num2str(length(find(valid == 0)))])
peak_idxs = peak_idxs(valid == 1);
onset_idxs = onset_idxs(valid == 1);
offset_idxs = offset_idxs(valid == 1);
peak_vals = peak_vals(valid == 1);
onset_vals = onset_vals(valid == 1);
offset_vals = offset_vals(valid == 1);
durations = durations(valid == 1);
gaze_times = onset_idxs(2: end) - offset_idxs(1: end-1); 

durations = durations/Fs*1000;
gaze_times = gaze_times/Fs*1000;

% Visualization
figure
    hold all
            title("Absolute angular velocity")
        plot(t, gaze_vel)
        plot(t(peak_idxs), peak_vals, 'x')
        plot(t(onset_idxs), onset_vals, 'o')
        plot(t(offset_idxs), offset_vals, '*')
            xlabel("Time [s]")
            ylabel("Velocity [\circ/s]")
            legend(["signal", "peaks", "start", "end"])
    hold off;

figure
    hold all
            title("Amplitude of d.v.a.")
        plot(t, gaze_amp)
        plot(t(onset_idxs), gaze_amp(onset_idxs), 'o')
        plot(t(offset_idxs), gaze_amp(offset_idxs), '*')
            xlabel("Time [s]")
            ylabel("Angular velocity [\circ/s]")
            legend(["signal", "start", "end"])
    hold off;
    
% Taking saccades trajectories
sacc_traj = {};
sacc_traj_t = {};

for ind = 1:length(peak_idxs)
    sacc_traj{ind} = gaze_amp(onset_idxs(ind):offset_idxs(ind));
    sacc_traj_t{ind} = t(onset_idxs(ind):offset_idxs(ind));
end
      
%% Calculating statistical parameters
sacc_amplitudes = abs(gaze_amp(onset_idxs)' - gaze_amp(offset_idxs)');

% output
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
