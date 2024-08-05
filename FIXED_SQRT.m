function [y] = FIXED_SQRT(x,V,VA,Ath)
%FIXED_SQRT funckija
y = VA + V*sqrt(x-Ath);
end

