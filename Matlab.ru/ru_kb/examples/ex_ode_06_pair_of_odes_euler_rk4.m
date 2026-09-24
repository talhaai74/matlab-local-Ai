% TOPIC: ode
% TITLE: A pair of ODEs by Euler and fourth-order RK with h = 0.1
% SOURCE: Chapra Prob. 22.7
% KEYWORDS: system of odes, pair of odes, euler's method, fourth-order runge-kutta, rk4, y and z, step size 0.1
% PROBLEM:
% Solve dy/dt = -2y + 5e^(-t), dz/dt = -y z^2/2 from t = 0 to 0.4 using a step size of 0.1 with
% y(0) = 2 and z(0) = 4. Obtain your solution with (a) Euler's method and (b) the fourth-order RK
% method. Display your results as a plot.
% CHECK: norm(YR(end,:) - [2.003606 1.512622]) < 1e-5 && norm(YE(end,:) - [2.062649 1.228730]) < 1e-5
% CODE:
f = @(t, u) [-2*u(1) + 5*exp(-t);
             -u(1)*u(2)^2/2];
[t, YE] = ode_euler(f, [0 0.4], [2; 4], 0.1);
[~, YR] = ode_rk4(f, [0 0.4], [2; 4], 0.1);
[~, Y45] = ode45(f, t, [2; 4], odeset('RelTol', 1e-10, 'AbsTol', 1e-12));
fprintf('%5s %10s %10s %10s %10s\n', 't', 'y Euler', 'z Euler', 'y RK4', 'z RK4');
fprintf('%5.1f %10.5f %10.5f %10.5f %10.5f\n', [t YE YR]');
figure; plot(t, YE(:,1), 'bo--', t, YE(:,2), 'ro--', t, YR(:,1), 'b-', t, YR(:,2), 'r-'); grid on;
xlabel('t'); legend('y Euler', 'z Euler', 'y RK4', 'z RK4');
