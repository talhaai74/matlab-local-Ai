% TOPIC: regression
% TITLE: Multiple linear regression y = a0 + a1 x1 + a2 x2 with standard error and correlation
% SOURCE: Chapra Prob. 15.8
% KEYWORDS: multiple linear regression, two independent variables, coefficients, standard error of the estimate, correlation coefficient
% PROBLEM:
% Use multiple linear regression to fit
% x1 = 0 1 1 2 2 3 3 4 4, x2 = 0 1 2 1 2 1 2 1 2, y = 15.1 17.9 12.7 25.6 20.5 35.1 29.7 45.4 40.2.
% Compute the coefficients, the standard error of the estimate and the correlation coefficient.
% CHECK: norm(a' - [14.4609 9.0252 -5.7043]) < 1e-3
% CODE:
x1 = [0 1 1 2 2 3 3 4 4]';
x2 = [0 1 2 1 2 1 2 1 2]';
y  = [15.1 17.9 12.7 25.6 20.5 35.1 29.7 45.4 40.2]';
[a, r2, syx] = fit_multilinear([x1 x2], y);
fprintf('y = %.4f %+.4f x1 %+.4f x2\n', a);
fprintf('syx = %.4f, r = %.4f (r^2 = %.4f)\n', syx, sqrt(r2), r2);
Z = [ones(size(x1)) x1 x2];
fprintf('Check with backslash: %s\n', mat2str((Z\y)', 6));
