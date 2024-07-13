function [y] = FIXED_SQRT(x,V,VA,Ath)

y = VA + V*sqrt(x-Ath);
end

