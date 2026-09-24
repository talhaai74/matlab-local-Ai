% TOPIC: integration
% TITLE: integral(), Romberg and Gauss for x e^(2x); double integral with integral2
% SOURCE: Chapra Probs. 20.3 and 19.6/20.9
% KEYWORDS: integral, quad, integral2, dblquad, double integral, romberg, gauss quadrature, analytical
% PROBLEM:
% (a) Evaluate the integral from 0 to 3 of x e^(2x) dx with Romberg integration (es = 0.5%), the
% two-point Gauss quadrature formula and MATLAB's integral function; compare with the analytical value.
% (b) Evaluate the double integral of (x^2 - 3y^2 + x y^3) with x from 0 to 4 and y from -2 to 2
% analytically and with integral2.
% CHECK: abs(Iint - 504.53599) < 1e-4 && abs(I2d - 64/3) < 1e-8
% CODE:
%% (a)
f = @(x) x.*exp(2*x);
Itrue = (5*exp(6) + 1)/4;                 % e^(2x)(2x - 1)/4 from 0 to 3
Ir = integ_romberg(f, 0, 3, 0.5);
Ig = integ_gauss(f, 0, 3, 2);
Iint = integral(f, 0, 3);
fprintf('(a) exact %.5f | Romberg %.5f | 2-pt Gauss %.5f | integral %.5f\n', Itrue, Ir, Ig, Iint);
%% (b)
g = @(x, y) x.^2 - 3*y.^2 + x.*y.^3;
I2d = integral2(g, 0, 4, -2, 2);
fprintf('(b) integral2 = %.6f, analytical = 64/3 = %.6f\n', I2d, 64/3);
