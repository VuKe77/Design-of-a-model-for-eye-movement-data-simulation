function [mean_x,std_x] = hist_normal(x,title)
max_x = max(x);
min_x = min(x);
x_mean = mean(x);
x_std = std(durations);
x = [min_x:0.001:max_x];
duration_normal = normpdf(x,x_mean,x_std);
figure
    hold on;
    title(["Histogram" title "sakada: \mu: " num2str(x_mean,2) "\, sigma: " num2str(x_std,2)])
    histogram(durations,25,'Normalization','pdf')
    plot(x,duration_normal)
    hold off;
end

