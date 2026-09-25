% TOPIC: differentiation
% TITLE: Slope, moment, shear and distributed load from measured beam deflections (repeated gradient)
% SOURCE: Class solution sheet "Numerical Differentiation"; Chapra Prob. 21.37
% KEYWORDS: beam, deflection, slope, moment, shear, distributed load, gradient, numerical differentiation, E I, simply supported
% PROBLEM:
% You measure the following deflections along a simply supported uniform beam:
% x (m) = 0 0.375 0.75 1.125 1.5 1.875 2.25 2.625 3,
% y (cm) = 0 -0.2571 -0.9484 -1.9689 -3.2262 -4.6414 -6.1503 -7.7051 -9.275.
% Employ numerical differentiation to compute the slope, the moment (N m), the shear (N) and the distributed
% load (N/m). Use E = 200 GPa and I = 0.0003 m^4.
% CHECK: abs(theta(1) - (-0.006856)) < 1e-12 && abs(M(5) - (-689386.6667)) < 1e-3 && abs(V(5) - 809955.5556) < 1e-3 && abs(w(5) - 450180.7407) < 1e-3
% CODE:
E = 200e9; I = 0.0003; dx = 0.375;
x = 0:dx:3;
y = [0 -0.2571 -0.9484 -1.9689 -3.2262 -4.6414 -6.1503 -7.7051 -9.275]*1e-2;
theta = gradient(y, dx);
M = E*I*gradient(theta, dx);
V = gradient(M, dx);
w = -gradient(V, dx);
fprintf('%6s %12s %14s %14s %14s\n', 'x (m)', 'slope', 'M (N m)', 'V (N)', 'w (N/m)');
fprintf('%6.3f %12.6f %14.2f %14.2f %14.2f\n', [x; theta; M; V; w]);
figure;
subplot(221); plot(x, theta); xlabel('x (m)'); ylabel('slope (m/m)');
subplot(222); plot(x, M); xlabel('x (m)'); ylabel('M (N m)');
subplot(223); plot(x, V); xlabel('x (m)'); ylabel('V (N)');
subplot(224); plot(x, w); xlabel('x (m)'); ylabel('w (N/m)');
