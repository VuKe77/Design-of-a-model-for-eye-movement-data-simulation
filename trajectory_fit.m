function [y,t,A] = trajectory_fit(Vmax,td,E0,Emax,Fs,tstart)
% Modeling saccade trajectory using Hill's equation.
% Input:
%     Vmax - maximum saccade velocity [deg/s]
%     td - saccade duration [s]
%     E0 - initial saccade amplitude [deg]
%     Emax - final saccade amplitude [deg]
%     Fs - sampling frequency [Hz]
%     tstart - initial time of the saccade
% Output:
%     y - modeled saccade amplitude trajectory
%     t - corresponding time axis
%     A - total saccade amplitude (difference between the initial and final amplitudes after the modeling process)

% NOTE: It is necessary to have the main sequence models and probability density functions of saccade parameters in the same file: 'ampPDF.mat', 'gazePDF.mat', 'modelDuration.mat', 'modelPeak.mat'.



%algorithm initialization
dE = Emax - E0;
t = 0:0.001:td-0.001; 
y2 = [];
E50s = [];
as = [];
%numerical algorithm
for a=1:0.01:10
    as = [as a];
    a1 = a*((a-1)/(a+1))^((a-1)/a);
    a2 = (a-1)/(a+1);
    E50 = dE*a1/(Vmax*(1+a2)^2);
    E50s = [E50s E50];
    y = dE*td^a/(E50^a+td^a);
    y2 = [y2 y]; 
end






[val,index] =min(abs(y2-dE));

E50 = E50s(index);
a = as(index);
y = real(E0+ dE.*t.^a./(E50.^a+t.^a));
a1 = a*((a-1)/(a+1))^((a-1)/a);
a2 = (a-1)/(a+1);
ymax = (Emax-E0)*a1/(1+a2)^2/E50;

y1 = central_der(y,1/Fs);

%Fix discontinuity of y1
if  y1(end)>=0 && length(y)>1
    %take last 1/4th of signal and perform spline
    idx = length(y1) - round(length(y1)/10);
    n = length(y) - idx;
    xs = [t(idx) td];
    ys = [y1(idx) 0];
    xx = t(idx+1:end);
    yy = spline(xs,ys,xx);
    y1(idx+1:end) = yy;
    
    % Initialize recovered function with the initial value
    y = zeros(size(y1));
    y(1) = E0;  % Assume the initial value is known

    % Cumulatively sum the derivative to recover the function values
    for i = 2:length(y)
        y(i) = y(i-1) + y1(i)*(1/Fs);
    end
end
%resampling
y = y(1:round(1000/Fs):end);
t =t(1:round(1000/Fs):end);
A = y(end);

%Adjust time vector
switch nargin
    case 6
        t = t+tstart;



end

