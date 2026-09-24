% TOPIC: roots
% TITLE: Critical depth in a trapezoidal channel: bisection vs false position
% SOURCE: CE206 slides 02 page 21; Chapra Prob. 5.10
% KEYWORDS: critical depth, trapezoidal channel, bisection, false position, regula falsi, compare methods, flow rate
% PROBLEM:
% Water is flowing in a trapezoidal channel at a rate of Q = 20 m^3/s. The critical
% depth y must satisfy 0 = 1 - Q^2*B/(g*Ac^3), where g = 9.81 m/s^2,
% Ac = 3y + y^2/2 (m^2) and B = 3 + y (m). Solve for the critical depth using both
% bisection and false position with initial guesses 0.5 and 2.5, iterating until the
% approximate error falls below 1% or the number of iterations exceeds 10. Compare.
% CHECK: abs(yb - 1.5078) < 1e-3 && itb == 8 && eab < 1
% CHECK: abs(yf - 2.0908) < 1e-3 && itf == 10
% CHECK: abs(yexact - 1.5141) < 1e-3
% CODE:
Q = 20; g = 9.81;
Ac = @(y) 3*y + y.^2/2;
B  = @(y) 3 + y;
f  = @(y) 1 - Q^2*B(y)./(g*Ac(y).^3);
xl = 0.5; xu = 2.5; es = 1; maxit = 10;
fprintf('f(y) = 1 - Q^2*B/(g*Ac^3), Q = %g m^3/s, Ac = 3y + y^2/2, B = 3 + y\n', Q);

%% Bisection
[yb, fb, eab, itb, tb] = root_bisection(f, xl, xu, es, maxit);
fprintf('\nBisection:\n%5s %10s %10s %10s %10s\n', 'iter', 'xl', 'xu', 'xr', 'ea (%)');
fprintf('%5d %10.5f %10.5f %10.5f %10.4f\n', tb(:, [1 2 3 4 6])');

%% False position
[yf, ff, eaf, itf, tf] = root_falseposition(f, xl, xu, es, maxit);
fprintf('\nFalse position:\n%5s %10s %10s %10s %10s\n', 'iter', 'xl', 'xu', 'xr', 'ea (%)');
fprintf('%5d %10.5f %10.5f %10.5f %10.4f\n', tf(:, [1 2 3 4 6])');

%% Comparison
yexact = fzero(f, [xl xu]);
fprintf('\n%-15s %10s %8s %10s %10s\n', 'Method', 'y (m)', 'iter', 'ea (%)', 'et (%)');
fprintf('%-15s %10.5f %8d %10.4f %10.4f\n', 'Bisection', yb, itb, eab, abs((yexact - yb)/yexact)*100);
fprintf('%-15s %10.5f %8d %10.4f %10.4f\n', 'False position', yf, itf, eaf, abs((yexact - yf)/yexact)*100);
fprintf('fzero: critical depth y = %.6f m\n', yexact);
fprintf(['Bisection meets ea < 1%%; false position does not within 10 iterations: f(y) is strongly\n' ...
    'curved, so the upper guess stays fixed and the false-position estimate creeps down slowly.\n']);
