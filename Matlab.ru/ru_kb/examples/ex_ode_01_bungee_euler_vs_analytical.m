% TOPIC: ode
% TITLE: Bungee jumper: Euler's method with h = 2 s versus the analytical solution
% SOURCE: CE206 slides 06 pages 3-6 (eulode); Chapra Example 1.2
% KEYWORDS: euler's method, eulode, bungee jumper, free fall, drag coefficient, step size, analytical solution, tanh, velocity
% PROBLEM:
% Solve the bungee jumper problem dv/dt = g - (cd/m) v^2 using Euler's method with a step size of 2 s
% from t = 0 to 12 s (v(0) = 0). Compare the results with the analytical solution
% v(t) = sqrt(g m/cd) tanh(sqrt(g cd/m) t). Given g = 9.81 m/s^2, cd = 0.25 kg/m, m = 68.1 kg.
% CHECK: abs(v(end) - 51.6008) < 1e-3 && abs(vt(end) - 50.6175) < 1e-3
% CODE:
g = 9.81; cd = 0.25; m = 68.1;
dvdt = @(t, v) g - cd/m*v.^2;
[t, v] = ode_euler(dvdt, [0 12], 0, 2);
vt = sqrt(g*m/cd)*tanh(sqrt(g*cd/m)*t);           % analytical
fprintf('%6s %12s %12s %10s\n', 't (s)', 'Euler v', 'exact v', 'et (%)');
for i = 1:numel(t)
    et = 0;
    if vt(i) ~= 0, et = abs((vt(i) - v(i))/vt(i))*100; end
    fprintf('%6g %12.4f %12.4f %10.2f\n', t(i), v(i), vt(i), et);
end
tt = linspace(0, 12, 200);
figure; plot(t, v, 'o-', tt, sqrt(g*m/cd)*tanh(sqrt(g*cd/m)*tt), 'k-'); grid on;
xlabel('t (s)'); ylabel('v (m/s)'); legend('Euler, h = 2 s', 'analytical', 'Location', 'southeast');
