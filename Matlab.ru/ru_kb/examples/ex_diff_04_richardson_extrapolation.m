% TOPIC: differentiation
% TITLE: Richardson extrapolation of centered differences for the derivative of cos(x)
% SOURCE: Chapra Prob. 21.4
% KEYWORDS: richardson extrapolation, centered difference, o(h^2), o(h^4), improve accuracy, h1, h2
% PROBLEM:
% Use Richardson extrapolation to estimate the first derivative of y = cos x at x = pi/4 using step
% sizes h1 = pi/3 and h2 = pi/6. Employ centered differences of O(h^2) for the initial estimates.
% CHECK: abs(D - (-0.705392)) < 1e-6
% CODE:
f = @(x) cos(x);
x = pi/4;
[D, D1, D2] = diff_richardson(f, x, pi/3, pi/6);
dtrue = -sin(x);
fprintf('D(h1 = pi/3) = %.6f  et = %.3f %%\n', D1, abs((dtrue - D1)/dtrue)*100);
fprintf('D(h2 = pi/6) = %.6f  et = %.3f %%\n', D2, abs((dtrue - D2)/dtrue)*100);
fprintf('Richardson D = 4/3 D(h2) - 1/3 D(h1) = %.6f  et = %.4f %%  (true %.6f)\n', D, abs((dtrue - D)/dtrue)*100, dtrue);
