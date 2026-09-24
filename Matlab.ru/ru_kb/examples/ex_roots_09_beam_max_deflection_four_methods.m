% TOPIC: roots
% TITLE: Point of maximum deflection of a beam (dy/dx = 0) by bisection, regula falsi, Newton-Raphson and secant
% SOURCE: CE206 slides 02 page 22 (Assignment); Chapra Prob. 5.13
% KEYWORDS: maximum deflection, elastic curve, linearly increasing load, dy/dx = 0, bisection, regula falsi, newton-raphson, secant, compare methods, student number
% PROBLEM:
% A uniform beam is subjected to a linearly increasing distributed load. The elastic curve is
% y = w0/(120*E*I*L)*(-x^5 + 2L^2 x^3 - L^4 x). Use Bisection, Regula Falsi, Newton-Raphson and
% Secant methods to determine the point of maximum deflection (the value of x where dy/dx = 0)
% and the maximum deflection. Compare x, the maximum deflection and the errors of these methods.
% L = 600 cm, E = 50,000 kN/cm^2, I = 30,000 cm^4 and w0 = 2.5 kN/cm.
% CHECK: abs(xs(1) - 268.3282) < 1e-3 && all(abs(xs - 268.3282) < 1e-3)
% CHECK: abs(ymax - (-0.5152)) < 1e-3
% CODE:
L = 600; E = 50000; I = 30000; w0 = 2.5;        % cm, kN/cm^2, cm^4, kN/cm
% For a student-number version: L = 6*r cm, E = 50000 + 10000*p kN/cm^2.
c  = w0/(120*E*I*L);
y  = @(x) c*(-x.^5 + 2*L^2*x.^3 - L^4*x);
dy = @(x) c*(-5*x.^4 + 6*L^2*x.^2 - L^4);        % dy/dx
d2y = @(x) c*(-20*x.^3 + 12*L^2*x);               % d2y/dx2 for Newton-Raphson
fprintf('y = w0/(120EIL)(-x^5 + 2L^2x^3 - L^4x), solve dy/dx = 0 on 0 < x < L\n');

es = 1e-6; maxit = 100;
% dy/dx is also 0 at x = L (the fixed end), so bracket away from it: [0, 400].
[x1, ~, e1, i1] = root_bisection(dy, 0, 400, es, maxit);
[x2, ~, e2, i2] = root_falseposition(dy, 0, 400, es, maxit);
[x3, ~, e3, i3] = root_newton(dy, d2y, 250, es, maxit);
[x4, ~, e4, i4] = root_secant(dy, 200, 300, es, maxit);
xs = [x1 x2 x3 x4];
names = {'Bisection', 'Regula falsi', 'Newton-Raphson', 'Secant'};
iters = [i1 i2 i3 i4]; eas = [e1 e2 e3 e4];
xtrue = L/sqrt(5);                               % analytical: x^2 = L^2/5
fprintf('\n%-15s %12s %14s %6s %12s %12s\n', 'Method', 'x (cm)', 'y max (cm)', 'iter', 'ea (%)', 'et (%)');
for k = 1:4
    fprintf('%-15s %12.4f %14.6f %6d %12.2e %12.2e\n', names{k}, xs(k), y(xs(k)), iters(k), eas(k), ...
        abs((xtrue - xs(k))/xtrue)*100);
end
ymax = y(x3);
fprintf('\nMaximum deflection = %.4f cm at x = %.4f cm (analytical x = L/sqrt(5) = %.4f cm)\n', ymax, x3, xtrue);
