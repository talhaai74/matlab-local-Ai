% TOPIC: ode
% TITLE: dy/dt = y t^3 - 1.5 y: analytical, Euler (h = 0.5, 0.25), Heun, midpoint and RK4 on the same graph
% SOURCE: CE206 slides 06 page 11 (practice problem); Chapra Prob. 22.1
% KEYWORDS: initial value problem, analytical, euler's method, heun's method, midpoint method, fourth-order runge-kutta, rk4, same graph, step size 0.5, 0.25
% PROBLEM:
% Solve the initial value problem dy/dt = y t^3 - 1.5y over the interval t = 0 to 2 where y(0) = 1.
% Display all your results on the same graph: (a) analytically, (b) Euler's method with h = 0.5 and
% h = 0.25, (c) Heun's method with h = 0.5 (and the midpoint method with h = 0.5), (d) the fourth-order
% RK method with h = 0.5.
% CHECK: abs(ye1(end) - 0.11352539) < 1e-8 && abs(ye2(end) - 0.52969483) < 1e-8 && abs(yr(end) - 2.51307247) < 1e-8
% CHECK: abs(ya(end) - exp(1)) < 1e-12
% CODE:
f = @(t, y) y.*t.^3 - 1.5*y;
yexact = @(t) exp(t.^4/4 - 1.5*t);          % analytical: ln y = t^4/4 - 1.5t
[t1, ye1] = ode_euler(f, [0 2], 1, 0.5);
[t2, ye2] = ode_euler(f, [0 2], 1, 0.25);
[t3, yh] = ode_heun(f, [0 2], 1, 0.5);
[t4, ym] = ode_midpoint(f, [0 2], 1, 0.5);
[t5, yr] = ode_rk4(f, [0 2], 1, 0.5);
ya = yexact(t1);
fprintf('%5s %10s %10s %10s %10s %10s\n', 't', 'exact', 'Euler .5', 'Heun .5', 'Midpt .5', 'RK4 .5');
fprintf('%5.2f %10.5f %10.5f %10.5f %10.5f %10.5f\n', [t1 ya ye1 yh ym yr]');
fprintf('Euler h = 0.25 at t = 2: %.5f\n', ye2(end));
tt = linspace(0, 2, 200);
figure;
plot(tt, yexact(tt), 'k-', t1, ye1, 'o--', t2, ye2, 's--', t3, yh, 'd-', t4, ym, '^-', t5, yr, 'x-', 'LineWidth', 1.2);
grid on; xlabel('t'); ylabel('y');
legend('analytical', 'Euler h = 0.5', 'Euler h = 0.25', 'Heun h = 0.5', 'midpoint h = 0.5', 'RK4 h = 0.5', 'Location', 'northwest');
