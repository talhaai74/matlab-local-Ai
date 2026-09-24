% TOPIC: integration
% TITLE: Error function erf(1.5) by two- and three-point Gauss-Legendre quadrature
% SOURCE: Chapra Prob. 20.4
% KEYWORDS: gauss quadrature, gauss-legendre, two-point, three-point, error function, erf, true percent relative error
% PROBLEM:
% erf(a) = 2/sqrt(pi) * integral from 0 to a of e^(-x^2) dx. Use the (a) two-point and (b) three-point
% Gauss-Legendre formulas to estimate erf(1.5). Determine the percent relative error for each case
% based on the true value from MATLAB's erf.
% CHECK: abs(I2 - integ_gauss(@(x) 2/sqrt(pi)*exp(-x.^2), 0, 1.5, 2)) < 1e-12 && abs(I3 - erf(1.5)) < 0.01
% CODE:
f = @(x) 2/sqrt(pi)*exp(-x.^2);
a = 0; b = 1.5;
I2 = integ_gauss(f, a, b, 2);
I3 = integ_gauss(f, a, b, 3);
Itrue = erf(1.5);
% two-point by hand: x = (b+a)/2 + (b-a)/2*xd, xd = +/- 1/sqrt(3)
xd = [-1 1]/sqrt(3);
I2hand = (b - a)/2*sum(f((b + a)/2 + (b - a)/2*xd));
fprintf('(a) two-point Gauss:   %.6f (by hand %.6f), et = %.3f %%\n', I2, I2hand, abs((Itrue - I2)/Itrue)*100);
fprintf('(b) three-point Gauss: %.6f, et = %.4f %%\n', I3, abs((Itrue - I3)/Itrue)*100);
fprintf('True value erf(1.5) = %.6f\n', Itrue);
