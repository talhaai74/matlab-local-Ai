% TOPIC: regression
% TITLE: Pipe flow Q = a0 D^a1 S^a2 by multiple linear regression on logarithms
% SOURCE: Class solution sheet "Curve-fitting and Interpolation"; Chapra Prob. 15.9
% KEYWORDS: multiple linear regression, power model, logarithms, concrete pipe, diameter, slope, flow, alpha0 alpha1 alpha2
% PROBLEM:
% The following data were collected for the steady flow of water in a concrete circular pipe:
% Experiment = 1 2 3 4 5 6 7 8 9,
% Diameter (m) = 0.3 0.6 0.9 0.3 0.6 0.9 0.3 0.6 0.9, Slope (m/m) = 0.001 0.001 0.001 0.01 0.01 0.01 0.05 0.05 0.05,
% Flow (m^3/s) = 0.04 0.24 0.69 0.13 0.82 2.38 0.31 1.95 5.66.
% Use multiple linear regression to fit the model Q = alpha0 D^alpha1 S^alpha2 to this data.
% CHECK: abs(alpha_0 - 36.381332) < 1e-4 && abs(alpha_1 - 2.627937) < 1e-6 && abs(alpha_2 - 0.531987) < 1e-6
% CODE:
D = [0.3; 0.6; 0.9; 0.3; 0.6; 0.9; 0.3; 0.6; 0.9];
S = [0.001; 0.001; 0.001; 0.01; 0.01; 0.01; 0.05; 0.05; 0.05];
Q = [0.04; 0.24; 0.69; 0.13; 0.82; 2.38; 0.31; 1.95; 5.66];
Z = [ones(size(D)) log(D) log(S)];
a = Z\log(Q);
alpha_0 = exp(a(1));
alpha_1 = a(2);
alpha_2 = a(3);
fprintf('Q = %.4f * D^%.4f * S^%.4f\n', alpha_0, alpha_1, alpha_2);
