% TOPIC: roots
% TITLE: Initial angle of a thrown ball to reach the catcher (projectile trajectory root, two solutions)
% SOURCE: Chapra Prob. 6.21
% KEYWORDS: trajectory, projectile, thrown ball, right fielder, catcher, initial angle, theta0, initial velocity, fzero, two roots
% PROBLEM:
% The trajectory of a ball thrown by a right fielder is y = tan(theta0) x - g x^2/(2 v0^2 cos^2(theta0)) + y0.
% Find the appropriate initial angle theta0 if v0 = 30 m/s and the distance to the catcher is 90 m. The throw
% leaves the right fielder's hand at an elevation of 1.8 m and the catcher receives it at 1 m.
% CHECK: abs(th1 - 37.958982) < 1e-5 && abs(th2 - 51.531736) < 1e-5
% CODE:
g = 9.81; v0 = 30; x = 90; y0 = 1.8; y = 1;
f = @(th) tand(th)*x - g*x^2./(2*v0^2*cosd(th).^2) + y0 - y;
th1 = fzero(f, [10 45]);
th2 = fzero(f, [45 80]);
fprintf('theta0 = %.4f deg (low throw) or %.4f deg (high throw)\n', th1, th2);
