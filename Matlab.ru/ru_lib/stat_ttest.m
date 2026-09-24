function [h, p, ci, stats] = stat_ttest(x, mu0, alpha, tail)
%STAT_TTEST  One-sample Student's t-test (like Statistics Toolbox ttest).
%   [h, p, ci, stats] = stat_ttest(x, mu0, alpha, tail)
%   x       data vector; mu0 hypothesized mean (default 0)
%   alpha   significance level (default 0.05)
%   tail    'both' (default, Ha: mu ~= mu0), 'right' (Ha: mu > mu0),
%           'left' (Ha: mu < mu0)
%   h       1 if H0 is rejected at level alpha, else 0
%   p       p-value; ci = confidence interval for the mean at level 1-alpha
%   stats   struct with tstat, df, sd (sample standard deviation)
%   Example: [h,p,ci,stats] = stat_ttest([151 152 148 150 155], 150)

if nargin < 1
    error('ru_lib:stat_ttest:nargin', 'STAT_TTEST: need a data vector x.');
end
if nargin < 2 || isempty(mu0), mu0 = 0; end
if nargin < 3 || isempty(alpha), alpha = 0.05; end
if nargin < 4 || isempty(tail), tail = 'both'; end
tail = lower(char(tail));
x = x(:);
n = length(x);
if n < 2
    error('ru_lib:stat_ttest:n', 'STAT_TTEST: need at least 2 data points (got %d).', n);
end
xbar = mean(x);
s = std(x);
se = s/sqrt(n);
tstat = (xbar - mu0)/se;
df = n - 1;
switch tail
    case 'both'
        p = 2*(1 - stat_tcdf(abs(tstat), df));
        tcrit = stat_tinv(1 - alpha/2, df);
        ci = [xbar - tcrit*se, xbar + tcrit*se];
    case 'right'
        p = 1 - stat_tcdf(tstat, df);
        tcrit = stat_tinv(1 - alpha, df);
        ci = [xbar - tcrit*se, Inf];
    case 'left'
        p = stat_tcdf(tstat, df);
        tcrit = stat_tinv(1 - alpha, df);
        ci = [-Inf, xbar + tcrit*se];
    otherwise
        error('ru_lib:stat_ttest:tail', 'STAT_TTEST: tail must be ''both'', ''right'' or ''left'' (got ''%s'').', tail);
end
h = double(p < alpha);
stats = struct('tstat', tstat, 'df', df, 'sd', s);
end
