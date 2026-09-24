function [counts, centers] = stat_hist(x, nbins)
%STAT_HIST  Histogram bin counts and bin centers (like [n,x] = hist(data,nbins)).
%   [counts, centers] = stat_hist(x, nbins)
%   x        data vector
%   nbins    number of equal-width bins spanning [min(x), max(x)] (default 10)
%   counts   1-by-nbins bin counts; centers = 1-by-nbins bin center locations
%   No plot is produced; use MATLAB's built-in hist(x,nbins) to plot.
%   Example: [n,c] = stat_hist([1 2 2 3 3 3 4 5], 5)

if nargin < 1
    error('ru_lib:stat_hist:nargin', 'STAT_HIST: need a data vector x.');
end
if nargin < 2 || isempty(nbins), nbins = 10; end
x = x(:);
x = x(~isnan(x));
if isempty(x)
    error('ru_lib:stat_hist:empty', 'STAT_HIST: x has no data.');
end
lo = min(x); hi = max(x);
if lo == hi
    lo = lo - floor(nbins/2) - 0.5;
    hi = hi + ceil(nbins/2) - 0.5;
end
binwidth = (hi - lo)/nbins;
edges = lo + binwidth*(0:nbins);
centers = lo + binwidth*((1:nbins) - 0.5);
counts = zeros(1, nbins);
for k = 1:nbins
    if k < nbins
        counts(k) = sum(x >= edges(k) & x < edges(k+1));
    else
        counts(k) = sum(x >= edges(k) & x <= edges(k+1));
    end
end
end
