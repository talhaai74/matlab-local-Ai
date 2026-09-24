% TOPIC: integration
% TITLE: Mass of a rod with variable density and cross-section (trapz with unequal spacing, units)
% SOURCE: Chapra Prob. 19.13
% KEYWORDS: mass, density, cross-sectional area, variable, trapz, unequal spacing, unit conversion, grams
% PROBLEM:
% The total mass of a variable-density rod is m = integral_0^L rho(x) Ac(x) dx. For a 20-m rod:
% x (m) = 0 4 6 8 12 16 20, rho (g/cm^3) = 4.00 3.95 3.89 3.80 3.60 3.41 3.30, Ac (cm^2) = 100 103 106 110 120 133 150.
% Determine the mass in grams to the best possible accuracy.
% CHECK: abs(m - 863135) < 1
% CODE:
x = [0 4 6 8 12 16 20];            % m
rho = [4.00 3.95 3.89 3.80 3.60 3.41 3.30];
Ac = [100 103 106 110 120 133 150];
xcm = x*100;                        % m -> cm so rho*Ac*dx is in grams
m = trapz(xcm, rho.*Ac);            % unequal spacing: trapezoid on each segment
fprintf('Mass = %.0f g = %.3f kg (trapezoidal, unequal segments)\n', m, m/1000);
