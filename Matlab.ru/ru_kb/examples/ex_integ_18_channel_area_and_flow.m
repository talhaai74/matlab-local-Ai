% TOPIC: integration
% TITLE: Channel cross-sectional area and flow from depth and velocity data (unequal spacing)
% SOURCE: Class solution sheet "Numerical Integration"; Chapra Prob. 19.17
% KEYWORDS: channel, cross-sectional area, flow, depth, velocity, distance from the bank, Ac = integral H dy, Q = integral U H dy, trapz
% PROBLEM:
% The cross-sectional area of a channel is Ac = integral_0^B H(y) dy and the average flow is
% Q = integral_0^B U(y) H(y) dy, where B = total channel width (m), H = depth (m), U = velocity (m/s) and
% y = distance from the bank (m). Determine Ac and Q for the data
% y (m) = 0 2 4 5 6 9, H (m) = 0.5 1.3 1.25 1.8 1 0.25, U (m/s) = 0.03 0.06 0.05 0.13 0.11 0.02.
% CHECK: abs(Ac - 9.15) < 1e-9 && abs(Q - 0.72625) < 1e-9
% CODE:
y = [0 2 4 5 6 9];
H = [0.5 1.3 1.25 1.8 1 0.25];
U = [0.03 0.06 0.05 0.13 0.11 0.02];
Ac = trapz(y, H);
Q = trapz(y, U.*H);
fprintf('Ac = %.4f m^2\n', Ac);
fprintf('Q = %.5f m^3/s\n', Q);
