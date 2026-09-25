% TOPIC: roots
% TITLE: Deflection of a nonlinear spring hit by a falling mass (energy balance root)
% SOURCE: Chapra Prob. 6.20
% KEYWORDS: nonlinear spring, deflection, conservation of energy, mass released, k1 k2, d^(5/2), fzero
% PROBLEM:
% A block of mass m is released a distance h above a nonlinear spring with resistance force
% F = -(k1 d + k2 d^(3/2)). Conservation of energy gives 0 = 2 k2 d^(5/2)/5 + (1/2) k1 d^2 - m g d - m g h.
% Solve for d, given k1 = 40,000 g/s^2, k2 = 40 g/(s^2 m^0.5), m = 95 g, g = 9.81 m/s^2 and h = 0.43 m.
% CHECK: abs(d - 0.1667236) < 1e-6
% CODE:
k1 = 40000; k2 = 40; m = 95; g = 9.81; h = 0.43;
f = @(d) 2*k2*d.^(5/2)/5 + 0.5*k1*d.^2 - m*g*d - m*g*h;
d = fzero(f, [0 1]);
fprintf('d = %.4f m\n', d);
