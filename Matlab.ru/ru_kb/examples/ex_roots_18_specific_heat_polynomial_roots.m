% TOPIC: roots
% TITLE: Specific heat of dry air: plot cp(T) and find T for cp = 1.1 with MATLAB polynomial functions
% SOURCE: Chapra Prob. 6.13
% KEYWORDS: specific heat, dry air, polynomial, roots, polyval, temperature, thermodynamics, plot
% PROBLEM:
% The zero-pressure specific heat of dry air cp (kJ/(kg K)) is related to temperature (K) by
% cp = 0.99403 + 1.671e-4 T + 9.7215e-8 T^2 - 9.5838e-11 T^3 + 1.9520e-14 T^4.
% Write a MATLAB script (a) to plot cp versus a range of T = 0 to 1200 K and (b) to determine the temperature
% that corresponds to a specific heat of 1.1 kJ/(kg K) with MATLAB polynomial functions.
% CHECK: abs(Tcp - 544.0875377) < 1e-6
% CODE:
c = [1.9520e-14 -9.5838e-11 9.7215e-8 1.671e-4 0.99403];
T = linspace(0, 1200);
figure; plot(T, polyval(c, T)); grid on; xlabel('T (K)'); ylabel('c_p (kJ/(kg K))');
r = roots(c - [0 0 0 0 1.1]);
r = real(r(abs(imag(r)) < 1e-9 & real(r) >= 0 & real(r) <= 1200));
Tcp = r(1);
fprintf('cp = 1.1 kJ/(kg K) at T = %.4f K\n', Tcp);
