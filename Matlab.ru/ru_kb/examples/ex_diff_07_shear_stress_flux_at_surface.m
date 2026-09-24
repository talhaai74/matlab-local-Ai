% TOPIC: differentiation
% TITLE: Derivative at a boundary from data: shear stress (Newton's viscosity law) and heat flux (Fourier's law)
% SOURCE: Chapra Probs. 21.21 and 21.24
% KEYWORDS: shear stress, newton's viscosity law, du/dy, surface, fourier's law, heat flux, thermal conductivity, dT/dx at x = 0, one-sided second-order
% PROBLEM:
% (a) Air velocity u (m/s) at distances y (m) from a flat plate: y = 0 0.002 0.006 0.012 0.018 0.024,
% u = 0 0.287 0.899 1.915 3.048 4.299. Use Newton's viscosity law tau = mu du/dy to find the shear
% stress at the surface (y = 0), mu = 1.8e-5 N s/m^2.
% (b) Temperatures in a stone wall: x (m) = 0 0.08 0.16, T (C) = 19 17 15. If the heat flux at x = 0 is
% 60 W/m^2, compute the thermal conductivity k from Fourier's law q = -k dT/dx.
% CHECK: abs(tau - 2.526e-3) < 1e-6 && abs(k - 2.4) < 1e-9
% CODE:
%% (a) shear stress at the wall
y = [0 0.002 0.006 0.012 0.018 0.024];
u = [0 0.287 0.899 1.915 3.048 4.299];
mu = 1.8e-5;
dudy = diff_data(y, u);                  % one-sided O(h^2) (3-point Lagrange) at y = 0
tau = mu*dudy(1);
fprintf('(a) du/dy at the surface = %.4f 1/s, tau = %.4e N/m^2\n', dudy(1), tau);
%% (b) thermal conductivity
x = [0 0.08 0.16];
T = [19 17 15];
dTdx = diff_data(x, T);                  % forward O(h^2) at x = 0
k = 60/(-dTdx(1));
fprintf('(b) dT/dx at x = 0 = %.4f C/m, k = q/(-dT/dx) = %.4f W/(m C)\n', dTdx(1), k);
