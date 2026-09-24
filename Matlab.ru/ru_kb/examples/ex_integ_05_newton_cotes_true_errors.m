% TOPIC: integration
% TITLE: Integral of (1 - e^-x) from 0 to 4: analytical, trapezoidal, Simpson 1/3, 3/8 and composite rules with true errors
% SOURCE: Chapra Prob. 19.2
% KEYWORDS: analytical, single application, trapezoidal rule, composite trapezoidal, simpson's 1/3, simpson's 3/8, composite simpson, true percent relative error, n = 2, n = 4, n = 5
% PROBLEM:
% Evaluate the integral of (1 - e^(-x)) dx from 0 to 4 (a) analytically, (b) single application of the
% trapezoidal rule, (c) composite trapezoidal rule with n = 2 and 4, (d) single application of
% Simpson's 1/3 rule, (e) composite Simpson's 1/3 rule with n = 4, (f) Simpson's 3/8 rule, and
% (g) composite Simpson's rule with n = 5. For (b)-(g) determine the true percent relative error.
% CHECK: abs(I(1) - 3.018316) < 1e-6 && abs(I(2) - 1.963369) < 1e-6
% CHECK: abs(I(end) - integ_simpdata(linspace(0,4,6), 1 - exp(-linspace(0,4,6)))) < 1e-12
% CODE:
f = @(x) 1 - exp(-x);
a = 0; b = 4;
Itrue = (b - a) + exp(-b) - exp(-a);          % analytical: x + e^-x from 0 to 4
xs5 = linspace(a, b, 6);
names = {'(a) analytical', '(b) trapezoidal, single', '(c) trapezoidal, n = 2', '(c) trapezoidal, n = 4', ...
    '(d) Simpson 1/3, single', '(e) Simpson 1/3, n = 4', '(f) Simpson 3/8, single', '(g) Simpson, n = 5 (1/3 + 3/8)'};
I = [Itrue, integ_trap(f, a, b, 1), integ_trap(f, a, b, 2), integ_trap(f, a, b, 4), ...
    integ_simp13(f, a, b, 2), integ_simp13(f, a, b, 4), integ_simp38(f, a, b), integ_simpdata(xs5, f(xs5))];
fprintf('%-32s %12s %10s\n', 'Method', 'Integral', 'et (%)');
for k = 1:numel(I)
    fprintf('%-32s %12.6f %10.4f\n', names{k}, I(k), abs((Itrue - I(k))/Itrue)*100);
end
