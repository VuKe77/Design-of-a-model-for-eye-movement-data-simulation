function [y] = EXPONENTIAL(x,V, A0, k)
% EXPONENTIAL model
y = V*(1-exp(-(x-A0)/k));
end
