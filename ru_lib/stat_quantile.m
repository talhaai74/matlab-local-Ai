function q = stat_quantile(x, p)
%STAT_QUANTILE  Sample quantiles (Statistics Toolbox quantile convention).
%   q = stat_quantile(x, p)
%   x   data vector or matrix (quantiles taken per column; vector = one column)
%   p   probabilities in [0,1] (fractions, NOT percent), scalar or vector
%   q   length(p)-by-1 for vector x; length(p)-by-ncols(x) for matrix x
%   Sorted data placed at cumulative prob (i-0.5)/n; linear interpolation
%   between points; clamped to min/max outside the first/last point.
%   Example: q = stat_quantile([2 4 6 8 10], [0.25 0.5 0.75])

if nargin < 2
    error('ru_lib:stat_quantile:nargin', 'STAT_QUANTILE: need x and p (probabilities in [0,1]).');
end
if isvector(x)
    x = x(:);
end
p = p(:);
if any(p < 0) || any(p > 1)
    error('ru_lib:stat_quantile:prange', 'STAT_QUANTILE: probabilities p must be in [0,1] (use fractions, not percent).');
end
[n, ncols] = size(x);
if n < 1
    error('ru_lib:stat_quantile:empty', 'STAT_QUANTILE: x has no data.');
end
xs = sort(x,1);
pos = ((1:n)' - 0.5) / n;
q = zeros(length(p), ncols);
for j = 1:ncols
    if n < 2
        q(:,j) = xs(1,j);
        continue
    end
    qj = interp1(pos, xs(:,j), p, 'linear');
    qj(p <= pos(1))   = xs(1,j);
    qj(p >= pos(end)) = xs(end,j);
    q(:,j) = qj;
end
end
