function [h, p, ci, stats] = stat_ttest2(x1, x2, alpha, tail)
%STAT_TTEST2  Two-sample pooled-variance t-test (like Statistics Toolbox ttest2).
%   [h, p, ci, stats] = stat_ttest2(x1, x2, alpha, tail)
%   x1, x2  independent sample data vectors
%   alpha   significance level (default 0.05)
%   tail    'both' (default, Ha: mu1 ~= mu2), 'right' (Ha: mu1 > mu2),
%           'left' (Ha: mu1 < mu2)
%   h       1 if H0: mu1 = mu2 is rejected at level alpha, else 0
%   p       p-value; ci = CI for (mean(x1)-mean(x2)) at level 1-alpha
%   stats   struct with tstat, df = n1+n2-2, sd (pooled standard deviation)
%   Example: [h,p,ci,stats] = stat_ttest2([1 2 3 4], [3 4 5 6])

if nargin < 2
    error('ru_lib:stat_ttest2:nargin', 'STAT_TTEST2: need two data vectors x1, x2.');
end
if nargin < 3 || isempty(alpha), alpha = 0.05; end
if nargin < 4 || isempty(tail), tail = 'both'; end
tail = lower(char(tail));
x1 = x1(:); x2 = x2(:);
n1 = length(x1); n2 = length(x2);
if n1 < 2 || n2 < 2
    error('ru_lib:stat_ttest2:n', 'STAT_TTEST2: each sample needs at least 2 points (got %d, %d).', n1, n2);
end
xbar1 = mean(x1); xbar2 = mean(x2);
s1 = std(x1); s2 = std(x2);
df = n1 + n2 - 2;
sp2 = ((n1-1)*s1^2 + (n2-1)*s2^2)/df;
sd = sqrt(sp2);
se = sqrt(sp2*(1/n1 + 1/n2));
diffm = xbar1 - xbar2;
tstat = diffm/se;
switch tail
    case 'both'
        p = 2*(1 - stat_tcdf(abs(tstat), df));
        tcrit = stat_tinv(1 - alpha/2, df);
        ci = [diffm - tcrit*se, diffm + tcrit*se];
    case 'right'
        p = 1 - stat_tcdf(tstat, df);
        tcrit = stat_tinv(1 - alpha, df);
        ci = [diffm - tcrit*se, Inf];
    case 'left'
        p = stat_tcdf(tstat, df);
        tcrit = stat_tinv(1 - alpha, df);
        ci = [-Inf, diffm + tcrit*se];
    otherwise
        error('ru_lib:stat_ttest2:tail', 'STAT_TTEST2: tail must be ''both'', ''right'' or ''left'' (got ''%s'').', tail);
end
h = double(p < alpha);
stats = struct('tstat', tstat, 'df', df, 'sd', sd);
end
