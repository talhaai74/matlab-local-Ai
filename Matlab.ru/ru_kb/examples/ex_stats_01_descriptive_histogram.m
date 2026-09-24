% TOPIC: stats
% TITLE: Descriptive statistics (mean, median, mode, range, std, variance, CV) and a histogram with given bins
% SOURCE: Chapra Probs. 14.1 and 14.2; CE206 slides 09 pages 3-13
% KEYWORDS: mean, median, mode, range, standard deviation, variance, coefficient of variation, histogram, bins, range 0.8 to 2.4, interval 0.2, descriptive statistics
% PROBLEM:
% Given the data 0.90 1.42 1.30 1.55 1.63 1.32 1.35 1.47 1.95 1.66 1.96 1.47 1.92 1.35 1.05 1.85 1.74
% 1.65 1.78 1.71 2.29 1.82 2.06 2.14 1.27, determine (a) the mean, (b) median, (c) mode, (d) range,
% (e) standard deviation, (f) variance and (g) coefficient of variation. Construct a histogram using a
% range from 0.8 to 2.4 with intervals of 0.2.
% CHECK: abs(mean(y) - 1.6244) < 1e-9 && abs(median(y) - 1.65) < 1e-12 && mode(y) == 1.35
% CHECK: abs(std(y) - 0.339388) < 1e-6 && abs(cv - 20.8931) < 1e-4 && isequal(counts, [1 1 5 4 6 5 2 1])
% CODE:
y = [0.90 1.42 1.30 1.55 1.63 1.32 1.35 1.47 1.95 1.66 1.96 1.47 1.92 1.35 1.05 1.85 1.74 ...
     1.65 1.78 1.71 2.29 1.82 2.06 2.14 1.27];
cv = std(y)/mean(y)*100;
fprintf('n = %d\n(a) mean = %.4f\n(b) median = %.4f\n(c) mode = %.2f (smallest of the most frequent values)\n', ...
    numel(y), mean(y), median(y), mode(y));
fprintf('(d) range = %.2f\n(e) standard deviation = %.4f\n(f) variance = %.4f\n(g) CV = %.2f %%\n', ...
    max(y) - min(y), std(y), var(y), cv);
edges = 0.8:0.2:2.4;
counts = zeros(1, numel(edges) - 1);
for k = 1:numel(counts)
    if k < numel(counts)
        counts(k) = sum(y >= edges(k) & y < edges(k+1));
    else
        counts(k) = sum(y >= edges(k) & y <= edges(k+1));      % last bin includes 2.4
    end
end
fprintf('%12s %8s\n', 'bin', 'count');
for k = 1:numel(counts)
    fprintf('%5.1f-%-5.1f %8d\n', edges(k), edges(k+1), counts(k));
end
figure; bar(edges(1:end-1) + 0.1, counts, 1); grid on; xlabel('value'); ylabel('Frequency'); title('Histogram');
