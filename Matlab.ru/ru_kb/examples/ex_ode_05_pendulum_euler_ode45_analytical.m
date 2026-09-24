% TOPIC: ode
% TITLE: Pendulum: Euler (h = 0.05) and ode45 versus the small-angle analytical solution
% SOURCE: CE206 slides 06 page 16 / Endfiles pendulum.m
% KEYWORDS: pendulum, second-order ode, system of first-order odes, euler's method, ode45, small angle, analytical solution, theta
% PROBLEM:
% The motion of a pendulum is d2(theta)/dt2 + (g/l) sin(theta) = 0. If l = 2 ft, g = 32.2 ft/s^2 and
% theta0 = pi/4 (released from rest), solve for theta from t = 0 to 1.6 s using (a) Euler's method with
% h = 0.05, (b) ode45 reporting at h = 0.05, and (c) plot your results and compare with the analytical
% solution theta = theta0 cos(sqrt(g/l) t) (which assumes sin(theta) = theta).
% CHECK: abs(th45(end) - 0.780777) < 2e-3 && abs(thE(end) - 1.316795) < 1e-5 && numel(t) == 33
% CODE:
g = 32.2; l = 2; th0 = pi/4;
f = @(t, y) [y(2); -g/l*sin(y(1))];          % y(1) = theta, y(2) = d(theta)/dt
[t, YE] = ode_euler(f, [0 1.6], [th0; 0], 0.05);
[t45, Y45] = ode45(f, 0:0.05:1.6, [th0; 0]);
thE = YE(:,1); th45 = Y45(:,1);
tha = th0*cos(sqrt(g/l)*t);
fprintf('%6s %10s %10s %12s\n', 't', 'Euler', 'ode45', 'small-angle');
fprintf('%6.2f %10.4f %10.4f %12.4f\n', [t(1:4:end) thE(1:4:end) th45(1:4:end) tha(1:4:end)]');
fprintf(['Euler''s method adds energy to an oscillator: with h = 0.05 its amplitude grows (theta(1.6) = %.3f\n' ...
    'instead of %.3f). ode45 is accurate; the analytical curve differs because theta0 = pi/4 is not small.\n'], thE(end), th45(end));
figure; plot(t, thE, 'o-', t45, th45, 's-', t, tha, 'k--'); grid on;
xlabel('t (s)'); ylabel('\theta (rad)'); legend('Euler h = 0.05', 'ode45', 'analytical (sin \theta = \theta)');
