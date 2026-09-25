% TOPIC: roots
% TITLE: Spherical tank depth for 30 m^3 with three iterations of the most efficient method (Newton-Raphson)
% SOURCE: Chapra Prob. 6.22
% KEYWORDS: spherical tank, depth, volume, most efficient method, newton raphson, three iterations, approximate relative error, justification
% PROBLEM:
% You are designing a spherical tank to hold water for a small village. The volume of liquid it can hold is
% V = pi*h^2*(3R - h)/3, where V = volume (m^3), h = depth of water (m) and R = tank radius (m). If R = 3 m,
% what depth must the tank be filled to so that it holds 30 m^3? Use three iterations of the most efficient
% numerical method possible to determine your answer. Determine the approximate relative error after each
% iteration. Also, provide justification for your choice of method. Extra information: (a) for bracketing
% methods, initial guesses of 0 and R will bracket a single root; (b) for open methods, an initial guess of R
% will always converge.
% CHECK: abs(h - 2.0269057) < 1e-6 && iter == 3 && abs(ea - 0.006730) < 1e-4
% CODE:
R = 3; V = 30;
f = @(h) pi*h.^2.*(3*R - h)/3 - V;
df = @(h) pi*(2*R*h - h.^2);
h = R;
fprintf('%5s %12s %12s\n', 'iter', 'h (m)', 'ea (%)');
for iter = 1:3
    hnew = h - f(h)/df(h);
    ea = abs((hnew - h)/hnew)*100;
    h = hnew;
    fprintf('%5d %12.6f %12.6f\n', iter, h, ea);
end
fprintf('Depth after 3 iterations: h = %.6f m (ea = %.4f %%)\n', h, ea);
disp('Newton-Raphson: the derivative is easy to write, it converges quadratically and x0 = R is guaranteed to converge.');
