% TOPIC: interpolation
% TITLE: Thermocline depth from a clamped spline (zero end slopes) and the heat flux by Fourier's law
% SOURCE: Chapra Prob. 18.2; CE206 slides 05 page 6 (thermocline assignment)
% KEYWORDS: thermocline, clamped spline, zero end derivatives, inflection point, second derivative, temperature depth, heat flux, fourier's law, lake, reactor
% PROBLEM:
% A reactor is thermally stratified: depth (m) = 0 0.5 1 1.5 2 2.5 3, temperature (C) = 70 70 55 22 13 10 10.
% Use a clamped cubic spline fit with zero end derivatives to determine the thermocline depth (the
% inflection point d2T/dz2 = 0 where the gradient is steepest). If k = 0.01 cal/(s cm C), compute the
% flux across this interface with Fourier's law J = -k dT/dz.
% CHECK: abs(zt - 1.2151) < 1e-3 && abs(dTdz - (-73.0589)) < 0.01
% CODE:
z = [0 0.5 1 1.5 2 2.5 3];
T = [70 70 55 22 13 10 10];
pp = spline(z, [0 T 0]);                       % clamped: dT/dz = 0 at both ends
zz = linspace(0, 3, 30001);
Tz = ppval(pp, zz);
dT = gradient(Tz, zz);                         % slope of the spline
[~, i] = min(dT);                              % steepest (most negative) gradient = inflection point
zt = zz(i);
% refine: the exact derivative of the spline pieces
coefs = pp.coefs;
dpp = mkpp(pp.breaks, [3*coefs(:,1) 2*coefs(:,2) coefs(:,3)]);
d2pp = mkpp(pp.breaks, [6*coefs(:,1) 2*coefs(:,2)]);
zt = fzero(@(s) ppval(d2pp, s), [zt - 0.05 zt + 0.05]);
dTdz = ppval(dpp, zt);                         % C/m
k = 0.01;                                      % cal/(s cm C)
J = -k*dTdz/100;                               % convert C/m -> C/cm
fprintf('Thermocline depth = %.4f m, dT/dz = %.4f C/m\n', zt, dTdz);
fprintf('Heat flux J = -k dT/dz = %.6f cal/(s cm^2)\n', J);
figure; plot(T, z, 'ko', ppval(pp, zz), zz, 'b-', ppval(pp, zt), zt, 'r*'); set(gca, 'YDir', 'reverse');
grid on; xlabel('T (C)'); ylabel('depth (m)'); legend('data', 'clamped spline', 'thermocline');
