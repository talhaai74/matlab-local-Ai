% TOPIC: interpolation
% TITLE: Cubic spline with natural and not-a-knot end conditions, and piecewise cubic Hermite (pchip)
% SOURCE: Chapra Prob. 18.1
% KEYWORDS: natural spline, not-a-knot, pchip, piecewise cubic hermite interpolation, end conditions, spline
% PROBLEM:
% Given x = 1 2 2.5 3 4 5 and f(x) = 1 5 7 8 2 1, fit these data with (a) a cubic spline with natural
% end conditions, (b) a cubic spline with not-a-knot end conditions and (c) piecewise cubic Hermite
% interpolation. Evaluate each at x = 3.5 and plot.
% CHECK: abs(v(1) - 5.46836) < 1e-4 && abs(v(2) - 5.77551) < 1e-4 && abs(v(3) - 5.21429) < 1e-4
% CODE:
x = [1 2 2.5 3 4 5];
f = [1 5 7 8 2 1];
xi = 3.5;
v = [interp_natspline(x, f, xi), spline(x, f, xi), pchip(x, f, xi)];
fprintf('f(3.5): natural spline = %.5f, not-a-knot spline = %.5f, pchip = %.5f\n', v);
xx = linspace(1, 5, 300);
figure;
plot(x, f, 'ko', xx, interp_natspline(x, f, xx), 'b-', xx, spline(x, f, xx), 'r--', xx, pchip(x, f, xx), 'g:', 'LineWidth', 1.3);
grid on; legend('data', 'natural', 'not-a-knot', 'pchip'); xlabel('x'); ylabel('f(x)');
