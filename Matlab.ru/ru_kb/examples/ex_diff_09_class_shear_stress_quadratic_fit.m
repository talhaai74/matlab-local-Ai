% TOPIC: differentiation
% TITLE: Class sheet: shear stress at a flat surface from Newton's viscosity law with a fitted parabola
% SOURCE: Class solution sheet "Numerical Differentiation"; Chapra Prob. 21.21
% KEYWORDS: shear stress, newton's viscosity law, du/dy, surface, air velocity, polyfit, second-order polynomial, viscosity
% PROBLEM:
% The velocity u (m/s) of air flowing past a flat surface is measured at several distances y (m) away from the
% surface: y = 0 0.002 0.006 0.012 0.018 0.024, u = 0 0.287 0.899 1.915 3.048 4.299. Use Newton's viscosity
% law tau = mu du/dy to determine the shear stress tau (N/m^2) at the surface (y = 0).
% Assume a dynamic viscosity mu = 1.8e-5 N s/m^2.
% CHECK: abs(tau - 2.520113e-3) < 1e-9
% CODE:
y = [0 2 6 12 18 24]*1e-3;
u = [0 0.287 0.899 1.915 3.048 4.299];
a = polyfit(y, u, 2);
y0 = 0;
dudy0 = 2*a(1)*y0 + a(2);
mu = 1.8e-5;
tau = mu*dudy0;
fprintf('du/dy at the surface = %.4f 1/s\n', dudy0);
fprintf('Shear stress tau = %.4e N/m^2\n', tau);
