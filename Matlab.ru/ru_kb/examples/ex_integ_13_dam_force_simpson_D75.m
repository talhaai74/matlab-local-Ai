% TOPIC: integration
% TITLE: Water force on a dam and its line of action with Simpson's rule (D = 75 m, 7 widths)
% SOURCE: Chapra Prob. 19.9 (4th ed., Fig. P19.9)
% KEYWORDS: dam, water pressure, total force, line of action, simpson's rule, width of dam face, elevation
% PROBLEM:
% Water exerts pressure on the upstream face of a dam: p(z) = rho*g*(D - z), rho = 10^3 kg/m^3, g = 9.81 m/s^2,
% D = 75 m. The total force is ft = integral_0^D rho*g*w(z)*(D - z) dz and the line of action is
% d = integral_0^D rho*g*z*w(z)*(D - z) dz / ft, with dam widths w (m) = 122 130 135 160 175 190 200 at
% equally spaced elevations from z = 0 to 75 m. Use Simpson's rule to compute ft and d.
% CHECK: abs(ft - 3.981225e9) < 1 && abs(d - 27.4640657) < 1e-6
% CODE:
rho = 1000; g = 9.81; D = 75;
z = linspace(0, D, 7);
w = [122 130 135 160 175 190 200];
ft = integ_simpdata(z, rho*g*w.*(D - z));
d = integ_simpdata(z, rho*g*z.*w.*(D - z))/ft;
fprintf('Total force ft = %.4e N (Simpson 1/3, 6 segments)\n', ft);
fprintf('Line of action d = %.4f m above the bottom\n', d);
