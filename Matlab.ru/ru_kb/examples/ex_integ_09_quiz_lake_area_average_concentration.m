% TOPIC: integration
% TITLE: Quiz: lake surface area by differentiating volume, and depth-averaged concentration by integration
% SOURCE: CE206 Final Quiz (18 batch) Set A, Q5; Chapra Probs. 19.18 and 21.25
% KEYWORDS: lake, surface area, volume, differentiation, dv/dz, gradient, average concentration, integration, trapz, depth, quiz
% PROBLEM:
% The horizontal surface area As (m^2) of a lake at depth z can be computed from volume by
% differentiation, As(z) = dV/dz, where V = volume (m^3) and z = depth (m) measured from the surface
% down. The average concentration of a substance is c_avg = integral_0^Z c(z) As(z) dz / integral_0^Z As(z) dz.
% Data: z (m) = 0 4 8 12 16, V (10^6 m^3) = 9.8175 5.1051 1.9635 0.3927 0.0000, c (g/m^3) = 10.2 8.5 7.4 5.2 4.1.
% Determine the area of the sections at each depth and the average concentration.
% CHECK: abs(cavg - 8.2260) < 1e-4
% CODE:
z = 0:4:16;
V = [9.8175 5.1051 1.9635 0.3927 0.0000]*1e6;
c = [10.2 8.5 7.4 5.2 4.1];
As = -gradient(V, 4);          % V decreases with depth, so the area is -dV/dz (O(h) at the ends, O(h^2) inside)
cavg = trapz(z, c.*As)/trapz(z, As);
fprintf('%8s %14s\n', 'z (m)', 'As (m^2)');
fprintf('%8g %14.1f\n', [z; As]);
fprintf('Average concentration = %.4f g/m^3\n', cavg);
fprintf('(The quiz solution printed 8.2252 because it typed 0.3972 instead of 0.3927.)\n');
