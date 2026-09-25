% TOPIC: integration
% TITLE: Class sheet: water force on a dam and its line of action with trapz (D = 75 m, 7 widths)
% SOURCE: Class solution sheet "Numerical Integration" (S. T. Azad), Chapra Prob. 19.9 (Simpson crossed out)
% KEYWORDS: dam, water pressure, total force, line of action, rho g w(z) (D - z), trapz, width of dam face, elevation
% PROBLEM:
% Water exerts pressure on the upstream face of a dam: p(z) = rho*g*(D - z), rho = 10^3 kg/m^3, g = 9.81 m/s^2,
% D = 75 m (elevation of the water surface). The total force is ft = integral_0^D rho*g*w(z)*(D - z) dz and the
% line of action is d = integral_0^D rho*g*z*w(z)*(D - z) dz / integral_0^D rho*g*w(z)*(D - z) dz, where the dam
% width w (m) = 122 130 135 160 175 190 200 at equally spaced elevations from z = 0 to 75 m.
% Compute ft and d.
% CHECK: abs(ft - 3.948525e9) < 1 && abs(d - 26.785714) < 1e-5
% CODE:
rho = 1000; g = 9.81; D = 75;
z = linspace(0, D, 7);
w = [122 130 135 160 175 190 200];
ft = trapz(z, rho*g*w.*(D - z));
d = trapz(z, rho*g*z.*w.*(D - z))/ft;
fprintf('Total force ft = %.4e N\n', ft);
fprintf('Line of action d = %.4f m above the bottom\n', d);
