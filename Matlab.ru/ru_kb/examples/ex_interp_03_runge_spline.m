% TOPIC: interpolation
% TITLE: Runge's function: 9 equidistant points, spline versus the exact function (and polynomial)
% SOURCE: CE206 slides 04 page 20; Chapra Prob. 18.11
% KEYWORDS: runge function, spline, not-a-knot, equidistant points, oscillation, polynomial interpolation, piecewise interpolation
% PROBLEM:
% Interpolate Runge's function f(x) = 1/(1 + 25x^2) taking 9 equidistant points between -1 and +1
% using the spline command, and compare with the exact function (and the 8th-order polynomial) on a plot.
% CHECK: abs(errS - 0.05615) < 1e-3
% CODE:
f = @(x) 1./(1 + 25*x.^2);
x = linspace(-1, 1, 9);
y = f(x);
xx = linspace(-1, 1, 1001);
ys = spline(x, y, xx);
yp = polyval(polyfit(x, y, 8), xx);
errS = max(abs(ys - f(xx)));
fprintf('Max error: spline = %.5f, 8th-order polynomial = %.5f\n', errS, max(abs(yp - f(xx))));
figure;
plot(x, y, 'o', xx, ys, '-', xx, f(xx), '--', xx, yp, ':', 'LineWidth', 1.2); grid on;
legend('data', 'spline', 'Runge function', '8th-order polynomial'); xlabel('x'); ylabel('f(x)');
