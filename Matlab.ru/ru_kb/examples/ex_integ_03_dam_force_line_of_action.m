% TOPIC: integration
% TITLE: Hydrostatic force on a dam and its line of action (numerical integration of tabulated widths)
% SOURCE: CE206 slides 05 page 13; Chapra Prob. 19.9 (Fig. P19.9)
% KEYWORDS: hydrostatic force, dam, line of action, pressure, width, simpson's rule, trapezoidal, rho g, total force
% PROBLEM:
% Calculate the force exerted on a dam and its line of action: P = integral_0^D rho g w(z) (D - z) dz and
% d = integral_0^D rho g z w(z) (D - z) dz / P, with rho = 1000 kg/m^3, g = 9.81 m/s^2, D = 60 m and the
% dam width w (m) = 122 130 135 160 175 190 200 at elevations z (m) = 0 10 20 30 40 50 60.
% (Answer: P = 2.54e9 N, d = 21.97 m.)
% CHECK: abs(P - 2.547984e9) < 1e3 && abs(d - 21.97125) < 1e-4
% CODE:
rho = 1000; g = 9.81; D = 60;
z = 0:10:60;
w = [122 130 135 160 175 190 200];
p1 = rho*g*w.*(D - z);
p2 = rho*g*z.*w.*(D - z);
P = integ_simpdata(z, p1);            % Simpson's 1/3 rule (6 equal segments)
d = integ_simpdata(z, p2)/P;
fprintf('Simpson:     P = %.4e N, line of action d = %.4f m above the bottom\n', P, d);
fprintf('Trapezoidal: P = %.4e N, d = %.4f m\n', trapz(z, p1), trapz(z, p2)/trapz(z, p1));
