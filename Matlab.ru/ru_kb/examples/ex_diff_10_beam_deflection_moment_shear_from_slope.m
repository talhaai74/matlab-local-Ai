% TOPIC: differentiation
% TITLE: Beam with linearly increasing load: deflection by cumtrapz, moment and shear by gradient of the slope
% SOURCE: Class solution sheet "Numerical Differentiation"; Chapra Prob. 21.36
% KEYWORDS: beam, slope, deflection, moment, shear, distributed load, cumtrapz, gradient, numerical integration, numerical differentiation, E I
% PROBLEM:
% Uniform beams: dy/dx = theta(x), dtheta/dx = M(x)/(E*I), dM/dx = V(x), dV/dx = -w(x). For a linearly increasing
% load the slope is theta(x) = w0/(120*E*I*L)*(-5x^4 + 6L^2x^2 - L^4). Employ (a) numerical integration to
% compute the deflection (m) and (b) numerical differentiation to compute the moment (N m) and shear (N).
% Use equally spaced intervals of dx = 0.125 m along a 3-m beam, E = 200 GPa, I = 0.0003 m^4 and
% w0 = 2.5 kN/cm. The deflections at the ends are y(0) = y(L) = 0.
% CHECK: numel(x) == 25 && abs(y(13) - (-7.895908e-4)) < 1e-9 && abs(M(13) - 65299.479167) < 1e-4 && abs(V(1) - 37120.225694) < 1e-4
% CODE:
E = 200e9; I = 0.0003; w0 = 2.5e5; del_x = 0.125; L = 3;
x = 0:del_x:L;
theta = (-5*x.^4 + 6*L^2*x.^2 - L^4)*w0/(120*E*I*L);
y = cumtrapz(x, theta);
M = E*I*gradient(theta, del_x);
V = gradient(M, del_x);
fprintf('%6s %13s %13s %13s %13s\n', 'x (m)', 'theta', 'y (m)', 'M (N m)', 'V (N)');
fprintf('%6.3f %13.4e %13.4e %13.2f %13.2f\n', [x; theta; y; M; V]);
figure;
subplot(311); plot(x, y); xlabel('x (m)'); ylabel('y (m)');
subplot(312); plot(x, M); xlabel('x (m)'); ylabel('M (N m)');
subplot(313); plot(x, V); xlabel('x (m)'); ylabel('V (N)');
