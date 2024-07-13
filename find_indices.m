function idxs = find_indices(x,y)
%find indices of values in y that most closly coresond to values in x

idxs = [];
for i=1:length(x)
    [val,idx] = min(abs(y-x(i)));
    idxs = [idxs idx];
end

end

