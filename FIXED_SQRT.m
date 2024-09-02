function [y] = FIXED_SQRT(x,V,VA,Ath)
%FIXED_SQRT model
y = VA + V*sqrt(x-Ath);
end

