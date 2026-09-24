% TOPIC: ode
% TITLE: Three-story building under a ground-floor velocity: 6 first-order ODEs with ode45
% SOURCE: Chapra Prob. 22.22 (Fig. P22.22)
% KEYWORDS: three-story building, mass-spring, earthquake, system of odes, ode45, displacements, velocities, phase plane, plot3
% PROBLEM:
% A three-story building is modeled as m1 x1'' = -k1 x1 + k2 (x2 - x1), m2 x2'' = k2 (x1 - x2) + k3 (x3 - x2),
% m3 x3'' = k3 (x2 - x3) with m1 = 12000, m2 = 10000, m3 = 8000 kg and k1 = 3000, k2 = 2400,
% k3 = 1800 kN/m. Simulate from t = 0 to 20 s given dx1/dt = 1 m/s at t = 0 and all other initial
% displacements and velocities zero. Plot (a) displacements and (b) velocities versus time and a
% three-dimensional phase-plane plot of the displacements.
% CHECK: size(Y, 2) == 6 && max(abs(Y(:,1))) < 0.2
% CODE:
m = [12000 10000 8000];                   % kg
k = [3000 2400 1800]*1000;                % kN/m -> N/m
f = @(t, y) [y(4); y(5); y(6);
            (-k(1)*y(1) + k(2)*(y(2) - y(1)))/m(1);
            ( k(2)*(y(1) - y(2)) + k(3)*(y(3) - y(2)))/m(2);
            ( k(3)*(y(2) - y(3)))/m(3)];  % y = [x1 x2 x3 v1 v2 v3]
[t, Y] = ode45(f, [0 20], [0 0 0 1 0 0]', odeset('RelTol', 1e-7));
fprintf('Maximum displacements: x1 = %.4f, x2 = %.4f, x3 = %.4f m\n', max(abs(Y(:,1:3))));
figure;
subplot(2,1,1); plot(t, Y(:,1:3)); grid on; ylabel('x (m)'); legend('x_1', 'x_2', 'x_3'); title('(a) displacements');
subplot(2,1,2); plot(t, Y(:,4:6)); grid on; ylabel('v (m/s)'); xlabel('t (s)'); legend('v_1', 'v_2', 'v_3'); title('(b) velocities');
figure; plot3(Y(:,1), Y(:,2), Y(:,3)); grid on; xlabel('x_1'); ylabel('x_2'); zlabel('x_3'); title('Phase plane');
