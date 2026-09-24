% TOPIC: ode
% TITLE: Heun without and with corrector iteration, midpoint and Ralston methods (h = 0.5)
% SOURCE: Chapra Prob. 22.3
% KEYWORDS: heun's method, iterating the corrector, es < 0.1%, midpoint method, ralston's method, second-order runge-kutta, analytical
% PROBLEM:
% Solve dy/dt = -2y + t^2 from t = 0 to 2 with h = 0.5 where y(0) = 1. Display all results on the same
% graph. Obtain your solutions with (a) Heun's method without iterating the corrector, (b) Heun's
% method with iterating the corrector until es < 0.1%, (c) the midpoint method and (d) Ralston's method.
% CHECK: abs(ya(end) - (0.5*4 - 0.5*2 + 0.25 + 0.75*exp(-4))) < 1e-12
% CHECK: max(abs(yb - ya)) < max(abs(yA - ya)) + 0.05
% CODE:
f = @(t, y) -2*y + t.^2;
yexact = @(t) 0.5*t.^2 - 0.5*t + 0.25 + 0.75*exp(-2*t);
[t, yA] = ode_heun(f, [0 2], 1, 0.5);              % (a) no iteration
[~, yb] = ode_heun(f, [0 2], 1, 0.5, 0.1, 50);     % (b) iterate the corrector until ea < 0.1 %
[~, yc] = ode_midpoint(f, [0 2], 1, 0.5);          % (c)
[~, yd] = ode_ralston(f, [0 2], 1, 0.5);           % (d)
ya = yexact(t);
fprintf('%5s %10s %10s %10s %10s %10s\n', 't', 'exact', 'Heun', 'Heun iter', 'midpoint', 'Ralston');
fprintf('%5.1f %10.5f %10.5f %10.5f %10.5f %10.5f\n', [t ya yA yb yc yd]');
tt = linspace(0, 2, 200);
figure; plot(tt, yexact(tt), 'k-', t, yA, 'o-', t, yb, 's-', t, yc, 'd-', t, yd, '^-'); grid on;
xlabel('t'); ylabel('y'); legend('analytical', 'Heun', 'Heun iterated', 'midpoint', 'Ralston');
