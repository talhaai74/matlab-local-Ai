% TOPIC: roots
% TITLE: Angular frequency giving 100 ohm impedance in a parallel RLC circuit (fzero with bracket 1 to 1000)
% SOURCE: Chapra Prob. 6.19
% KEYWORDS: circuit, resistor, inductor, capacitor, parallel, impedance, angular frequency, omega, fzero, kirchhoff
% PROBLEM:
% A circuit has a resistor, an inductor and a capacitor in parallel. The impedance is
% 1/Z = sqrt(1/R^2 + (omega C - 1/(omega L))^2). Find the omega that results in an impedance of 100 ohm using
% the fzero function with initial guesses of 1 and 1000 for R = 225 ohm, C = 0.6e-6 F and L = 0.5 H.
% CHECK: abs(omega - 220.020156) < 1e-5
% CODE:
R = 225; C = 0.6e-6; L = 0.5; Z = 100;
f = @(w) sqrt(1/R^2 + (w*C - 1./(w*L)).^2) - 1/Z;
omega = fzero(f, [1 1000]);
fprintf('omega = %.4f rad/s\n', omega);
