% TOPIC: regression
% TITLE: Linear regression with standard error and correlation coefficient; regress x on y
% SOURCE: Chapra Prob. 14.5
% KEYWORDS: least-squares straight line, slope, intercept, standard error of the estimate, correlation coefficient, regress x versus y, switch the variables
% PROBLEM:
% Use least-squares regression to fit a straight line to
% x = 0 2 4 6 9 11 12 15 17 19, y = 5 6 7 6 9 8 8 10 12 12.
% Along with the slope and intercept compute the standard error of the estimate and the
% correlation coefficient. Plot the data and the regression line. Then repeat the problem but
% regress x versus y (switch the variables) and interpret the result.
% CHECK: abs(a(1) - 0.359146) < 1e-5 && abs(a(2) - 4.888117) < 1e-5
% CHECK: abs(syx - 0.851097) < 1e-5 && abs(r - 0.944926) < 1e-5
% CODE:
x = [0 2 4 6 9 11 12 15 17 19];
y = [5 6 7 6 9 8 8 10 12 12];
[a, r2, syx] = fit_linear(x, y);
r = sqrt(r2);
fprintf('y = %.5f x + %.5f,  syx = %.5f,  r = %.5f,  r^2 = %.5f\n', a(1), a(2), syx, r, r2);
[b, r2b, sxy] = fit_linear(y, x);
fprintf('x = %.5f y %+.5f  ->  y = %.5f x %+.5f (r^2 = %.5f)\n', b(1), b(2), 1/b(1), -b(2)/b(1), r2b);
fprintf(['The two lines differ: y-on-x minimizes vertical errors, x-on-y horizontal errors;\n' ...
    'r^2 is the same (%.5f) because correlation is symmetric.\n'], r2);
xx = linspace(0, 20, 100);
figure;
plot(x, y, 'ko', xx, a(1)*xx + a(2), 'b-', xx, (xx - b(2))/b(1), 'r--');
grid on; xlabel('x'); ylabel('y'); legend('data', 'y vs x', 'x vs y', 'Location', 'northwest');
