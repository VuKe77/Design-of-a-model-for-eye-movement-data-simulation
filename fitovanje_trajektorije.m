function [y,t] = fitovanje_trajketorije(Vmax,td,E0,Emax,tstart)
%Racunanje trajektorije sakade y na osnovu parametara
%E0, Emax, td, Vmax.
Ts=0.001;
% if Emax < E0
%     temp = Emax;
%     Emax = E0;
%     E0 = temp;
% end


dE = Emax - E0;
%inicilajizacija
t = 0:Ts:td+0.1; %dodajemo 100ms na trajanje sakade
y2 = [];
E50s = [];
as = [];
%algoritam numericki
for a=1:0.001:10
    as = [as a];
    a1 = a*((a-1)/(a+1))^((a-1)/a);
    a2 = (a-1)/(a+1);
    E50 = dE*a1/(Vmax*(1+a2)^2);
    E50s = [E50s E50];
    y = dE*td^a/(E50^a+td^a);
    y2 = [y2 y]; 
end






[val,index] =min(abs(y2-1*dE));

E50 = E50s(index);
a = as(index);
y = real(E0+ dE.*t.^a./(E50.^a+t.^a));
a1 = a*((a-1)/(a+1))^((a-1)/a);
a2 = (a-1)/(a+1);
ymax = (Emax-E0)*a1/(1+a2)^2/E50;

switch nargin
    case 5
        t = t+tstart;
        


end

