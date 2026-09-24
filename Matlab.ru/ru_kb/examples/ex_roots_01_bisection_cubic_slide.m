% TOPIC: roots
% TITLE: Bisection method: root of x^3 - 10x^2 + 5 between 0.6 and 0.8
% SOURCE: CE206 slides 02 (Roots of Equations), pages 4-7
% KEYWORDS: bisection, bisect, bracketing method, iteration table, approximate relative error, fzero check
% PROBLEM:
% Use the bisection method to find the root of f(x) = x^3 - 10x^2 + 5 between
% x = 0.6 and x = 0.8 with a stopping criterion es = 0.0001 %. Report the root,
% f(root), the approximate relative error and the number of iterations, and
% print the iteration table.
% CHECK: abs(root - 0.7346) < 1e-4 && iter == 19
% CHECK: abs(f(root)) < 1e-3
% CODE:
f = @(x) x.^3 - 10*x.^2 + 5;
xl = 0.6; xu = 0.8; es = 0.0001; maxit = 50;

[root, fx, ea, iter, tab] = root_bisection(f, xl, xu, es, maxit);
fprintf('%5s %10s %10s %10s %12s %12s\n', 'iter', 'xl', 'xu', 'xr', 'f(xr)', 'ea (%)');
fprintf('%5d %10.6f %10.6f %10.6f %12.4e %12.4e\n', tab');
fprintf('Root = %.6f\nf(root) = %.4e\nea = %.4e %%\niterations = %d\n', root, fx, ea, iter);
fprintf('Check with fzero: root = %.6f\n', fzero(f, [xl xu]));
