function dx = central_diff(x,Ts)
% Racuna centralni diferencijal vektora x
% Ulaz
%     x - ulazni 1D vektor
%     Ts - perioda odabiranja
% Izlaz
%     dx - centralni diferencijal

if length(x)==1
    dx = 0;
    return 
end
dx = zeros(1,length(x));
dx_backward = [0 x(1:end-2) 0];
dx_forward = [0 x(3:end) 0 ];
dx = (dx_forward - dx_backward)/(2*Ts);
    

    
end

