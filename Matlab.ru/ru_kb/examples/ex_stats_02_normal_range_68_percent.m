% TOPIC: stats
% TITLE: Descriptive statistics and the mean +/- one standard deviation range (68% check for normality)
% SOURCE: Chapra Prob. 14.3
% KEYWORDS: mean, median, mode, standard deviation, variance, coefficient of variation, normal distribution, 68 percent, one standard deviation, histogram
% PROBLEM:
% Given the data 29.65 28.55 28.65 30.15 29.35 29.75 29.25 30.65 28.15 29.85 29.05 30.25 30.85 28.75
% 29.65 30.45 29.15 30.45 33.65 29.35 29.75 31.25 29.45 30.15 29.65 30.55 29.65 29.25, determine the
% mean, median, mode, range, standard deviation, variance and coefficient of variation. Construct a
% histogram from 28 to 34 in increments of 0.4. Assuming the distribution is normal, compute the range
% that encompasses 68% of the readings and determine whether this is a valid estimate for these data.
% CHECK: abs(mean(y) - 29.832143) < 1e-5 && abs(s - 1.045291) < 1e-5 && abs(frac - 22/28) < 1e-12
% CODE:
y = [29.65 28.55 28.65 30.15 29.35 29.75 29.25 30.65 28.15 29.85 29.05 30.25 30.85 28.75 ...
     29.65 30.45 29.15 30.45 33.65 29.35 29.75 31.25 29.45 30.15 29.65 30.55 29.65 29.25];
m = mean(y); s = std(y);
fprintf('mean = %.4f, median = %.4f, mode = %.2f, range = %.2f\n', m, median(y), mode(y), max(y) - min(y));
fprintf('std = %.4f, variance = %.4f, CV = %.3f %%\n', s, var(y), s/m*100);
lo = m - s; hi = m + s;
frac = mean(y >= lo & y <= hi);
fprintf('68%% range (mean +/- std) = %.4f to %.4f; %.1f %% of the readings fall inside\n', lo, hi, frac*100);
fprintf('%.1f %% is above 68 %% because one outlier (33.65) inflates the standard deviation.\n', frac*100);
edges = 28:0.4:34;
counts = zeros(1, numel(edges) - 1);
for k = 1:numel(counts)
    counts(k) = sum(y >= edges(k) & (y < edges(k+1) | (k == numel(counts) & y <= edges(k+1))));
end
figure; bar(edges(1:end-1) + 0.2, counts, 1); grid on; xlabel('value'); ylabel('Frequency');
