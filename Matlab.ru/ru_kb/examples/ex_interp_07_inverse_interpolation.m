% TOPIC: interpolation
% TITLE: Inverse interpolation: cubic polynomial and bisection to find x where f(x) = 1.7
% SOURCE: Chapra Prob. 17.8
% KEYWORDS: inverse interpolation, cubic interpolating polynomial, bisection, find x for a given f(x)
% PROBLEM:
% Employ inverse interpolation using a cubic interpolating polynomial and bisection to determine the
% value of x that corresponds to f(x) = 1.7 for the data x = 1 2 3 4 5 6 7,
% f(x) = 3.6 1.8 1.2 0.9 0.72 1.5 0.51429.
% CHECK: abs(xr - 2.100910) < 1e-5
% CODE:
x = 1:7;
f = [3.6 1.8 1.2 0.9 0.72 1.5 0.51429];
target = 1.7;
idx = 1:4;                                   % f = 1.7 lies between x = 2 and 3; use 4 nearby points
p = polyfit(x(idx), f(idx), 3);
g = @(xx) polyval(p, xx) - target;
xr = root_bisection(g, 2, 3, 1e-8, 100);
fprintf('Cubic through x = %s: p(x) = %s\n', mat2str(x(idx)), mat2str(p, 6));
fprintf('f(x) = %.1f at x = %.6f (check p(x) = %.6f)\n', target, xr, polyval(p, xr));
