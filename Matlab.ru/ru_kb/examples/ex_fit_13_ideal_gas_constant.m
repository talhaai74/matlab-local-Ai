% TOPIC: regression
% TITLE: Gas constant R from pressure-temperature data (slope of p versus absolute T)
% SOURCE: Chapra Prob. 14.7
% KEYWORDS: ideal gas law, pv = nrt, gas constant, pressure, temperature, kelvin, slope, nitrogen
% PROBLEM:
% Data for 1 kg of nitrogen in a fixed volume of 10 m^3:
% T (C) = -40 0 40 80 120 160, p (N/m^2) = 6900 8100 9350 10500 11700 12800.
% Employ the ideal gas law pV = nRT to determine R. T must be expressed in kelvins.
% CHECK: abs(R - 8.34) < 0.1
% CODE:
Tc = [-40 0 40 80 120 160];
p = [6900 8100 9350 10500 11700 12800];
V = 10; n = 1000/28;                        % mol of N2 in 1 kg (molar mass 28 g/mol)
T = Tc + 273.15;
a = fit_linear(T, p);                       % p = (nR/V) T + intercept
R = a(1)*V/n;
fprintf('p = %.4f T %+.2f  ->  R = slope*V/n = %.4f J/(mol K)\n', a(1), a(2), R);
fprintf('Accepted value: 8.314 J/(mol K), error = %.2f %%\n', abs(R - 8.314)/8.314*100);
