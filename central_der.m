function dx = central_der(x,Ts)
% Computes the central derivative of the vector x.
% INPUT:
%     x - input 1D vector
%     Ts - sampling period
% OUTPUT:
%     dx - central difference
if length(x)==1
    dx = 0;
    return 
end
dx = zeros(1,length(x));
dx_backward = [0 x(1:end-2) 0];
dx_forward = [0 x(3:end) 0 ];
dx = (dx_forward - dx_backward)/(2*Ts);
       
end
