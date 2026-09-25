% TOPIC: interpolation
% TITLE: Class sheet: clamped cubic spline (zero end slopes) through reactor temperature-depth data
% SOURCE: Class solution sheet "Curve-fitting and Interpolation"; Chapra Prob. 18.2 (thermocline/flux part crossed out)
% KEYWORDS: clamped spline, zero end derivatives, cubic spline, reactor, thermally stratified, temperature, depth, plot
% PROBLEM:
% A reactor is thermally stratified as in the following table: Depth (m) = 0 0.5 1 1.5 2 2.5 3,
% Temperature (C) = 70 70 55 22 13 10 10. Use a clamped cubic spline fit with zero end derivatives.
% CHECK: abs(ppval(pp, 1.25) - 37.801923) < 1e-5 && abs(ppval(pp, 0.75) - 65.644231) < 1e-5
% CODE:
z = 0:0.5:3;
T = [70 70 55 22 13 10 10];
pp = spline(z, [0 T 0]);
zz = linspace(0, 3);
figure; plot(T, z, '*', ppval(pp, zz), zz, '-'); set(gca, 'YDir', 'reverse'); grid on;
xlabel('Temperature (C)'); ylabel('Depth (m)'); legend('data', 'clamped spline');
