% TOPIC: interpolation
% TITLE: Steam table: entropy by linear and quadratic interpolation, volume by inverse interpolation
% SOURCE: Chapra Prob. 17.10
% KEYWORDS: steam table, superheated water, entropy, specific volume, linear interpolation, quadratic interpolation, inverse interpolation
% PROBLEM:
% For superheated water at 200 MPa: v (m^3/kg) = 0.10377 0.11144 0.12547 and
% s (kJ/(kg K)) = 6.4147 6.5453 6.7664. Find (a) the entropy s for v = 0.118 with linear interpolation,
% (b) the same with quadratic interpolation, and (c) the volume corresponding to s = 6.45 using inverse
% interpolation.
% CHECK: abs(sa - 6.648680) < 1e-5 && abs(sb - 6.651544) < 1e-5 && abs(vc - 0.1058038) < 1e-6
% CODE:
v = [0.10377 0.11144 0.12547];
s = [6.4147 6.5453 6.7664];
sa = interp1(v, s, 0.118, 'linear');
p = polyfit(v, s, 2);                          % quadratic through the 3 points
sb = polyval(p, 0.118);
vc = fzero(@(vv) polyval(p, vv) - 6.45, [v(1) v(2)]);
fprintf('(a) linear:    s(0.118) = %.6f kJ/(kg K)\n', sa);
fprintf('(b) quadratic: s(0.118) = %.6f kJ/(kg K)\n', sb);
fprintf('(c) inverse:   v at s = 6.45 is %.7f m^3/kg\n', vc);
