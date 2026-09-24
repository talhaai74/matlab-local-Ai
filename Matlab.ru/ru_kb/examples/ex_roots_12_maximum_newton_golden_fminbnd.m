% TOPIC: roots
% TITLE: Maximum of a function: Newton-Raphson on f'(x) = 0, golden section and fminbnd
% SOURCE: Chapra Prob. 6.28
% KEYWORDS: maximum, optimum, derivative equal zero, newton-raphson, golden section, fminbnd, approximate relative error below 5%
% PROBLEM:
% Given f(x) = -2x^6 - 1.5x^4 + 10x + 2, use a root-location technique to determine the maximum of
% this function. Perform iterations until the approximate relative error falls below 5%. If you
% use Newton-Raphson, use an initial guess of x = 1. Confirm with golden-section search and fminbnd.
% CHECK: abs(xmax - 0.8714) < 0.005 && ea < 5
% CHECK: abs(xg - xb) < 1e-4
% CODE:
f   = @(x) -2*x.^6 - 1.5*x.^4 + 10*x + 2;
df  = @(x) -12*x.^5 - 6*x.^3 + 10;           % f'(x) = 0 at the maximum
d2f = @(x) -60*x.^4 - 18*x.^2;               % f''(x) < 0 there
[xmax, ~, ea, iter, tab] = root_newton(df, d2f, 1, 5, 50);
fprintf('%5s %12s %12s %12s %10s\n', 'iter', 'x', 'f''(x)', 'f''''(x)', 'ea (%)');
fprintf('%5d %12.6f %12.6f %12.6f %10.4f\n', tab');
fprintf('Newton-Raphson: x = %.4f, f(x) = %.4f (ea = %.3f %% < 5 %%, f'''' = %.2f < 0 -> maximum)\n', ...
    xmax, f(xmax), ea, d2f(xmax));
xg = opt_golden(@(x) -f(x), 0, 1, 1e-6);    % maximum of f = minimum of -f
xb = fminbnd(@(x) -f(x), 0, 1);
fprintf('Golden section: x = %.6f, fminbnd: x = %.6f, f max = %.6f\n', xg, xb, f(xb));
