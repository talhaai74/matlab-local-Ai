function [lo, hi, margin, xbar] = stat_ci_mean(x, conf)
%STAT_CI_MEAN  Confidence interval for a sample mean (t-based).
%   [lo, hi, margin, xbar] = stat_ci_mean(x, conf)
%   x       data vector (or matrix; each column is a separate sample)
%   conf    confidence level, e.g. 0.95 for 95% (default 0.95)
%   lo, hi  interval [lo, hi]; margin = t*(s/sqrt(n)); xbar = mean(x)
%   Uses t = stat_tinv(1 - (1-conf)/2, n-1)  (two-sided)
%   Call without outputs to print the result.
%   Example: [lo,hi] = stat_ci_mean([12 15 11 19 14 15], 0.95)

if nargin < 1
    error('ru_lib:stat_ci_mean:nargin', 'STAT_CI_MEAN: need a data vector x.');
end
if nargin < 2 || isempty(conf), conf = 0.95; end
if conf <= 0 || conf >= 1
    error('ru_lib:stat_ci_mean:conf', 'STAT_CI_MEAN: conf must be in (0,1) (got %g).', conf);
end
if isvector(x), x = x(:); end
n = size(x,1);
if n < 2
    error('ru_lib:stat_ci_mean:n', 'STAT_CI_MEAN: need at least 2 data points (got %d).', n);
end
xbar = mean(x,1);
s = std(x,0,1);
alpha = 1 - conf;
tcrit = stat_tinv(1 - alpha/2, n-1);
margin = tcrit .* s ./ sqrt(n);
lo = xbar - margin;
hi = xbar + margin;
if nargout == 0
    for j = 1:numel(xbar)
        fprintf('mean = %.4f  %.0f%% CI = [%.4f, %.4f]  (margin = %.4f)\n', ...
            xbar(j), conf*100, lo(j), hi(j), margin(j));
    end
end
end
