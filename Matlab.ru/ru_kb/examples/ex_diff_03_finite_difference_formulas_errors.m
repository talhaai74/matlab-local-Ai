% TOPIC: differentiation
% TITLE: Forward, backward and centered finite differences of O(h), O(h^2), O(h^4) for cos(x) with true errors
% SOURCE: Chapra Prob. 21.1 (Figs. 21.3-21.5)
% KEYWORDS: forward difference, backward difference, centered difference, o(h), o(h^2), o(h^4), finite difference, true percent relative error, cos x, h = pi/12
% PROBLEM:
% Compute forward and backward difference approximations of O(h) and O(h^2), and central difference
% approximations of O(h^2) and O(h^4) for the first derivative of y = cos x at x = pi/4 using h = pi/12.
% Estimate the true percent relative error for each approximation.
% CHECK: abs(D(1) - (-0.791090)) < 1e-6 && abs(D(6) - (-0.706997)) < 1e-6
% CODE:
f = @(x) cos(x);
x = pi/4; h = pi/12;
dtrue = -sin(x);
D = [diff_fd(f, x, h, 'forward', 1), diff_fd(f, x, h, 'forward', 2), ...
     diff_fd(f, x, h, 'backward', 1), diff_fd(f, x, h, 'backward', 2), ...
     diff_fd(f, x, h, 'centered', 2), diff_fd(f, x, h, 'centered', 4)];
names = {'forward O(h)', 'forward O(h^2)', 'backward O(h)', 'backward O(h^2)', 'centered O(h^2)', 'centered O(h^4)'};
fprintf('True derivative -sin(pi/4) = %.6f\n', dtrue);
fprintf('%-18s %12s %10s\n', 'Formula', 'f''(x)', 'et (%)');
for k = 1:6
    fprintf('%-18s %12.6f %10.4f\n', names{k}, D(k), abs((dtrue - D(k))/dtrue)*100);
end
