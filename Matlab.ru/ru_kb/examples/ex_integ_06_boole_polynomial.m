% TOPIC: integration
% TITLE: Integral of a 5th-degree polynomial with trapezoidal, Simpson and Boole's rules (true errors)
% SOURCE: Chapra Prob. 19.4
% KEYWORDS: boole's rule, simpson's 3/8, simpson's 1/3, composite trapezoidal, polynomial integral, exact for polynomials, true error
% PROBLEM:
% Evaluate the integral of (1 - x - 4x^3 + 2x^5) dx from -2 to 4 (a) analytically, (b) single
% application of the trapezoidal rule, (c) composite trapezoidal rule with n = 2 and 4, (d) single
% application of Simpson's 1/3 rule, (e) Simpson's 3/8 rule, and (f) Boole's rule. For each numerical
% estimate determine the true percent relative error.
% CHECK: abs(I(1) - 1104) < 1e-9 && abs(I(end) - 1104) < 1e-9
% CODE:
f = @(x) 1 - x - 4*x.^3 + 2*x.^5;
a = -2; b = 4;
F = @(x) x - x.^2/2 - x.^4 + x.^6/3;           % antiderivative
names = {'(a) analytical', '(b) trapezoidal, single', '(c) trapezoidal, n = 2', '(c) trapezoidal, n = 4', ...
    '(d) Simpson 1/3, single', '(e) Simpson 3/8', '(f) Boole'};
I = [F(b) - F(a), integ_newtoncotes(f, a, b, 'trap'), integ_trap(f, a, b, 2), integ_trap(f, a, b, 4), ...
    integ_newtoncotes(f, a, b, 'simp13'), integ_newtoncotes(f, a, b, 'simp38'), integ_newtoncotes(f, a, b, 'boole')];
fprintf('%-26s %14s %12s\n', 'Method', 'Integral', 'et (%)');
for k = 1:numel(I)
    fprintf('%-26s %14.4f %12.4f\n', names{k}, I(k), abs((I(1) - I(k))/I(1))*100);
end
fprintf('Boole''s rule is exact for polynomials up to degree 5.\n');
