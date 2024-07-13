function [y] = EXPONENTIAL(x,V, A0, k)

y = V*(1-exp(-(x-A0)/k));
end

