% TOPIC: regression
% TITLE: Nonlinear regression of a power model with fminsearch (untransformed data)
% SOURCE: CE206 slides 04 pages 15-17 (fSSR)
% KEYWORDS: nonlinear regression, fminsearch, sum of squares of residuals, fssr, power model, untransformed, compare with transformed fit
% PROBLEM:
% For the wind tunnel data (v = 10:10:80 m/s, F = 25 70 380 550 610 1220 830 1450 N), determine
% the coefficients of F = a1*v^a2 by minimizing the sum of the squares of the residuals with
% fminsearch (initial guess a = [1, 1]). Compare with the log-transformed fit F = 0.2741 v^1.9842
% on a plot.
% CHECK: norm(a - [2.5384 1.4359]) < 2e-3
% CODE:
v = 10:10:80;
F = [25 70 380 550 610 1220 830 1450];
SSR = @(a) sum((F - a(1)*v.^a(2)).^2);
a = fminsearch(SSR, [1 1]);
fprintf('Nonlinear fit: F = %.4f v^%.4f, SSR = %.2f\n', a(1), a(2), SSR(a));
fprintf('Transformed fit: F = 0.2741 v^1.9842, SSR = %.2f\n', SSR([0.2741 1.9842]));
vv = linspace(0, 80, 200);
figure;
plot(v, F, 'ko', vv, a(1)*vv.^a(2), 'b-', vv, 0.2741*vv.^1.9842, 'r--', 'LineWidth', 1.5);
grid on; xlabel('v (m/s)'); ylabel('F (N)'); legend('data', 'untransformed (fminsearch)', 'transformed');
