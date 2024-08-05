clc
close all
clear all

%%
t = 0:0.1:100;
x0 = [1;1;1];


[t,x] = ode45('mc_ode',t,x0);


figure
    hold on;
    %plot(t,x(:,1))
    %plot(t,x(:,2))
    plot(t,x(:,3))
    
    hold off;
%%

