function dx = mc_ode(t,x)

theta0 = [-pi/3 -pi/12 0 pi/12 pi/2];
a = [1.2 -5 30 -7.5 0.75];
b = [0.25 0.1 0.1 0.1 0.4];
z0=0;

theta = atan2(x(2),x(1));
dtheta = mod((theta - theta0),2*pi);
z =  sum(a.*dtheta.*exp(-dtheta.^2./(2*b.^2))) -x(3);


alpha = 1- (x(1).^2+x(2).^2)^0.5;
w = (2*pi)/10;
dx=[alpha*x(1)-w*x(2)+rand()*0.1; alpha*x(2)+w*x(1)+rand()*0.1; z];
%dx = [-w*x(2); w*x(1); x(3)];


end

