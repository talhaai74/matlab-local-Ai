% TOPIC: interpolation
% TITLE: interp1 with linear, nearest, spline and pchip on spot measurements of velocity
% SOURCE: CE206 slides 04 pages 21-22
% KEYWORDS: interp1, linear, nearest, spline, pchip, piecewise cubic hermite, time series, velocity
% PROBLEM:
% Time series of spot measurements of velocity: t = 0 20 40 56 68 80 84 96 104, v = 0 20 20 38 80 80 100 100 125.
% Interpolate with interp1 using 'linear', 'nearest', 'spline' and 'pchip', estimate v at t = 50 and
% t = 90, and plot the curves.
% CHECK: abs(vl(1) - 31.25) < 1e-9 && abs(vl(2) - 100) < 1e-9
% CODE:
t = [0 20 40 56 68 80 84 96 104];
v = [0 20 20 38 80 80 100 100 125];
tq = [50 90];
vl = interp1(t, v, tq, 'linear');
vn = interp1(t, v, tq, 'nearest');
vs = interp1(t, v, tq, 'spline');
vp = interp1(t, v, tq, 'pchip');
fprintf('%8s %10s %10s %10s %10s\n', 't', 'linear', 'nearest', 'spline', 'pchip');
fprintf('%8g %10.4f %10.4f %10.4f %10.4f\n', [tq; vl; vn; vs; vp]);
tt = linspace(0, 104);                       % interp1 returns NaN outside the data range (no extrapolation)
figure;
plot(t, v, 'ko', tt, interp1(t, v, tt), '-', tt, interp1(t, v, tt, 'spline'), '--', tt, interp1(t, v, tt, 'pchip'), ':');
grid on; xlabel('t'); ylabel('v'); legend('data', 'linear', 'spline', 'pchip', 'Location', 'northwest');
