% TOPIC: regression
% TITLE: Cubic polynomial regression with r^2 and standard error
% SOURCE: Chapra Prob. 15.3
% KEYWORDS: polynomial regression, cubic polynomial, third order, polyfit, polyval, r2, standard error syx
% PROBLEM:
% Fit a cubic polynomial to x = 3 4 5 7 8 9 11 12, y = 1.6 3.6 4.4 3.4 2.2 2.8 3.8 4.6.
% Along with the coefficients, determine r^2 and sy/x, and plot the fit.
% CHECK: abs(r2 - 0.8290) < 1e-3 && abs(syx - 0.5700) < 1e-3
% CODE:
x = [3 4 5 7 8 9 11 12];
y = [1.6 3.6 4.4 3.4 2.2 2.8 3.8 4.6];
[p, r2, syx] = fit_poly(x, y, 3);
fprintf('y = %.5f x^3 %+.5f x^2 %+.5f x %+.5f\n', p);
fprintf('r^2 = %.4f, sy/x = %.4f\n', r2, syx);
xx = linspace(3, 12, 200);
figure; plot(x, y, 'ko', xx, polyval(p, xx), 'b-'); grid on; xlabel('x'); ylabel('y'); legend('data', 'cubic fit');
