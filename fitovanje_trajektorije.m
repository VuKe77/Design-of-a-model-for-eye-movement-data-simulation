function [y,t,A] = fitovanje_trajketorije(Vmax,td,E0,Emax,Fs,tstart)
%Modelovanje trajektorije sakade Hilovom jednacinom. 
% Ulaz:
%     Vmax - maksimalna brina sakade [deg/s]
%     td - trajanje sakade [s]
%     E0 - pocetna amplituda sakade [deg]
%     Emax - krajnja amplituda sakade [deg]
%     Fs - perioda odabiranja[Hz]
%     tstart - pocetan trenutak sakade
% Izlaz:
%     y - modelovana trajektorija amplitude sakade
%     t - odgovarajuca vremenska osa
%     A - ukupna amplituda sakade(razlika izmedju pocetne i krajnje nakon 
%     procesa modelovanja

%NAPOMENA:Neophodno je da se u istom faju nalaze modeli glavnih sekvenci i
%funkcije gustina verovatnoce parametara sakada: 'ampPDF.mat','gazePDF.mat',
%'modelDuration.mat', 'modelPeak.mat'.



%inicilajizacija algoritma
dE = Emax - E0;
t = 0:0.001:td-0.001; %dodajemo 100ms na trajanje sakade
y2 = [];
E50s = [];
as = [];
%algoritam numericki
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

% figure
%     plot(abs(y2-dE))
%     xlabel("Iteracija[n]")
%     ylabel("Greška[deg]")
%     title("Prikaz vrednosti greške kroz iteracije algoritma")



y1 = central_diff(y,1/Fs);

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
        y(i) = y(i-1) + y1(i-1)*(1/Fs);
    end
end
A = y(end);
%resampling
y = y(1:round(1000/Fs):end);

switch nargin
    case 6
        t = t+tstart;
        


end

