function [dydx, d2ydx2] = diff_data(x, y)
%DIFF_DATA  First and second derivatives of TABULATED data, O(h^2), any spacing.
%   [dydx, d2ydx2] = diff_data(x, y)
%   x, y    data vectors of the same length (at least 3 points); x may be
%           equally or unequally spaced but must be strictly monotonic
%   dydx    first derivative at every x (same shape as y)
%   d2ydx2  second derivative at every x
%   Each estimate differentiates the 3-point Lagrange polynomial through the
%   point and its neighbours (Chapra Eq. 21.21): centered at interior points,
%   one-sided at the two ends. For equal spacing this is exactly the O(h^2)
%   centered formula inside and the O(h^2) forward/backward formula at the
%   ends. (MATLAB's gradient uses only O(h) formulas at the two ends.)
%   Call without outputs to print a table.
%   Example: [v, a] = diff_data([0 25 50 75 100 125], [0 32 58 78 92 100])
rowOut = isrow(y);
x = x(:); y = y(:);
n = numel(x);
if numel(y) ~= n
    error('ru_lib:diff_data:size', 'diff_data: x and y must have the same length.');
end
if n < 3
    error('ru_lib:diff_data:size', 'diff_data: need at least 3 data points.');
end
dx = diff(x);
if ~(all(dx > 0) || all(dx < 0))
    error('ru_lib:diff_data:x', 'diff_data: x must be strictly increasing or decreasing.');
end
dydx = zeros(n,1);
d2ydx2 = zeros(n,1);
for i = 1:n
    if i == 1
        k = [1 2 3];
    elseif i == n
        k = [n-2 n-1 n];
    else
        k = [i-1 i i+1];
    end
    x0 = x(k(1)); x1 = x(k(2)); x2 = x(k(3));
    f0 = y(k(1)); f1 = y(k(2)); f2 = y(k(3));
    xx = x(i);
    dydx(i) = f0*(2*xx - x1 - x2)/((x0 - x1)*(x0 - x2)) ...
        + f1*(2*xx - x0 - x2)/((x1 - x0)*(x1 - x2)) ...
        + f2*(2*xx - x0 - x1)/((x2 - x0)*(x2 - x1));
    d2ydx2(i) = 2*(f0/((x0 - x1)*(x0 - x2)) + f1/((x1 - x0)*(x1 - x2)) + f2/((x2 - x0)*(x2 - x1)));
end
if rowOut
    dydx = dydx.'; d2ydx2 = d2ydx2.';
end
if nargout == 0
    fprintf('%6s %14s %14s %14s %14s\n', 'i', 'x', 'y', 'dy/dx', 'd2y/dx2');
    for i = 1:n
        fprintf('%6d %14.6g %14.6g %14.6g %14.6g\n', i, x(i), y(i), dydx(i), d2ydx2(i));
    end
end
end
